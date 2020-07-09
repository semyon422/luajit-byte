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
	local size = 64e6
	local b = byte.buffer(size)
	assert(b.size == size)
	ffi.fill(b.pointer, b.size, 0)

	b:fill("hello", 0)
	b:fill("world", b.size - 10)

	b:seek(0)
	assert(b:read_string(5) == "hello")
	b:seek(b.size - 10)
	assert(b:read_string(5) == "world")

	assert(b:free())
	assert(b:free() == false)
end

print("OK!")
