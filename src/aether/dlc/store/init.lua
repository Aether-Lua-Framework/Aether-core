local errors = require("aether.errors.error")

return {
    name = "store",
    requires = {},
    provides = { "store" },
    setup = function(app)
        local tables = {}

        local function tableInterface(table_)
            local nextId = 0

            return {
            insert = function(_, value)
                table_.nextId = table_.nextId + 1
                table_.data[table_.nextId] = value
                return table_.nextId
            end,
            set = function(_, key, value)
                table_.data[key] = value
            end,
            get = function(_, key)
                return table_.data[key]
            end,
            delete = function(_, key)
                table_.data[key] = nil
            end,
            all = function(_)
                return table_.data
            end,
        }
        end

        app.store = {
            create = function(_, name)
                if tables[name] then
                    error(errors.of("conflict",
                        "table '" .. name .. "' already exists"))
                end
                tables[name] = { data = {}, nextId = 0 }
                return tableInterface(tables[name])
            end,

            table = function(_, name)
                if not tables[name] then
                    error(errors.of("not_found",
                        "table '" .. name .. "' does not exist")
                        :with("hint", "create it first: app.store:create('" .. name .. "')"))
                end
                return tableInterface(tables[name])
            end
        }
    end
}