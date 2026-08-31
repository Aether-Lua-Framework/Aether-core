local kernel = require("aether.kernel")
local tcp = require("aether.dlc.tcp")

local app = kernel.build({ tcp })

app:serve("0.0.0.0", 8080, function(conn)
    conn:write("hello from aether\n")
    conn:close()
end)

app:run()