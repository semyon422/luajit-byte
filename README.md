# luajit-byte
Binary data module
```lua
local byte = require("byte")

-- Byte buffer example, check source code for more info
local b = byte.buffer(2e9) -- allocate 2GB
b:resize(4e9) -- reallocate to 4GB
ffi.fill(b.pointer, b.size, 0) -- fill with zeros

print(b:fill("Hello, "):fill("World!"):seek(0):string(13)) -- Hello, World!

b:free() -- optional, the garbage collector can handle this correctly

-- nan boxing example
local b = byte.buffer(8)
b:double_be(0 / 0):seek(4):fill("love")

local nanbox = b:seek(0):double_be()
assert(nanbox ~= nanbox) -- nan

assert(b:seek(0):double_be(nanbox):seek(4):string(4) == "love")
```
