const numbers_lcg = require("./numbers_lcg")
const runtime_types = require("./runtime_types")
const constants = require("./constants")
const type_fns = require("./type_fns")

--- for my sanity
type Ptr = number

const clone = table.clone(numbers_lcg)
const module: typeof({}) = clone :: any

type Exports = typeof(numbers_lcg) & typeof(module)

type Arr<T> = { read [number]: T }
function module.arr<ItemInput, ItemOutput>(
	val_ty: runtime_types.SerDesIO<ItemInput, ItemOutput>,
	len_ty: runtime_types.SerDes<number>?
): runtime_types.TArrayDense<ItemInput, ItemOutput>
	-- todo(report, luau): ambiguous overload
	len_ty = len_ty or numbers_lcg.vlq16() :: runtime_types.SerDes<number>

	const length_des, length_ser, length_ser_resize, length_sizeof =
		len_ty.des, len_ty.ser, len_ty.ser_resize, len_ty.bytes_sizeof
	const value_des, value_ser, value_ser_resize, value_sizeof = val_ty.des, val_ty.ser, val_ty.ser_resize, val_ty.bytes_sizeof

	const function lux_read_arr(buf: buffer, byte: Ptr): (Ptr, Arr<ItemOutput>)
		local size: number
		byte, size = length_des(buf, byte)

		const output = table.create(size)

		for i = 1, size do
			byte, output[i] = value_des(buf, byte)
		end

		return byte, output
	end

	const function lux_write_arr(buf: buffer, byte: Ptr, data: Arr<ItemInput>): Ptr
		const size = #data
		byte = length_ser(buf, byte, size)

		for index = 1, size do
			byte = value_ser(buf, byte, data[index])
		end

		return byte
	end

	const function lux_write_arr_resize(buf: buffer, byte: Ptr, data: Arr<ItemInput>): (Ptr, buffer)
		const size = #data
		byte, buf = length_ser_resize(buf, byte, size)

		for index = 1, size do
			byte, buf = value_ser_resize(buf, byte, data[index])
		end

		return byte, buf
	end

	const function lux_arr_sizeof(data: Arr<ItemInput>): number
		local output_size = 0

		-- todo(refactor): rename ocurrences of count w/ strs & arrays to be 'len'
		const count = #data
		output_size += length_sizeof(count)

		for index = 1, count do
			output_size += value_sizeof(data[index])
		end

		return output_size
	end

	return {
		bytes_static = false,
		bytes_lowerbound = len_ty.bytes_lowerbound,
		bytes_upperbound = constants.HUGE,
		bytes_sizeof = lux_arr_sizeof,

		des = lux_read_arr,
		ser = lux_write_arr,
		ser_resize = lux_write_arr_resize,

		kind = "array",
		subkind = "dense",

		length = len_ty,
		items = val_ty,
	}
end

type Map<Key, Value> = { read [Key]: Value }
function module.map<KeyInput, ValueInput, KeyOutput, ValueOutput>(
	key_ty: runtime_types.SerDesIO<KeyInput, KeyOutput>,
	val_ty: runtime_types.SerDesIO<ValueInput, ValueOutput>,
	len_ty: runtime_types.SerDes<number>?
): runtime_types.TMapSparse<
	KeyInput,
	ValueInput,
	KeyOutput,
	ValueOutput
>
	-- todo(report, luau): ambiguous overload
	len_ty = len_ty or numbers_lcg.vlq16() :: runtime_types.SerDes<number>

	const length_des, length_ser, length_ser_resize, length_sizeof =
		len_ty.des, len_ty.ser, len_ty.ser_resize, len_ty.bytes_sizeof

	const key_des, key_ser, key_ser_resize, key_sizeof = key_ty.des, key_ty.ser, key_ty.ser_resize, key_ty.bytes_sizeof
	const value_des, value_ser, value_ser_resize, value_sizeof = val_ty.des, val_ty.ser, val_ty.ser_resize, val_ty.bytes_sizeof

	const function lux_read_map(buf: buffer, byte: Ptr): (Ptr, Map<KeyOutput, ValueOutput>)
		local size: number
		byte, size = length_des(buf, byte)

		const output = {}

		for i = 1, size do
			local key
			byte, key = key_des(buf, byte)
			local value
			byte, value = value_des(buf, byte)

			output[key] = value
		end

		return byte, output
	end

	const function lux_write_map(buf: buffer, byte: Ptr, data: Map<KeyInput, ValueInput>): Ptr
		local count = 0
		for _ in data do
			count += 1
		end

		byte = length_ser(buf, byte, count)

		for key, value in data do
			byte = key_ser(buf, byte, key)
			byte = value_ser(buf, byte, value)
		end

		return byte
	end

	const function lux_write_map_resize(buf: buffer, byte: Ptr, data: Map<KeyInput, ValueInput>): (Ptr, buffer)
		local count = 0
		for _ in data do
			count += 1
		end

		byte, buf = length_ser_resize(buf, byte, count)

		for key, value in data do
			byte, buf = key_ser_resize(buf, byte, key)
			byte, buf = value_ser_resize(buf, byte, value)
		end

		return byte, buf
	end

	const function lux_map_sizeof(data: Map<KeyInput, ValueInput>): number
		local size = 0

		local count = 0
		for key, value in data do
			count += 1

			size += key_sizeof(key) + value_sizeof(value)
		end

		size += length_sizeof(count)

		return size
	end

	return {
		bytes_static = false,
		bytes_lowerbound = len_ty.bytes_lowerbound,
		bytes_upperbound = constants.HUGE,
		bytes_sizeof = lux_map_sizeof,

		des = lux_read_map,
		ser = lux_write_map,
		ser_resize = lux_write_map_resize,

		kind = "map",
		subkind = "sparse",

		length = len_ty,
		keys = key_ty,
		values = val_ty,
	}
