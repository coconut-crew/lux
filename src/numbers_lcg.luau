
const runtime_types = require("./runtime_types")

const module = {}

--[=[
	u8 / u16 / u32
]=]

function module.u8(): runtime_types.TNumberIntegral
	local lux_read_u8, lux_write_u8, lux_write_u8_resize

	function lux_read_u8(buf: buffer, byte: number): (number, number)
		return byte + 1, buffer.readu8(buf, byte)
	end

	function lux_write_u8(buf: buffer, byte: number, value: number): number
		buffer.writeu8(buf, byte, value)
		return byte + 1
	end

	@native
	function lux_write_u8_resize(buf: buffer, byte: number, value: number): (number, buffer)
		local len = buffer.len(buf)
		const target = byte + 1

		if len < target then
			repeat
				len *= 2
			until len >= target
			const new = buffer.create(len)
			buffer.copy(new, 0, buf, 0, byte)
			buf = new
		end

		buffer.writeu8(buf, byte, value)
		return target, buf
	end

	return {
		kind = "number";
		subkind = "integral";
		representation = "8";
		signed = false;

		bytes_static = 1;
		bytes_lowerbound = 1;
		bytes_upperbound = 1;
		bytes_sizeof = function() return 1 end;

		des = lux_read_u8;
		ser = lux_write_u8;
		ser_resize = lux_write_u8_resize;
	}
end
function module.u16(): runtime_types.TNumberIntegral
	local lux_read_u16, lux_write_u16, lux_write_u16_resize

	function lux_read_u16(buf: buffer, byte: number): (number, number)
		return byte + 2, buffer.readu16(buf, byte)
	end

	function lux_write_u16(buf: buffer, byte: number, value: number): number
		buffer.writeu16(buf, byte, value)
		return byte + 2
	end

	@native
	function lux_write_u16_resize(buf: buffer, byte: number, value: number): (number, buffer)
		local len = buffer.len(buf)
		const target = byte + 2

		if len < target then
			repeat
				len *= 2
			until len >= target
			const new = buffer.create(len)
			buffer.copy(new, 0, buf, 0, byte)
			buf = new
		end

		buffer.writeu16(buf, byte, value)
		return target, buf
	end

	return {
		kind = "number";
		subkind = "integral";
		representation = "16";
		signed = false;

		bytes_static = 2;
		bytes_lowerbound = 2;
		bytes_upperbound = 2;
		bytes_sizeof = function() return 2 end;

		des = lux_read_u16;
		ser = lux_write_u16;
		ser_resize = lux_write_u16_resize;
	}
end
function module.u32(): runtime_types.TNumberIntegral
	local lux_read_u32, lux_write_u32, lux_write_u32_resize

	function lux_read_u32(buf: buffer, byte: number): (number, number)
		return byte + 4, buffer.readu32(buf, byte)
	end

	function lux_write_u32(buf: buffer, byte: number, value: number): number
		buffer.writeu32(buf, byte, value)
		return byte + 4
	end

	@native
	function lux_write_u32_resize(buf: buffer, byte: number, value: number): (number, buffer)
		local len = buffer.len(buf)
		const target = byte + 4

		if len < target then
			repeat
				len *= 2
			until len >= target
			const new = buffer.create(len)
			buffer.copy(new, 0, buf, 0, byte)
			buf = new
		end

		buffer.writeu32(buf, byte, value)
		return target, buf
	end

	return {
		kind = "number";
		subkind = "integral";
		representation = "32";
		signed = false;

		bytes_static = 4;
		bytes_lowerbound = 4;
		bytes_upperbound = 4;
		bytes_sizeof = function() return 4 end;

		des = lux_read_u32;
		ser = lux_write_u32;
		ser_resize = lux_write_u32_resize;
	}
end

--[=[
	i8 / i16 / i32
]=]

function module.i8(): runtime_types.TNumberIntegral
	local lux_read_i8, lux_write_i8, lux_write_i8_resize

	function lux_read_i8(buf: buffer, byte: number): (number, number)
		return byte + 1, buffer.readi8(buf, byte)
	end

	function lux_write_i8(buf: buffer, byte: number, value: number): number
		buffer.writei8(buf, byte, value)
		return byte + 1
	end

	@native
	function lux_write_i8_resize(buf: buffer, byte: number, value: number): (number, buffer)
		local len = buffer.len(buf)
		const target = byte + 1

		if len < target then
			repeat
				len *= 2
			until len >= target
			const new = buffer.create(len)
			buffer.copy(new, 0, buf, 0, byte)
			buf = new
		end

		buffer.writei8(buf, byte, value)
		return target, buf
	end

	return {
		kind = "number";
		subkind = "integral";
		representation = "8";
		signed = true;

		bytes_static = 1;
		bytes_lowerbound = 1;
		bytes_upperbound = 1;
		bytes_sizeof = function() return 1 end;

		des = lux_read_i8;
		ser = lux_write_i8;
		ser_resize = lux_write_i8_resize;
	}
end
function module.i16(): runtime_types.TNumberIntegral
	local lux_read_i16, lux_write_i16, lux_write_i16_resize

	function lux_read_i16(buf: buffer, byte: number): (number, number)
		return byte + 2, buffer.readi16(buf, byte)
	end

	function lux_write_i16(buf: buffer, byte: number, value: number): number
		buffer.writei16(buf, byte, value)
		return byte + 2
	end

	@native
	function lux_write_i16_resize(buf: buffer, byte: number, value: number): (number, buffer)
		local len = buffer.len(buf)
		const target = byte + 2

		if len < target then
			repeat
				len *= 2
			until len >= target
			const new = buffer.create(len)
			buffer.copy(new, 0, buf, 0, byte)
			buf = new
		end

		buffer.writei16(buf, byte, value)
		return target, buf
	end

	return {
		kind = "number";
		subkind = "integral";
		representation = "16";
		signed = true;

		bytes_static = 2;
		bytes_lowerbound = 2;
		bytes_upperbound = 2;
		bytes_sizeof = function() return 2 end;

		des = lux_read_i16;
		ser = lux_write_i16;
		ser_resize = lux_write_i16_resize;
	}
