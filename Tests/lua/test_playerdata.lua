-- Wallets and the reward trackers live in ModData, so the interesting parts are
-- the key they are filed under, whether the one-off import of converted legacy
-- files lands where the rest of the mod looks, and whether progress written in
-- one session is still there in the next.
--
-- That last group is ported from test_wallet.lua and test_trackers.lua, which
-- covered the same ground back when these were files. The move to ModData
-- retired their mechanism, not their questions.
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
print("\n-- a tracker record survives a reload --")

-- Ported from the file-backed tests that the move to ModData retired. The
-- mechanism they checked is gone (there is no save() writing a .json any more)
-- but the question is not: progress written during one session has to still be
-- there when load() binds the table again on the next one.

Core.playtimeRewards:load()
local playtime = Core.playtimeRewards:getPlayerData(fakePlayer)
playtime.previousHours = 12
playtime.claimed["playtime_60"] = true

Core.playtimeRewards.data = {} -- drop the reference, as a restart would
Core.playtimeRewards:load()
local playtimeAgain = Core.playtimeRewards:getPlayerData(fakePlayer)
check("previousHours survives a reload", playtimeAgain.previousHours == 12,
    "got " .. tostring(playtimeAgain.previousHours))
check("the claimed milestone survives", playtimeAgain.claimed["playtime_60"] == true)
check("still one record, not two", (function()
    local n = 0
    for _ in pairs(Core.playtimeRewards.data) do n = n + 1 end
    return n
end)() == 1)

Core.killRewards:load()
local kills = Core.killRewards:getPlayerData("ignored in SP")
kills.zombieKills = 137
kills.claimed["zombie_100"] = true

Core.killRewards.data = {}
Core.killRewards:load()
local killsAgain = Core.killRewards:getPlayerData("ignored in SP")
check("the kill count survives a reload", killsAgain.zombieKills == 137,
    "got " .. tostring(killsAgain.zombieKills))
check("its claimed milestone survives too", killsAgain.claimed["zombie_100"] == true)

---------------------------------------------------------------------------
print("\n-- a record written before a field existed --")

-- getPlayerData backfills rather than trusting the record it finds. A save
-- made before sprinterKills was added hands back nil otherwise, and the
-- milestone check adds to it.
Core.killRewards.data = {
    ["0"] = {zombieKills = 5}
}
local partial = Core.killRewards:getPlayerData("ignored in SP")
check("the missing count reads as 0, not nil", partial.sprinterKills == 0,
    "got " .. tostring(partial.sprinterKills))
check("so it can be added to", partial.sprinterKills + 1 == 1)
check("the missing claimed set is a table", type(partial.claimed) == "table")
check("and the field that was there is untouched", partial.zombieKills == 5)

---------------------------------------------------------------------------
print("\n-- multiplayer keeps players apart --")

Core.isLocal = false
Core.killRewards.data = {}
Core.killRewards:getPlayerData("PhunZoider").zombieKills = 5
Core.killRewards:getPlayerData("Someone Else").zombieKills = 9

check("each player gets their own record", (function()
    local n = 0
    for _ in pairs(Core.killRewards.data) do n = n + 1 end
    return n
end)() == 2)
check("keyed by username rather than \"0\"", Core.killRewards.data["0"] == nil)
check("the first player reads back", Core.killRewards:getPlayerData("PhunZoider").zombieKills == 5)
check("the second is separate", Core.killRewards:getPlayerData("Someone Else").zombieKills == 9)
check("and the table encodes", encodes(Core.killRewards.data))
Core.isLocal = true

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
