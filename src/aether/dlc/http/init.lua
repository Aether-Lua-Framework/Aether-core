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
                local requestLine, err = conn:read("*l")
                if not requestLine then
                    conn:close()
                    return
                end

                local method, path = requestLine:match("^(%S+)%s+(%S+)")
                if not method then
                    conn:write("HTTP/1.1 400 Bad Request\r\n\r\n")
                    conn:close()
                    return
                end

                -- throw away other headers
                
            end)
        end
    end
}