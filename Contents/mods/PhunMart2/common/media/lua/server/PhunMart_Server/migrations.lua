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
Migrations.CURRENT = 2

-- Printed once, unconditionally. debugLn prefixes "[PhunMart] " and prints too,
-- so calling both put every line out twice with slightly different spacing.
local function log(msg)
    print("[PhunMart][migrate] " .. msg)
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
}, {
    version = 2,
    describe = "Port groups off the removed vehicle_* specials onto their own defaults",
    apply = function(files, touch)
        -- The ten vehicle_* specials are gone. They were price bands wearing a
        -- special's clothes, and every one of them is now expressed by the
        -- group that holds the cars.
        --
        -- A group naming a removed key would lose its price and its reward at
        -- once, and an offer that resolves neither is dropped. That is quiet
        -- rather than dangerous, but an admin's car shop going empty with only
        -- a line in the server log is not an upgrade. So port the band onto the
        -- group instead of leaving it to fail.
        --
        -- The bands are spelled out here rather than read from the current
        -- defaults on purpose: a migration describes what the data meant when
        -- it was written, and has to keep working after those defaults move on.
        local BANDS = {
            vehicle_smallcar = {price = "vehicle_common", weight = 1.0},
            vehicle_van = {price = "vehicle_common", weight = 1.0},
            vehicle_stepvan = {price = "vehicle_common", weight = 1.0},
            vehicle_normalcar = {price = "vehicle_uncommon", weight = 1.0},
            vehicle_stationwagon = {price = "vehicle_uncommon", weight = 1.0},
            vehicle_pickup = {price = "vehicle_uncommon", weight = 1.0},
            vehicle_offroad = {price = "vehicle_uncommon", weight = 1.0},
            vehicle_suv = {price = "vehicle_uncommon", weight = 1.0},
            vehicle_luxury = {price = "vehicle_rare", weight = 0.5},
            vehicle_sportscar = {price = "vehicle_rare", weight = 0.5}
        }

        --- Write the band onto `target`, without overwriting anything the admin
        --- chose themselves. Their price beat the special's before this ran, so
        --- it has to keep beating it afterwards.
        local function port(target, band)
            if target.price == nil then
                target.price = band.price
            end
            target.offer = target.offer or {}
            if target.offer.weight == nil then
                target.offer.weight = band.weight
            end
            if target.offer.stock == nil then
                target.offer.stock = {min = 1, max = 1}
            end
            if target.spawn == nil then
                target.spawn = {condition = {min = 85, max = 100}}
            end
            target.reward = nil
        end

        local fixed = 0

        for _, name in ipairs(Core.overridePaths.groups) do
            local tbl = files[name]
            if tbl then
                for key, def in pairs(tbl) do
                    local band = type(def) == "table" and type(def.defaults) == "table" and
                                     BANDS[def.defaults.reward]
                    if band then
                        port(def.defaults, band)
                        fixed = fixed + 1
                        touch(name)
                        log("  " .. name .. ": group '" .. tostring(key) .. "' now carries its own vehicle band")
                    end
                end
            end
        end

        for _, name in ipairs(Core.overridePaths.items) do
            local tbl = files[name]
            if tbl then
                for key, def in pairs(tbl) do
                    local band = type(def) == "table" and BANDS[def.reward]
                    if band then
                        port(def, band)
                        fixed = fixed + 1
                        touch(name)
                        log("  " .. name .. ": item '" .. tostring(key) .. "' now carries its own vehicle band")
                    end
                end
            end
        end

        -- An override that only patched a shipped vehicle special is now a
        -- fragment of a definition that no longer exists. Left alone it would
        -- resolve to a special with no actions, and unlike a missing key that
        -- passes the "has a reward" check: the offer would be sold and hand
        -- over nothing. Drop those. One that carries its own actions stands on
        -- its own, so it stays and simply moves to the Other tab.
        for _, name in ipairs(Core.overridePaths.specials) do
            local tbl = files[name]
            if tbl then
                for key, def in pairs(tbl) do
                    if BANDS[key] and type(def) == "table" and def.actions == nil then
                        tbl[key] = nil
                        fixed = fixed + 1
                        touch(name)
                        log("  " .. name .. ": dropped '" .. tostring(key) .. "', the special it patched is gone")
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
        -- Nothing on disk to lose, so there is nothing to protect and no reason
        -- to hold the migration up.
        return true
    end
    local name = Core.backupFileFor(fromVersion)
    if not fileUtils.saveTable(name, snapshot) then
        -- The backup is the only way back out of a bad migration, so not having
        -- one is a reason to stop rather than a reason to be careful.
        log("could not write " .. name .. "; leaving the overrides alone")
        return false
    end
    log("backed up overrides to " .. name)
    return true
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
    if not backup(files, from) then
        -- Left unstamped on purpose, so the upgrade is retried next start once
        -- whatever stopped the backup has been dealt with.
        return
    end

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
