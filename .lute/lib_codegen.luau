const fs = require("@std/fs")

const function tab_newlines(str: string, count: number?)
	const indentation = string.rep(`\t`, count or 1)
	return (string.gsub(str, `\n`, `\n{indentation}`))
end

local codegen_tabs, codegen_segments = 0, {}

const function lines(...: string): ()
	local first, rest = ...
	if rest then
		table.insert(
			codegen_segments,
			tab_newlines(`\n{table.concat({ ... }, `\n`)}`, codegen_tabs)
		)
	elseif first then
		table.insert(codegen_segments, tab_newlines(`\n{first}`, codegen_tabs))
	end
end

const function apply_indent(): ()
	codegen_tabs += 1
end

const function apply_dedent(): ()
	codegen_tabs -= 1
end

local id, currently_open = 0, {}
const function codegen_open(block: string): (closer: string) -> ()
	lines(block)
	apply_indent()

	const this_id = id + 1
	id = this_id

	const function close(segment: string): ()
		if currently_open[this_id] then
			currently_open[this_id] = nil

			apply_dedent()
			lines(segment)
			return
		end
		(error)(`already closed id {this_id} which began with {block}`, 2)
	end
	currently_open[this_id] = block

	return close
end

const function finish_module(filepath: string): ()
	for k, v: string in currently_open do
		print(`forgot to close block id {k} which began with {v}`)
	end
	if next(currently_open) then
		(error)(`problems happened, not writing to {filepath}`)
	elseif codegen_tabs ~= 0 then
		(error)(`indentation uneven by {codegen_tabs}`)
	end

	local content = table.concat(codegen_segments)

	content = string.gsub(content, `\n%s+\n`, `\n\n`)

	fs.writeStringToFile(filepath, content)

	id, currently_open = 0, {}
	codegen_tabs, codegen_segments = 0, {}

	print(`successfully finished {filepath}`)
end

const function native_fn(...: string): ()
	lines(`@native`, ...)
end

const function vm_fn(...: string): ()
	lines(...)
end

const HEADER = [[
const runtime_types = require("./runtime_types")

const module = {}
]]

const FOOTER = [[

return table.freeze(module)
]]

const PTR_T = `number`
const REALLOC_FACTOR = 2
const BITMASK7 = 0b10 ^ 7
local VLQ_OUT1 = 0b00000000_00000000_00000000_00000000_10000000
local VLQ_OUT2 = 0b00000000_00000000_00000000_10000000_10000000
local VLQ_OUT3 = 0b00000000_00000000_10000000_10000000_10000000
local VLQ_OUT4 = 0b00000000_10000000_10000000_10000000_10000000
local VLQ_OUT5 = 0b10000000_10000000_10000000_10000000_10000000

const function codegen_luau_number(
	offset: number,
	prefix: string,
	return_type: string,
	specification: (bits: number, identifier: string) -> ()
): ()
	const bits = offset * 8
	const identifier = prefix .. bits

	const closer = codegen_open(`function module.{identifier}(): {return_type}`)

	const read_name = `lux_read_{identifier}`
	const write_name = `lux_write_{identifier}`
	const write_resize_name = `lux_write_{identifier}_resize`

	lines(`local {read_name}, {write_name}, {write_resize_name}\n`)

	const function bodies()
		vm_fn(
			`function {read_name}(buf: buffer, byte: {PTR_T}): ({PTR_T}, number)`,
			`	return byte + {offset}, buffer.read{identifier}(buf, byte)`,
			`end`
		)

		lines(``)
		vm_fn(
			`function {write_name}(buf: buffer, byte: {PTR_T}, value: number): number`,
			`	buffer.write{identifier}(buf, byte, value)`,
			`	return byte + {offset}`,
			`end`
		)

		lines(``)
		native_fn(
			`function {write_resize_name}(buf: buffer, byte: {PTR_T}, value: number): ({PTR_T}, buffer)`,
			`	local len = buffer.len(buf)`,
			`	const target = byte + {offset}`,
			`	`,
			`	if len < target then`,
			`		repeat`,
			`			len *= {REALLOC_FACTOR}`,
			`		until len >= target`,
			`		const new = buffer.create(len)`,
			`		buffer.copy(new, 0, buf, 0, byte)`,
			`		buf = new`,
			`	end`,
			`	`,
			`	buffer.write{identifier}(buf, byte, value)`,
			`	return target, buf`,
			`end`
		)
	end

	bodies()

	specification(bits, identifier)

	closer(`end`)