end
function module.i32(): runtime_types.TNumberIntegral
	local lux_read_i32, lux_write_i32, lux_write_i32_resize

	function lux_read_i32(buf: buffer, byte: number): (number, number)
		return byte + 4, buffer.readi32(buf, byte)
	end

	function lux_write_i32(buf: buffer, byte: number, value: number): number
		buffer.writei32(buf, byte, value)
		return byte + 4
	end

	@native
	function lux_write_i32_resize(buf: buffer, byte: number, value: number): (number, buffer)
		local len = buffer.len(buf)
		const target = byte + 4

		if len < target then
			repeat
				len *= 2
			until len >= target
			const new = buffer.create(len)
			buffer.copy(new, 0, buf, 0, byte)
			buf = new
		end

		buffer.writei32(buf, byte, value)
		return target, buf
	end

	return {
		kind = "number";
		subkind = "integral";
		representation = "32";
		signed = true;

		bytes_static = 4;
		bytes_lowerbound = 4;
		bytes_upperbound = 4;
		bytes_sizeof = function() return 4 end;

		des = lux_read_i32;
		ser = lux_write_i32;
		ser_resize = lux_write_i32_resize;
	}
end

--[=[
	f32 / f64
]=]

function module.f32(): runtime_types.TNumberFloat
	local lux_read_f32, lux_write_f32, lux_write_f32_resize

	function lux_read_f32(buf: buffer, byte: number): (number, number)
		return byte + 4, buffer.readf32(buf, byte)
	end

	function lux_write_f32(buf: buffer, byte: number, value: number): number
		buffer.writef32(buf, byte, value)
		return byte + 4
	end

	@native
	function lux_write_f32_resize(buf: buffer, byte: number, value: number): (number, buffer)
		local len = buffer.len(buf)
		const target = byte + 4

		if len < target then
			repeat
				len *= 2
			until len >= target
			const new = buffer.create(len)
			buffer.copy(new, 0, buf, 0, byte)
			buf = new
		end

		buffer.writef32(buf, byte, value)
		return target, buf
	end

	return {
		kind = "number";
		subkind = "float";
		representation = "32";

		bytes_static = 4;
		bytes_lowerbound = 4;
		bytes_upperbound = 4;
		bytes_sizeof = function() return 4 end;

		des = lux_read_f32;
		ser = lux_write_f32;
		ser_resize = lux_write_f32_resize;
	}
end
function module.f64(): runtime_types.TNumberFloat
	local lux_read_f64, lux_write_f64, lux_write_f64_resize

	function lux_read_f64(buf: buffer, byte: number): (number, number)
		return byte + 8, buffer.readf64(buf, byte)
	end

	function lux_write_f64(buf: buffer, byte: number, value: number): number
		buffer.writef64(buf, byte, value)
		return byte + 8
	end

	@native
	function lux_write_f64_resize(buf: buffer, byte: number, value: number): (number, buffer)
		local len = buffer.len(buf)
		const target = byte + 8

		if len < target then
			repeat
				len *= 2
			until len >= target
			const new = buffer.create(len)
			buffer.copy(new, 0, buf, 0, byte)
			buf = new
		end

		buffer.writef64(buf, byte, value)
		return target, buf
	end

	return {
		kind = "number";
		subkind = "float";
		representation = "64";

		bytes_static = 8;
		bytes_lowerbound = 8;
		bytes_upperbound = 8;
		bytes_sizeof = function() return 8 end;

		des = lux_read_f64;
		ser = lux_write_f64;
		ser_resize = lux_write_f64_resize;
	}
end

--[=[
	vlq8 / vlq16 / vlq24 / vlq32 / vlq40 / vlq48 / vlq56 / vlq64
]=]

function module.vlq16(): runtime_types.TNumberVLQ
	@native
	const function lux_write_vlq16(buf: buffer, byte: number, input: number): number
		if input >= 128 then
			local sep = input % 128
			input -= sep
			local output = sep + 128
			output += input * 2
			buffer.writeu16(buf, byte, output)
			return byte + 2
		end
		buffer.writeu8(buf, byte, input)
		return byte + 1
	end
	@native
	const function lux_write_vlq16_resize(buf: buffer, byte: number, input: number): (number, buffer)
		local len = buffer.len(buf)
		if input >= 128 then
			local sep = input % 128
			const target = byte + 2
			if len < target then
				repeat
					len *= 2
				until len >= target
				const new = buffer.create(len)
				buffer.copy(new, 0, buf, 0, byte)
				buf = new
			end
			input -= sep
			local output = sep + 128
			output += input * 2
			buffer.writeu16(buf, byte, output)
			return target, buf
		end
		const target = byte + 1
		if len < target then
			repeat
				len *= 2
			until len >= target
			const new = buffer.create(len)
			buffer.copy(new, 0, buf, 0, byte)
			buf = new
		end
		buffer.writeu8(buf, byte, input)
		return target, buf
	end
	@native
	const function lux_read_vlq16(buf: buffer, byte: number): (number, number)
		-- 128 ^ 0
		local octet = buffer.readu8(buf, byte)
		byte += 1
		if octet < 128 then

			return byte, octet
		end
		-- 128 ^ 1
		local output = octet - 128
		octet = buffer.readu8(buf, byte)
		byte += 1
		octet *= 128
		return byte, output + octet
	end
	@native
	const function lux_vlq16_sizeof(data: number): number
		if data < 128 then
			return 1
		else
			return 2
		end
	end

	return {
		kind = "number";
		subkind = "vlq";
		representation = "16";

		bytes_static = false;
		bytes_lowerbound = 1;
		bytes_upperbound = 2;
		bytes_sizeof = lux_vlq16_sizeof;

		des = lux_read_vlq16;
		ser = lux_write_vlq16;
		ser_resize = lux_write_vlq16_resize;
	}
