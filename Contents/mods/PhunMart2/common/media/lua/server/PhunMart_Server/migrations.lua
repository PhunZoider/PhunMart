if isClient() then
    return
end

-- Upgrade path for the override files.
--
-- Overrides are a thin patch layer sitting on top of the shipped defaults, so
-- most changes to those defaults need nothing: a server that never customised
-- a pool just picks up the new one. What does need help is a change that makes
-- an existing override wrong rather than merely stale, and there is no way to
-- do that safely without knowing which version wrote the file.
--
-- So the version is stamped alongside the overrides, in the same directory and
-- with the same lifetime, rather than in ModData. ModData is per save, while
-- these files are shared by every save on the machine, and a version that
-- outlives or under-lives the thing it describes is worse than none.
--
-- The stamp is one key in the shared state file rather than a file of its own,
-- because it will not be the only thing that wants this scope.

local Core = PhunMart
local fileUtils = require "PhunMart_Server/utils_file"
local State = require "PhunMart_Server/state"

local Migrations = {}

local VERSION_KEY = "overrideVersion"

--- Bump this when adding a migration. A file stamped lower than this runs
--- everything above its stamp, in order.
Migrations.CURRENT = 1

local function log(msg)
    print("[PhunMart][migrate] " .. msg)
    if Core.debugLn then
        Core.debugLn("[migrate] " .. msg)
    end
end

---------------------------------------------------------------------------
-- Migrations, lowest version first.
--
-- `apply` receives the loaded override files as {filename = table} and a
-- `touch(filename)` to call for each one it modifies. It mutates in place and
-- returns how many entries it changed. A file absent from disk is absent from
-- the table, so always test before indexing. Returning 0 is normal and means
-- the migration had nothing to do here.
--
-- Only touched files are written back. Reserialising the rest would rewrite
-- every override file on every upgrade, and pairs() ordering is not stable
-- across a mutation, so a before/after comparison could not tell the
-- difference between a real change and a reshuffle.
---------------------------------------------------------------------------

Migrations.list = {{
    version = 1,
    describe = "Repair specials whose action was rewritten as an empty addTrait",
    apply = function(files, touch)
        -- The specials editor listed seven action types when the data uses
        -- nine. A combo cannot show an option it does not have, so opening any
        -- giveXP or applyBoost special displayed addTrait, and saving wrote
        -- that back over the real action with an empty trait attached.
        --
        -- Only shipped keys are touched, and only when the trait is missing,
        -- which the editor never produces: it requires one. Dropping the
        -- actions block restores the shipped action underneath.
        local fixed = 0
        for _, name in ipairs(Core.overridePaths.specials) do
            local tbl = files[name]
            if tbl then
                for key, def in pairs(tbl) do
                    if type(def) == "table" and type(def.actions) == "table" then
                        local act = def.actions[1]
                        if type(act) == "table" and act.type == "addTrait" and
                            (act.trait == nil or act.trait == "") and Core.isShippedKey("specials", key) then
                            def.actions = nil
                            fixed = fixed + 1
                            touch(name)
                            log("  " .. name .. ": restored the shipped action for '" .. tostring(key) .. "'")
                        end
                    end
                end
            end
        end
        return fixed
    end
}}

---------------------------------------------------------------------------
-- Running
---------------------------------------------------------------------------

local function everyOverrideFile()
    local out = {}
    for _, names in pairs(Core.overridePaths) do
        for _, name in ipairs(names) do
            table.insert(out, name)
        end
    end
    table.sort(out)
    return out
end

local function stamp(version)
    State.set(VERSION_KEY, version)
end

--- Everything as it was before we touched it, in one file rather than a .bak
--- per override, so restoring is one paste and inspecting is one open.
local function backup(files, fromVersion)
    local snapshot = {}
    local any = false
    for name, tbl in pairs(files) do
        snapshot[name] = tbl
        any = true
    end
    if not any then
        return
    end
    local name = "PhunMart_Backup_v" .. tostring(fromVersion) .. ".txt"
    fileUtils.saveTable(name, snapshot)
    log("backed up overrides to " .. name)
end

--- Run any migrations the override files have not seen. Safe to call more than
--- once; it does the work at most once per session.
function Migrations.run()
    if Migrations._done then
        return
    end
    Migrations._done = true

    local from = tonumber(State.get(VERSION_KEY))

    local files, hasOverrides = {}, false
    for _, name in ipairs(everyOverrideFile()) do
        local tbl = fileUtils.loadTable(name)
        if tbl then
            files[name] = tbl
            hasOverrides = true
        end
    end

    if from == nil then
        -- No stamp. Either a fresh install, which has nothing to migrate and
        -- should simply be marked current, or an install that predates this
        -- mechanism, which has to run everything.
        if not hasOverrides then
            stamp(Migrations.CURRENT)
            return
        end
        from = 0
        log("override files with no version stamp, treating as version 0")
    end

    if from >= Migrations.CURRENT then
        return
    end

    local pending = {}
    for _, m in ipairs(Migrations.list) do
        if m.version > from and m.version <= Migrations.CURRENT then
            table.insert(pending, m)
        end
    end
    table.sort(pending, function(a, b)
        return a.version < b.version
    end)

    if #pending == 0 then
        stamp(Migrations.CURRENT)
        return
    end

    log("upgrading overrides from version " .. tostring(from) .. " to " .. tostring(Migrations.CURRENT))
    backup(files, from)

    local touched = {}
    local touch = function(name)
        touched[name] = true
    end

    local reached = from
    local changed = 0
    for _, m in ipairs(pending) do
        local ok, result = pcall(m.apply, files, touch)
        if not ok then
            -- Stop at the last one that worked. Stamping past a failure would
            -- mean it never runs again, which is worse than running it twice:
            -- these are written to be safe to repeat.
            log("MIGRATION " .. tostring(m.version) .. " FAILED: " .. tostring(result))
            log("stopping at version " .. tostring(reached) .. "; overrides left as they were")
            break
        end
        local n = tonumber(result) or 0
        changed = changed + n
        reached = m.version
        log("v" .. tostring(m.version) .. " (" .. m.describe .. "): " .. tostring(n) .. " changed")
    end

    local written = 0
    for name in pairs(touched) do
        if files[name] then
            fileUtils.saveTable(name, files[name])
            written = written + 1
        end
    end
    if written > 0 then
        log("rewrote " .. tostring(changed) .. " entries across " .. tostring(written) .. " files")
    end

    stamp(reached)
end

Core.migrations = Migrations
return Migrations
