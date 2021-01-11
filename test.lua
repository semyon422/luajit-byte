local ffi = require("ffi")
local bit = require("bit")

local byte = require("init")

do
	local sn1 = ffi.cast("int8_t", 0xf1)
	local sn2 = ffi.cast("int16_t", 0xf1f2)
	local sn3 = ffi.cast("int32_t", bit.tobit(0xf1f2f3f4))
	local sn4 = ffi.cast("int64_t", 0xf1f2f3f4f5f6f7f8ll)
	local un1 = ffi.cast("uint8_t", 0xf1)
	local un2 = ffi.cast("uint16_t", 0xf1f2)
	local un3 = ffi.cast("uint32_t", 0xf1f2f3f4)
	local un4 = ffi.cast("uint64_t", 0xf1f2f3f4f5f6f7f8ull)
	assert(sn1 == -0x100 + 0xf1)
	assert(sn2 == -0x10000 + 0xf1f2)
	assert(sn3 == -0x100000000 + 0xf1f2f3f4)

	local s1 = string.char(0xf1)
	local s2_be = string.char(0xf1, 0xf2)
	local s3_be = string.char(0xf1, 0xf2, 0xf3, 0xf4)
	local s4_be = string.char(0xf1, 0xf2, 0xf3, 0xf4, 0xf5, 0xf6, 0xf7, 0xf8)
	local s2_le = string.char(0xf2, 0xf1)
	local s3_le = string.char(0xf4, 0xf3, 0xf2, 0xf1)
	local s4_le = string.char(0xf8, 0xf7, 0xf6, 0xf5, 0xf4, 0xf3, 0xf2, 0xf1)

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

	assert(byte.string_to_uint64_le(s4_le) == un4)
	assert(byte.string_to_uint64_be(s4_be) == un4)
	assert(byte.string_to_int64_le(s4_le) == sn4)
	assert(byte.string_to_int64_be(s4_be) == sn4)
end

do
	local n1 = 0x3e200000
	local n2 = 0x3f800000
	local n3 = 0xc0000000

	local s1_be = string.char(0x3e, 0x20, 0x00, 0x00)
	local s2_be = string.char(0x3f, 0x80, 0x00, 0x00)
	local s3_be = string.char(0xc0, 0x00, 0x00, 0x00)
	local s1_le = string.char(0x00, 0x00, 0x20, 0x3e)
	local s2_le = string.char(0x00, 0x00, 0x80, 0x3f)
	local s3_le = string.char(0x00, 0x00, 0x00, 0xc0)

	assert(byte.uint32_to_float(n1) == 0.15625) -- 0011 1110 0010 0000 0000 0000 0000 0000
	assert(byte.uint32_to_float(n2) == 1)
	assert(byte.uint32_to_float(n3) == -2)

	assert(byte.string_to_float_le(s1_le) == 0.15625)
	assert(byte.string_to_float_le(s2_le) == 1)
	assert(byte.string_to_float_le(s3_le) == -2)

	assert(byte.string_to_float_be(s1_be) == 0.15625)
	assert(byte.string_to_float_be(s2_be) == 1)
	assert(byte.string_to_float_be(s3_be) == -2)

	assert(byte.float_to_uint32(0.15625) == n1)
	assert(byte.float_to_uint32(1) == n2)
	assert(byte.float_to_uint32(-2) == n3)

	assert(byte.float_to_string_le(0.15625) == s1_le)
	assert(byte.float_to_string_le(1) == s2_le)
	assert(byte.float_to_string_le(-2) == s3_le)

	assert(byte.float_to_string_be(0.15625) == s1_be)
	assert(byte.float_to_string_be(1) == s2_be)
	assert(byte.float_to_string_be(-2) == s3_be)

	assert(byte.int8_to_string(113) == "q")
	assert(byte.int16_to_string_le(0x4952) == "RI")
	assert(byte.int16_to_string_be(0x5249) == "RI")
	assert(byte.int32_to_string_le(0x46464952) == "RIFF")
	assert(byte.int32_to_string_be(0x52494646) == "RIFF")

	assert(byte.string_to_uint8(byte.int8_to_string(-1)) == 255)
	assert(byte.string_to_int8(byte.int8_to_string(-1)) == -1)

	assert(byte.string_to_uint16_le(byte.int16_to_string_le(-1)) == 65535)
	assert(byte.string_to_uint16_be(byte.int16_to_string_be(-1)) == 65535)
	assert(byte.string_to_int16_le(byte.int16_to_string_le(-1)) == -1)
	assert(byte.string_to_int16_be(byte.int16_to_string_be(-1)) == -1)

	assert(byte.string_to_uint32_le(byte.int32_to_string_le(-1)) == 4294967295)
	assert(byte.string_to_uint32_be(byte.int32_to_string_be(-1)) == 4294967295)
	assert(byte.string_to_int32_le(byte.int32_to_string_le(-1)) == -1)
	assert(byte.string_to_int32_be(byte.int32_to_string_be(-1)) == -1)

	assert(byte.string_to_uint64_le(byte.uint64_to_string_le(-1ull)) == -1ull)
	assert(byte.string_to_uint64_be(byte.uint64_to_string_be(-1ull)) == -1ull)
	assert(byte.string_to_int64_le(byte.int64_to_string_le(-1ll)) == -1ll)
	assert(byte.string_to_int64_be(byte.int64_to_string_be(-1ll)) == -1ll)

	assert(byte.string_to_double_le(byte.double_to_string_le(math.pi)) == math.pi)
	assert(byte.string_to_double_le(byte.double_to_string_le(0.2 + 0.1)) == 0.2 + 0.1)

	assert(byte.string_to_double_be(byte.double_to_string_be(math.pi)) == math.pi)
	assert(byte.string_to_double_be(byte.double_to_string_be(0.2 + 0.1)) == 0.2 + 0.1)

	local n4 = 0xc000000000000000ull
	local s4_be = string.char(0xc0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00)
	local s4_le = string.char(0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xc0)

	assert(byte.uint64_to_double(n4) == -2)
	assert(byte.string_to_double_le(s4_le) == -2)
	assert(byte.string_to_double_be(s4_be) == -2)
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

	local n = 0.123
	b:float_le(n)
	b:seek(0)
	assert(math.abs(b:float_le() - n) < 1e-6)

	b:free()
