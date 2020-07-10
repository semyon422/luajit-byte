# luajit-byte
Binary data module
```lua
-- Byte buffer example
local byte = require("byte")

local b = byte.buffer(4e9) -- allocate 4GB
ffi.fill(b.pointer, b.size, 0) -- fill with zeros

b:fill("Hello, ") -- the initial position is 0
b:fill("World!")

b:seek(0)
print(b:string(13)) -- Hello, World!

b:seek(b.size - 7)
b:fill("LuaJIT!") -- write at the end of buffer

b:seek(0)
local temp = b:string(7)
b:seek(b.size - 7)
print(temp .. b:string(7)) -- Hello, LuaJIT!

b:free() -- optional, the garbage collector can handle this correctly

-- type casting example
print(byte.int32_to_string_be(0x52494646)) -- RIFF
```
