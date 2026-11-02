const runtime_types = require(`./runtime_types`)

type function negationof(ty: type): type
	return types.negationof(ty)
end

export type PeerId = Player | Actor | { read lux_peer: true }
export type PeerBackend = {
	read id: PeerId,
	read _send_reliable: (buffer) -> (),
	read _send_unreliable: (buffer) -> (),
}
export type PeerFrontend = PeerBackend & {
	plr: Player,
	actor: Actor,
}

export type OnRecv<Output> = (p: PeerFrontend, data: Output) -> ()
-- todo: structured faults
export type OnFault = (p: PeerFrontend, msg: string) -> ()

export type QueuedPayload = {
	read peer: PeerFrontend,
	read buf: buffer,
}
export type MessageConfig<Input, Output = Input> = {
	debug_name: string,

	recv_queue: { QueuedPayload },

	on_recv: false | OnRecv<Output>,
	on_fault: false | OnFault,
}

export type Message<Input, Output = Input> = {
	_namespaced_id: false | number,

	read serdes: runtime_types.SerDesIO<Input, Output>,
	read config: MessageConfig<Input, Output>,
	--[=[
		this method will be deprecated once luau inference is
		a bit friendlier towards directly writing the config

		returns the old callback if there was one
	]=]
	read on: (self: Message<Input, Output>, callback: OnRecv<Output>) -> OnRecv<Output> | false,
}

export type Event<Input, Output = Input> = {
	_namespaced_id: false | number,

	read serdes: runtime_types.SerDesIO<Input, Output>,
	read config: MessageConfig<Input, Output>,

	read connect: (self: Event<Input, Output>, callback: OnRecv<Output>) -> (),
}

export type Sendable<Input, Output = Input> = Message<Input, Output> | Event<Input, Output>

export type ConnectedPeer = {
	read frontend: PeerFrontend,
	read stream: Stream,
}

export type ConnectedPeers = { [PeerId]: ConnectedPeer? }

export type FlushMode = "reliables" | "unreliables" | "all"

export type NetworkConfig = {
	peer_auto_reserve: number,
	peer_auto_resize: boolean,
}
export type Network = {
	read config: NetworkConfig,
	read _connected_peers: ConnectedPeers,

	read stream: (self: Network, reserve: number, name: string?) -> Stream,
	read connect_peer: (self: Network, backend: PeerBackend) -> () -> (),
	read dispatch_payload: (self: Network, namespace: Namespace, peer_ref: PeerId, buffer) -> (),

	read send: <Input, Output>(self: Network, Sendable<Input, Output>, p: PeerId, data: Input) -> (),
	read send_unreliably: <Input, Output>(self: Network, Sendable<Input, Output>, p: PeerId, data: Input) -> (),

	read broadcast: (self: Network, mode: FlushMode) -> (),
}

export type NamespaceRegistry = {
	[string]: Sendable<any>?,
}

export type StreamConfig = {
	name: string | false,
	auto_resize: boolean,
}
export type Stream = {
	read config: StreamConfig,
	read _connected_peers: ConnectedPeers,

	_buf: buffer,
	_buf_unreliable: buffer,

	read wipe_reliables: (self: Stream, reserve: number) -> (),
	read wipe_unreliables: (self: Stream, reserve: number) -> (),

	read write: <Input, Output>(self: Stream, Sendable<Input, Output>, data: Input) -> (),
	read write_unreliably: <Input, Output>(self: Stream, Sendable<Input, Output>, data: Input) -> (),

	read flush: (self: Stream, mode: FlushMode, targets: { read [unknown]: true? }) -> (),
}

--[=[
	absolutely diabolical use of metatables
]=]
-- todo: refactor
export type NamespaceMeta = {
	read id_map: { read [number]: Sendable<any>? },
}
export type Namespace<Registry = {}> = setmetatable<Registry, NamespaceMeta>

return table.freeze({})
