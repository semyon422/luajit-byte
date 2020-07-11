local ffi = require("ffi")
local bit = require("bit")

local byte = require("init")

do
	local sn1 = ffi.cast("int8_t", 0xf1)
	local sn2 = ffi.cast("int16_t", 0xf1f2)
	local sn3 = ffi.cast("int32_t", bit.tobit(0xf1f2f3f4))
	local un1 = ffi.cast("uint8_t", 0xf1)
	local un2 = ffi.cast("uint16_t", 0xf1f2)
	local un3 = ffi.cast("uint32_t", 0xf1f2f3f4)

	local s1 = string.char(0xf1)
	local s2_be = string.char(0xf1, 0xf2)
	local s3_be = string.char(0xf1, 0xf2, 0xf3, 0xf4)
	local s2_le = string.char(0xf2, 0xf1)
	local s3_le = string.char(0xf4, 0xf3, 0xf2, 0xf1)

	assert(byte.string_to_uint8(s1) == un1)
	assert(byte.string_to_int8(s1) == sn1)
	assert(byte.string_to_uint16_le(s2_le) == un2)
	assert(byte.string_to_uint16_be(s2_be) == un2)
	assert(byte.string_to_int16_le(s2_le) == sn2)
	assert(byte.string_to_int16_be(s2_be) == sn2)
	assert(byte.string_to_uint32_le(s3_le) == un3)
	assert(byte.string_to_uint32_be(s3_be) == un3)
	assert(byte.string_to_int32_le(s3_le) == sn3)
	assert(byte.string_to_int32_be(s3_be) == sn3)
end

do
	local n1 = 0x3e200000
	local n2 = 0x3f800000

	local s1_be = string.char(0x3e, 0x20, 0x00, 0x00)
	local s2_be = string.char(0x3f, 0x80, 0x00, 0x00)
	local s1_le = string.char(0x00, 0x00, 0x20, 0x3e)
	local s2_le = string.char(0x00, 0x00, 0x80, 0x3f)

	assert(byte.int32_to_float(n1) == 0.15625) -- 0011 1110 0010 0000 0000 0000 0000 0000
	assert(byte.int32_to_float(n2) == 1)

	assert(byte.string_to_float_le(s1_le) == 0.15625)
	assert(byte.string_to_float_le(s2_le) == 1)

	assert(byte.string_to_float_be(s1_be) == 0.15625)
	assert(byte.string_to_float_be(s2_be) == 1)

	assert(byte.int8_to_string(113) == "q")
	assert(byte.int16_to_string_le(0x4952) == "RI")
	assert(byte.int16_to_string_be(0x5249) == "RI")
	assert(byte.int32_to_string_le(0x46464952) == "RIFF")
	assert(byte.int32_to_string_be(0x52494646) == "RIFF")
end

do
	local b1 = byte.buffer(4)
	assert(b1:total() == 4)

	local b2 = byte.buffer(4)
	assert(b2:total() == 8)

	b1:free()
	b2:free()

	assert(b2:total() == 0)
end

do
	local b = byte.buffer(4)
	ffi.fill(b.pointer, b.size, 0)

	local s1 = b:string(4)
	assert(#s1 == 4)
	assert(s1 == string.char(0x00, 0x00, 0x00, 0x00))

	b:seek(0)

	local s2 = b:cstring(4)
	assert(#s2 == 0)
	assert(s2 == "")

	b:free()
end

do
	local b = byte.buffer(4)
	b:fill("a\0a\0")

	b:seek(0)
	local s1 = b:string(4)
	assert(#s1 == 4)
	assert(s1 == "a\0a\0")

	for i = 1, 4 do
		b:seek(0)
		local s2 = b:cstring(i)
		assert(#s2 == 1)
		assert(s2 == "a")
		assert(b.offset == i)
	end

	b:free()
end

do
	local size = 64e6
	local b = byte.buffer(size)
	assert(b.size == size)

	assert(b.offset == 0)
	b:fill("hello")
	assert(b.offset == 5)

	b:seek(b.size - 5)
	b:fill("world")
	assert(b.offset == b.size)

	b:seek(0)
	assert(b:string(5) == "hello")
	assert(b.offset == 5)

	b:seek(b.size - 5)
	assert(b:string(5) == "world")
	assert(b.offset == b.size)

	b:free()
end

print("OK!")
