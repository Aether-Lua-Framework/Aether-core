return {
    name = "crypto",
    requires = "",
    needsLibrary = { "openssl.hmac" },
    provides = { "crypto" },
    setup = function(app)
        local hmac = require("openssl.hmac")
        app.crypto = {
            -- sign with HMAC SHA256
            hmacSha256 = function(k, msg)
                local h = hmac.new(k, "sha256")
                h:update(msg)
                return h:final()
            end,
        }
    end,
}