const network_types = require("@self/network_types")
const runtime_types = require("@self/runtime_types")
const datatypes = require("@self/datatypes")
const future = require("@self/future")
const tasklib = require("@self/tasklib")
const type_fns = require("@self/type_fns")
const constants = require("@self/constants")
const lib_state = require("@self/lib_state")

export type SerDes<Data> = runtime_types.SerDes<Data>
export type SerDesIO<Input, Output> = runtime_types.SerDesIO<Input, Output>

export type Namespace = network_types.Namespace
export type Stream = network_types.Stream
export type NamespaceRegistry = network_types.NamespaceRegistry
export type PeerBackend = network_types.PeerBackend
export type PeerFrontend = network_types.PeerFrontend
export type PeerId = network_types.PeerId

export type get_ser_data<T> = type_fns.get_ser_data<T>
export type get_des_data<T> = type_fns.get_des_data<T>
export type get_dsl_ser_data<T> = type_fns.get_dsl_ser_data<T>
export type get_dsl_des_data<T> = type_fns.get_dsl_des_data<T>
export type new_dsl<T> = type_fns.new_dsl<T>

const module = {
	datatypes = datatypes,
}

const dead_mt = {}
function dead_mt.__index()
	(error)(`critical error - this is dead as hell`)
end

const message_mt = {}
function message_mt.__tostring<Input, Output>(self: network_types.Sendable<Input, Output>): string
	const config = self.config

	const name, queue = config.debug_name, config.recv_queue

	local stringified = `Message "{name}"`

	if #queue == 0 then
		stringified ..= `; none queued`
	else
		stringified ..= `; queued`

		local unique_peers = 0
		local visited_peers = {}

		local queued_payloads, queued_bytes = #queue, 0
		for _, payload in queue do
			queued_bytes += buffer.len(payload.buf)

			if not visited_peers[payload.peer] then
				visited_peers[payload.peer] = true
				unique_peers += 1
			end
		end

		stringified ..= if queued_bytes == 1 then ` 1 byte` else ` {queued_bytes} bytes`
		if unique_peers > 1 then
			stringified ..= ` from {unique_peers} peers`
		end
		stringified ..= if queued_payloads == 1 then ` across 1 payload` else ` across {queued_payloads} payloads`
	end

	return stringified
end

local free_dispatch
--- todo(dev, debug): this is way too many arguments
const function dispatch_job(
	sendable: network_types.Sendable<any>,
	on_recv: network_types.OnRecv<any>,
	peer: network_types.PeerFrontend,
	buf: buffer,
	byte: number,
	target: number
): ()
	const restore = free_dispatch
	free_dispatch = nil

	const deserializer = sendable.serdes.des

	while byte < target do
		local deserialize_success, incoming_data
		deserialize_success, byte, incoming_data = pcall(deserializer, buf, byte)

		local err_msg
		if not deserialize_success then
			err_msg = `deserializer for {sendable} errored:\n{byte}`
		elseif byte > target then
			err_msg = `deserializer for {sendable} exceeded the target size (payload fault)`
		else
			const callback_success, callback_err = pcall(on_recv, peer, incoming_data)
			if callback_success then
				continue
			end
			err_msg = `callback for {sendable} errored:\n{callback_err}`
		end

		const guaranteed_fault: string = err_msg
		print(debug.traceback(guaranteed_fault, 2))

		const on_fault = sendable.config.on_fault
		if on_fault then
			on_fault(peer, guaranteed_fault)
		end

		break
	end

	free_dispatch = restore
end
free_dispatch = future.wrap(dispatch_job)

const function message_on<Input, Output>(
	self: network_types.Message<Input, Output>,
	callback: network_types.OnRecv<Output>
): network_types.OnRecv<Output> | false
	const config = self.config
	const old = config.on_recv
	config.on_recv = callback

	const recv_queue = config.recv_queue

	while true do
		const consume_payload = table.remove(recv_queue, 1)
		if not consume_payload then
			break
		end

		const dispatch_thread = free_dispatch or future.wrap(dispatch_job)
		future.wake(
			dispatch_thread,
			self,
			callback,
			consume_payload.peer,
			consume_payload.buf,
			0,
			buffer.len(consume_payload.buf)
		)
	end

	return old
end

