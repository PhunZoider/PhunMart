-- Covers the three registries another mod extends PhunMart through, plus the
-- compiler's shop-definition passthrough that makes the third one usable.
--
-- All four exist for the same reason: a mod that adds a machine of its own has
-- to be able to add the tab that administers it, the window mode that operates
-- it, and the flag that tells the two apart -- without editing this mod. Each
-- is a small amount of table work, and each has a failure mode that is silent
-- in the game and obvious here:
--   * a tab or mode registered twice appearing twice
--   * order ties resolving differently between two openings, because
--     table.sort is not stable
--   * a shop-def flag being dropped between the definition and the runtime, so
--     the mode keyed on it never appears and nothing says why
--
-- Run: luajit test_extension_points.lua   (or run.cmd, which runs all of them)

local here = arg[0]:match("^(.*)[/\\][^/\\]*$") or "."
local root = arg[1] or (here .. "/../..")
package.path = here .. "/?.lua;" .. package.path

local harness = require "harness"

local shared = root .. "/Contents/mods/PhunMart2/common/media/lua/shared"
package.path = shared .. "/?.lua;" .. package.path

harness.installGlobals()

_G.getScriptManager = function()
    return {
        getVehicle = function()
            return nil
        end,
        FindItem = function()
            return nil
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

_G.SandboxVars = {
    PhunMart = {
        Debug = false
    }
}
_G.LuaEventManager = {
    AddEvent = function()
    end
}
_G.getSandboxOptions = function()
    return {
        getOptionByName = function()
            return nil
        end
    }
end
_G.ModData = {
    getOrCreate = function()
        return {}
    end
}

require "PhunMart/core"
require "PhunMart/compiler"
local Core = PhunMart
local Compiler = Core.compiler

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

local function keysOf(list)
    local out = {}
    for i, entry in ipairs(list) do
        out[i] = entry.key
    end
    return table.concat(out, ",")
end

---------------------------------------------------------------------------

print("-- admin tab registry --")
do
    Core.ui.adminTabs = {}

    Core.registerAdminTab({
        key = "b",
        order = 20
    })
    Core.registerAdminTab({
        key = "a",
        order = 10
    })
    Core.registerAdminTab({
        key = "z",
        order = 1000
    })

    ok("orders the strip by order, not registration", keysOf(Core.adminTabsInOrder()) == "a,b,z")

    Core.registerAdminTab({
        key = "mid",
        order = 15
    })
    ok("a mod can sit between two shipped tabs", keysOf(Core.adminTabsInOrder()) == "a,mid,b,z")

    -- The gap Tools sits in: whatever arrives later, it stays last.
    Core.registerAdminTab({
        key = "late",
        order = 900
    })
    ok("a far-out order keeps a tab last", keysOf(Core.adminTabsInOrder()) == "a,mid,b,late,z")
end

print("-- registering the same key twice --")
do
    Core.ui.adminTabs = {}
    Core.registerAdminTab({
        key = "a",
        order = 10,
        label = "first"
    })
    Core.registerAdminTab({
        key = "a",
        order = 10,
        label = "second"
    })

    local tabs = Core.adminTabsInOrder()
    ok("replaces rather than duplicating", #tabs == 1, "got " .. #tabs .. " tabs")
    ok("the later registration wins", tabs[1] and tabs[1].label == "second")
end

print("-- a spec with no key --")
do
    Core.ui.adminTabs = {}
    ok("is refused", Core.registerAdminTab({
        order = 10
    }) == false)
    ok("and is not registered", #Core.adminTabsInOrder() == 0)
    ok("a non-table is refused too", Core.registerAdminTab("nope") == false)
end

print("-- ties keep registration order --")
do
    -- table.sort is not stable, so without the registration index carried
    -- through as a tiebreak these could come back either way round, and
    -- differently between two openings of the same window.
    Core.ui.adminTabs = {}
    for _, key in ipairs({"one", "two", "three", "four", "five", "six"}) do
        Core.registerAdminTab({
            key = key,
            order = 50
        })
    end
    local first = keysOf(Core.adminTabsInOrder())
    ok("all at one order come back in the order given", first == "one,two,three,four,five,six", first)
    ok("and again the same way", keysOf(Core.adminTabsInOrder()) == first)
end

print("-- an order that was never set --")
do
    Core.ui.adminTabs = {}
    Core.registerAdminTab({
        key = "unordered"
    })
    Core.registerAdminTab({
        key = "ordered",
        order = 10
    })
    ok("sorts as zero, ahead of everything positive", keysOf(Core.adminTabsInOrder()) == "unordered,ordered")
end

---------------------------------------------------------------------------

print("-- shop mode registry --")
do
    Core.ui.shopModes = {}

    Core.registerShopMode({
        key = "buy",
        order = 10
    })
    Core.registerShopMode({
        key = "sell",
        order = 20,
        flag = "consignment"
    })

    local plain = Core.shopModesFor({
        key = "shop1"
    })
    ok("a mode with no flag shows on an ordinary machine", keysOf(plain) == "buy")

    local market = Core.shopModesFor({
        key = "shop2",
        consignment = true
    })
    ok("a flagged mode shows on the machine that carries it", keysOf(market) == "buy,sell")

    local falseFlag = Core.shopModesFor({
        key = "shop3",
        consignment = false
    })
    ok("a flag set false is still not a match", keysOf(falseFlag) == "buy")
end

print("-- applies, for what a flag cannot express --")
do
    Core.ui.shopModes = {}
    Core.registerShopMode({
        key = "buy",
        order = 10
    })
    Core.registerShopMode({
        key = "stocked",
        order = 20,
        applies = function(data)
            return data and data.offers ~= nil
        end
    })

    ok("applies gates the mode", keysOf(Core.shopModesFor({})) == "buy")
    ok("and admits it when satisfied", keysOf(Core.shopModesFor({
        offers = {}
    })) == "buy,stocked")
end

print("-- flag and applies together --")
do
    Core.ui.shopModes = {}
    Core.registerShopMode({
        key = "both",
        order = 10,
        flag = "consignment",
        applies = function(data)
            return data.ready == true
        end
    })

    ok("both must pass: flag alone is not enough", #Core.shopModesFor({
        consignment = true
    }) == 0)
    ok("applies alone is not enough either", #Core.shopModesFor({
        ready = true
    }) == 0)
    ok("together they admit the mode", #Core.shopModesFor({
        consignment = true,
        ready = true
    }) == 1)
