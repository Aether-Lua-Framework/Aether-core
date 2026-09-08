local kernel = require("aether.kernel")
local tcp = require("aether.dlc.tcp")
local http = require("aether.dlc.http")

-- 순서 상관없음 (위상 정렬). http를 먼저 넣어봐도 됨.
local app = kernel.build({ http, tcp })

app:get("/", function()
    return "Hello from Aether HTTP!"
end)

app:get("/ping", function()
    return "pong"
end)

app:post("/echo", function(req)
    return "You sent: " .. req.body
end)

app:get("/crash", function(req)
    return "x" .. nil   -- 일부러 nil concat 에러
end)

app:serveHttp("0.0.0.0", 8080)
app:run()