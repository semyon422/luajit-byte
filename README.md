# luajit-byte
Binary data module
```lua
-- Byte buffer example
local byte = require("byte")

local size = 4e9 -- you can allocate more than 2GB without crash!
local b = byte.buffer(size)
ffi.fill(b.pointer, b.size, 0) -- optional, filled with zeros by default

b:fill("Hello, ", 0)
b:fill("World!", b.size - 6)

b:seek(0)
local temp = b:read_string(7)
b:seek(b.size - 6)
print(temp .. b:read_string(6)) -- Hello, World!

b:free() -- optional, the garbage collector can handle this correctly

-- type casting example
print(byte.int32_to_string_be(0x52494646)) -- RIFF
```
