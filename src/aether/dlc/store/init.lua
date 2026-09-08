local errors = require("aether.errors.error")

return {
    name = "store",
    requires = {},
    provides = { "store" },
    setup = function(app)
        local tables = {}

        local function tableInterface(data)
            return {
                set = function(_, key, value)
                    data[key] = value
                end,
                get = function(_, key)
                    return data[key]
                end,
                delete = function(_, key)
                    data[key] = nil
                end,
                all = function(_)
                    return data
                end,
            }
        end

        app.store = {
            create = function(_, name)
                if tables[name] then
                    error(errors.of("conflict",
                        "table '" .. name .. "' already exists"))
                end
                tables[name] = {}
                return tableInterface(tables[name])
            end,

            table = function(_, name)
                if not tables[name] then
                    error(errors.of("not_found",
                        "table '" .. name .. "' does not exist")
                        :with("hint", "create it first: app:store('create', '" .. name .. "')"))
                end
                return tableInterface(tables[name])
            end
        }
    end
}