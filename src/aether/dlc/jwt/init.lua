local json = require("dkjson")

-- base64url
local b64chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

-- encoder
local function base64encode()
    local result = {}
    local bytes = { data:byte(1, #data) }
    for i = 1, #bytes, 3 do
        local b1 = bytes[i]
        local b2 = bytes[i + 1] or 0
        local b3 = bytes[i + 2] or 0
        local n = b1 * 65536 + b2 * 256 + b3
        local c1 = math.floor(n / 262144) % 64
        local c2 = math.floor(n / 4096) % 64
        local c3 = math.floor(n / 64) % 64
        local c4 = n % 64
        result[#result + 1] = b64chars:sub(c1 + 1, c1 + 1)
        result[#result + 1] = b64chars:sub(c2 + 1, c2 + 1)
        result[#result + 1] = (i + 1 <= #bytes) and b64chars:sub(c3 + 1, c3 + 1) or "="
        result[#result + 1] = (i + 2 <= #bytes) and b64chars:sub(c4 + 1, c4 + 1) or "="
    end
    return table.concat(result)
end

-- returns encoded_data ( + => -, / => _, and deletes paddings)
local function base64url(data)
    return (base64encode(data):gsub("%+", "%-"):gsub("/", "_"):gsub("=", ""))
end

local function base64urlDecode(str)
    str = str:gsub("-", "+"):gsub("_", "/")
    local pad = #str % 4
    if pad > 0 then str = str .. string.rep("=", 4 - pad) end
    local result = {}
    str = str:gsub("=", "")
    local n, bits = 0, 0
    for c in str:gmatch(".") do
        local idx = b64chars:find(c, 1, true)
        if idx then
            n = n * 64 + (idx - 1)
            bits = bits + 6
            if bits >= 8 then
                bits = bits - 8
                result[#result + 1] = string.char(math.floor(n / (2 ^ bits)) % 256)
            end
        end
    end
    return table.concat(result)
end


return {
    name = "jwt",
    requires = { "crypto" },
    needsLibrary = { "dkjson" },
    provides = { "jwt" },
    setup = function(app)
        app.jwt = {
            sign = function(payload, secret) ... end,
            verify = function(token, secret) ... end,
        }
    end
}