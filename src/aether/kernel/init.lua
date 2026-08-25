local errors = require("aether.errors.error")

errors.registerKind("composition")

local kernel = {}

local App = {}
App.__index = App

function kernel.build(dlcs)
    local app = setmetatable({}, App)

    -- isDLC?
    for i, dlc in ipairs(dlcs) do
        if type(dlc) ~= "table" then
            error(errors.of("composition",
                "item #" .. i .. " is not a valid DLC (expected a table, got " .. type(dlc) .. ")")
                :with("index", i)
                :with("info", "each item must be a DLC table with a 'name' field"))
        end
        if not dlc.name then
            error(errors.of("composition",
                "item #" .. i .. " is missing a 'name' field")
                :with("index", i)
                :with("info", "a DLC must declare its name, e.g. { name = 'tcp', ... }"))
        end
    end

    local provided = {}
    for _, dlc in ipairs(dlcs) do
        for _, cap in ipairs(dlc.provides or {}) do
            provided[cap] = dlc.name
        end
    end

    for _, dlc in ipairs(dlcs) do
        for _, need in ipairs(dlc.requires or {}) do
            if not provided[need] then
                error(errors.of("composition",
                "'" .. dlc.name .. "' needs a '" .. need .. "' provider, but none is loaded")
                :with("module", dlc.name)
                :with("missing", need)
                :with("info", "add a DLC that provides '" .. need .. "'"))
            end
        end
    end

    -- library verifying
    for _, dlc in ipairs(dlcs) do
        for _, lib in ipairs(dlc.needsLibrary or {}) do
            local ok = pcall(require, lib)
            if not ok then
                error(errors.of("composition",
                "'" .. dlc.name .. "' needs the Lua library '" .. lib .. "', but it is not installed")
                :with("module", dlc.name)
                :with("library", lib)
                :with("info", "install it with: luarocks install " .. lib))
            end
        end
    end

    for _, dlc in ipairs(dlcs) do
        if dlc.setup then
            dlc.setup(app)
        end
    end

    return app
end

return kernel