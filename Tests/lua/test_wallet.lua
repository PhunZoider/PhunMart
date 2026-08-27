-- Exercises the wallet's single-player key and the migration off the old
-- numeric one, against a runtime cut down to PZ B42.20.4.
--
-- Run: luajit test_wallet.lua   (or run.cmd, which runs all of them)

local here = arg[0]:match("^(.*)[/\\][^/\\]*$") or "."
local root = arg[1] or (here .. "/../..")
package.path = here .. "/?.lua;" .. package.path

local harness = require "harness"

local shared = root .. "/Contents/mods/PhunMart2/common/media/lua/shared"
local server = root .. "/Contents/mods/PhunMart2/common/media/lua/server"
package.path = shared .. "/?.lua;" .. server .. "/?.lua;" .. package.path

harness.installGlobals()

---------------------------------------------------------------------------
-- Enough of the engine for core.lua and wallet.lua to load
---------------------------------------------------------------------------

_G.SandboxVars = {PhunMart = {Debug = false}}
_G.LuaEventManager = {AddEvent = function() end}
_G.getSandboxOptions = function()
    return {
        getOptionByName = function() return nil end
    }
end

local modDataStore = {}
_G.ModData = {
    getOrCreate = function(name)
        modDataStore[name] = modDataStore[name] or {}
        return modDataStore[name]
    end
}

local Core = require "PhunMart/core"
Core = _G.PhunMart
require "PhunMart/wallet"

local json = require "PhunMart/json"

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

--- Put the wallet back to a known state with `data` as the existing save.
local function withSave(data)
    Core.wallet.data = data
    Core.wallet.keysNormalised = nil
end

local function encodes(value)
    local out = json.encode(value)
    return out ~= nil
end

---------------------------------------------------------------------------
print("\n-- single player --")

check("isLocal is true with no client, server or coop host", Core.isLocal == true)

withSave(nil)
local fresh = Core.wallet:get(nil)
check("a fresh wallet is created", type(fresh) == "table")
check("filed under the string \"0\"", Core.wallet.data["0"] ~= nil)
check("and not under the number 0", Core.wallet.data[0] == nil)
check("so the table encodes", encodes(Core.wallet.data))

---------------------------------------------------------------------------
print("\n-- a save made before the fix --")

withSave({
    [0] = {
        current = {change = 1234, tokens = 7},
        bound = {tokens = 2},
        purchases = {}
    }
})
check("that save does not encode as it stands", not encodes(Core.wallet.data))

local migrated = Core.wallet:get(nil)
check("the balance survives the move", migrated.current.change == 1234 and migrated.current.tokens == 7)
check("bound tokens survive too", migrated.bound.tokens == 2)
check("it is now under \"0\"", Core.wallet.data["0"] ~= nil)
check("the numeric key is gone", Core.wallet.data[0] == nil)
check("and the table encodes", encodes(Core.wallet.data))

---------------------------------------------------------------------------
print("\n-- both keys present --")

withSave({
    [0] = {current = {change = 1, tokens = 0}, bound = {tokens = 0}, purchases = {}},
    ["0"] = {current = {change = 999, tokens = 0}, bound = {tokens = 0}, purchases = {}}
})
local both = Core.wallet:get(nil)
check("the string key wins, being the later write", both.current.change == 999)
check("the numeric key is still removed", Core.wallet.data[0] == nil)
check("so the table encodes", encodes(Core.wallet.data))

---------------------------------------------------------------------------
print("\n-- multiplayer is unaffected --")

Core.isLocal = false
withSave({})
local mp = Core.wallet:get("PhunZoider")
check("keyed on the username", Core.wallet.data["PhunZoider"] ~= nil)
check("no stray \"0\" record", Core.wallet.data["0"] == nil)
mp.current.change = 500
check("a second player is separate", Core.wallet:get("Someone Else").current.change == 0)
check("and the table encodes", encodes(Core.wallet.data))
Core.isLocal = true

---------------------------------------------------------------------------
print("\n" .. passed .. " passed, " .. failed .. " failed")
os.exit(failed == 0 and 0 or 1)
