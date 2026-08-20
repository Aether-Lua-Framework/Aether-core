local csocket = require("cqueues.socket")
local errors = require("aether.errors.error")

local socket = {}

-- Connection Wrapper
local Conn = {}
Conn.__index = Conn

-- raw : cqueues socket instance
local function wrapConn(raw)
    return setmetatable({ raw = raw }, Conn)
end

function Conn:read(fmt)
    local data, err = self.raw:read(fmt or "*l")
    if err then
        return nil, errors.wrap(err, "socket read failed")
    end
    return data
end

-- write. if cqueues buffer is full, it yields automatically
function Conn:write(data)
    local ok, err = self.raw:write(data)
    if err then
        return nil, errors.wrap(err, "socket write failed")
    end
    return true
end

function Conn:close()
    self.raw:close()
end