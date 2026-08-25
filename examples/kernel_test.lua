local kernel = require("aether.kernel")
local tcp    = require("aether.dlc.tcp")

-- tcp만 조립 (tcp는 requires 없으니 통과해야)
local app = kernel.build({ tcp })
print("build OK:", app ~= nil)
print("app has listen:", app.listen ~= nil)

-- 4단계: stream을 요구하는 가짜 http DLC (tcp 없이)
local fakeHttp = {
    name = "http",
    requires = { "stream" },
    provides = { "http" },
    setup = function() end,
}

local fakeLib = {
    name = "faketool",
    needsLibrary = { "this_does_not_exist" },
    provides = {},
    setup = function() end,
}

local ok, err = pcall(function() return kernel.build({ fakeLib }) end)
print("lib check should fail:", not ok)
print("error:", tostring(err))

print("---")

-- tcp(stream 제공자) 없이 http만 조립 → 거부돼야 함
local ok, err = pcall(function()
    return kernel.build({ fakeHttp })
end)

print("build should fail:", not ok)
print("error:", tostring(err))

print("---")

-- tcp를 넣으면 통과해야 함
local tcp = require("aether.dlc.tcp")
local app2 = kernel.build({ tcp, fakeHttp })
print("with tcp, build OK:", app2 ~= nil)