end
const function codegen_luau_number_integral(offset: number, signed: boolean): ()
	const sign = if signed then `i` else `u`
	const return_type = "runtime_types.TNumberIntegral"
	codegen_luau_number(offset, sign, return_type, function(bits, identifier): ()
		lines(
			``,
			"return {",
			`	kind = "number";`,
			`	subkind = "integral";`,
			`	representation = "{bits}";`,
			`	signed = {signed};`,
			`	`,
			`	bytes_static = {offset};`,
			`	bytes_lowerbound = {offset};`,
			`	bytes_upperbound = {offset};`,
			`	bytes_sizeof = function() return {offset} end;`,
			`	`,
			`	des = lux_read_{identifier};`,
			`	ser = lux_write_{identifier};`,
			`	ser_resize = lux_write_{identifier}_resize;`,
			`}`
		)
	end)
end
const function codegen_luau_number_float(offset: number): ()
	const return_type = "runtime_types.TNumberFloat"
	codegen_luau_number(offset, "f", return_type, function(bits, identifier): ()
		lines(
			``,
			"return {",
			`	kind = "number";`,
			`	subkind = "float";`,
			`	representation = "{bits}";`,
			`	`,
			`	bytes_static = {offset};`,
			`	bytes_lowerbound = {offset};`,
			`	bytes_upperbound = {offset};`,
			`	bytes_sizeof = function() return {offset} end;`,
			`	`,
			`	des = lux_read_{identifier};`,
			`	ser = lux_write_{identifier};`,
			`	ser_resize = lux_write_{identifier}_resize;`,
			`}`
		)
	end)
end

