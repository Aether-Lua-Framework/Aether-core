local kernel = require("aether.kernel")
local crypto = require("aether.dlc.crypto")

local app = kernel.build({ crypto })

-- HMAC-SHA256 결과는 raw 바이트라 눈으로 못 봄. hex로 바꿔서 확인.
local function toHex(s)
    return (s:gsub(".", function(c)
        return string.format("%02x", string.byte(c))
    end))
end

local result = app.crypto.hmacSha256("mykey", "hello")
print("hmac:", toHex(result))