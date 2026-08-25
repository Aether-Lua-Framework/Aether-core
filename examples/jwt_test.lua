local kernel = require("aether.kernel")
local crypto = require("aether.dlc.crypto")
local jwt = require("aether.dlc.jwt")

-- crypto를 먼저! (jwt가 crypto를 requires하니 순서 중요)
local app = kernel.build({ crypto, jwt })

local secret = "my-secret-key"

-- 토큰 만들기
local token = app.jwt.sign({ sub = "user123", exp = os.time() + 3600 }, secret)
print("token:", token)

-- 검증 (정상)
local payload, err = app.jwt.verify(token, secret)
print("verified sub:", payload and payload.sub or ("FAIL: " .. err))

-- 위조 검증 (틀린 secret)
local bad, badErr = app.jwt.verify(token, "wrong-secret")
print("forged rejected:", bad == nil, "-", badErr)

-- jwt만 조립 (crypto 없이) → kernel이 거부해야
local ok, buildErr = pcall(function() return kernel.build({ jwt }) end)
print("jwt without crypto fails:", not ok)