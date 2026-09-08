local kernel = require("aether.kernel")
local tcp = require("aether.dlc.tcp")
local http = require("aether.dlc.http")
local store = require("aether.dlc.store")

local app = kernel.build({ http, tcp, store })

-- 테이블 미리 선언
app:store("create", "users")
app:store("create", "posts")

-- users에 저장
app:post("/users", function(req)
    local users = app:store("table", "users")
    local id = tostring(os.time())
    users:set(id, req.body)
    return "created user: " .. id
end)

-- users 전체
app:get("/users", function(req)
    local users = app:store("table", "users")
    local lines = {}
    for k, v in pairs(users:all()) do
        lines[#lines+1] = k .. " = " .. v
    end
    return table.concat(lines, "\n")
end)

-- posts (분리 확인용)
app:post("/posts", function(req)
    local posts = app:store("table", "posts")
    posts:set(tostring(os.time()), req.body)
    return "created post"
end)

app:get("/posts", function(req)
    local posts = app:store("table", "posts")
    local lines = {}
    for k, v in pairs(posts:all()) do
        lines[#lines+1] = k .. " = " .. v
    end
    return table.concat(lines, "\n")
end)

-- 오타 방어 확인용 (없는 테이블)
app:get("/broken", function(req)
    local x = app:store("table", "userss")   -- 오타
    return "should not reach"
end)

app:serveHttp("0.0.0.0", 8080)
app:run()