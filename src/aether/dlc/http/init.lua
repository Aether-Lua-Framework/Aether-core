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
                while true do
                    local line = conn:read("*l")
                    if not line or line == "" then break end
                end

                local handler = routes[method .. " " .. path]

                if handler then
                    local body = handler()
                    conn:write(
                        "HTTP/1.1 200 OK\r\n" ..
                        "Content-Length: " .. #body .. "\r\n" ..
                        "Content-Type: text/plain\r\n" ..
                        "\r\n" ..
                        body
                    )
                else
                    local body = "Not Found"
                    conn:write(
                        "HTTP/1.1 404 Not Found\r\n" ..
                        "Content-Length: " .. #body .. "\r\n" ..
                        "\r\n" ..
                        body
                    )
                end

                conn:close()
            end)
        end
    end
}