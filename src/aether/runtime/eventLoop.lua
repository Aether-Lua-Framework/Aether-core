local cqueues = require("cqueues")
local errors = require("aether.errors.error")
local handler = require("aether.errors.handler")

local eventLoop = {}
eventLoop.__index = eventLoop

function eventLoop.new()
    return setmetatable({
        cq = cqueues.new(),
        running = false,
    }, eventLoop)
end

function eventLoop:spawn(fn, ...)
    self.cq:wrap(fn, ...)
    return self
end

function eventLoop:run()
    if self.running then
        error(errors.of("invalid", "event loop is already running."))
    end
    self.running = true
    local ok, err = self.cq:loop()
    self.running = false
    if not ok then
        handler.report(errors.wrap(err, "event loop terminated with error"))
        -- print("  raw error:", err)
        -- print("  raw type:", type(err))
        return false, err
    end
    return true
end

return eventLoop