function module.message<Input, Output>(serdes: runtime_types.SerDesIO<Input, Output>): network_types.Message<Input, Output>
	const config: network_types.MessageConfig<Input, Output> = {
		debug_name = "N/A",

		recv_queue = {},

		on_recv = false,
		on_fault = false,
	}

	const result: network_types.Message<Input, Output> = {
		_namespaced_id = false,

		config = config,

		on = message_on,

		serdes = serdes,
	}

	(setmetatable)(result, message_mt)

	return result
end

function module.event<Input, Output>(serdes: runtime_types.SerDesIO<Input, Output>): network_types.Event<Input, Output>
	const message = module.message(serdes)

	const extend: typeof({}) = message :: any

	const event_connections: { network_types.OnRecv<Output> } = {}
	message:on(function(p, data)
		for _, callback in event_connections do
			-- todo: thread re-use
			tasklib.spawn(callback, p, data)
		end
	end)

	function extend.connect(_self, callback: network_types.OnRecv<Output>): ()
		table.insert(event_connections, callback)
	end

	return extend :: typeof(extend) & typeof(message)
end

function module.tbl_message<T>(template: T): network_types.Message<type_fns.get_dsl_ser_data<T>, type_fns.get_dsl_des_data<T>>
	return module.message(datatypes.tbl(template)) :: any
end

function module.tbl_event<T>(template: T): network_types.Event<type_fns.get_dsl_ser_data<T>, type_fns.get_dsl_des_data<T>>
	return module.event(datatypes.tbl(template)) :: any
end

const vlq40 = datatypes.vlq40()

const function write_message(
	data: unknown,
	obj: network_types.Sendable<any>,
	id: number,
	buf: buffer,
	auto_resize: boolean
): (buffer, number)
	local ptr = buffer.readu32(buf, 0)

	const ptr_final = ptr
	ptr += 4
	const ptr_id = ptr
	ptr += 4

	const serdes = obj.serdes

	if auto_resize then
		ptr, buf = serdes.ser_resize(buf, ptr, data)
	else
		ptr = serdes.ser(buf, ptr, data)
	end

	buffer.writeu32(buf, ptr_id, id)
	buffer.writeu32(buf, ptr_final, ptr)
	buffer.writeu32(buf, 0, ptr)

	return buf, ptr
end

const function stream_write<Input, Output>(self: network_types.Stream, obj: network_types.Sendable<Input, Output>, data: Input): ()
	const id = obj._namespaced_id
	if not id then
		error(`cannot send this message because it has not been given a namespace yet`, 2)
		return
	end

	const buf = self._buf
	const auto_resize = self.config.auto_resize

	if auto_resize then
		self._buf = write_message(data, obj, id, buf, auto_resize)
	else
		write_message(data, obj, id, buf, auto_resize)
	end
end

const function stream_write_unreliably<Input, Output>(self: network_types.Stream, obj: network_types.Sendable<Input, Output>, data: Input): ()
	const id = obj._namespaced_id
	if not id then
		print(debug.traceback(`warn: this unreliable event ({obj.config.debug_name}) has not been given a namespace yet`, 2))
		return
	end

	const buf = self._buf_unreliable
	const auto_resize = self.config.auto_resize

	if auto_resize then
		self._buf = write_message(data, obj, id, buf, auto_resize)
	else
		write_message(data, obj, id, buf, auto_resize)
	end
end

const function stream_wipe_reliables(self: network_types.Stream, reserve: number)
	const buf = buffer.create(4 + reserve)
	buffer.writeu32(buf, 0, 4)
	self._buf = buf
end

const function stream_wipe_unreliables(self: network_types.Stream, reserve: number)
	const buf = buffer.create(4 + reserve)
	buffer.writeu32(buf, 0, 4)
	self._buf_unreliable = buf
end

