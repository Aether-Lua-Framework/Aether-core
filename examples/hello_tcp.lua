local event_loop = require("aether.runtime.eventLoop")
local socket     = require("aether.runtime.socket")

local PORT = 8080
local loop = event_loop.new()

-- task that running on accept 
loop:spawn(function()
    local server, err = socket.listen("0.0.0.0", PORT)
    if err then
        print("listen error:", tostring(err))
        return
    end
    print("Aether listening on port " .. PORT)

    while true do
        local conn, aerr = server:accept()   -- 연결 올 때까지 자동 yield
        if conn then
            -- 각 연결을 처리할 task를 새로 얹는다.
            -- 한 연결 처리 중에도 다음 연결을 받을 수 있다 (동시성).
            loop:spawn(function()
                conn:write("hello from aether\n")
                conn:close()
            end)
        else
            print("accept error:", tostring(aerr))
        end
    end
end)

loop:run()