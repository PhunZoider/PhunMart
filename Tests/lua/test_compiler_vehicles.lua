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
---
--- `itemDefs` is the items.lua layer, the per-item override that sits above the
--- group. `extraSpecials` are merged over the two defined here, so a test can
--- add a second band and check which one an offer actually lands in.
local function compileOffer(groupDef, itemDefs, extraSpecials)
    local specials = {
        vehicle_smallcar = {
            kind = "vehicle",
            price = "cheap",
            offer = {
                weight = 1.0
            },
            actions = {{
                type = "spawnVehicle",
                scripts = {"SmallCar"}
            }}
        }
    }
    for k, v in pairs(extraSpecials or {}) do
        specials[k] = v
    end

    local runtime, logger = Compiler.compileAll({
        prices = {
            cheap = {
                kind = "change",
                amount = 10
            },
            dear = {
                kind = "change",
                amount = 500
            }
        },
        specials = specials,
        conditionsDefs = {},
        items = itemDefs or {},
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

print("-- a group that sets the condition its vehicles arrive in --")
do
    local offer = compileOffer({
        defaults = {
            price = "cheap",
            spawn = {
                condition = {
                    min = 85,
                    max = 100
                }
            }
        },
        items = {"SmallCar"}
    })
    -- The group is the class now, so the condition range has to reach the spawn
    -- action from group defaults. It used to arrive only from a vehicle special.
    local args = action(offer).args
    ok("the condition range reaches the action", args ~= nil and args.condition ~= nil)
    ok("with the numbers the group gave", args and args.condition and args.condition.min == 85 and
        args.condition.max == 100)
end

print("-- an item override that moves an item into another band --")
do
    -- The bug this pins: the special supplying price and weight used to be
    -- looked up from the group's reward, i.e. the band the override was moving
    -- the item OUT of. It went unseen because every shipped override restated
    -- price and weight by hand. This one deliberately does not.
    -- No price on the group, so the price can only have come from a special,
    -- which makes it visible which special was consulted.
    local offer = compileOffer({
        defaults = {
            reward = "vehicle_smallcar"
        },
        items = {"SmallCar"}
    }, {
        SmallCar = {
            reward = "vehicle_fancy"
        }
    }, {
        vehicle_fancy = {
            kind = "vehicle",
            price = "dear",
            offer = {
                weight = 0.25
            },
            actions = {{
                type = "spawnVehicle",
                scripts = {"SmallCar"}
            }}
        }
    })
    ok("the offer takes the new band's price", offer and offer.price and offer.price.amount == 500,
        "amount was " .. tostring(offer and offer.price and offer.price.amount))
    ok("and the new band's weight", offer and offer.offer and offer.offer.weight == 0.25,
        "weight was " .. tostring(offer and offer.offer and offer.offer.weight))
end

print("-- an item override still outranks the special it names --")
do
    local offer = compileOffer({
        defaults = {
            price = "cheap"
        },
        items = {"SmallCar"}
    }, {
        SmallCar = {
            reward = "vehicle_smallcar",
            price = "dear",
            offer = {
                weight = 0.1
            }
        }
    })
    ok("the override's price wins over the special's", offer and offer.price and offer.price.amount == 500,
        "amount was " .. tostring(offer and offer.price and offer.price.amount))
    ok("and the override's weight", offer and offer.offer and offer.offer.weight == 0.1,
        "weight was " .. tostring(offer and offer.offer and offer.offer.weight))
end

print("-- a group that sets the fuel its vehicles arrive with --")
do
    local offer = compileOffer({
        defaults = {
            price = "cheap",
            spawn = {
                condition = {
                    min = 85,
                    max = 100
                },
                fuel = {
                    min = 0.1,
                    max = 0.25
                }
            }
        },
        items = {"SmallCar"}
    })
    local args = action(offer).args
    ok("fuel reaches the action", args ~= nil and args.fuel ~= nil)
    ok("as the range the group gave", args and args.fuel and args.fuel.min == 0.1 and args.fuel.max == 0.25)
    ok("alongside condition, not instead of it", args and args.condition and args.condition.min == 85)
end

print("-- a group that sets condition but not fuel --")
do
    -- Fuel absent has to stay absent all the way to the action. A nil there is
    -- what tells the claim to leave the tank as the engine spawned it.
    local offer = compileOffer({
        defaults = {
            price = "cheap",
            spawn = {
                condition = {
                    min = 85,
                    max = 100
                }
            }
        },
        items = {"SmallCar"}
    })
    local args = action(offer).args
    ok("condition still arrives", args and args.condition ~= nil)
    ok("and fuel is absent rather than zero", args and args.fuel == nil,
        "fuel was " .. tostring(args and args.fuel))
end

print("-- rolling a fuel fraction --")
do
    -- The compiler only carries the range. Turning it into a number happens at
    -- claim time, and it is the one piece of arithmetic in the vehicle path.
    local utils = require "PhunMart/utils"

    --- Rollers that pin the ends of the range ZombRand would pick from, [lo, hi).
    local function lowest(lo, _)
        return lo
    end
    local function highest(_, hi)
        return hi - 1
    end

    ok("nil stays nil, so the tank is left alone", utils.rollFraction(nil) == nil)
    ok("a range's floor is its min", utils.rollFraction({min = 0.1, max = 0.25}, lowest) == 0.1,
        tostring(utils.rollFraction({min = 0.1, max = 0.25}, lowest)))
    ok("a range's ceiling is its max", utils.rollFraction({min = 0.1, max = 0.25}, highest) == 0.25,
        tostring(utils.rollFraction({min = 0.1, max = 0.25}, highest)))
    ok("a plain number passes through", utils.rollFraction(0.4) == 0.4)
    ok("a fixed range needs no roll at all", utils.rollFraction({min = 0.2, max = 0.2}, function()
        error("rolled when min == max")
    end) == 0.2)

    -- These come out of a config file someone typed by hand.
    ok("a reversed range is read the right way up", utils.rollFraction({min = 0.9, max = 0.2}, lowest) == 0.2)
    ok("more than a full tank clamps to full", utils.rollFraction(1.7) == 1)
    ok("less than empty clamps to empty", utils.rollFraction(-0.5) == 0)
    ok("text is nil rather than a crash", utils.rollFraction("half") == nil)
end

print("-- a group naming a special that no longer exists --")
do
    -- The vehicle_* specials were deleted rather than kept as shims, which is
    -- only safe because an offer whose reward does not resolve is dropped.
    -- If it were ever kept instead, a group left pointing at a removed key
    -- would sell cars and hand over nothing.
    local offer, count, logger = compileOffer({
        defaults = {
            price = "cheap",
            reward = "vehicle_deleted"
        },
        items = {"SmallCar"}
    })
    ok("the offer is dropped, not sold empty", count == 0, "got " .. tostring(count) .. " offers")
    ok("and the reason names the missing key",
        #logger.errors > 0 and table.concat(logger.errors, " "):find("vehicle_deleted") ~= nil,
        logger.errors[1] or "no error logged")
    ok("nothing was handed over", offer == nil)
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
