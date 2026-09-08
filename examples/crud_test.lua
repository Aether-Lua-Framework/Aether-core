local kernel = require("aether.kernel")
local tcp = require("aether.dlc.tcp")
local http = require("aether.dlc.http")
local store = require("aether.dlc.store")

local app = kernel.build({ http, tcp, store })

app.store:create("users")
app.store:create("posts")

app:post("/users", function(req)
    local users = app.store:table("users")     -- 고침
    local id = users:insert(req.body)
    return "created user: " .. id
end)

app:get("/users", function(req)
    local users = app.store:table("users")     -- 고침
    local lines = {}
    for k, v in pairs(users:all()) do
        lines[#lines+1] = k .. " = " .. v
    end
    return table.concat(lines, "\n")
end)

app:post("/posts", function(req)
    local posts = app.store:table("posts")     -- 고침
    local id = posts:insert(req.body)
    return "created post" .. id
end)

app:get("/posts", function(req)
    local posts = app.store:table("posts")     -- 고침
    local lines = {}
    for k, v in pairs(posts:all()) do
        lines[#lines+1] = k .. " = " .. v
    end
    return table.concat(lines, "\n")
end)

app:get("/broken", function(req)
    local x = app.store:table("userss")        -- 고침
    return "should not reach"
end)

app:serveHttp("0.0.0.0", 8080)
app:run()