end
function module.vlq24(): runtime_types.TNumberVLQ
	@native
	const function lux_write_vlq24(buf: buffer, byte: number, input: number): number
		if input >= 128 then
			local sep = input % 128
			if input >= 16384 then
				input -= sep
				local output = sep + 32896
				sep = input % 16384
				input -= sep
				output += sep * 2
				output += input * 4
				buffer.writeu16(buf, byte, output)
				byte += 2
				output /= 65536
				buffer.writeu8(buf, byte, output)
				return byte + 1
			end
			input -= sep
			local output = sep + 128
			output += input * 2
			buffer.writeu16(buf, byte, output)
			return byte + 2
		end
		buffer.writeu8(buf, byte, input)
		return byte + 1
	end
	@native
	const function lux_write_vlq24_resize(buf: buffer, byte: number, input: number): (number, buffer)
		local len = buffer.len(buf)
		if input >= 128 then
			local sep = input % 128
			if input >= 16384 then
				const target = byte + 3
				if len < target then
					repeat
						len *= 2
					until len >= target
					const new = buffer.create(len)
					buffer.copy(new, 0, buf, 0, byte)
					buf = new
				end
				input -= sep
				local output = sep + 32896
				sep = input % 16384
				input -= sep
				output += sep * 2
				output += input * 4
				buffer.writeu16(buf, byte, output)
				byte += 2
				output /= 65536
				buffer.writeu8(buf, byte, output)
				return target, buf
			end
			const target = byte + 2
			if len < target then
				repeat
					len *= 2
				until len >= target
				const new = buffer.create(len)
				buffer.copy(new, 0, buf, 0, byte)
				buf = new
			end
			input -= sep
			local output = sep + 128
			output += input * 2
			buffer.writeu16(buf, byte, output)
			return target, buf
		end
		const target = byte + 1
		if len < target then
			repeat
				len *= 2
			until len >= target
			const new = buffer.create(len)
			buffer.copy(new, 0, buf, 0, byte)
			buf = new
		end
		buffer.writeu8(buf, byte, input)
		return target, buf
	end
	@native
	const function lux_read_vlq24(buf: buffer, byte: number): (number, number)
		-- 128 ^ 0
		local octet = buffer.readu8(buf, byte)
		byte += 1
		if octet < 128 then

			return byte, octet
		end
		-- 128 ^ 1
		local output = octet - 128
		octet = buffer.readu8(buf, byte)
		byte += 1
		if octet < 128 then
			octet *= 128
			return byte, output + octet
		end
		octet -= 128
		octet *= 128
		output += octet
		-- 128 ^ 2
		octet = buffer.readu8(buf, byte)
		byte += 1
		octet *= 16384
		return byte, output + octet
	end
	@native
	const function lux_vlq24_sizeof(data: number): number
		if data < 128 then
			return 1
		elseif data < 16384 then
			return 2
		else
			return 3
		end
	end

	return {
		kind = "number";
		subkind = "vlq";
		representation = "24";

		bytes_static = false;
		bytes_lowerbound = 1;
		bytes_upperbound = 3;
		bytes_sizeof = lux_vlq24_sizeof;

		des = lux_read_vlq24;
		ser = lux_write_vlq24;
		ser_resize = lux_write_vlq24_resize;
	}
end
function module.vlq32(): runtime_types.TNumberVLQ
	@native
	const function lux_write_vlq32(buf: buffer, byte: number, input: number): number
		if input >= 128 then
			local sep = input % 128
			if input >= 16384 then
				if input >= 2097152 then
					input -= sep
					local output = sep + 8421504
					sep = input % 16384
					input -= sep
					output += sep * 2
					sep = input % 2097152
					input -= sep
					output += sep * 4
					output += input * 8
					buffer.writeu32(buf, byte, output)
					return byte + 4
				end
				input -= sep
				local output = sep + 32896
				sep = input % 16384
				input -= sep
				output += sep * 2
				output += input * 4
				buffer.writeu16(buf, byte, output)
				byte += 2
				output /= 65536
				buffer.writeu8(buf, byte, output)
				return byte + 1
			end
			input -= sep
			local output = sep + 128
			output += input * 2
			buffer.writeu16(buf, byte, output)
			return byte + 2
		end
		buffer.writeu8(buf, byte, input)
		return byte + 1
	end
	@native
	const function lux_write_vlq32_resize(buf: buffer, byte: number, input: number): (number, buffer)
		local len = buffer.len(buf)
		if input >= 128 then
			local sep = input % 128
			if input >= 16384 then
				if input >= 2097152 then
					const target = byte + 4
					if len < target then
						repeat
							len *= 2
						until len >= target
						const new = buffer.create(len)
						buffer.copy(new, 0, buf, 0, byte)
						buf = new
					end
					input -= sep
					local output = sep + 8421504
					sep = input % 16384
					input -= sep
					output += sep * 2
					sep = input % 2097152
					input -= sep
					output += sep * 4
					output += input * 8
					buffer.writeu32(buf, byte, output)
					return target, buf
				end
				const target = byte + 3
				if len < target then
					repeat
						len *= 2
					until len >= target
					const new = buffer.create(len)
					buffer.copy(new, 0, buf, 0, byte)
					buf = new
				end
				input -= sep
				local output = sep + 32896
				sep = input % 16384
				input -= sep
				output += sep * 2
				output += input * 4
				buffer.writeu16(buf, byte, output)
				byte += 2
				output /= 65536
				buffer.writeu8(buf, byte, output)
				return target, buf
			end
			const target = byte + 2
			if len < target then
				repeat
					len *= 2
				until len >= target
				const new = buffer.create(len)
				buffer.copy(new, 0, buf, 0, byte)
				buf = new
			end
			input -= sep
			local output = sep + 128
			output += input * 2
			buffer.writeu16(buf, byte, output)
			return target, buf
		end
		const target = byte + 1
		if len < target then
			repeat
				len *= 2
			until len >= target
			const new = buffer.create(len)
			buffer.copy(new, 0, buf, 0, byte)
			buf = new
		end
		buffer.writeu8(buf, byte, input)
		return target, buf
	end
	@native
	const function lux_read_vlq32(buf: buffer, byte: number): (number, number)
		-- 128 ^ 0
		local octet = buffer.readu8(buf, byte)
		byte += 1
		if octet < 128 then

			return byte, octet
		end
		-- 128 ^ 1
		local output = octet - 128
		octet = buffer.readu8(buf, byte)
		byte += 1
		if octet < 128 then
			octet *= 128
			return byte, output + octet
		end
		octet -= 128
		octet *= 128
		output += octet
		-- 128 ^ 2
		octet = buffer.readu8(buf, byte)
		byte += 1
		if octet < 128 then
			octet *= 16384
			return byte, output + octet
		end
		octet -= 128
		octet *= 16384
		output += octet
		-- 128 ^ 3
		octet = buffer.readu8(buf, byte)
		byte += 1
		octet *= 2097152
		return byte, output + octet
	end
	@native
	const function lux_vlq32_sizeof(data: number): number
		if data < 128 then
			return 1
		elseif data < 16384 then
			return 2
		elseif data < 2097152 then
			return 3
		else
			return 4
		end
	end

	return {
		kind = "number";
		subkind = "vlq";
		representation = "32";

		bytes_static = false;
		bytes_lowerbound = 1;
		bytes_upperbound = 4;
		bytes_sizeof = lux_vlq32_sizeof;

		des = lux_read_vlq32;
		ser = lux_write_vlq32;
		ser_resize = lux_write_vlq32_resize;
	}