end

function module.string(len_ty: runtime_types.SerDes<number>?): runtime_types.TStringArbitrary
	-- todo(report, luau): ambiguous overload
	len_ty = len_ty or numbers_lcg.vlq16() :: runtime_types.SerDes<number>

	const length_des, length_ser, length_ser_resize, length_sizeof =
		len_ty.des, len_ty.ser, len_ty.ser_resize, len_ty.bytes_sizeof

	const function lux_read_str(buf: buffer, byte: Ptr): (Ptr, string)
		local size: number
		byte, size = length_des(buf, byte)

		const output = buffer.readstring(buf, byte, size)
		byte += size

		return byte, output
	end

	const function lux_write_str(buf: buffer, byte: Ptr, data: string): Ptr
		const size = #data
		byte = length_ser(buf, byte, size)

		buffer.writestring(buf, byte, data, size)
		byte += size

		return byte
	end

	const function lux_write_str_resize(buf: buffer, byte: Ptr, data: string): (Ptr, buffer)
		const size = #data
		byte, buf = length_ser_resize(buf, byte, size)

		local target = byte + size

		local buf_len = buffer.len(buf)
		if buf_len < target then
			repeat
				buf_len *= 2
			until buf_len >= target
			const new = buffer.create(buf_len)
			buffer.copy(new, 0, buf, 0, byte)
			buf = new
		end

		buffer.writestring(buf, byte, data, size)
		byte += size

		return byte, buf
	end

	const function lux_str_sizeof(data: string): number
		const data_len = #data
		return length_sizeof(data_len) + data_len
	end

	return {
		bytes_static = false,
		bytes_lowerbound = len_ty.bytes_lowerbound,
		bytes_upperbound = constants.HUGE,
		bytes_sizeof = lux_str_sizeof,

		des = lux_read_str,
		ser = lux_write_str,
		ser_resize = lux_write_str_resize,

		kind = "string",
		subkind = "arbitrary",

		length = len_ty,
	}
end

function module.struct<T>(template: T): type_fns.new_struct<T>
	local bytes_static: number | false = 0
	local bytes_lowerbound = 0
	local bytes_upperbound = 0

	const keys_names = {}

	for field in template :: { read [string]: unknown } do
		table.insert(keys_names, field)
	end

	table.sort(keys_names)

	const keys_serdes = {}
	const keys_des = {}
	const keys_ser = {}
	const keys_ser_resize = {}
	const keys_sizeof = {}
	for index, key_name in keys_names do
		const serdes: runtime_types.SerDes<any> = (template :: any)[key_name]

		keys_serdes[index] = serdes
		keys_des[index] = serdes.des
		keys_ser[index] = serdes.ser
		keys_ser_resize[index] = serdes.ser_resize
		keys_sizeof[index] = serdes.bytes_sizeof

		bytes_lowerbound += serdes.bytes_lowerbound
		bytes_upperbound += serdes.bytes_upperbound

		if not bytes_static then
			continue
		elseif not serdes.bytes_static then
			bytes_static = false
			continue
		end

		bytes_static += serdes.bytes_static
	end

	const function lux_read_struct(buf: buffer, byte: Ptr): (Ptr, any)
		const output: any = table.clone(template)

		for index, key_name in keys_names do
			byte, output[key_name] = keys_des[index](buf, byte)
		end

		return byte, output
	end

	const function lux_write_struct(buf: buffer, byte: Ptr, data: any): Ptr
		for index, key_name in keys_names do
			byte = keys_ser[index](buf, byte, data[key_name])
		end

		return byte
	end

	const function lux_write_struct_resize(buf: buffer, byte: Ptr, data: any): (Ptr, buffer)
		for index, key_name in keys_names do
			byte, buf = keys_ser_resize[index](buf, byte, data[key_name])
		end

		return byte, buf
	end

	const function lux_struct_sizeof(data: any): number
		local size = 0

		for index, key_name in keys_names do
			const value = data[key_name]
			size += keys_sizeof[index](value)
		end

		return size
	end

	const output: runtime_types.TStruct = {
		bytes_static = bytes_static,
		bytes_lowerbound = bytes_lowerbound,
		bytes_upperbound = bytes_upperbound,
		bytes_sizeof = lux_struct_sizeof,

		des = lux_read_struct,
		ser = lux_write_struct,
		ser_resize = lux_write_struct_resize,

		kind = "struct",
		subkind = "basic",

		key_names = keys_names,
		key_writers = keys_serdes,
	}

	return output :: any
