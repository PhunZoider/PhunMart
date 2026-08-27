if isClient() then
    return
end

-- Small persistent key/value store for the mod itself, as opposed to the
-- definition overrides.
--
-- It lives in PhunMart.json beside the override files, so it shares their
-- lifetime: one per install rather than one per save. That is the right scope
-- for anything describing the state of the *configuration* (which migrations
-- have run) and for anything that needs to notice a save being replaced
-- underneath it (the last world seen, so a wipe can be detected rather than
-- silently inherited).
--
-- Deliberately untyped and flat. Callers own their own keys; this only owns
-- reading and writing the file.

local Core = PhunMart
local fileUtils = require "PhunMart_Server/utils_file"

local State = {}

local FILE = Core.configFiles.state
local cache = nil

--- The whole table. Loaded once, then held: every write goes through this copy,
--- so two callers setting different keys in one session cannot clobber each
--- other the way two independent read-modify-writes would.
function State.all()
    if cache == nil then
        cache = fileUtils.loadTable(FILE) or {}
    end
    return cache
end

function State.get(key, default)
    local v = State.all()[key]
    if v == nil then
        return default
    end
    return v
end

function State.set(key, value)
    State.all()[key] = value
    fileUtils.saveTable(FILE, cache)
end

--- Set several keys with a single write, for when a caller is updating things
--- that belong together and a half-written pair would be misleading.
function State.setAll(values)
    local all = State.all()
    for k, v in pairs(values or {}) do
        all[k] = v
    end
    fileUtils.saveTable(FILE, all)
end

--- Drop the cache so the next read comes off disk. Only useful if something
--- outside the mod has edited the file mid-session.
function State.reload()
    cache = nil
end

Core.state = State
return State
