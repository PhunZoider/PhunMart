-- Covers Compiler.previewGroup: what a group would put on a shelf, worked out
-- without a pool to put it in.
--
-- A group is never compiled alone in the real pipeline, so the preview builds
-- the smallest pool that could hold it and compiles that. The things worth
-- pinning are the deliberate differences from a real compile, because each one
-- exists to answer a question the preview was opened to ask:
--   * a disabled group still shows its contents
--   * an offer with no price is kept and flagged, rather than dropped silently
-- and the thing that must NOT differ: a real compile still drops it.
--
-- Run: luajit test_compiler_preview.lua   (or run.cmd, which runs all of them)

local here = arg[0]:match("^(.*)[/\\][^/\\]*$") or "."
local root = arg[1] or (here .. "/../..")
package.path = here .. "/?.lua;" .. package.path

local harness = require "harness"

local shared = root .. "/Contents/mods/PhunMart2/common/media/lua/shared"
local server = root .. "/Contents/mods/PhunMart2/common/media/lua/server"
package.path = shared .. "/?.lua;" .. server .. "/?.lua;" .. package.path

harness.installGlobals()

local ITEMS = {
    ["Base.Axe"] = true,
    ["Base.Saw"] = true,
    ["Base.Hammer"] = true
}
local CATEGORY = {
    ["Base.Axe"] = "Tools",
    ["Base.Saw"] = "Tools",
    ["Base.Hammer"] = "Building"
}

local function scriptItem(full)
    return {
        getFullName = function()
            return full
        end,
        getDisplayName = function()
            return full
        end,
        getDisplayCategory = function()
            return CATEGORY[full] or "None"
        end
    }
end

