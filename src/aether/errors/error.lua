local errors = {}

local clock = (os and os.time) or function() return 0 end
function errors.setClock(fn)
    clock = fn
    return fn
end


local MAX_CAUSE_DEPTH = 32 -- can change

errors.Kind = {
    unknown      = "unknown",
    invalid      = "invalid",
    not_found    = "not_found",
    conflict     = "conflict",
    unauthorized = "unauthorized",
    forbidden    = "forbidden",
    timeout      = "timeout",
    internal     = "internal",
}

-- Error MT
local Error = {}
local Error_mt = {
    __index = Error,
    __name = "Error",
    __tostring = function(self)
        return errors.format(self)
    end
}

function errors.isError(x)
    return getmetatable(x) == Error_mt
end


-- without teal, for stability
local known_kinds = {}
for _, v in pairs(errors.Kind) do
    known_kinds[v] = true
end

function errors.registerKind(kind)
    known_kinds[kind] = true
    return kind
end


-- Error Constructor
local function newError(kind, message)
    return setmetatable({
        kind = kind or errors.Kind.unknown,
        message = message or "",
        context = {},
        cause = nil,
        time = clock()
    }, Error_mt)
end

function errors.new(message)
    return newError(errors.Kind.unknown, message)
end

function errors.of(kind, message)
    if not known_kinds[kind] then
        local e = newError(errors.Kind.unknown, message)
        e.context.bad_kind = kind
        return e
    end
    return newError(kind, message)
end


-- Error Wrapper
function errors.wrap(cause, message)
    local wrapped

    if errors.isError(cause) then
        wrapped = newError(cause.kind, message)
        wrapped.cause = cause
    else
        wrapped = newError(errors.Kind.internal, message)
        wrapped.context.raw = cause
    end

    return wrapped
end


-- __index method sharing
-- adding context, checking kind and self
function Error:with(key, value)
    self.context[key] = value
    return self
end

function Error:as(kind)
    self.kind = kind
    return self
end

function Error:is(kind)
    local cur = self
    while cur do
        if cur.kind == kind then
            return true
        end
        cur = cur.cause
    end
    return false
end


-- Do not change this signature.
-- logger and kenel are calling this method.
-- formatting
function errors.format(e)
    local parts = {}
    local cur = e
    local depth = 0

    while cur and depth < MAX_CAUSE_DEPTH do
        parts[#parts+1] = string.format("[%s] %s", cur.kind, cur.message)
        cur = cur.cause
        depth = depth + 1
    end

    if cur then
        parts[#parts+1] = "[truncated] cause chain too deep or cyclic"
    end
    return table.concat(parts, ": ")
end

function errors.internal(message)
    local e = newError(errors.Kind.internal, message)
    if debug and debug.traceback then
        e.traceback = debug.traceback(nil, 2)
    end
    return e
end


return errors
