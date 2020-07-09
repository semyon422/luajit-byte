local bit = require('bit')
local ffi = require('ffi')

--------------------------------------------------------------------------------

local string_to_uint8 = function(s)
	assert(#s == 1)
	return s:byte()
end

local string_to_int8 = function(s)
	local n = string_to_uint8(s)
	return n < 0x80 and n or -0x100 + n
end

local string_to_uint16_le = function(s)
	assert(#s == 2)
	local a, b = s:byte(1, -1)
	return bit.lshift(b, 8) + a
end

local string_to_uint16_be = function(s)
	assert(#s == 2)
	local a, b = s:byte(1, -1)
	return bit.lshift(a, 8) + b
end

local string_to_int16_le = function(s)
	local n = string_to_uint16_le(s)
	return n < 0x8000 and n or -0x10000 + n
end

local string_to_int16_be = function(s)
	local n = string_to_uint16_be(s)
	return n < 0x8000 and n or -0x10000 + n
end

local string_to_int32_le = function(s)
	assert(#s == 4)
	local a, b, c, d = s:byte(1, -1)
	return
		  bit.lshift(d, 24)
		+ bit.lshift(c, 16)
		+ bit.lshift(b, 8)
		+            a
end

local string_to_int32_be = function(s)
	local a, b, c, d = s:byte(1, -1)
	return
		  bit.lshift(a, 24)
		+ bit.lshift(b, 16)
		+ bit.lshift(c, 8)
		+            d
end

local string_to_uint32_le = function(s)
	return ffi.cast("uint32_t", string_to_int32_le(s))
end

local string_to_uint32_be = function(s)
	return ffi.cast("uint32_t", string_to_int32_be(s))
end

--------------------------------------------------------------------------------

local int32_to_float = function(n)
	local sign = bit.rshift(n, 31) == 1 and -1 or 1
	local exponent = bit.band(bit.rshift(n, 23), 0xFF)
	local mantissa = exponent ~= 0 and bit.bor(bit.band(n, 0x7FFFFF), 0x800000) or bit.lshift(bit.band(n, 0x7FFFFF), 1)

	return sign * (mantissa * 2 ^ -23) * (2 ^ (exponent - 127))
end

local string_to_float_le = function(s)
	return int32_to_float(string_to_int32_le(s))
end

local string_to_float_be = function(s)
	return int32_to_float(string_to_int32_be(s))
end

--------------------------------------------------------------------------------

local int8_to_string = function(n)
	return string.char(bit.band(n, 0x000000ff))
end

local int16_to_string_le = function(n)
	return string.char(
		           bit.band(n, 0x000000ff),
		bit.rshift(bit.band(n, 0x0000ff00), 8)
	)
end

local int16_to_string_be = function(n)
	return string.char(
		bit.rshift(bit.band(n, 0x0000ff00), 8),
		           bit.band(n, 0x000000ff)
	)
end

local int32_to_string_le = function(n)
	return string.char(
		           bit.band(n, 0x000000ff),
		bit.rshift(bit.band(n, 0x0000ff00), 8),
		bit.rshift(bit.band(n, 0x00ff0000), 16),
		bit.rshift(bit.band(n, 0xff000000), 24)
	)
end

local int32_to_string_be = function(n)
	return string.char(
		bit.rshift(bit.band(n, 0xff000000), 24),
		bit.rshift(bit.band(n, 0x00ff0000), 16),
		bit.rshift(bit.band(n, 0x0000ff00), 8),
		           bit.band(n, 0x000000ff)
	)
end

--------------------------------------------------------------------------------

local byte = {}

byte.string_to_uint8 = string_to_uint8
byte.string_to_int8 = string_to_int8
byte.string_to_uint16_le = string_to_uint16_le
byte.string_to_uint16_be = string_to_uint16_be
byte.string_to_int16_le = string_to_int16_le
byte.string_to_int16_be = string_to_int16_be
byte.string_to_uint32_le = string_to_uint32_le
byte.string_to_uint32_be = string_to_uint32_be
byte.string_to_int32_le = string_to_int32_le
byte.string_to_int32_be = string_to_int32_be

byte.int32_to_float = int32_to_float
byte.string_to_float_le = string_to_float_le
byte.string_to_float_be = string_to_float_be

byte.int8_to_string = int8_to_string
byte.int16_to_string_le = int16_to_string_le
byte.int16_to_string_be = int16_to_string_be
byte.int32_to_string_le = int32_to_string_le
byte.int32_to_string_be = int32_to_string_be

--------------------------------------------------------------------------------

local free = function(self)
	if self.size ~= 0 then
		ffi.C.free(self.pointer)
		self.size = 0
		return true
	end
	return false
end

local fill = function(self, s, offset)
	ffi.copy(self.pointer + (offset or 0), s)
end

local seek = function(self, offset)
	self.offset = offset
end

local read_string = function(self, length)
	local s = ffi.string(self.pointer + self.offset, length)
	seek(self, self.offset + length)
	return s
end

local read_uint8 = function(self)
	return string_to_uint8(read_string(self, 1))
end

local read_int8 = function(self)
	return string_to_int8(read_string(self, 1))
end

local read_uint16_le = function(self)
	return string_to_uint16_le(read_string(self, 2))
end

local read_uint16_be = function(self)
	return string_to_uint16_be(read_string(self, 2))
end

local read_int16_le = function(self)
	return string_to_int16_le(read_string(self, 2))
end

local read_int16_be = function(self)
	return string_to_int16_be(read_string(self, 2))
end

local read_uint32_le = function(self)
	return string_to_uint32_le(read_string(self, 4))
end

local read_uint32_be = function(self)
	return string_to_uint32_be(read_string(self, 4))
end

local read_int32_le = function(self)
	return string_to_int32_le(read_string(self, 4))
end

local read_int32_be = function(self)
	return string_to_int32_be(read_string(self, 4))
end

local read_float_le = function(self)
	return int32_to_float(string_to_uint32_le(read_string(self, 4)))
end

local read_float_be = function(self)
	return int32_to_float(string_to_uint32_be(read_string(self, 4)))
end

local buffer = {}

buffer.free = free
buffer.fill = fill
buffer.seek = seek
buffer.read_string = read_string
buffer.read_uint8 = read_uint8
buffer.read_int8 = read_int8
buffer.read_uint16_le = read_uint16_le
buffer.read_uint16_be = read_uint16_be
buffer.read_int16_le = read_int16_le
buffer.read_int16_be = read_int16_be
buffer.read_uint32_le = read_uint32_le
buffer.read_uint32_be = read_uint32_be
buffer.read_int32_le = read_int32_le
buffer.read_int32_be = read_int32_be
buffer.read_float_le = read_float_le
buffer.read_float_be = read_float_be

--------------------------------------------------------------------------------

ffi.cdef("void* malloc(size_t size);")
ffi.cdef("void free(void* ptr);")

ffi.cdef("typedef struct {uint64_t size; uint64_t offset; unsigned char* pointer;} buffer_t;")

local mt = {}

mt.__index = function(_, key)
	return buffer[key]
end

local buffer_t = ffi.metatype(ffi.typeof("buffer_t"), mt)

local newbuffer = function(size)
	local pointer = ffi.C.malloc(size)
	assert(pointer ~= nil, "allocation error")
	local buffer = buffer_t(size, 0, pointer)
	ffi.gc(buffer, free)
	return buffer
end

byte.buffer = newbuffer

return byte
