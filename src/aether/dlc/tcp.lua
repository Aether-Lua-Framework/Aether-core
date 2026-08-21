local socket = require("aether.runtime.socket")

return {
    name = "tcp",
    requires = {},
    provides = { "stream" },

    setup = function(app)
        app.listen = function(_, host, port)
            return socket.listen(host, port)
        end
    end,
}