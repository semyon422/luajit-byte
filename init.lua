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
	assert(#s == 4)
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
	assert(self.size ~= 0, "buffer was already freed")
	ffi.C.free(self.pointer)
	self.size = 0
	ffi.gc(self, nil)
end

local seek = function(self, offset)
	offset = ffi.cast("uint64_t", offset)
	assert(offset <= self.size, "attempt to perform seek outside buffer bounds")
	self.offset = offset
	return self
end

local fill = function(self, s)
	local length = #s
	local offset = self.offset
	assert(offset + length <= self.size, "attempt to write outside buffer bounds")
	seek(self, offset + length)
	ffi.copy(self.pointer + offset, s)
	return self
end

local read = function(self, length)
	local size = self.size
	local offset = self.offset
	assert(size ~= 0, "buffer was already freed")
	assert(length >= 0, "length cannot be less than zero")
	assert(offset + length <= size, "attempt to read after end of buffer")
	seek(self, offset + length)
	return self.pointer + offset
end

local _string = function(self, length)
	return ffi.string(read(self, length), length)
end

local _cstring = function(self, length)
	return ffi.string(read(self, length))
end

local uint8 = function(self)
	return string_to_uint8(_string(self, 1))
end

local int8 = function(self)
	return string_to_int8(_string(self, 1))
end

local uint16_le = function(self)
	return string_to_uint16_le(_string(self, 2))
end

local uint16_be = function(self)
	return string_to_uint16_be(_string(self, 2))
end

local int16_le = function(self)
	return string_to_int16_le(_string(self, 2))
end

local int16_be = function(self)
	return string_to_int16_be(_string(self, 2))
end

local uint32_le = function(self)
	return string_to_uint32_le(_string(self, 4))
end

local uint32_be = function(self)
	return string_to_uint32_be(_string(self, 4))
end

local int32_le = function(self)
	return string_to_int32_le(_string(self, 4))
end

local int32_be = function(self)
	return string_to_int32_be(_string(self, 4))
end

local float_le = function(self)
	return int32_to_float(string_to_uint32_le(_string(self, 4)))
end

local float_be = function(self)
	return int32_to_float(string_to_uint32_be(_string(self, 4)))
end

local buffer = {}

buffer.free = free
buffer.fill = fill
buffer.seek = seek
buffer.string = _string
buffer.cstring = _cstring
buffer.uint8 = uint8
buffer.int8 = int8
buffer.uint16_le = uint16_le
buffer.uint16_be = uint16_be
buffer.int16_le = int16_le
buffer.int16_be = int16_be
buffer.uint32_le = uint32_le
buffer.uint32_be = uint32_be
buffer.int32_le = int32_le
buffer.int32_be = int32_be
buffer.float_le = float_le
buffer.float_be = float_be

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
	assert(size > 0, "buffer size must be greater than zero")
	local pointer = ffi.C.malloc(size)
	assert(pointer ~= nil, "allocation error")
	local buffer = buffer_t(size, 0, pointer)
	ffi.gc(buffer, free)
	return buffer
end

byte.buffer = newbuffer

return byte
