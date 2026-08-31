local socket = require("aether.runtime.socket")
local eventLoop = require("aether.runtime.eventLoop")

return {
    name = "tcp",
    requires = {},
    needsLibrary = {},
    provides = { "tcp" },
    setup = function(app)

        if not app._loop then
            app._loop = eventLoop.new()
        end

        app.listen = function(_, host, port)
            return socket.listen(host, port)
        end
    end
}