end
function module.vlq40(): runtime_types.TNumberVLQ
	@native
	const function lux_write_vlq40(buf: buffer, byte: number, input: number): number
		if input >= 128 then
			local sep = input % 128
			if input >= 16384 then
				if input >= 2097152 then
					if input >= 268435456 then
						input -= sep
						local output = sep + 2155905152
						sep = input % 16384
						input -= sep
						output += sep * 2
						sep = input % 2097152
						input -= sep
						output += sep * 4
						sep = input % 268435456
						input -= sep
						output += sep * 8
						output += input * 16
						buffer.writeu32(buf, byte, output)
						byte += 4
						output /= 4294967296
						buffer.writeu8(buf, byte, output)
						return byte + 1
					end
					input -= sep
					local output = sep + 8421504
					sep = input % 16384
					input -= sep
					output += sep * 2
					sep = input % 2097152
					input -= sep
					output += sep * 4
					output += input * 8
					buffer.writeu32(buf, byte, output)
					return byte + 4
				end
				input -= sep
				local output = sep + 32896
				sep = input % 16384
				input -= sep
				output += sep * 2
				output += input * 4
				buffer.writeu16(buf, byte, output)
				byte += 2
				output /= 65536
				buffer.writeu8(buf, byte, output)
				return byte + 1
			end
			input -= sep
			local output = sep + 128
			output += input * 2
			buffer.writeu16(buf, byte, output)
			return byte + 2
		end
		buffer.writeu8(buf, byte, input)
		return byte + 1
	end
	@native
	const function lux_write_vlq40_resize(buf: buffer, byte: number, input: number): (number, buffer)
		local len = buffer.len(buf)
		if input >= 128 then
			local sep = input % 128
			if input >= 16384 then
				if input >= 2097152 then
					if input >= 268435456 then
						const target = byte + 5
						if len < target then
							repeat
								len *= 2
							until len >= target
							const new = buffer.create(len)
							buffer.copy(new, 0, buf, 0, byte)
							buf = new
						end
						input -= sep
						local output = sep + 2155905152
						sep = input % 16384
						input -= sep
						output += sep * 2
						sep = input % 2097152
						input -= sep
						output += sep * 4
						sep = input % 268435456
						input -= sep
						output += sep * 8
						output += input * 16
						buffer.writeu32(buf, byte, output)
						byte += 4
						output /= 4294967296
						buffer.writeu8(buf, byte, output)
						return target, buf
					end
					const target = byte + 4
					if len < target then
						repeat
							len *= 2
						until len >= target
						const new = buffer.create(len)
						buffer.copy(new, 0, buf, 0, byte)
						buf = new
					end
					input -= sep
					local output = sep + 8421504
					sep = input % 16384
					input -= sep
					output += sep * 2
					sep = input % 2097152
					input -= sep
					output += sep * 4
					output += input * 8
					buffer.writeu32(buf, byte, output)
					return target, buf
				end
				const target = byte + 3
				if len < target then
					repeat
						len *= 2
					until len >= target
					const new = buffer.create(len)
					buffer.copy(new, 0, buf, 0, byte)
					buf = new
				end
				input -= sep
				local output = sep + 32896
				sep = input % 16384
				input -= sep
				output += sep * 2
				output += input * 4
				buffer.writeu16(buf, byte, output)
				byte += 2
				output /= 65536
				buffer.writeu8(buf, byte, output)
				return target, buf
			end
			const target = byte + 2
			if len < target then
				repeat
					len *= 2
				until len >= target
				const new = buffer.create(len)
				buffer.copy(new, 0, buf, 0, byte)
				buf = new
			end
			input -= sep
			local output = sep + 128
			output += input * 2
			buffer.writeu16(buf, byte, output)
			return target, buf
		end
		const target = byte + 1
		if len < target then
			repeat
				len *= 2
			until len >= target
			const new = buffer.create(len)
			buffer.copy(new, 0, buf, 0, byte)
			buf = new
		end
		buffer.writeu8(buf, byte, input)
		return target, buf
	end
	@native
	const function lux_read_vlq40(buf: buffer, byte: number): (number, number)
		-- 128 ^ 0
		local octet = buffer.readu8(buf, byte)
		byte += 1
		if octet < 128 then

			return byte, octet
		end
		-- 128 ^ 1
		local output = octet - 128
		octet = buffer.readu8(buf, byte)
		byte += 1
		if octet < 128 then
			octet *= 128
			return byte, output + octet
		end
		octet -= 128
		octet *= 128
		output += octet
		-- 128 ^ 2
		octet = buffer.readu8(buf, byte)
		byte += 1
		if octet < 128 then
			octet *= 16384
			return byte, output + octet
		end
		octet -= 128
		octet *= 16384
		output += octet
		-- 128 ^ 3
		octet = buffer.readu8(buf, byte)
		byte += 1
		if octet < 128 then
			octet *= 2097152
			return byte, output + octet
		end
		octet -= 128
		octet *= 2097152
		output += octet
		-- 128 ^ 4
		octet = buffer.readu8(buf, byte)
		byte += 1
		octet *= 268435456
		return byte, output + octet
	end
	@native
	const function lux_vlq40_sizeof(data: number): number
		if data < 128 then
			return 1
		elseif data < 16384 then
			return 2
		elseif data < 2097152 then
			return 3
		elseif data < 268435456 then
			return 4
		else
			return 5
		end
	end

	return {
		kind = "number";
		subkind = "vlq";
		representation = "40";

		bytes_static = false;
		bytes_lowerbound = 1;
		bytes_upperbound = 5;
		bytes_sizeof = lux_vlq40_sizeof;

		des = lux_read_vlq40;
		ser = lux_write_vlq40;
		ser_resize = lux_write_vlq40_resize;
	}
