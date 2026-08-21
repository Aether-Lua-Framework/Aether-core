local hmac = require("openssl.hmac")

return {
    name = "crypto",
    requires = "",
    provides = { "crypto" },

    setup = function(app)
        app.crypto = {
            -- sign with HAMC SHA256
            hmacSha256 = function(k, msg)
                local h = hmac.new(k, "sha256")
                h:update(msg)
                return h:final()
            end,
        }
    end,
}