_G.getScriptManager = function()
    return {
        getVehicle = function()
            return nil
        end,
        FindItem = function(_, itemType)
            local full = itemType:find("%.") and itemType or ("Base." .. itemType)
            return ITEMS[full] and scriptItem(full) or nil
        end,
        getAllItems = function()
            local all = {}
            for full in pairs(ITEMS) do
                table.insert(all, scriptItem(full))
            end
            table.sort(all, function(a, b)
                return a:getFullName() < b:getFullName()
            end)
            return {
                size = function()
                    return #all
                end,
                get = function(_, i)
                    return all[i + 1]
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

--- The defs a preview is compiled against: whatever groups the caller passes,
--- plus one price to point at.
local function defsWith(groups)
    return {
        prices = {
            cheap = {
                kind = "change",
                amount = 10
            }
        },
        specials = {},
        conditionsDefs = {},
        items = {},
        groups = groups,
        pools = {},
        shops = {}
    }
end

--- Item keys in a preview result, sorted, so assertions read as sets.
local function itemsOf(pool)
    local out = {}
    for _, offer in pairs(pool and pool.offers or {}) do
        table.insert(out, offer.item)
    end
    table.sort(out)
    return out
end

local function contains(list, want)
    for _, v in ipairs(list) do
        if v == want then
            return true
        end
    end
    return false
end

print("-- a plain group --")
do
    local pool = Compiler.previewGroup(defsWith({
        g = {
            defaults = {price = "cheap"},
            items = {"Base.Axe", "Base.Saw"}
        }
    }), "g")
    local items = itemsOf(pool)
    ok("both items are previewed", #items == 2, "got " .. #items)
    ok("by name", contains(items, "Base.Axe") and contains(items, "Base.Saw"))
end

print("-- a group built from a category --")
do
    -- The case the preview exists for: the definition names a category, and
    -- what that stands for is not written down anywhere an admin can read.
    local pool = Compiler.previewGroup(defsWith({
        g = {
            defaults = {price = "cheap"},
            categories = {"Tools"}
        }
    }), "g")
    local items = itemsOf(pool)
    ok("the category is expanded", #items == 2, "got " .. #items)
    ok("to the items in it", contains(items, "Base.Axe") and contains(items, "Base.Saw"))
    ok("and nothing from another category", not contains(items, "Base.Hammer"))
end

print("-- a disabled group --")
do
    local pool = Compiler.previewGroup(defsWith({
        g = {
            enabled = false,
            defaults = {price = "cheap"},
            items = {"Base.Axe"}
        }
    }), "g")
    ok("still shows its contents", #itemsOf(pool) == 1,
        "a switched-off group is exactly what someone opens a preview to inspect")
end

print("-- a group with no price --")
do
    local pool = Compiler.previewGroup(defsWith({
        g = {
            items = {"Base.Axe"}
        }
    }), "g")
    local offers = pool and pool.offers or {}
    local kept
    for _, offer in pairs(offers) do
        kept = offer
    end
    ok("the offer is kept rather than dropped", kept ~= nil)
    ok("and flagged as having no price", kept and kept.meta and kept.meta.noPrice == true)
    ok("with no price on it", kept and kept.price == nil)
end

print("-- the real compile is unchanged --")
do
    -- The preview's leniency must not leak: an offer with no price cannot be
    -- sold, so a shop must never receive one.
    local ctx = defsWith({
        g = {
            items = {"Base.Axe"}
        }
    })
    ctx.pools = {p = {sources = {groups = {"g"}}}}
    local runtime = Compiler.compileAll(ctx)
    local count = 0
    for _ in pairs(runtime.pools.p.offers or {}) do
        count = count + 1
    end
    ok("a priceless offer is still dropped from a real pool", count == 0)
end

print("-- a group that does not exist --")
do
    local pool = Compiler.previewGroup(defsWith({}), "nope")
    ok("returns nothing rather than erroring", pool == nil)
end

---------------------------------------------------------------------------


print("-- an item currency reaches the whole price ladder --")
do
    -- currency_base exactly as the Currency tool and GUIDE_ITEM_CURRENCY write
    -- it: kind items, one line naming the item, and a factor to bring a ladder
    -- written in cents down to a count of things.
    --
    -- The line carries an amount of its own, so every child inherits that 1. If
    -- the line is allowed to win, the entire ladder compiles to one item and a
    -- nickel costs the same as fifty dollars. That is what this pins.
    local function itemPriceOf(priceKey, amount)
        local defs = {
            prices = {
                currency_base = {
                    kind = "items",
                    items = {{
                        item = "Base.Money",
                        amount = 1
                    }},
                    factor = 0.04
                },
                [priceKey] = {
                    inherit = "currency_base",
                    amount = amount
                }
            },
            specials = {},
            conditionsDefs = {},
            items = {},
            pools = {},
            shops = {},
            groups = {
                g = {
                    defaults = {price = priceKey},
                    items = {"Base.Axe"}
                }
            }
        }
        local pool = Compiler.previewGroup(defs, "g")
        for _, offer in pairs(pool and pool.offers or {}) do
            local line = offer.price and offer.price.items and offer.price.items[1]
            return line and line.amount, line and line.item
        end
    end

    local cheap, item = itemPriceOf("currency_25", 25)
    ok("the cheap end scales to one", cheap == 1, tostring(cheap))
    ok("and names the currency item", item == "Base.Money", tostring(item))

    local dear = itemPriceOf("currency_500", 500)
    -- ceil(500 * 0.04). The table in GUIDE_ITEM_CURRENCY says 20, and the shop
    -- window has always drawn 20; only the compiler disagreed.
    ok("the dear end is twenty, not one", dear == 20, tostring(dear))

    -- A barter basket has no top-level amount to bridge and every line means
    -- its own count, so nothing here may touch it.
    local defs = {
        prices = {
            basket = {
                kind = "items",
                items = {{
                    item = "Base.Money",
                    amount = 2
                }, {
                    item = "Base.Saw",
                    amount = 3
                }}
            }
        },
        specials = {},
        conditionsDefs = {},
        items = {},
        pools = {},
        shops = {},
        groups = {
            g = {
                defaults = {price = "basket"},
                items = {"Base.Axe"}
            }
        }
    }
    local pool = Compiler.previewGroup(defs, "g")
    local lines
    for _, offer in pairs(pool and pool.offers or {}) do
        lines = offer.price and offer.price.items
    end
    ok("a basket keeps both of its lines", lines and #lines == 2, lines and tostring(#lines))
    ok("each at its own count", lines and lines[1].amount == 2 and lines[2].amount == 3)
end
print("")
print("passed: " .. passed .. "  failed: " .. failed)
if failed > 0 then
    os.exit(1)
end
