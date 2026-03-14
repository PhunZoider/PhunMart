require "PhunMart/core"
local Core = PhunMart

local shopsData = {}

local function getRangeResult(data, key, defaultValue)
    local range = {
        min = defaultValue or 1,
        max = defaultValue or 10
    }

    if data[key] then
        if type(data[key]) == "number" then
            range.min = data[key]
            range.max = data[key]
        else
            if data[key].min then
                range.min = data[key].min
            end
            if data[key].max then
                range.max = data[key].max
            end
        end
    end

    return {
        min = math.min(range.min, range.max),
        max = math.max(range.min, range.max)
    }
end

local function formatPool(data)

    local result = {}
    for k, v in pairs(data) do
        result[k] = {
            currency = data.currency or nil,
            price = data.price and getRangeResult(data, "price", 25) or nil,
            totalItems = data.totalItems and
                getRangeResult(data, "totalItems", Core.settings.DefaultNumOfItemsWhenRestocking or 1) or nil,
            items = v.items or {},
            categories = v.categories or {},
            include = v.include or {},
            exclude = v.exclude or {},
            blacklist = v.blacklist or {}
        }
    end

end

local function getShopPool(entry)

    -- pools = {{
    -- currency = Base.money,
    -- price = {min, max},
    -- totalItems = {min, max},
    -- zones = { difficulty = {3,4}},
    -- enabled = false
    -- probability = 10
    -- when = {months = {}}} 
    -- keys = { "clothing_all_hats" }

    -- }},

    local result = {
        currency = entry.currency or nil,
        price = entry.price and getRangeResult(entry, "price", 25) or nil,
        totalItems = entry.totalItems and
            getRangeResult(entry, "totalItems", Core.settings.DefaultNumOfItemsWhenRestocking or 1) or nil,
        zones = entry.zones or {},
        enabled = entry.enabled == true or nil,
        probability = entry.probability or nil,
        when = entry.when or nil,
        keys = entry.keys or {}
    }

    return result

end

local function getShopPools(data)

    local results = {}

    for i, entry in ipairs(data.pools or {}) do
        local status, err = pcall(function()
            table.insert(results, getShopPool(entry or {}))
        end)
        if not status then
            Core.debugLn("Error formatting pool " .. tostring(i) .. " of " .. tostring(data.key) .. ": " .. tostring(err))
        end
    end
    return results

end

local function formatShop(data)

    local result = {
        label = data.label or data.key,
        group = data.group,
        distance = data.distance or Core.settings.DefaultDistanceBetweenGroups or 0,
        probability = data.probability or 15,
        filters = data.filters or {},
        reroll = data.reroll or 0,
        powered = data.powered == true,
        restock = data.restock or 48,
        pools = getShopPools(data),
        currency = data.currency or "change",
        price = getRangeResult(data, "price", 25),
        totalItems = getRangeResult(data, "totalItems", Core.settings.DefaultNumOfItemsWhenRestocking or 1),
        image = data.image or "machine-none.png",
        sprites = data.sprites or {"phunmart_01_0", -- east
        "phunmart_01_1", -- south
        "phunmart_01_2", -- west
        "phunmart_01_3" -- north
        },
        unpoweredSprites = {"phunmart_01_4", -- east
        "phunmart_01_5", -- south
        "phunmart_01_6", -- west
        "phunmart_01_7" -- north
        }
    }

    return result
end

local function formatGroup(data)

    local result = {
        categories = data.categories or {},
        include = data.include or {},
        exclude = data.exclude or {}
    }

end

local function getCoreShops()

    local results = {}
    local order = 0
    local all = Core.utils.merge(shopsData, Core.extended or {})
    for key, entry in pairs(all) do
        local status, err = pcall(function()
            results[key] = formatShop(entry)
        end)
        if not status then
            Core.debugLn("Error in shop '" .. key .. "': " .. tostring(err))
        end

    end
    return results
end

local function getModifications()

    local data = {}
    if not isClient() then
        -- this is a server or local game
        local data = Core.fileUtils.loadTable(Core.consts.shopsLuaFile)
        if not data then
            Core.debugLn("missing ./lua/" .. Core.consts.shopsLuaFile .. ", this is normal if you haven't modified any shops")
        else
            ModData.add(Core.consts.shops, data)
            Core.debugLn("loaded customisations from ./lua/" .. Core.consts.shopsLuaFile)
        end
    end
    data = ModData.get(Core.consts.shops)
    if data == nil then
        data = {}
        ModData.add(Core.consts.shops, data)
    end
    local results = {}
    for key, entry in pairs(data) do
        local status, err = pcall(function()
            results[key] = formatShop(entry)
        end)
        if not status then
            Core.debugLn("Error in modification '" .. key .. "': " .. tostring(err))
        end
    end
    return results
end

function Core:getShops()
    local core = getCoreShops()
    local modified = getModifications() or {}
    local results = Core.utils.merge(modified or {}, core or {})
    return results
end
