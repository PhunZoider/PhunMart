-- Round-trips the mod's real data through json.lua and utils_file.lua on a
-- runtime cut down to what PZ B42.20.4 offers.
--
-- Run: luajit test_json.lua   (or run.cmd, which runs all of them)

local here = arg[0]:match("^(.*)[/\\][^/\\]*$") or "."
local root = arg[1] or (here .. "/../..")
package.path = here .. "/?.lua;" .. package.path

local harness = require "harness"

local shared = root .. "/Contents/mods/PhunMart2/common/media/lua/shared"
local server = root .. "/Contents/mods/PhunMart2/common/media/lua/server"
package.path = shared .. "/?.lua;" .. server .. "/?.lua;" .. package.path

harness.installGlobals()

-- Defaults are loaded before the strip, because they are plain `return {...}`
-- modules and require() itself needs the loader machinery.
local DEFAULT_MODULES = {"items", "pools", "groups", "shops", "specials", "prices", "conditions", "blacklist",
                         "token_rewards", "xp_items", "xp_conditions", "xp_rewards", "animal_rewards"}
local defaults = {}
for _, name in ipairs(DEFAULT_MODULES) do
    local ok, mod = pcall(require, "PhunMart/defaults/" .. name)
    if ok and type(mod) == "table" then
        defaults[name] = mod
    else
        print("  (skipped defaults/" .. name .. ": " .. tostring(mod):sub(1, 60) .. ")")
    end
end

-- Everything past this point runs without loadstring, load, loadfile or next.
harness.strip()

local json = require "PhunMart/json"
local fileUtils = require "PhunMart_Server/utils_file"

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

--- Encode, decode, and assert we got back what we put in.
local function roundTrip(name, value)
    local encoded, encErr = json.encode(value)
    if not encoded then
        check(name, false, "encode: " .. tostring(encErr))
        return
    end
    local decoded, decErr = json.decode(encoded)
    if decErr then
        check(name, false, "decode: " .. tostring(decErr))
        return
    end
    local same, why = harness.deepEqual(value, decoded)
    check(name, same, why)
end

--- Assert encoding fails, and that the message names the offending key.
local function encodeRefuses(name, value, mustMention)
    local encoded, err = json.encode(value)
    if encoded then
        check(name, false, "expected a refusal, got " .. encoded)
        return
    end
    if mustMention and not tostring(err):find(mustMention, 1, true) then
        check(name, false, "message did not mention '" .. mustMention .. "': " .. tostring(err))
        return
    end
    check(name, true)
end

---------------------------------------------------------------------------
print("\n-- the runtime is actually cut down --")

check("loadstring is gone", not pcall(function() return loadstring("return 1") end))
check("load is gone", not pcall(function() return load("return 1") end))
check("next is gone", not pcall(function() return next({}) end))
check("pairs still works", pcall(function()
    local n = 0
    for _ in pairs({a = 1, b = 2}) do
        n = n + 1
    end
    return n
end))

---------------------------------------------------------------------------
print("\n-- the bug that was reported --")

-- Single-player used to key player data on the number 0.
encodeRefuses("SP wallet keyed on the number 0 is refused", {
    [0] = {
        current = {change = 0, tokens = 0},
        bound = {tokens = 0},
        purchases = {}
    }
}, "number")

encodeRefuses("the refusal names the key", {[0] = {previousHours = 0}}, "(0)")

encodeRefuses("a player object as a key is refused too", {[{}] = {previousHours = 0}}, "table")

---------------------------------------------------------------------------
print("\n-- the shapes as they are now --")

roundTrip("SP wallet on the string key", {
    ["0"] = {
        current = {change = 250, tokens = 3},
        bound = {tokens = 1},
        purchases = {}
    }
})

roundTrip("MP wallet keyed on usernames", {
    ["PhunZoider"] = {current = {change = 1000, tokens = 0}, bound = {tokens = 5}, purchases = {}},
    ["Someone Else"] = {current = {change = 0, tokens = 0}, bound = {tokens = 0}, purchases = {}}
})

roundTrip("playtime tracking, the file from the screenshot", {
    ["0"] = {
        previousHours = 0,
        claimed = {
            ["playtime_10"] = true,
            ["playtime_60"] = true,
            ["playtime_every_30"] = 4
        }
    }
})

roundTrip("kill tracking", {
    ["0"] = {
        zombieKills = 137,
        sprinterKills = 0,
        claimed = {["zombie_100"] = true}
    }
})

roundTrip("purchase history", {
    ["PhunZoider"] = {
        ["offer:my_pistol"] = {{at = 1234567, shop = "FinalAmendment", qty = 1}}
    }
})

roundTrip("an empty tracker file", {})

roundTrip("awkward strings survive", {
    ["quote\"key"] = "back\\slash",
    ["tab\tkey"] = "new\nline",
    ["unicode"] = "caf\195\169"
})

---------------------------------------------------------------------------
print("\n-- every shipped defaults file --")

for _, name in ipairs(DEFAULT_MODULES) do
    if defaults[name] then
        roundTrip("defaults/" .. name, defaults[name])
    end
end

---------------------------------------------------------------------------
print("\n-- utils_file --")

harness.reset()

check("loadTable on a missing file is nil", fileUtils.loadTable("PhunMart_Nothing.json") == nil)

local sample = {pool_bobshardware = {sources = {groups = {"bobs_tools"}}}}
check("saveTable reports success", fileUtils.saveTable("PhunMart_Pools.json", sample) == true)
local reloaded = fileUtils.loadTable("PhunMart_Pools.json")
local same, why = harness.deepEqual(sample, reloaded)
check("saveTable then loadTable returns the same table", same, why)

-- The guarantee that matters: a table that cannot be encoded must not take the
-- existing file down with it.
local before = harness.files["PhunMart_Pools.json"]
check("saveTable refuses an unencodable table", fileUtils.saveTable("PhunMart_Pools.json", {[0] = "bad"}) == false)
check("the file on disk is untouched after a refusal", harness.files["PhunMart_Pools.json"] == before)
local stillThere = fileUtils.loadTable("PhunMart_Pools.json")
local same2, why2 = harness.deepEqual(sample, stillThere)
check("and it still reads back correctly", same2, why2)

-- Legacy detection.
harness.reset()
harness.files["PhunMart_Pools.txt"] = "return {\n  foo = { bar = 1 },\n}"
check("needsConversion spots a stranded .txt", fileUtils.needsConversion("PhunMart_Pools.json") == true)
check("loadTable returns nil for it", fileUtils.loadTable("PhunMart_Pools.json") == nil)
harness.files["PhunMart_Pools.json"] = '{"foo":{"bar":1}}'
check("and stops once the .json is there", fileUtils.needsConversion("PhunMart_Pools.json") == false)
check("legacyNameFor maps the extension", fileUtils.legacyNameFor("PhunMart_Pools.json") == "PhunMart_Pools.txt")

-- Malformed input must not be mistaken for an empty config.
harness.reset()
harness.files["PhunMart_Broken.json"] = '{"unterminated": '
check("malformed JSON reads as nil", fileUtils.loadTable("PhunMart_Broken.json") == nil)
harness.files["PhunMart_Scalar.json"] = '"just a string"'
check("a non-object JSON file reads as nil", fileUtils.loadTable("PhunMart_Scalar.json") == nil)

---------------------------------------------------------------------------
print("\n" .. passed .. " passed, " .. failed .. " failed")
os.exit(failed == 0 and 0 or 1)
