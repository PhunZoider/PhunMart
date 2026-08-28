-- Covers what a group's Vehicles field compiles into.
--
-- A group's `items` list holds two kinds of key: inventory item types, and
-- vehicle script names. Nothing in the data distinguishes them, so the compiler
-- has to, and when it did not, a rewardless vehicle offer compiled to
-- giveItem("SmallCar"). AddItem fails on a script name, the failure is a debug
-- line, and the player has already paid. Money in, nothing out.
--
-- The shipped vehicle groups all name a vehicle special in defaults.reward and
-- never went down that path, which is why this survived: the hole was open only
-- for groups an admin wrote in the editor, which is the one place the Vehicles
-- field exists to serve.
--
-- Run: luajit test_compiler_vehicles.lua   (or run.cmd, which runs all of them)

local here = arg[0]:match("^(.*)[/\\][^/\\]*$") or "."
local root = arg[1] or (here .. "/../..")
package.path = here .. "/?.lua;" .. package.path

local harness = require "harness"

local shared = root .. "/Contents/mods/PhunMart2/common/media/lua/shared"
local server = root .. "/Contents/mods/PhunMart2/common/media/lua/server"
package.path = shared .. "/?.lua;" .. server .. "/?.lua;" .. package.path

harness.installGlobals()

---------------------------------------------------------------------------
-- A stand-in script manager.
--
-- The distinction under test is exactly the one this object draws: getVehicle
-- answers for vehicle scripts, FindItem answers for inventory items, and a key
-- is a vehicle only when the first says yes and the second says no.
---------------------------------------------------------------------------

local VEHICLES = {
    ["Base.SmallCar"] = true,
    ["Base.VanMail"] = true
}
local ITEMS = {
    ["Base.Axe"] = true,
    -- Deliberate collision: a mod shipping an item named like a vehicle script
    -- must not turn an item purchase into a car.
    ["Base.VanMail"] = true
}

_G.getScriptManager = function()
    return {
        getVehicle = function(_, fullType)
            return VEHICLES[fullType] or nil
        end,
        FindItem = function(_, itemType)
            local full = itemType:find("%.") and itemType or ("Base." .. itemType)
            if not ITEMS[full] then
                return nil
            end
            return {
                getFullName = function()
                    return full
                end,
                getDisplayName = function()
                    return full
                end,
                getDisplayCategory = function()
                    return "Tools"
                end
            }
        end,
        getAllItems = function()
            return {
                size = function()
                    return 0
                end,
                get = function()
                    return nil
                end
            }
        end
    }
end

_G.getActivatedMods = function()
    return {
        size = function()
            return 0
        end,
        get = function()
            return nil
        end
    }
end

_G.SandboxVars = {PhunMart = {Debug = false}}
_G.LuaEventManager = {AddEvent = function() end}
_G.getSandboxOptions = function()
    return {getOptionByName = function() return nil end}
end
_G.ModData = {
    getOrCreate = function()
        return {}
    end
}

require "PhunMart/core"
require "PhunMart/compiler"
local Compiler = PhunMart.compiler

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

--- Compile one pool holding one group, and hand back the single offer in it.
--- Everything else is the smallest world the compiler will accept.
local function compileOffer(groupDef)
    local runtime, logger = Compiler.compileAll({
        prices = {
            cheap = {
                kind = "change",
                amount = 10
            }
        },
        specials = {
            vehicle_smallcar = {
                kind = "vehicle",
                actions = {{
                    type = "spawnVehicle",
                    scripts = {"SmallCar"}
                }}
            }
        },
        conditionsDefs = {},
        items = {},
        groups = {
            g = groupDef
        },
        pools = {
            p = {
                sources = {
                    groups = {"g"}
                }
            }
        },
        shops = {}
    })
    local pool = runtime.pools and runtime.pools.p
    local offers = pool and pool.offers or {}
    local found, count = nil, 0
    for _, offer in pairs(offers) do
        found = offer
        count = count + 1
    end
    return found, count, logger
end

--- The first action of an offer, or an empty table so assertions can read
--- fields off it without guarding every one.
local function action(offer)
    return offer and offer.reward and offer.reward.actions and offer.reward.actions[1] or {}
end

print("-- a group selling a vehicle, with no reward named --")
do
    local offer, count = compileOffer({
        defaults = {
            price = "cheap"
        },
        items = {"SmallCar"}
    })
    ok("the offer compiles at all", count == 1, "got " .. tostring(count) .. " offers")
    ok("it spawns the vehicle", action(offer).type == "spawnVehicle", "type was " .. tostring(action(offer).type))
    ok("it spawns the one the group listed", action(offer).script == "SmallCar",
        "script was " .. tostring(action(offer).script))
    ok("it does not try to hand over a script name as an item", action(offer).type ~= "giveItem")
    ok("the reward is labelled a vehicle", offer and offer.reward and offer.reward.kind == "vehicle")
end

print("-- a group selling an ordinary item --")
do
    local offer, count = compileOffer({
        defaults = {
            price = "cheap"
        },
        items = {"Base.Axe"}
    })
    ok("the offer compiles", count == 1, "got " .. tostring(count) .. " offers")
    ok("it still gives the item", action(offer).type == "giveItem", "type was " .. tostring(action(offer).type))
    ok("it gives the item asked for", action(offer).item == "Base.Axe")
end

print("-- an item whose name collides with a vehicle script --")
do
    local offer = compileOffer({
        defaults = {
            price = "cheap"
        },
        items = {"Base.VanMail"}
    })
    ok("the item wins over the vehicle", action(offer).type == "giveItem",
        "type was " .. tostring(action(offer).type))
end

print("-- a group that does name a vehicle reward --")
do
    local offer = compileOffer({
        defaults = {
            price = "cheap",
            reward = "vehicle_smallcar"
        },
        items = {"SmallCar"}
    })
    ok("the named special still wins", action(offer).type == "spawnVehicle")
    ok("and keeps its own script list", action(offer).scripts ~= nil and action(offer).scripts[1] == "SmallCar")
end

print("-- a vehicle offer with no price --")
do
    local offer, count, logger = compileOffer({
        items = {"SmallCar"}
    })
    -- Unchanged behaviour, asserted so the vehicle path does not quietly
    -- acquire an exemption from the rule every other offer follows.
    ok("it is dropped like any other priceless offer", count == 0)
    ok("and says why", #logger.errors > 0 and logger.errors[1]:find("no price") ~= nil,
        logger.errors[1] or "no error logged")
end

---------------------------------------------------------------------------

print("")
print("passed: " .. passed .. "  failed: " .. failed)
if failed > 0 then
    os.exit(1)
end