-- todo(dev): make payloads into a datatype
-- todo(dev): investigate deferred serialization
const function encode_payload(input_buf: buffer): buffer?
	local input_ptr = 0

	const input_virtual_len = buffer.readu32(input_buf, input_ptr)
	input_ptr += 4

	if input_virtual_len == 4 then
		return nil
	end

	local output_len = 0

	const sub_payload_sizes: { [number]: number } = {}
	const sub_payloads: { [number]: { number }? } = {}

	while input_ptr < input_virtual_len do
		const message_finish = buffer.readu32(input_buf, input_ptr)
		input_ptr += 4
		const message_id = buffer.readu32(input_buf, input_ptr)
		input_ptr += 4

		const added_size = message_finish - input_ptr
		output_len += added_size

		const sub_payload = sub_payloads[message_id]
		if sub_payload then
			table.insert(sub_payload, input_ptr)
			table.insert(sub_payload, message_finish)

			sub_payload_sizes[message_id] += added_size
		else
			sub_payloads[message_id] = { input_ptr, message_finish }

			sub_payload_sizes[message_id] = added_size
		end

		input_ptr = message_finish
	end

	for message_id, size in sub_payload_sizes do
		output_len += vlq40.bytes_sizeof(message_id)
		output_len += vlq40.bytes_sizeof(size)
	end

	local output_buf = buffer.create(output_len)
	local output_ptr = 0

	for message_id, sub_payload in sub_payloads do
		output_ptr = vlq40.ser(output_buf, output_ptr, message_id)
		output_ptr = vlq40.ser(output_buf, output_ptr, sub_payload_sizes[message_id])

		for sub_payload_idx = 1, #sub_payload, 2 do
			const copy_start = sub_payload[sub_payload_idx]
			const copy_stop = sub_payload[sub_payload_idx + 1]
			const copy_size = copy_stop - copy_start

			buffer.copy(output_buf, output_ptr, input_buf, copy_start, copy_size)
			output_ptr += copy_size
		end
	end

	return output_buf
end

type PayloadInvocations = {
	read message_id: number,
	read data_start: number,
	read data_stop: number,
}
type DecodedPayload = {
	read invocation_ranges: { PayloadInvocations },
}
const function decode_payload(buf: buffer): DecodedPayload
	const buf_len = buffer.len(buf)

	const invocation_ranges: { PayloadInvocations } = {}

	local ptr = 0
	while ptr < buf_len do
		local message_id: number
		ptr, message_id = vlq40.des(buf, ptr)
		local invocations_size: number
		ptr, invocations_size = vlq40.des(buf, ptr)

		table.insert(invocation_ranges, {
			message_id = message_id,
			data_start = ptr,
			data_stop = ptr + invocations_size,
		})
		ptr += invocations_size
	end

	return {
		invocation_ranges = invocation_ranges,
	}
end

const function stream_flush(self: network_types.Stream, mode: network_types.FlushMode, targets: { read [unknown]: true? }): ()
	const buf, buf_unreliable = self._buf, self._buf_unreliable
	const connected_peers = self._connected_peers

	const reliable_payload, unreliable_payload = encode_payload(buf), encode_payload(buf_unreliable)

	local should_send_reliables = mode == "all" or mode == "reliables"
	local should_send_unreliables = mode == "all" or mode == "unreliables"

	for target in targets do
		const connected = connected_peers[target :: any]
		if not connected then
			print(`could not send to target {target} because they were not connected`)
			print(`peers which are connected:`, connected_peers)
			continue
		end

		const interface = connected.frontend
		if reliable_payload and should_send_reliables then
			interface._send_reliable(reliable_payload)
		end
		if unreliable_payload and should_send_unreliables then
			interface._send_unreliable(unreliable_payload)
		end
	end

	if reliable_payload and should_send_reliables then
		buffer.writeu32(buf, 0, 4)
	end

	if unreliable_payload and should_send_unreliables then
		buffer.writeu32(buf_unreliable, 0, 4)
	end
end

const function network_stream(self: network_types.Network, reserve: number, name: string?): network_types.Stream
	const stream_config: network_types.StreamConfig = {
		name = name or false,
		auto_resize = true,
		targets = {},
	}

	const stream_buf = buffer.create(4 + reserve)
	const stream_buf_unreliable = buffer.create(4 + reserve)
	buffer.writeu32(stream_buf, 0, 4)
	buffer.writeu32(stream_buf_unreliable, 0, 4)

	return {
		config = stream_config,
		_connected_peers = self._connected_peers,

		_buf = stream_buf,
		_buf_unreliable = stream_buf_unreliable,

		wipe_reliables = stream_wipe_reliables,
		wipe_unreliables = stream_wipe_unreliables,

		write = stream_write,
		write_unreliably = stream_write_unreliably,

		flush = stream_flush,
	}
end

