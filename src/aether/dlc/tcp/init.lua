local socket = require("aether.runtime.socket")
local eventLoop = require("aether.runtime.eventLoop")
local errors = require("aether.errors.error")
local errorHandler = require("aether.errors.handler")

return {
    name = "tcp",
    requires = {},
    needsLibrary = {},
    provides = { "stream" },
    setup = function(app)

        if not app._loop then
            app._loop = eventLoop.new()
        end

        app.listen = function(_, host, port)
            return socket.listen(host, port)
        end

        app.serve = function(_, host, port, handler)
            app._loop:spawn(function()
                local server, err = socket.listen(host, port)
                if not server then
                    print("listen error: ", tostring(err))
                    return
                end
                
                print("Aether listening on " .. host .. ":" .. port)


                while true do
                    local conn, aerr = server:accept()
                    if conn then
                        -- new task spawn
                        app._loop:spawn(function()
                            local ok, err = pcall(handler, conn)
                            if not ok then
                                errorHandler.report(errors.wrap(err, "handler failed"))
                                pcall(function()
                                    conn:write("HTTP/1.1 500 Internal Server Error\r\n\r\n")
                                    conn:close()
                                end)
                            end
                        end)
                    else
                        print("accept error : " .. aerr)
                    end
                end
            end)
        end

        app.run = function()
            app._loop:run()
        end
    end,
}