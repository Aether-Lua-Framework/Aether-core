local errorHandler = require("aether.errors.handler")

return {
    name = "logger",
    requires = {},
    provides = { "logger" },
    setup = function(app)
        local log_file = io.open("logs/error.log", "a")

        if not log_file then
            io.stderr:write(
                "[aether] logger: cannot open 'logs/error.log' — " ..
                "create the 'logs/' directory first (mkdir logs)\n"
            )
            return
        end

        errorHandler.register(function(err)
            if log_file then
                log_file:write(os.date("%Y-%m-%d %H:%M:%S") .. " " .. tostring(err) .. "\n")
                log_file:flush()
            end
        end)
    end,
}