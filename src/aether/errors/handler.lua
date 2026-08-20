local handler = {}





-- Default Sink
local function defaultSink(err)
    io.stderr:write(tostring(err), "\n")
end





local sinks = { defaultSink }

local usingDefault = true





function handler.register(sink)
    if usingDefault then
        sinks = {}
        usingDefault = false
    end

    sinks[#sinks + 1] = sink
    return sink
end





function handler.report(err)
    for i=1, #sinks do
        -- handler should not get down by itself
        pcall(sinks[i], error)
    end
end

return handler