end
function module.vlq48(): runtime_types.TNumberVLQ
	@native
	const function lux_write_vlq48(buf: buffer, byte: number, input: number): number
		if input >= 128 then
			local sep = input % 128
			if input >= 16384 then
				if input >= 2097152 then
					if input >= 268435456 then
						if input >= 34359738368 then
							input -= sep
							local output = sep + 551911719040
							sep = input % 16384
							input -= sep
							output += sep * 2
							sep = input % 2097152
							input -= sep
							output += sep * 4
							sep = input % 268435456
							input -= sep
							output += sep * 8
							sep = input % 34359738368
							input -= sep
							output += sep * 16
							output += input * 32
							buffer.writeu32(buf, byte, output)
							byte += 4
							output /= 4294967296
							buffer.writeu16(buf, byte, output)
							return byte + 2
						end
						input -= sep
						local output = sep + 2155905152
						sep = input % 16384
						input -= sep
						output += sep * 2
						sep = input % 2097152
						input -= sep
						output += sep * 4
						sep = input % 268435456
						input -= sep
						output += sep * 8
						output += input * 16
						buffer.writeu32(buf, byte, output)
						byte += 4
						output /= 4294967296
						buffer.writeu8(buf, byte, output)
						return byte + 1
					end
					input -= sep
					local output = sep + 8421504
					sep = input % 16384
					input -= sep
					output += sep * 2
					sep = input % 2097152
					input -= sep
					output += sep * 4
					output += input * 8
					buffer.writeu32(buf, byte, output)
					return byte + 4
				end
				input -= sep
				local output = sep + 32896
				sep = input % 16384
				input -= sep
				output += sep * 2
				output += input * 4
				buffer.writeu16(buf, byte, output)
				byte += 2
				output /= 65536
				buffer.writeu8(buf, byte, output)
				return byte + 1
			end
			input -= sep
			local output = sep + 128
			output += input * 2
			buffer.writeu16(buf, byte, output)
			return byte + 2
		end
		buffer.writeu8(buf, byte, input)
		return byte + 1
	end
	@native
	const function lux_write_vlq48_resize(buf: buffer, byte: number, input: number): (number, buffer)
		local len = buffer.len(buf)
		if input >= 128 then
			local sep = input % 128
			if input >= 16384 then
				if input >= 2097152 then
					if input >= 268435456 then
						if input >= 34359738368 then
							const target = byte + 6
							if len < target then
								repeat
									len *= 2
								until len >= target
								const new = buffer.create(len)
								buffer.copy(new, 0, buf, 0, byte)
								buf = new
							end
							input -= sep
							local output = sep + 551911719040
							sep = input % 16384
							input -= sep
							output += sep * 2
							sep = input % 2097152
							input -= sep
							output += sep * 4
							sep = input % 268435456
							input -= sep
							output += sep * 8
							sep = input % 34359738368
							input -= sep
							output += sep * 16
							output += input * 32
							buffer.writeu32(buf, byte, output)
							byte += 4
							output /= 4294967296
							buffer.writeu16(buf, byte, output)
							return target, buf
						end
						const target = byte + 5
						if len < target then
							repeat
								len *= 2
							until len >= target
							const new = buffer.create(len)
							buffer.copy(new, 0, buf, 0, byte)
							buf = new
						end
						input -= sep
						local output = sep + 2155905152
						sep = input % 16384
						input -= sep
						output += sep * 2
						sep = input % 2097152
						input -= sep
						output += sep * 4
						sep = input % 268435456
						input -= sep
						output += sep * 8
						output += input * 16
						buffer.writeu32(buf, byte, output)
						byte += 4
						output /= 4294967296
						buffer.writeu8(buf, byte, output)
						return target, buf
					end
					const target = byte + 4
					if len < target then
						repeat
							len *= 2
						until len >= target
						const new = buffer.create(len)
						buffer.copy(new, 0, buf, 0, byte)
						buf = new
					end
					input -= sep
					local output = sep + 8421504
					sep = input % 16384
					input -= sep
					output += sep * 2
					sep = input % 2097152
					input -= sep
					output += sep * 4
					output += input * 8
					buffer.writeu32(buf, byte, output)
					return target, buf
				end
				const target = byte + 3
				if len < target then
					repeat
						len *= 2
					until len >= target
					const new = buffer.create(len)
					buffer.copy(new, 0, buf, 0, byte)
					buf = new
				end
				input -= sep
				local output = sep + 32896
				sep = input % 16384
				input -= sep
				output += sep * 2
				output += input * 4
				buffer.writeu16(buf, byte, output)
				byte += 2
				output /= 65536
				buffer.writeu8(buf, byte, output)
				return target, buf
			end
			const target = byte + 2
			if len < target then
				repeat
					len *= 2
				until len >= target
				const new = buffer.create(len)
				buffer.copy(new, 0, buf, 0, byte)
				buf = new
			end
			input -= sep
			local output = sep + 128
			output += input * 2
			buffer.writeu16(buf, byte, output)
			return target, buf
		end
		const target = byte + 1
		if len < target then
			repeat
				len *= 2
			until len >= target
			const new = buffer.create(len)
			buffer.copy(new, 0, buf, 0, byte)
			buf = new
		end
		buffer.writeu8(buf, byte, input)
		return target, buf
	end
	@native
	const function lux_read_vlq48(buf: buffer, byte: number): (number, number)
		-- 128 ^ 0
		local octet = buffer.readu8(buf, byte)
		byte += 1
		if octet < 128 then

			return byte, octet
		end
		-- 128 ^ 1
		local output = octet - 128
		octet = buffer.readu8(buf, byte)
		byte += 1
		if octet < 128 then
			octet *= 128
			return byte, output + octet
		end
		octet -= 128
		octet *= 128
		output += octet
		-- 128 ^ 2
		octet = buffer.readu8(buf, byte)
		byte += 1
		if octet < 128 then
			octet *= 16384
			return byte, output + octet
		end
		octet -= 128
		octet *= 16384
		output += octet
		-- 128 ^ 3
		octet = buffer.readu8(buf, byte)
		byte += 1
		if octet < 128 then
			octet *= 2097152
			return byte, output + octet
		end
		octet -= 128
		octet *= 2097152
		output += octet
		-- 128 ^ 4
		octet = buffer.readu8(buf, byte)
		byte += 1
		if octet < 128 then
			octet *= 268435456
			return byte, output + octet
		end
		octet -= 128
		octet *= 268435456
		output += octet
		-- 128 ^ 5
		octet = buffer.readu8(buf, byte)
		byte += 1
		octet *= 34359738368
		return byte, output + octet
	end
	@native
	const function lux_vlq48_sizeof(data: number): number
		if data < 128 then
			return 1
		elseif data < 16384 then
			return 2
		elseif data < 2097152 then
			return 3
		elseif data < 268435456 then
			return 4
		elseif data < 34359738368 then
			return 5
		else
			return 6
		end
	end

	return {
		kind = "number";
		subkind = "vlq";
		representation = "48";

		bytes_static = false;
		bytes_lowerbound = 1;
		bytes_upperbound = 6;
		bytes_sizeof = lux_vlq48_sizeof;

		des = lux_read_vlq48;
		ser = lux_write_vlq48;
		ser_resize = lux_write_vlq48_resize;
	}
