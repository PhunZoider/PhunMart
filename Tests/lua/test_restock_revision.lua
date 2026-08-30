-- A machine bakes its offers at restock and keeps them until it rolls again, so
-- a change to the shipped definitions does not reach existing shops on its own.
-- Core.restockForChangedDefinitions is what closes that gap on the first start
-- after an upgrade, and it has to fire exactly once per save per revision.
--
-- Run: luajit test_restock_revision.lua   (or run.cmd, which runs all of them)

local here = arg[0]:match("^(.*)[/\\][^/\\]*$") or "."
local root = arg[1] or (here .. "/../..")
package.path = here .. "/?.lua;" .. package.path

local harness = require "harness"

local shared = root .. "/Contents/mods/PhunMart2/common/media/lua/shared"
local server = root .. "/Contents/mods/PhunMart2/common/media/lua/server"
package.path = shared .. "/?.lua;" .. server .. "/?.lua;" .. package.path

harness.installGlobals()

_G.SandboxVars = {PhunMart = {Debug = false}}
_G.LuaEventManager = {AddEvent = function() end}
_G.getSandboxOptions = function()
    return {getOptionByName = function() return nil end}
end

-- ModData is per save. Two saves on one install get their own tables, which is
-- the whole reason the marker lives here rather than in State.
local modDataStore = {}
_G.ModData = {
    getOrCreate = function(name)
        modDataStore[name] = modDataStore[name] or {}
        return modDataStore[name]
    end
}

local worldAge = 0
_G.GameTime = {
    getInstance = function()
        return {
            getWorldAgeHours = function()
                return worldAge
            end
        }
    end
}

require "PhunMart/core"
local Core = _G.PhunMart
Core.fileUtils = require "PhunMart_Server/utils_file"
require "PhunMart_Server/main"

-- Taken before any test below sets its own, so the last section still checks
-- what actually ships rather than whatever the previous case left behind.
local SHIPPED_REVISION = Core.defsRevision
local SHIPPED_SHOPS = Core.defsRevisionShops

harness.strip()

---------------------------------------------------------------------------

local passed, failed = 0, 0
local function ok(label, condition, detail)
    if condition then
        passed = passed + 1
        print("  ok    " .. label)
    else
        failed = failed + 1
        print("  FAIL  " .. label .. (detail and ("  <- " .. detail) or ""))
    end
end

--- Start from a save that has never seen this mechanism.
---
--- Cleared in place rather than replaced, because Core.restockStamps() holds the
--- table it first saw. One process only ever serves one save, so that cache is
--- right in production and only this test has to work around it.
local function freshSave()
    for _, name in ipairs({"PhunMart_Restock", "PhunMart"}) do
        local t = modDataStore[name] or {}
        for k in pairs(t) do
            t[k] = nil
        end
        modDataStore[name] = t
    end
    return modDataStore["PhunMart_Restock"]
end

local function stampsFor(t)
    local s = modDataStore["PhunMart_Restock"]
    return s.forceRestockTypeAt and s.forceRestockTypeAt[t]
end

---------------------------------------------------------------------------

print("-- the first start after an upgrade --")
do
    local stamps = freshSave()
    worldAge = 1234.56
    Core.defsRevision = 1
    Core.defsRevisionShops = {"WrentAWreck"}

    Core.restockForChangedDefinitions()

    ok("the affected shop is stamped", stampsFor("WrentAWreck") ~= nil)
    ok("at the current world age, rounded like restockAll", stampsFor("WrentAWreck") == 1234.6,
        "stamp was " .. tostring(stampsFor("WrentAWreck")))
    ok("the revision is recorded", stamps.defsRevision == 1)
    -- Rerolling every machine in the world would pull stock out from under
    -- players standing at shops this change never touched.
    ok("no global restock is forced", stamps.forceRestockAt == nil,
        "forceRestockAt was " .. tostring(stamps.forceRestockAt))
    ok("an untouched shop type is not stamped", stampsFor("GoodPhoods") == nil)
end

print("-- every start after that --")
do
    freshSave()
    worldAge = 100
    Core.defsRevision = 1
    Core.defsRevisionShops = {"WrentAWreck"}
    Core.restockForChangedDefinitions()

    -- A stamp on every boot would reroll the shop every boot, which on a server
    -- that restarts nightly means the shelves never settle.
    worldAge = 500
    Core.restockForChangedDefinitions()
    ok("the stamp is not refreshed", stampsFor("WrentAWreck") == 100,
        "stamp was " .. tostring(stampsFor("WrentAWreck")))

    worldAge = 900
    Core.restockForChangedDefinitions()
    ok("still not refreshed on a third start", stampsFor("WrentAWreck") == 100)
end

print("-- the next revision --")
do
    freshSave()
    worldAge = 100
    Core.defsRevision = 1
    Core.defsRevisionShops = {"WrentAWreck"}
    Core.restockForChangedDefinitions()

    worldAge = 700
    Core.defsRevision = 2
    Core.defsRevisionShops = {"GoodPhoods"}
    Core.restockForChangedDefinitions()

    ok("the newly affected shop is stamped", stampsFor("GoodPhoods") == 700)
    ok("and the old stamp is left where it was", stampsFor("WrentAWreck") == 100)
    ok("the recorded revision moves on", modDataStore["PhunMart_Restock"].defsRevision == 2)
end

print("-- a revision that affects everything --")
do
    local stamps = freshSave()
    worldAge = 42
    Core.defsRevision = 3
    Core.defsRevisionShops = nil
    Core.restockForChangedDefinitions()

    ok("the global stamp is used", stamps.forceRestockAt == 42)
    ok("rather than a per-type one", stamps.forceRestockTypeAt == nil)
end

print("-- two saves on one install --")
do
    -- State is per install, ModData is per save. Putting the marker in State
    -- would mean the second world never restocked.
    freshSave()
    worldAge = 100
    Core.defsRevision = 4
    Core.defsRevisionShops = {"WrentAWreck"}
    Core.restockForChangedDefinitions()
    ok("the first save is stamped", stampsFor("WrentAWreck") == 100)

    -- Second world: fresh ModData, same install, same mod version.
    freshSave()
    worldAge = 3
    Core.restockForChangedDefinitions()
    ok("the second save is stamped too", stampsFor("WrentAWreck") == 3,
        "stamp was " .. tostring(stampsFor("WrentAWreck")))
end

print("-- what ships --")
do
    -- Guards the pair going out of step: a revision bump with a stale shop list
    -- restocks the wrong machines, and naming a shop that does not exist
    -- restocks none.
    local shipped = require "PhunMart/defaults/shops"
    ok("defsRevision is a number", type(SHIPPED_REVISION) == "number",
        "was " .. tostring(SHIPPED_REVISION))
    ok("defsRevisionShops is a list or nil",
        SHIPPED_SHOPS == nil or type(SHIPPED_SHOPS) == "table")
    for _, t in ipairs(SHIPPED_SHOPS or {}) do
        ok("'" .. t .. "' is a real shop", shipped[t] ~= nil)
    end
end

---------------------------------------------------------------------------

print("")
print("passed: " .. passed .. "  failed: " .. failed)
if failed > 0 then
    os.exit(1)
end