const function network_connect_peer(self: network_types.Network, backend: network_types.PeerBackend): () -> ()
	const connected_peers = self._connected_peers

	const id = backend.id
	if connected_peers[id] then
		error(`peer id {id} is already connected to this network`, 2)
	end

	const frontend = backend :: network_types.PeerFrontend

	if typeof(id) == "Instance" then
		if id:IsA("Player") then
			frontend.plr = id
		elseif id:IsA("Actor") then
			frontend.actor = id
		end
	end

	const net_config = self.config

	const connected: network_types.ConnectedPeer = {
		frontend = frontend,
		stream = self:stream(net_config.peer_auto_reserve, `peer-{id}`),
	}
	connected.stream.config.auto_resize = net_config.peer_auto_resize
	connected_peers[id] = connected

	local exited = false
	return function(): ()
		if exited then
			print(`cannot disconnect already disconnected peer`)
			return
		end
		exited = true

		connected_peers[id] = nil

		table.clear(connected)
		setmetatable(connected, dead_mt)
	end
end

const function network_send<Input, Output>(
	self: network_types.Network,
	obj: network_types.Sendable<Input, Output>,
	p: network_types.PeerId,
	data: Input
): ()
	const connected = self._connected_peers[p]
	if not connected then
		print(debug.traceback(`cannot send to non connected peer '{p}'`))
		return
	end

	connected.stream:write(obj, data)
end
const function network_send_unreliably<Input, Output>(
	self: network_types.Network,
	obj: network_types.Sendable<Input, Output>,
	peer: network_types.PeerId,
	data: Input
): ()
	const connected_peer = self._connected_peers[peer]
	if not connected_peer then
		print(debug.traceback(`cannot send unreliably to non connected peer '{peer}'`))
		return
	end

	connected_peer.stream:write_unreliably(obj, data)
end
const function network_broadcast(self: network_types.Network, mode: network_types.FlushMode): ()
	-- todo(dev, perf?): make this not allocate a table for every
	-- connected peer, we want people to be able to broadcast easily
	for _, info in self._connected_peers do
		info.stream:flush(mode, { [info.frontend.id] = true })
	end
end

-- todo: move this closer to the payload serdes stuff
const function network_dispatch_payload(
	self: network_types.Network,
	namespace: network_types.Namespace,
	peer_id: network_types.PeerId,
	buf: buffer
): ()
	const connected = self._connected_peers[peer_id]
	if not connected then
		error(`peer '{peer_id}' has not been connected yet`, 2)
	end
	const peer = connected.frontend

	const meta = getmetatable(namespace)
	const id_map = meta.id_map

	const decoded = decode_payload(buf)

	const invocation_ranges = decoded.invocation_ranges

	const sendables: { [number]: network_types.Sendable<any> } = {}
	for _, invocation_range in invocation_ranges do
		const id = invocation_range.message_id
		const message = id_map[id]
		if not message then
			print(`payload had invalid message id {id}, aborting all messages`)
			return
		end

		sendables[id] = message
	end

	for _, invocation_range in invocation_ranges do
		const id = invocation_range.message_id
		const sendable = sendables[id]

		const data_start, data_stop = invocation_range.data_start, invocation_range.data_stop
		const data_size = data_stop - data_start

		const message_config = sendable.config
		const on_recv = message_config.on_recv
		if not on_recv then
			-- todo(security): validate data_size
			const payload_buf = buffer.create(data_size)
			buffer.copy(payload_buf, 0, buf, data_start, data_size)

			const recv_queue = message_config.recv_queue
			table.insert(recv_queue, {
				peer = peer,
				buf = payload_buf,
			})

			continue
		end

		const dispatch_thread = free_dispatch or future.wrap(dispatch_job)
		future.wake(dispatch_thread, sendable, on_recv, peer, buf, data_start, data_stop)
	end
end

function module.network(): network_types.Network
	return {
		config = {
			peer_auto_reserve = 1024,
			peer_auto_resize = true,
		},
		_connected_peers = {},

		connect_peer = network_connect_peer,
		dispatch_payload = network_dispatch_payload,

		stream = network_stream,

		send = network_send,
		send_unreliably = network_send_unreliably,

		broadcast = network_broadcast,
	}
end