end
function module.vlq56(): runtime_types.TNumberVLQ
	@native
	const function lux_write_vlq56(buf: buffer, byte: number, input: number): number
		if input >= 128 then
			local sep = input % 128
			if input >= 16384 then
				if input >= 2097152 then
					if input >= 268435456 then
						if input >= 34359738368 then
							if input >= 4398046511104 then
								input -= sep
								local output = sep + 2155905152
								sep = input % 16384
								input -= sep
								output += sep * 2
								sep = input % 2097152
								input -= sep
								output += sep * 4
								sep = input % 268435456
								output += sep * 8
								buffer.writeu32(buf, byte, output)
								byte += 4
								input //= 268435456
								output = 32896
								sep = input % 128
								output += sep
								input -= sep
								sep = input % 16384
								input -= sep
								output += sep * 2
								output += input * 4
								buffer.writeu16(buf, byte, output)
								byte += 2
								output /= 65536
								buffer.writeu8(buf, byte, output)
								return byte + 1
							end
							input -= sep
							local output = sep + 551911719040
							sep = input % 16384
							input -= sep
							output += sep * 2
							sep = input % 2097152
							input -= sep
							output += sep * 4
							sep = input % 268435456
							input -= sep
							output += sep * 8
							sep = input % 34359738368
							input -= sep
							output += sep * 16
							output += input * 32
							buffer.writeu32(buf, byte, output)
							byte += 4
							output /= 4294967296
							buffer.writeu16(buf, byte, output)
							return byte + 2
						end
						input -= sep
						local output = sep + 2155905152
						sep = input % 16384
						input -= sep
						output += sep * 2
						sep = input % 2097152
						input -= sep
						output += sep * 4
						sep = input % 268435456
						input -= sep
						output += sep * 8
						output += input * 16
						buffer.writeu32(buf, byte, output)
						byte += 4
						output /= 4294967296
						buffer.writeu8(buf, byte, output)
						return byte + 1
					end
					input -= sep
					local output = sep + 8421504
					sep = input % 16384
					input -= sep
					output += sep * 2
					sep = input % 2097152
					input -= sep
					output += sep * 4
					output += input * 8
					buffer.writeu32(buf, byte, output)
					return byte + 4
				end
				input -= sep
				local output = sep + 32896
				sep = input % 16384
				input -= sep
				output += sep * 2
				output += input * 4
				buffer.writeu16(buf, byte, output)
				byte += 2
				output /= 65536
				buffer.writeu8(buf, byte, output)
				return byte + 1
			end
			input -= sep
			local output = sep + 128
			output += input * 2
			buffer.writeu16(buf, byte, output)
			return byte + 2
		end
		buffer.writeu8(buf, byte, input)
		return byte + 1
	end
	@native
	const function lux_write_vlq56_resize(buf: buffer, byte: number, input: number): (number, buffer)
		local len = buffer.len(buf)
		if input >= 128 then
			local sep = input % 128
			if input >= 16384 then
				if input >= 2097152 then
					if input >= 268435456 then
						if input >= 34359738368 then
							if input >= 4398046511104 then
								const target = byte + 7
								if len < target then
									repeat
										len *= 2
									until len >= target
									const new = buffer.create(len)
									buffer.copy(new, 0, buf, 0, byte)
									buf = new
								end
								input -= sep
								local output = sep + 2155905152
								sep = input % 16384
								input -= sep
								output += sep * 2
								sep = input % 2097152
								input -= sep
								output += sep * 4
								sep = input % 268435456
								output += sep * 8
								buffer.writeu32(buf, byte, output)
								byte += 4
								input //= 268435456
								output = 32896
								sep = input % 128
								output += sep
								input -= sep
								sep = input % 16384
								input -= sep
								output += sep * 2
								output += input * 4
								buffer.writeu16(buf, byte, output)
								byte += 2
								output /= 65536
								buffer.writeu8(buf, byte, output)
								return target, buf
							end
							const target = byte + 6
							if len < target then
								repeat
									len *= 2
								until len >= target
								const new = buffer.create(len)
								buffer.copy(new, 0, buf, 0, byte)
								buf = new
							end
							input -= sep
							local output = sep + 551911719040
							sep = input % 16384
							input -= sep
							output += sep * 2
							sep = input % 2097152
							input -= sep
							output += sep * 4
							sep = input % 268435456
							input -= sep
							output += sep * 8
							sep = input % 34359738368
							input -= sep
							output += sep * 16
							output += input * 32
							buffer.writeu32(buf, byte, output)
							byte += 4
							output /= 4294967296
							buffer.writeu16(buf, byte, output)
							return target, buf
						end
						const target = byte + 5
						if len < target then
							repeat
								len *= 2
							until len >= target
							const new = buffer.create(len)
							buffer.copy(new, 0, buf, 0, byte)
							buf = new
						end
						input -= sep
						local output = sep + 2155905152
						sep = input % 16384
						input -= sep
						output += sep * 2
						sep = input % 2097152
						input -= sep
						output += sep * 4
						sep = input % 268435456
						input -= sep
						output += sep * 8
						output += input * 16
						buffer.writeu32(buf, byte, output)
						byte += 4
						output /= 4294967296
						buffer.writeu8(buf, byte, output)
						return target, buf
					end
					const target = byte + 4
					if len < target then
						repeat
							len *= 2
						until len >= target
						const new = buffer.create(len)
						buffer.copy(new, 0, buf, 0, byte)
						buf = new
					end
					input -= sep
					local output = sep + 8421504
					sep = input % 16384
					input -= sep
					output += sep * 2
					sep = input % 2097152
					input -= sep
					output += sep * 4
					output += input * 8
					buffer.writeu32(buf, byte, output)
					return target, buf
				end
				const target = byte + 3
				if len < target then
					repeat
						len *= 2
					until len >= target
					const new = buffer.create(len)
					buffer.copy(new, 0, buf, 0, byte)
					buf = new
				end
				input -= sep
				local output = sep + 32896
				sep = input % 16384
				input -= sep
				output += sep * 2
				output += input * 4
				buffer.writeu16(buf, byte, output)
				byte += 2
				output /= 65536
				buffer.writeu8(buf, byte, output)
				return target, buf
			end
			const target = byte + 2
			if len < target then
				repeat
					len *= 2
				until len >= target
				const new = buffer.create(len)
				buffer.copy(new, 0, buf, 0, byte)
				buf = new
			end
			input -= sep
			local output = sep + 128
			output += input * 2
			buffer.writeu16(buf, byte, output)
			return target, buf
		end
		const target = byte + 1
		if len < target then
			repeat
				len *= 2
			until len >= target
			const new = buffer.create(len)
			buffer.copy(new, 0, buf, 0, byte)
			buf = new
		end
		buffer.writeu8(buf, byte, input)
		return target, buf
	end
	@native
	const function lux_read_vlq56(buf: buffer, byte: number): (number, number)
		-- 128 ^ 0
		local octet = buffer.readu8(buf, byte)
		byte += 1
		if octet < 128 then

			return byte, octet
		end
		-- 128 ^ 1
		local output = octet - 128
		octet = buffer.readu8(buf, byte)
		byte += 1
		if octet < 128 then
			octet *= 128
			return byte, output + octet
		end
		octet -= 128
		octet *= 128
		output += octet
		-- 128 ^ 2
		octet = buffer.readu8(buf, byte)
		byte += 1
		if octet < 128 then
			octet *= 16384
			return byte, output + octet
		end
		octet -= 128
		octet *= 16384
		output += octet
		-- 128 ^ 3
		octet = buffer.readu8(buf, byte)
		byte += 1
		if octet < 128 then
			octet *= 2097152
			return byte, output + octet
		end
		octet -= 128
		octet *= 2097152
		output += octet
		-- 128 ^ 4
		octet = buffer.readu8(buf, byte)
		byte += 1
		if octet < 128 then
			octet *= 268435456
			return byte, output + octet
		end
		octet -= 128
		octet *= 268435456
		output += octet
		-- 128 ^ 5
		octet = buffer.readu8(buf, byte)
		byte += 1
		if octet < 128 then
			octet *= 34359738368
			return byte, output + octet
		end
		octet -= 128
		octet *= 34359738368
		output += octet
		-- 128 ^ 6
		octet = buffer.readu8(buf, byte)
		byte += 1
		octet *= 4398046511104
		return byte, output + octet
	end
	@native
	const function lux_vlq56_sizeof(data: number): number
		if data < 128 then
			return 1
		elseif data < 16384 then
			return 2
		elseif data < 2097152 then
			return 3
		elseif data < 268435456 then
			return 4
		elseif data < 34359738368 then
			return 5
		elseif data < 4398046511104 then
			return 6
		else
			return 7
		end
	end

	return {
		kind = "number";
		subkind = "vlq";
		representation = "56";

		bytes_static = false;
		bytes_lowerbound = 1;
		bytes_upperbound = 7;
		bytes_sizeof = lux_vlq56_sizeof;

		des = lux_read_vlq56;
		ser = lux_write_vlq56;
		ser_resize = lux_write_vlq56_resize;
	}
