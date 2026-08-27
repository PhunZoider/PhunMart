-- Wallets and the reward trackers on this branch live in ModData, so the
-- interesting part is not saving them but the key they are filed under, and
-- whether the one-off import of converted legacy files lands where the rest of
-- the mod looks.
--
-- Run: luajit test_playerdata.lua   (or run.cmd, which runs all of them)

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

local json = require "PhunMart/json"
require "PhunMart/wallet"
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

local function encodes(value)
    return json.encode(value) ~= nil
end

local fakePlayer = {getUsername = function() return "SomeCharacterName" end}

---------------------------------------------------------------------------
print("\n-- the singleplayer key --")

check("isLocal is true with no client, server or coop host", Core.isLocal == true)
check("wallet keyFor returns the string \"0\"", Core.wallet:keyFor(nil) == "0")
check("and not the number 0", Core.wallet:keyFor(nil) ~= 0)
check("multiplayer still keys on the username", (function()
    Core.isLocal = false
    local k = Core.wallet:keyFor("PhunZoider")
    Core.isLocal = true
    return k == "PhunZoider"
end)())

---------------------------------------------------------------------------
print("\n-- repairKeys folds the old numeric record in --")

Core.wallet.data = {
    [0] = {current = {change = 1234, tokens = 7}, bound = {tokens = 2}, purchases = {}}
}
check("a pre-change save does not encode as it stands", not encodes(Core.wallet.data))
Core.wallet:repairKeys()
check("the record moved to \"0\"", Core.wallet.data["0"] ~= nil)
check("the numeric key is gone", Core.wallet.data[0] == nil)
check("the balance came with it", Core.wallet.data["0"].current.change == 1234)
check("and it encodes now", encodes(Core.wallet.data))

Core.wallet.data = {
    [0] = {current = {change = 50, tokens = 9}, bound = {tokens = 0}, purchases = {}},
    ["0"] = {current = {change = 900, tokens = 1}, bound = {tokens = 4}, purchases = {}}
}
Core.wallet:repairKeys()
check("merging two records keeps the larger of each pool",
    Core.wallet.data["0"].current.change == 900 and Core.wallet.data["0"].current.tokens == 9)
check("bound pools merge the same way", Core.wallet.data["0"].bound.tokens == 4)
check("only one record is left", (function()
    local n = 0
    for _ in pairs(Core.wallet.data) do n = n + 1 end
    return n
end)() == 1)

Core.wallet.data = {["0"] = {current = {change = 5, tokens = 0}, bound = {tokens = 0}, purchases = {}}}
Core.wallet:repairKeys()
check("repairKeys is a no-op once already repaired", Core.wallet.data["0"].current.change == 5)

---------------------------------------------------------------------------
print("\n-- the trackers use the same key --")

Core.playtimeRewards.data = {}
local pd = Core.playtimeRewards:getPlayerData(fakePlayer)
pd.previousHours = 12
check("playtime files under \"0\"", Core.playtimeRewards.data["0"] ~= nil)
check("not under the number 0", Core.playtimeRewards.data[0] == nil)
check("and the table encodes", encodes(Core.playtimeRewards.data))

Core.killRewards.data = {}
Core.killRewards:getPlayerData("ignored in SP").zombieKills = 137
check("kills file under \"0\"", Core.killRewards.data["0"] ~= nil)
check("not under the number 0", Core.killRewards.data[0] == nil)
check("and the table encodes", encodes(Core.killRewards.data))

---------------------------------------------------------------------------
print("\n-- importing a converted legacy file --")

-- This is the case the numeric key broke silently. The converter can only
-- produce string keys, because JSON has no other kind. An import that landed
-- them beside a number the rest of the mod reads from would report success and
-- restore nothing.
harness.reset()
harness.files["PhunMart_PlaytimeTracking.json"] = json.encode({
    ["0"] = {previousHours = 40, claimed = {["playtime_60"] = true}}
})

Core.playtimeRewards.data = {}
local imported = Core.fileUtils.loadTable("PhunMart_PlaytimeTracking.json")
check("the converted file reads back", imported ~= nil and imported["0"] ~= nil)

for key, value in pairs(imported or {}) do
    Core.playtimeRewards.data[key] = value
end

local afterImport = Core.playtimeRewards:getPlayerData(fakePlayer)
check("getPlayerData finds the imported record", afterImport.previousHours == 40)
check("the claimed milestone came with it", afterImport.claimed["playtime_60"] == true)
check("no second empty record was created", (function()
    local n = 0
    for _ in pairs(Core.playtimeRewards.data) do n = n + 1 end
    return n
end)() == 1)

---------------------------------------------------------------------------
print("\n" .. passed .. " passed, " .. failed .. " failed")
os.exit(failed == 0 and 0 or 1)