--[=[
	the namespace name is only really for debugging,
]=]
function module.namespace<Registry>(
	namespace_name: string,
	registry: Registry,
	skip_registering_names: boolean?
): network_types.Namespace<Registry>
	if typeof(registry) ~= "table" then
		error(`namespace '{namespace_name}' registry was not a table`, 2)
	elseif getmetatable(registry) ~= nil then
		error(`registry cannot have a metatable`, 2)
	end

	const name_map: { [string]: network_types.Sendable<any> } = {}
	const name_list: { string } = {}

	for reg_key, reg_value in pairs(registry) do
		if type(reg_key) ~= "string" then
			print(
				`namespace '{namespace_name}' had a {typeof(reg_key)} key, but only strings are allowed (key was {reg_key}, value was {reg_value})`
			)
			continue
		elseif (type(reg_value) ~= "table") or (getmetatable(reg_value) ~= message_mt) then
			print(`'{reg_key}' of namespace '{namespace_name}' was not an event or message`)
			continue
		end

		name_map[reg_key] = reg_value :: network_types.Sendable<any>
		table.insert(name_list, reg_key)
	end

	table.sort(name_list)

	const id_map = {}

	for id, message_name in name_list do
		const pending = name_map[message_name]
		if pending._namespaced_id then
			print(`'{message_name}' of namespace '{namespace_name}' was already registered in another namespace`)
			continue
		end

		pending._namespaced_id, id_map[id] = id, pending
		if not skip_registering_names then
			pending.config.debug_name = `{namespace_name}/{message_name}`
		end
	end

	-- todo(luau, report): weird setmetatable generic stuff
	const setmt: <T>(T, network_types.NamespaceMeta) -> setmetatable<T, network_types.NamespaceMeta> = setmetatable

	return setmt(registry, {
		-- todo(luau, report, regression)
		id_map = id_map :: any,
	})
end

-- todo: integrate async datatypes with message queueing :pray:
-- this is difficult because datatypes are meant to be simple
-- interfaces rather than something explicitly managed by the library
--
-- maybe coroutine.finally-based task groups?
function module.async<I, O>(fn: (inject: (SerDesIO<I, O>) -> ()) -> ()): runtime_types.TAsync<I, O>
	const async_serdes: type_fns.unfreeze<runtime_types.TAsync<any, any>> = {
		bytes_static = false,
		bytes_lowerbound = 1,
		bytes_upperbound = constants.HUGE,
		bytes_sizeof = function()
			return error("cannot call sizeof; async datatype is not ready yet")
		end,

		ser = function()
			error("cannot serialize; async datatype is not ready yet")
		end,
		des = function()
			error("cannot deserialize; async datatype is not ready yet")
		end,
		ser_resize = function()
			error("cannot resize + serialize; async datatype is not ready yet")
		end,

		ready = false,
	}

	const function async_inject(injected: SerDesIO<I, O>)
		async_serdes.bytes_sizeof = injected.bytes_sizeof
		async_serdes.ser_resize, async_serdes.ser, async_serdes.des = injected.ser_resize, injected.ser, injected.des
		async_serdes.ready = true
	end

	if lib_state.get() ~= "compiler" then
		tasklib.spawn(fn, async_inject)
	end

	return async_serdes
end

--[=[
	provides glue for roblox networking
]=]
const roblox = {}

