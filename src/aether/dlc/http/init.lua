return {
    name = "http",
    requires = { "stream" },
    provides = { "http" },
    setup = function(app)
        local routes = {} -- <- buffer!

        app.get = function(_, path, handler)
            routes["GET " .. path] = handler
        end
        app.post = function(_, path, handler)
            routes["POST " .. path] = handler
        end

        app.serveHttp = function(_, host, port)
            app:serve(host, port, function(conn)
                -- read first request line

            end)
        end
    end
}