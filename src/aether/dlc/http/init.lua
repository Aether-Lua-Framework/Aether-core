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

                local headers = {} -- make header buffer instead of throw 
                local contentLength = 0
                while true do
                    local line = conn:read("*l")
                    if not line or line == "" then break end

                    local key, value = line:match("^(.-):%s*(.*)$")
                    if key then
                        key = key:lower()
                        headers[key] = value
                        if key == "content-length" then
                            contentLength = tonumber(value) or 0
                        end
                    end
                end

                local body = ""
                if contentLength > 0 then
                    while #body < contentLength do
                        local chunk = conn:read(contentLength - #body)
                        if not chunk or chunk == "" then break end
                        body = body .. chunk
                    end
                end
                
                local req = {
                    method = method,
                    path = path,
                    headers = headers,
                    body = body,
                }

                local handler = routes[method .. " " .. path]

                if handler then
                    local resBody = handler(req)
                    resBody = resBody or ""
                    conn:write(
                        "HTTP/1.1 200 OK\r\n" ..
                        "Content-Length: " .. #resBody .. "\r\n" ..
                        "Content-Type: text/plain\r\n" ..
                        "\r\n" ..
                        resBody
                    )
                else
                    local resBody = "Not Found"
                    conn:write(
                        "HTTP/1.1 404 Not Found\r\n" ..
                        "Content-Length: " .. #resBody .. "\r\n" ..
                        "\r\n" ..
                        resBody
                    )
                end

                conn:close()
            end)
        end
    end
}