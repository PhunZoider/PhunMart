-- The playtime and kill trackers, save and load, on a runtime cut down to
-- PZ B42.20.4. This is the path in the reported bug.
--
-- Run: luajit test_trackers.lua   (or run.cmd, which runs all of them)

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
local modDataStore = {}
_G.ModData = {
    getOrCreate = function(name)
        modDataStore[name] = modDataStore[name] or {}
        return modDataStore[name]
    end
}

require "PhunMart/core"
local Core = _G.PhunMart
Core.fileUtils = require "PhunMart_Server/utils_file"

harness.strip()

require "PhunMart_Server/rewards_playtime"
require "PhunMart_Server/rewards_kill"

---------------------------------------------------------------------------

local passed, failed = 0, 0
local function check(name, ok, detail)
    if ok then
        passed = passed + 1
        print("  ok    " .. name)
    else
        failed = failed + 1
        print("  FAIL  " .. name .. (detail and ("  -- " .. detail) or ""))
    end
end

local fakePlayer = {
    getUsername = function() return "SomeCharacterName" end
}

---------------------------------------------------------------------------
print("\n-- playtime tracker, single player --")

harness.reset()
local P = Core.playtimeRewards
P.data = {}

local pd = P:getPlayerData(fakePlayer)
pd.claimed["playtime_60"] = true
pd.previousHours = 12

check("filed under the string \"0\"", P.data["0"] ~= nil)
check("not under the number 0", P.data[0] == nil)
check("save succeeds", P:save() ~= false)
check("a file was actually written", harness.files["PhunMart_PlaytimeTracking.json"] ~= nil)

P.data = nil
P:load()
local reloaded = P:getPlayerData(fakePlayer)
check("previousHours survives a reload", reloaded.previousHours == 12)
check("the claimed milestone survives", reloaded.claimed["playtime_60"] == true)
check("still one record, not two", (function()
    local n = 0
    for _ in pairs(P.data) do
        n = n + 1
    end
    return n
end)() == 1)

-- The recurring milestones store a number against a string key, which is the
-- shape most likely to be mistaken for an array.
harness.reset()
P.data = {}
local rec = P:getPlayerData(fakePlayer)
rec.claimed["playtime_every_30"] = 4
P:save()
P.data = nil
P:load()
check("a numeric value under a string key round-trips",
    P:getPlayerData(fakePlayer).claimed["playtime_every_30"] == 4)

---------------------------------------------------------------------------
print("\n-- kill tracker, single player --")

harness.reset()
local K = Core.killRewards
K.data = {}

local kd = K:getPlayerData("ignored in SP")
kd.zombieKills = 137
kd.claimed["zombie_100"] = true

check("filed under the string \"0\"", K.data["0"] ~= nil)
check("not under the number 0", K.data[0] == nil)
check("save succeeds", K:save() ~= false)

K.data = nil
K:load()
local kreload = K:getPlayerData("ignored in SP")
check("kill count survives a reload", kreload.zombieKills == 137)
check("the claimed milestone survives", kreload.claimed["zombie_100"] == true)
check("sprinterKills defaults back to 0", kreload.sprinterKills == 0)

---------------------------------------------------------------------------
print("\n-- multiplayer --")

Core.isLocal = false
harness.reset()
K.data = {}
K:getPlayerData("PhunZoider").zombieKills = 5
K:getPlayerData("Someone Else").zombieKills = 9
check("save succeeds with username keys", K:save() ~= false)
K.data = nil
K:load()
check("first player reloads", K:getPlayerData("PhunZoider").zombieKills == 5)
check("second player reloads", K:getPlayerData("Someone Else").zombieKills == 9)
Core.isLocal = true

---------------------------------------------------------------------------
print("\n" .. passed .. " passed, " .. failed .. " failed")
os.exit(failed == 0 and 0 or 1)