end
function module.vlq64(): runtime_types.TNumberVLQ
	@native
	const function lux_write_vlq64(buf: buffer, byte: number, input: number): number
		if input >= 128 then
			local sep = input % 128
			if input >= 16384 then
				if input >= 2097152 then
					if input >= 268435456 then
						if input >= 34359738368 then
							if input >= 4398046511104 then
								if input >= 562949953421312 then
									input -= sep
									local output = sep + 2155905152
									sep = input % 16384
									input -= sep
									output += sep * 2
									sep = input % 2097152
									input -= sep
									output += sep * 4
									sep = input % 268435456
									output += sep * 8
									buffer.writeu32(buf, byte, output)
									byte += 4
									input //= 268435456
									output = 8421504
									sep = input % 128
									input -= sep
									output += sep
									sep = input % 16384
									input -= sep
									output += sep * 2
									sep = input % 2097152
									input -= sep
									output += sep * 4
									sep = input % 268435456
									output += sep * 8
									buffer.writeu32(buf, byte, output)
									return byte + 4
								end
								input -= sep
								local output = sep + 2155905152
								sep = input % 16384
								input -= sep
								output += sep * 2
								sep = input % 2097152
								input -= sep
								output += sep * 4
								sep = input % 268435456
								output += sep * 8
								buffer.writeu32(buf, byte, output)
								byte += 4
								input //= 268435456
								output = 32896
								sep = input % 128
								output += sep
								input -= sep
								sep = input % 16384
								input -= sep
								output += sep * 2
								output += input * 4
								buffer.writeu16(buf, byte, output)
								byte += 2
								output /= 65536
								buffer.writeu8(buf, byte, output)
								return byte + 1
							end
							input -= sep
							local output = sep + 551911719040
							sep = input % 16384
							input -= sep
							output += sep * 2
							sep = input % 2097152
							input -= sep
							output += sep * 4
							sep = input % 268435456
							input -= sep
							output += sep * 8
							sep = input % 34359738368
							input -= sep
							output += sep * 16
							output += input * 32
							buffer.writeu32(buf, byte, output)
							byte += 4
							output /= 4294967296
							buffer.writeu16(buf, byte, output)
							return byte + 2
						end
						input -= sep
						local output = sep + 2155905152
						sep = input % 16384
						input -= sep
						output += sep * 2
						sep = input % 2097152
						input -= sep
						output += sep * 4
						sep = input % 268435456
						input -= sep
						output += sep * 8
						output += input * 16
						buffer.writeu32(buf, byte, output)
						byte += 4
						output /= 4294967296
						buffer.writeu8(buf, byte, output)
						return byte + 1
					end
					input -= sep
					local output = sep + 8421504
					sep = input % 16384
					input -= sep
					output += sep * 2
					sep = input % 2097152
					input -= sep
					output += sep * 4
					output += input * 8
					buffer.writeu32(buf, byte, output)
					return byte + 4
				end
				input -= sep
				local output = sep + 32896
				sep = input % 16384
				input -= sep
				output += sep * 2
				output += input * 4
				buffer.writeu16(buf, byte, output)
				byte += 2
				output /= 65536
				buffer.writeu8(buf, byte, output)
				return byte + 1
			end
			input -= sep
			local output = sep + 128
			output += input * 2
			buffer.writeu16(buf, byte, output)
			return byte + 2
		end
		buffer.writeu8(buf, byte, input)
		return byte + 1
	end
	@native
	const function lux_write_vlq64_resize(buf: buffer, byte: number, input: number): (number, buffer)
		local len = buffer.len(buf)
		if input >= 128 then
			local sep = input % 128
			if input >= 16384 then
				if input >= 2097152 then
					if input >= 268435456 then
						if input >= 34359738368 then
							if input >= 4398046511104 then
								if input >= 562949953421312 then
									const target = byte + 8
									if len < target then
										repeat
											len *= 2
										until len >= target
										const new = buffer.create(len)
										buffer.copy(new, 0, buf, 0, byte)
										buf = new
									end
									input -= sep
									local output = sep + 2155905152
									sep = input % 16384
									input -= sep
									output += sep * 2
									sep = input % 2097152
									input -= sep
									output += sep * 4
									sep = input % 268435456
									output += sep * 8
									buffer.writeu32(buf, byte, output)
									byte += 4
									input //= 268435456
									output = 8421504
									sep = input % 128
									input -= sep
									output += sep
									sep = input % 16384
									input -= sep
									output += sep * 2
									sep = input % 2097152
									input -= sep
									output += sep * 4
									sep = input % 268435456
									output += sep * 8
									buffer.writeu32(buf, byte, output)
									return target, buf
								end
								const target = byte + 7
								if len < target then
									repeat
										len *= 2
									until len >= target
									const new = buffer.create(len)
									buffer.copy(new, 0, buf, 0, byte)
									buf = new
								end
								input -= sep
								local output = sep + 2155905152
								sep = input % 16384
								input -= sep
								output += sep * 2
								sep = input % 2097152
								input -= sep
								output += sep * 4
								sep = input % 268435456
								output += sep * 8
								buffer.writeu32(buf, byte, output)
								byte += 4
								input //= 268435456
								output = 32896
								sep = input % 128
								output += sep
								input -= sep
								sep = input % 16384
								input -= sep
								output += sep * 2
								output += input * 4
								buffer.writeu16(buf, byte, output)
								byte += 2
								output /= 65536
								buffer.writeu8(buf, byte, output)
								return target, buf
							end
							const target = byte + 6
							if len < target then
								repeat
									len *= 2
								until len >= target
								const new = buffer.create(len)
								buffer.copy(new, 0, buf, 0, byte)
								buf = new
							end
							input -= sep
							local output = sep + 551911719040
							sep = input % 16384
							input -= sep
							output += sep * 2
							sep = input % 2097152
							input -= sep
							output += sep * 4
							sep = input % 268435456
							input -= sep
							output += sep * 8
							sep = input % 34359738368
							input -= sep
							output += sep * 16
							output += input * 32
							buffer.writeu32(buf, byte, output)
							byte += 4
							output /= 4294967296
							buffer.writeu16(buf, byte, output)
							return target, buf
						end
						const target = byte + 5
						if len < target then
							repeat
								len *= 2
							until len >= target
							const new = buffer.create(len)
							buffer.copy(new, 0, buf, 0, byte)
							buf = new
						end
						input -= sep
						local output = sep + 2155905152
						sep = input % 16384
						input -= sep
						output += sep * 2
						sep = input % 2097152
						input -= sep
						output += sep * 4
						sep = input % 268435456
						input -= sep
						output += sep * 8
						output += input * 16
						buffer.writeu32(buf, byte, output)
						byte += 4
						output /= 4294967296
						buffer.writeu8(buf, byte, output)
						return target, buf
					end
					const target = byte + 4
					if len < target then
						repeat
							len *= 2
						until len >= target
						const new = buffer.create(len)
						buffer.copy(new, 0, buf, 0, byte)
						buf = new
					end
					input -= sep
					local output = sep + 8421504
					sep = input % 16384
					input -= sep
					output += sep * 2
					sep = input % 2097152
					input -= sep
					output += sep * 4
					output += input * 8
					buffer.writeu32(buf, byte, output)
					return target, buf
				end
				const target = byte + 3
				if len < target then
					repeat
						len *= 2
					until len >= target
					const new = buffer.create(len)
					buffer.copy(new, 0, buf, 0, byte)
					buf = new
				end
				input -= sep
				local output = sep + 32896
				sep = input % 16384
				input -= sep
				output += sep * 2
				output += input * 4
				buffer.writeu16(buf, byte, output)
				byte += 2
				output /= 65536
				buffer.writeu8(buf, byte, output)
				return target, buf
			end
			const target = byte + 2
			if len < target then
				repeat
					len *= 2
				until len >= target
				const new = buffer.create(len)
				buffer.copy(new, 0, buf, 0, byte)
				buf = new
			end
			input -= sep
			local output = sep + 128
			output += input * 2
			buffer.writeu16(buf, byte, output)
			return target, buf
		end
		const target = byte + 1
		if len < target then
			repeat
				len *= 2
			until len >= target
			const new = buffer.create(len)
			buffer.copy(new, 0, buf, 0, byte)
			buf = new
		end
		buffer.writeu8(buf, byte, input)
		return target, buf
	end
	@native
	const function lux_read_vlq64(buf: buffer, byte: number): (number, number)
		-- 128 ^ 0
		local octet = buffer.readu8(buf, byte)
		byte += 1
		if octet < 128 then

			return byte, octet
		end
		-- 128 ^ 1
		local output = octet - 128
		octet = buffer.readu8(buf, byte)
		byte += 1
		if octet < 128 then
			octet *= 128
			return byte, output + octet
		end
		octet -= 128
		octet *= 128
		output += octet
		-- 128 ^ 2
		octet = buffer.readu8(buf, byte)
		byte += 1
		if octet < 128 then
			octet *= 16384
			return byte, output + octet
		end
		octet -= 128
		octet *= 16384
		output += octet
		-- 128 ^ 3
		octet = buffer.readu8(buf, byte)
		byte += 1
		if octet < 128 then
			octet *= 2097152
			return byte, output + octet
		end
		octet -= 128
		octet *= 2097152
		output += octet
		-- 128 ^ 4
		octet = buffer.readu8(buf, byte)
		byte += 1
		if octet < 128 then
			octet *= 268435456
			return byte, output + octet
		end
		octet -= 128
		octet *= 268435456
		output += octet
		-- 128 ^ 5
		octet = buffer.readu8(buf, byte)
		byte += 1
		if octet < 128 then
			octet *= 34359738368
			return byte, output + octet
		end
		octet -= 128
		octet *= 34359738368
		output += octet
		-- 128 ^ 6
		octet = buffer.readu8(buf, byte)
		byte += 1
		if octet < 128 then
			octet *= 4398046511104
			return byte, output + octet
		end
		octet -= 128
		octet *= 4398046511104
		output += octet
		-- 128 ^ 7
		octet = buffer.readu8(buf, byte)
		byte += 1
		octet *= 562949953421312
		return byte, output + octet
	end
	@native
	const function lux_vlq64_sizeof(data: number): number
		if data < 128 then
			return 1
		elseif data < 16384 then
			return 2
		elseif data < 2097152 then
			return 3
		elseif data < 268435456 then
			return 4
		elseif data < 34359738368 then
			return 5
		elseif data < 4398046511104 then
			return 6
		elseif data < 562949953421312 then
			return 7
		else
			return 8
		end
	end

	return {
		kind = "number";
		subkind = "vlq";
		representation = "64";

		bytes_static = false;
		bytes_lowerbound = 1;
		bytes_upperbound = 8;
		bytes_sizeof = lux_vlq64_sizeof;

		des = lux_read_vlq64;
		ser = lux_write_vlq64;
		ser_resize = lux_write_vlq64_resize;
	}
end

return table.freeze(module)