-- todo(dev): vlq serdes is not fast enough
const function codegen_vlqs(): ()
	const function codegen_vlq_alloc(offset: number, should_alloc: boolean): ()
		if not should_alloc then
			return
		end

		lines(
			`const target = byte + {offset}`,
			`if len < target then`,
			`	repeat`,
			`		len *= {REALLOC_FACTOR}`,
			`	until len >= target`,
			`	const new = buffer.create(len)`,
			`	buffer.copy(new, 0, buf, 0, byte)`,
			`	buf = new`,
			`end`
		)
	end

	const function codegen_vlq_section8(max_offset: number, should_alloc: boolean)
		if max_offset > 8 then
			(error)(`max offset {max_offset} is too high`)
		end

		codegen_vlq_alloc(8, should_alloc)

		lines(
			-- todo(dev, debug): the arithmetic logic here is a little scary
			-- once we have inputs this size since they can exceed 2 ^ 53
			`input -= sep`,
			`local output = sep + {VLQ_OUT4}`,
			`sep = input % {BITMASK7 ^ 2}`,
			`input -= sep`,
			`output += sep * {0b10 ^ 1}`,
			`sep = input % {BITMASK7 ^ 3}`,
			`input -= sep`,
			`output += sep * {0b10 ^ 2}`,
			`sep = input % {BITMASK7 ^ 4}`,
			`output += sep * {0b10 ^ 3}`
		)

		lines(
			`buffer.writeu{32}(buf, byte, output)`,
			`byte += {4}`,
			`input //= {BITMASK7 ^ 4}`,
			`output = {VLQ_OUT3}`
		)

		lines(
			`sep = input % {BITMASK7 ^ 1}`,
			`input -= sep`,
			`output += sep`,
			`sep = input % {BITMASK7 ^ 2}`,
			`input -= sep`,
			`output += sep * {0b10 ^ 1}`,
			`sep = input % {BITMASK7 ^ 3}`,
			`input -= sep`,
			`output += sep * {0b10 ^ 2}`,
			`sep = input % {BITMASK7 ^ 4}`,
			`output += sep * {0b10 ^ 3}`
		)

		lines(
			`buffer.writeu{32}(buf, byte, output)`,
			if not should_alloc then `return byte + {4}` else `return target, buf`
		)
	end
	const function codegen_vlq_section7(max_offset: number, should_alloc: boolean)
		if max_offset > 7 then
			const closer = codegen_open(`if input >= {BITMASK7 ^ 7} then`)
			codegen_vlq_section8(max_offset, should_alloc)
			closer(`end`)
		end

		codegen_vlq_alloc(7, should_alloc)

		lines(
			`input -= sep`,
			`local output = sep + {VLQ_OUT4}`,
			`sep = input % {BITMASK7 ^ 2}`,
			`input -= sep`,
			`output += sep * {0b10 ^ 1}`,
			`sep = input % {BITMASK7 ^ 3}`,
			`input -= sep`,
			`output += sep * {0b10 ^ 2}`,
			`sep = input % {BITMASK7 ^ 4}`,
			`output += sep * {0b10 ^ 3}`
		)

		lines(
			`buffer.writeu{32}(buf, byte, output)`,
			`byte += {4}`,
			`input //= {BITMASK7 ^ 4}`,
			`output = {VLQ_OUT2}`
		)

		lines(
			`sep = input % {BITMASK7 ^ 1}`,
			`output += sep`,
			`input -= sep`,
			`sep = input % {BITMASK7 ^ 2}`,
			`input -= sep`,
			`output += sep * {0b10 ^ 1}`,
			`output += input * {0b10 ^ 2}`
		)

		lines(
			`buffer.writeu{16}(buf, byte, output)`,
			`byte += {2}`,
			`output /= {2 ^ 16}`,
			`buffer.writeu{8}(buf, byte, output)`,
			if not should_alloc then `return byte + {1}` else `return target, buf`
		)
	end
	const function codegen_vlq_section6(max_offset: number, should_alloc: boolean)
		if max_offset > 6 then
			const closer = codegen_open(`if input >= {BITMASK7 ^ 6} then`)
			codegen_vlq_section7(max_offset, should_alloc)
			closer(`end`)
		end

		codegen_vlq_alloc(6, should_alloc)

		lines(
			`input -= sep`,
			`local output = sep + {VLQ_OUT5}`,
			`sep = input % {BITMASK7 ^ 2}`,
			`input -= sep`,
			`output += sep * {0b10 ^ 1}`,
			`sep = input % {BITMASK7 ^ 3}`,
			`input -= sep`,
			`output += sep * {0b10 ^ 2}`,
			`sep = input % {BITMASK7 ^ 4}`,
			`input -= sep`,
			`output += sep * {0b10 ^ 3}`,
			`sep = input % {BITMASK7 ^ 5}`,
			`input -= sep`,
			`output += sep * {0b10 ^ 4}`,
			`output += input * {0b10 ^ 5}`
		)

		lines(
			`buffer.writeu{32}(buf, byte, output)`,
			`byte += {4}`,
			`output /= {2 ^ 32}`,
			`buffer.writeu{16}(buf, byte, output)`,
			if not should_alloc then `return byte + {2}` else `return target, buf`
		)
	end
	const function codegen_vlq_section5(max_offset: number, should_alloc: boolean)
		if max_offset > 5 then
			const closer = codegen_open(`if input >= {BITMASK7 ^ 5} then`)
			codegen_vlq_section6(max_offset, should_alloc)
			closer(`end`)
		end

		codegen_vlq_alloc(5, should_alloc)

		lines(
			`input -= sep`,
			`local output = sep + {VLQ_OUT4}`,
			`sep = input % {BITMASK7 ^ 2}`,
			`input -= sep`,
			`output += sep * {0b10 ^ 1}`,
			`sep = input % {BITMASK7 ^ 3}`,
			`input -= sep`,
			`output += sep * {0b10 ^ 2}`,
			`sep = input % {BITMASK7 ^ 4}`,
			`input -= sep`,
			`output += sep * {0b10 ^ 3}`,
			`output += input * {0b10 ^ 4}`
		)

		lines(
			`buffer.writeu{32}(buf, byte, output)`,
			`byte += {4}`,
			`output /= {2 ^ 32}`,
			`buffer.writeu{8}(buf, byte, output)`,
			if not should_alloc then `return byte + {1}` else `return target, buf`
		)
	end
	const function codegen_vlq_section4(max_offset: number, should_alloc: boolean)
		if max_offset > 4 then
			const closer = codegen_open(`if input >= {BITMASK7 ^ 4} then`)
			codegen_vlq_section5(max_offset, should_alloc)
			closer(`end`)
		end

		codegen_vlq_alloc(4, should_alloc)

		lines(
			`input -= sep`,
			`local output = sep + {VLQ_OUT3}`,
			`sep = input % {BITMASK7 ^ 2}`,
			`input -= sep`,
			`output += sep * {0b10 ^ 1}`,
			`sep = input % {BITMASK7 ^ 3}`,
			`input -= sep`,
			`output += sep * {0b10 ^ 2}`,
			`output += input * {0b10 ^ 3}`
		)

		lines(
			`buffer.writeu{32}(buf, byte, output)`,
			if not should_alloc then `return byte + 4` else `return target, buf`
		)
	end
	const function codegen_vlq_section3(max_offset: number, should_alloc: boolean)
		if max_offset > 3 then
			const closer = codegen_open(`if input >= {BITMASK7 ^ 3} then`)
			codegen_vlq_section4(max_offset, should_alloc)
			closer(`end`)
		end

		codegen_vlq_alloc(3, should_alloc)

		lines(
			`input -= sep`,
			`local output = sep + {VLQ_OUT2}`,
			`sep = input % {BITMASK7 ^ 2}`,
			`input -= sep`,
			`output += sep * {0b10 ^ 1}`,
			`output += input * {0b10 ^ 2}`
		)

		lines(
			`buffer.writeu{16}(buf, byte, output)`,
			`byte += {2}`,
			`output /= {0b10 ^ 16}`,
			`buffer.writeu{8}(buf, byte, output)`,
			if not should_alloc then `return byte + {1}` else `return target, buf`
		)
	end
	const function codegen_vlq_section2(max_offset: number, should_alloc: boolean)
		if max_offset > 2 then
			const closer = codegen_open(`if input >= {BITMASK7 ^ 2} then`)
			codegen_vlq_section3(max_offset, should_alloc)
			closer(`end`)
		end

		codegen_vlq_alloc(2, should_alloc)

		lines(
			`input -= sep`,
			`local output = sep + {VLQ_OUT1}`,
			`output += input * {0b10 ^ 1}`
		)

		lines(
			`buffer.writeu{16}(buf, byte, output)`,
			if not should_alloc then `return byte + 2` else `return target, buf`
		)
	end
	const function codegen_vlq_section1(max_offset: number, should_alloc: boolean)
		if should_alloc then
			lines(`local len = buffer.len(buf)`)
		end

		if max_offset > 1 then
			const closer = codegen_open(`if input >= {BITMASK7 ^ 1} then`)
			lines(`local sep = input % {BITMASK7 ^ 1}`)
			codegen_vlq_section2(max_offset, should_alloc)
			closer(`end`)
		end

		codegen_vlq_alloc(1, should_alloc)

		lines(
			`buffer.writeu{8}(buf, byte, input)`,
			if not should_alloc then `return byte + 1` else `return target, buf`
		)
	end

	for max_bytes = 2, 8 do
		const max_bits = max_bytes * 8

		const closer =
			codegen_open(`function module.vlq{max_bits}(): runtime_types.TNumberVLQ`)

		const name_read = `lux_read_vlq{max_bits}`
		const name_write = `lux_write_vlq{max_bits}`
		const name_write_resize = `lux_write_vlq{max_bits}_resize`
		const name_sizeof = `lux_vlq{max_bits}_sizeof`

		native_fn()
		const closer_write = codegen_open(
			`const function {name_write}(buf: buffer, byte: {PTR_T}, input: number): number`
		)

		codegen_vlq_section1(max_bytes, false)
		closer_write(`end`)

		native_fn()
		const closer_write_resize = codegen_open(
			`const function {name_write_resize}(buf: buffer, byte: {PTR_T}, input: number): ({PTR_T}, buffer)`
		)
		codegen_vlq_section1(max_bytes, true)
		closer_write_resize(`end`)

		native_fn()
		const closer_read = codegen_open(
			`const function {name_read}(buf: buffer, byte: {PTR_T}): ({PTR_T}, number)`
		)

		for septet = 0, max_bytes - 1 do
			lines(`-- {BITMASK7} ^ {septet}`)

			const is_first, is_second, is_last =
				septet == 0, septet == 1, septet == max_bytes - 1

			const function shift_octet(): string
				if is_first then
					return ``
				end
				return `octet *= {BITMASK7 ^ septet}`
			end

			if is_second then
				lines(`local output = octet - {BITMASK7}`)
			end

			lines( --
				`{is_first and `local ` or ``}octet = buffer.readu{8}(buf, byte)`,
				`byte += {1}`
			)

			if is_last then
				lines( --
					shift_octet(),
					`return byte, output + octet`
				)
			elseif is_first then
				lines( --
					`if octet < {BITMASK7} then`,
					`	{shift_octet()}`,
					`	return byte, octet`,
					`end`
				)
			else
				lines(
					`if octet < {BITMASK7} then`,
					`	{shift_octet()}`,
					`	return byte, output + octet`,
					`end`,
					`octet -= {BITMASK7}`,
					shift_octet(),
					`output += octet`
				)
			end
		end

		closer_read(`end`)

		native_fn()
		const closer_sizeof =
			codegen_open(`const function {name_sizeof}(data: number): number`)

		lines( --
			`if data < {BITMASK7 ^ 1} then`,
			`	return 1`
		)
		for i = 2, max_bytes - 1 do
			lines( --
				`elseif data < {BITMASK7 ^ i} then`,
				`	return {i}`
			)
		end
		lines( --
			`else`,
			`	return {max_bytes}`,
			`end`
		)

		closer_sizeof(`end`)

		lines(
			``,
			"return {",
			`	kind = "number";`,
			`	subkind = "vlq";`,
			`	representation = "{max_bits}";`,
			`	`,
			`	bytes_static = false;`,
			`	bytes_lowerbound = 1;`,
			`	bytes_upperbound = {max_bytes};`,
			`	bytes_sizeof = {name_sizeof};`,
			`	`,
			`	des = {name_read};`,
			`	ser = {name_write};`,
			`	ser_resize = {name_write_resize};`,
			`}`
		)

		closer(`end`)
	end
end

const function codegen_section(name: string)
	lines(`\n--[=[`, `	{name}`, `]=]\n`)
end

lines(HEADER)

codegen_section("u8 / u16 / u32")

codegen_luau_number_integral(1, false)
codegen_luau_number_integral(2, false)
codegen_luau_number_integral(4, false)

codegen_section("i8 / i16 / i32")

codegen_luau_number_integral(1, true)
codegen_luau_number_integral(2, true)
codegen_luau_number_integral(4, true)

codegen_section("f32 / f64")

codegen_luau_number_float(4)
codegen_luau_number_float(8)

codegen_section("vlq8 / vlq16 / vlq24 / vlq32 / vlq40 / vlq48 / vlq56 / vlq64")

codegen_vlqs()

lines(FOOTER)

finish_module(`./src/numbers_lcg.luau`)