end

do
	local b = byte.buffer(4)

	local n = 777
	b:int16_be(n)
	b:seek(0)
	assert(b:int16_be() == n)

	b:free()
end

do
	local b = byte.buffer(8)

	local n = 0xfedcba9876543210ll
	b:int64_be(n)
	b:seek(0)
	assert(b:int64_be() == n)

	b:free()
end

do
	local b = byte.buffer(8)

	local n = math.pi
	b:double_le(n)
	b:seek(0)
	assert(b:double_le() == n)

	b:free()
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
	b:fill("aaaa")
	b:seek(0)
	b:fill("bb")
	b:seek(0)

	assert(b:string(4) == "bbaa")

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
	local size = 4
	local pointer
	do
		local b = byte.buffer(size)
		b:gc(false)
		b:fill("aaaa")
		pointer = b.pointer
	end
	collectgarbage("collect")
	do
		local b = byte.buffer_t(size, 0, pointer)
		b:gc(true)
		assert(b:string(size) == "aaaa")
		b:free()
	end
end

do
	local size = 4
	local address
	do
		local b = byte.buffer(size)
		b:gc(false)
		b:fill("aaaa")
		address = ffi.cast("size_t", b.pointer)
	end
	collectgarbage("collect")
	do
		local b = byte.buffer_t(size, 0, ffi.cast("void*", address))
		assert(b:string(size) == "aaaa")
		b:free()
	end
end

do
	local b = byte.buffer(4)
	assert(b:total() == 4)

	b:fill("aaaa")
	assert(b.offset == 4)
	assert(b.size == 4)

	b:resize(8)
	assert(b:total() == 8)
	assert(b.offset == 4)
	assert(b.size == 8)

	b:fill("bb")
	assert(b.offset == 6)
	assert(b.size == 8)

	b:resize(4)
	assert(b:total() == 4)
	assert(b.offset == 4)
	assert(b.size == 4)
end

do
	local nanbox
	do
		local b = byte.buffer(8)
		b:double_be(0 / 0)
		b:seek(4)
		b:fill("love")
		b:seek(0)

		nanbox = b:double_be()
		assert(nanbox ~= nanbox)

		b:free()
	end
	do
		local b = byte.buffer(8)
		b:double_be(nanbox)
		b:seek(4)

		assert(b:string(4) == "love")

		b:free()
	end
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