type ServerSetup = {
	read net: network_types.Network,
	read namespace: network_types.Namespace,
	read reliable: RemoteEvent?,
	read unreliable: UnreliableRemoteEvent?,
}
function roblox.setup_server(opts: ServerSetup)
	const ReplicatedStorage = game:GetService("ReplicatedStorage")
	const Players = game:GetService("Players")

	local lux_reliable, lux_unreliable
	if opts.reliable then
		lux_reliable = opts.reliable
	else
		const reliable_name = "LuxReliableEvent"
		lux_reliable = Instance.new("RemoteEvent")
		lux_reliable.Name = reliable_name

		if ReplicatedStorage:FindFirstChild(reliable_name) then
			error(`reliable event with name {reliable_name} already exists on the server`)
		end

		lux_reliable.Parent = ReplicatedStorage
	end

	if opts.unreliable then
		lux_unreliable = opts.unreliable
	else
		const unreliable_name = "LuxReliableEvent"
		lux_unreliable = Instance.new("UnreliableRemoteEvent")
		lux_unreliable.Name = unreliable_name

		if ReplicatedStorage:FindFirstChild(unreliable_name) then
			error(`reliable event with name {unreliable_name} already exists on the server`)
		end

		lux_unreliable.Parent = ReplicatedStorage
	end

	-- todo(luau)
	const lux_reliable, lux_unreliable = lux_reliable, lux_unreliable

	const net, namespace = opts.net, opts.namespace

	lux_reliable.OnServerEvent:Connect(function(play_person, buf)
		net:dispatch_payload(namespace, play_person, buf)
	end)
	lux_unreliable.OnServerEvent:Connect(function(play_person, buf)
		net:dispatch_payload(namespace, play_person, buf)
	end)

	const connected_players = {}

	const function setup_play_person(play_person): ()
		if connected_players[play_person] then
			return
		end

		const function lux_reliable_to_client(buf: buffer): ()
			lux_reliable:FireClient(play_person, buf)
		end

		const function lux_unreliable_to_client(buf: buffer): ()
			lux_unreliable:FireClient(play_person, buf)
		end

		connected_players[play_person] = net:connect_peer({
			id = play_person,
			_send_reliable = lux_reliable_to_client,
			_send_unreliable = lux_unreliable_to_client,
		})
	end

	for _, player in Players:GetPlayers() do
		setup_play_person(player)
	end
	Players.PlayerAdded:Connect(setup_play_person)

	Players.PlayerRemoving:Connect(function(play_person): ()
		const disconnect_plr = connected_players[play_person]
		if not disconnect_plr then
			return
		end

		disconnect_plr()
		connected_players[play_person] = nil
	end)
end

type ClientSetup = {
	read net: network_types.Network,
	read namespace: network_types.Namespace,
	read reserve: number,
	read reliable_name: string?,
	read unreliable_name: string?,
	read server_stream_name: string?,
}
function roblox.setup_client(opts: ClientSetup)
	const ReplicatedStorage = game:GetService("ReplicatedStorage")
	const RunService = game:GetService("RunService")

	const net, namespace = opts.net, opts.namespace

	const outgoing_id: network_types.PeerId = { lux_peer = true }

	local reliable, unreliable

	local queued_payloads: { { unknown } } = {}

	const function lux_reliable_to_server(buf: buffer): ()
		if reliable then
			reliable:FireServer(buf)
		else
			table.insert(queued_payloads, { buf })
		end
	end

	const function lux_unreliable_to_server(buf: buffer): ()
		if unreliable then
			unreliable:FireServer(buf)
		else
			-- we're just gonna discard unreliable events until the instance replicates, they're not worth queueing
		end
	end

	const reliable_name = opts.reliable_name or "LuxReliable"
	const unreliable_name = opts.unreliable_name or "LuxUnreliable"

	tasklib.spawn(function()
		local lux_reliable = ReplicatedStorage:WaitForChild(reliable_name)
		local lux_unreliable = ReplicatedStorage:WaitForChild(unreliable_name)

		assert(lux_reliable:IsA("RemoteEvent"))
		assert(lux_unreliable:IsA("UnreliableRemoteEvent"))

		reliable, unreliable = lux_reliable, lux_unreliable

		for _, payload in queued_payloads do
			lux_reliable:FireServer(table.unpack(payload))
		end
		table.clear(queued_payloads)

		lux_reliable.OnClientEvent:Connect(function(buf): ()
			net:dispatch_payload(namespace, outgoing_id, buf)
		end)
		lux_unreliable.OnClientEvent:Connect(function(buf): ()
			net:dispatch_payload(namespace, outgoing_id, buf)
		end)
	end)

	const disconnect_outgoing = opts.net:connect_peer({
		id = outgoing_id,
		_send_reliable = lux_reliable_to_server,
		_send_unreliable = lux_unreliable_to_server,
	})

	const outgoing_stream = opts.net:stream(opts.reserve, opts.server_stream_name or "server")
	outgoing_stream.config.auto_resize = false

	const postsim_connection = RunService.PostSimulation:Connect(function()
		outgoing_stream:flush("reliables", { [outgoing_id] = true })
	end)

	return {
		reliable_name = reliable_name,
		unreliable_name = unreliable_name,
		outgoing_id = outgoing_id,
		disconnect_outgoing = disconnect_outgoing,
		outgoing_stream = outgoing_stream,
		postsim_connection = postsim_connection,
		lux_reliable_to_server = lux_reliable_to_server,
		lux_unreliable_to_server = lux_unreliable_to_server,
	}
end

module.roblox = table.freeze(roblox)

return table.freeze(module)