end

print("-- shopModesFor with no data --")
do
    Core.ui.shopModes = {}
    Core.registerShopMode({
        key = "buy",
        order = 10
    })
    Core.registerShopMode({
        key = "sell",
        order = 20,
        flag = "consignment"
    })
    -- The window calls this before it has ever been handed a payload.
    local okCall, modes = pcall(Core.shopModesFor, nil)
    ok("does not error", okCall, tostring(modes))
    ok("and offers only the unflagged modes", okCall and keysOf(modes) == "buy")
end

---------------------------------------------------------------------------

print("-- compiler: shop definition passthrough --")

local function compileShop(shopDef, passthrough)
    Core.shopDefPassthrough = passthrough or {}
    local ctx = {
        prices = {},
        specials = {},
        conditionsDefs = {},
        items = {},
        groups = {},
        pools = {},
        shops = {
            TestShop = shopDef
        }
    }
    local runtime = Compiler.compileAll(ctx)
    return runtime.shops.TestShop
end

do
    local compiled = compileShop({
        category = "Test",
        probability = 5
    })
    ok("a shop compiles at all", compiled ~= nil)
    ok("named fields come through", compiled and compiled.probability == 5)
end

print("-- stocksNothing --")
do
    local compiled = compileShop({
        category = "Test",
        stocksNothing = true,
        poolSets = {}
    })
    -- Placement reads this off the compiled table, so it being dropped here is
    -- the difference between a machine that can be placed and one that cannot.
    ok("survives compilation", compiled and compiled.stocksNothing == true)

    local plain = compileShop({
        category = "Test"
    })
    ok("is absent when not declared", plain and plain.stocksNothing == nil)
end

print("-- light --")
do
    local compiled = compileShop({
        category = "Test",
        light = {
            r = 10,
            g = 20,
            b = 30,
            radius = 4
        }
    })
    -- The client reads colour and reach off the compiled table. Dropped here
    -- and every machine of this shop quietly falls back to the default white.
    ok("survives compilation", compiled and compiled.light ~= nil and compiled.light.r == 10 and
        compiled.light.radius == 4)

    local dark = compileShop({
        category = "Test",
        light = false
    })
    -- false has to arrive as false rather than as nil, because nil is the shop
    -- that never said anything and takes the default.
    ok("and false is not the same as absent", dark and dark.light == false)

    local plain = compileShop({
        category = "Test"
    })
    ok("which is absent when not declared", plain and plain.light == nil)
end

print("-- a flag another mod asked to keep --")
do
    local dropped = compileShop({
        category = "Test",
        consignment = true
    })
    ok("is dropped when unregistered", dropped and dropped.consignment == nil)

    local kept = compileShop({
        category = "Test",
        consignment = true
    }, {"consignment"})
    ok("and kept once registered", kept and kept.consignment == true)
end

print("-- passthrough cannot overwrite a named field --")
do
    -- Naming a field the compiler already decides would let a definition put
    -- back the raw value the compiler deliberately replaced -- poolSets being
    -- the one that matters, since the compiled form has resolved prices in it.
    local compiled = compileShop({
        category = "Test",
        poolSets = {{
            keys = {"p"}
        }},
        probability = 5
    }, {"poolSets", "probability"})

    ok("probability is still the compiler's", compiled and compiled.probability == 5)
    ok("poolSets is still the compiled form", compiled and compiled.poolSets ~= nil and
        compiled.poolSets[1] ~= nil and compiled.poolSets[1].keys ~= nil)
end

print("-- passthrough naming something absent --")
do
    local compiled = compileShop({
        category = "Test"
    }, {"neverSet"})
    ok("leaves no key behind", compiled and compiled.neverSet == nil)
end

---------------------------------------------------------------------------

print("")
print("passed: " .. passed .. "  failed: " .. failed)
if failed > 0 then
    os.exit(1)
end