end

const function is_datatype_ish(tbl: { [any]: any }): boolean
	return tbl["bytes_static"] ~= nil
		and tbl["bytes_lowerbound"] ~= nil
		and tbl["bytes_upperbound"] ~= nil
		and tbl["bytes_sizeof"] ~= nil
		and tbl["des"] ~= nil
		and tbl["ser"] ~= nil
		and tbl["ser_resize"] ~= nil
end

const function tbl(t: any, debug_name: string): runtime_types.SerDes<any>
	if typeof(t) ~= "table" then
		error(`could not convert {debug_name} into datatype`)
	end
	const template: { [unknown]: unknown } = t

	if is_datatype_ish(template) then
		return template :: any
	end

	local expected_kind: "string" | "table" | "number" = "string"
	for key, value in template :: { [any]: any } do
		const key_ty = typeof(key)
		if key_ty == "string" or key_ty == "table" or key_ty == "number" then
			expected_kind = key_ty
		else
			error(`table data {debug_name} cannot use key of type '{key_ty}'`)
		end

		break
	end

	for key in template do
		if typeof(key) ~= expected_kind then
			error(
				`table data {debug_name} expected keys of type {expected_kind}, but got {typeof(key)}; mixed tables are not currently allowed`
			)
		end
	end

	if expected_kind == "number" then
		if #template ~= 1 then
			error(
				`table data {debug_name} is an array with multiple items, but tuples are not currently supported in tables`
			)
		end

		return module.arr(tbl(template[1], `{debug_name}/items`))
	elseif expected_kind == "table" then
		const key, value = next(template :: any)
		if next(template :: any, key) then
			error(
				`table data {debug_name} is a map with multiple keys, but mixed tables are not currently supported in tables`
			)
		end

		return module.map(tbl(key, `{debug_name}/keys`), tbl(value, `{debug_name}/values`))
	elseif expected_kind == "string" then
		local output = table.clone(template)

		for key, value in template do
			output[key] = tbl(value, `{debug_name}[{string.format(`%q`, key :: string)}]`)
		end

		return module.struct(output)
	else
		const _: never = expected_kind
		return error("unreachable")
	end
end

function module.tbl<T>(template: T, debug_name: string?): type_fns.new_dsl<T>
	return tbl(template, debug_name or debug.info(2, "s")) :: any
end

function module.vector3_of(components: runtime_types.SerDes<number>?): runtime_types.TVectorUniform
	-- todo(report, luau): ambiguous overload
	components = components or numbers_lcg.f32() :: runtime_types.SerDes<number>

	const component_des, component_ser, component_ser_resize, component_sizeof =
		components.des, components.ser, components.ser_resize, components.bytes_sizeof

	const function lux_read_vector3_of(buf: buffer, byte: Ptr): (Ptr, vector)
		local x, y, z

		byte, x = component_des(buf, byte)
		byte, y = component_des(buf, byte)
		byte, z = component_des(buf, byte)

		return byte, vector.create(x, y, z)
	end

	const function lux_write_vector3_of(buf: buffer, byte: Ptr, data: vector): Ptr
		byte = component_ser(buf, byte, data.X)
		byte = component_ser(buf, byte, data.Y)
		byte = component_ser(buf, byte, data.Z)

		return byte
	end

	const function lux_write_vector3_of_resize(buf: buffer, byte: Ptr, data: vector): (Ptr, buffer)
		byte, buf = component_ser_resize(buf, byte, data.X)
		byte, buf = component_ser_resize(buf, byte, data.Y)
		byte, buf = component_ser_resize(buf, byte, data.Z)

		return byte, buf
	end

	const function lux_vector3_of_sizeof(data: vector): number
		return component_sizeof(data.X) + component_sizeof(data.Y) + component_sizeof(data.Z)
	end

	return {
		bytes_static = components.bytes_static and components.bytes_static * 3,
		bytes_lowerbound = math.min(components.bytes_lowerbound * 3, constants.HUGE),
		bytes_upperbound = math.min(components.bytes_upperbound * 3, constants.HUGE),
		bytes_sizeof = lux_vector3_of_sizeof,

		des = lux_read_vector3_of,
		ser = lux_write_vector3_of,
		ser_resize = lux_write_vector3_of_resize,

		kind = "vector",
		subkind = "uniform",

		components = components,
		realized_x = true,
		realized_y = true,
		realized_z = true,
		realized_w = false,
	}
end

--[=[
	currently unimplemented
]=]
function module.vector_xyz(
	x: runtime_types.SerDes<number>?,
	y: runtime_types.SerDes<number>?,
	z: runtime_types.SerDes<number>?
): runtime_types.TVectorXYZW
	return error("unimplemented")
end

--[=[
	currently unimplemented
]=]
function module.vector_xyzw(
	x: runtime_types.SerDes<number>?,
	y: runtime_types.SerDes<number>?,
	z: runtime_types.SerDes<number>?,
	w: runtime_types.SerDes<number>?
): runtime_types.TVectorXYZW
	return error("unimplemented")
end

const exports: Exports = module :: any

return exports
