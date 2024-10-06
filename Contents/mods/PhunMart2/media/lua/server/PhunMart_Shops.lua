if not isServer() then
    return
end
require "PhunMart_Core"
local PhunMart = PhunMart
local PhunTools = PhunTools

function PhunMart:validateShopDef(shop)
    local issues = {}
    if not shop.abstract and shop.enabled then
        if not shop.key then
            table.insert(issues, "Missing key")
        end
        if not shop.pools or not shop.pools.items or #shop.pools.items < 0 then
            table.insert(issues, "Missing or misconfigured pools " .. tostring(shop.pools) .. " " ..
                tostring((shop.pools or {}).items) .. " ")
        else
            for pi, v in ipairs(shop.pools.items) do
                if not v.keys or #v.keys < 1 then
                    table.insert(issues, "Missing item keys in pool " .. pi)
                end
            end
        end
    end
    return issues
end

function PhunMart:isShopValid(shop)
    local issues = self:validateShopDef(shop)
    if #issues > 0 then
        print("PhunMart: Invalid shop definition for " .. shop.key)
        for _, v in ipairs(issues) do
            print("  - " .. v)
        end
        return false
    end
    return #issues == 0
end

function PhunMart:validateShops()
    local results = {
        total = 0,
        valid = 0,
        invalid = 0,
        abstract = 0,
        disabled = 0,
        issues = {}
    }
    for k, v in pairs(self.defs.shops) do

        results.total = results.total + 1
        if v.abstract == true then
            v.enabled = false
            results.abstract = results.abstract + 1
        elseif not v.enabled then
            results.disabled = results.disabled + 1
        else
            local issues = self:validateShopDef(v)
            if #issues > 0 then
                print("Issue with shop " .. v.key .. " (" .. #issues .. " issues)")
                PhunTools:printTable(v)
                v.enabled = false
                results.issues[v.key] = issues
                results.invalid = results.invalid + 1
            else
                results.valid = results.valid + 1
            end
        end
    end
    return results
end

local function formatFilter(filters)
    local f = {}
    for k, v in pairs(filters) do
        if k == "tags" and type(v) == "string" then
            f[k] = PhunTools:splitString(v)
        elseif k == "files" and type(v) == "string" then
            f[k] = PhunTools:splitString(v)
        else
            f[k] = PhunTools:deepCopyTable(v)
        end
    end
    return f
end

local function buildPool(shop)
    -- local base = {}
    -- if shop.inherits then
    --     local b = PhunMart.defs.shops[shop.inherits] and PhunTools:deepCopyTable(PhunMart.defs.shops[shop.inherits]) or
    --                   nil
    --     if b then
    --         base = b
    --     end
    -- end

    local pools = {
        items = {}
    } -- default to empty pool

    -- copy over any inherited pools
    -- for k, v in pairs(base.pools or {}) do
    --     if k ~= "items" then
    --         pools[k] = v
    --     else
    --         for _, i in ipairs(v) do
    --             table.insert(pools.items, i)
    --         end
    --     end
    -- end

    if shop.filters then
        -- top level filter, move into first pool item
        local filters = formatFilter(shop.filters)
        if not pools.items[1] then
            pools.items[1] = {
                filters = {}
            }
        end
        for k, v in pairs(filters) do
            pools.items[1].filters[k] = v
        end
    end

    for k, v in pairs(shop.pools or {}) do
        if k ~= "items" then
            pools[k] = v
        else
            for index, item in ipairs(v) do
                -- iterate through each pool.items entry and merge with any existing pool.item entry (of the same index)
                if not pools.items[index] then
                    pools.items[index] = {}
                end

                local existing = pools.items[index]

                for kk, vv in pairs(item) do
                    if kk == "filters" then
                        existing.filters = existing.filters or {}
                        local f = formatFilter(vv)
                        for fk, fv in pairs(f or {}) do
                            existing.filters[fk] = fv
                        end
                    else
                        existing[kk] = vv
                    end
                end

                if pools[index] then
                    for _, j in ipairs(i) do
                        table.insert(pools[index], j)
                    end
                else
                    pools[index] = i
                end
            end
        end
    end

    if shop.items then
        -- shop has a specific top level list of keys to always use, so add to first pools.item list
        if not pools.items[1] then
            pools.items[1] = {
                keys = {}
            }
        end
        pools.items[1].keys = shop.items
    end
    return pools

end

local populatePoolItems = function(pool)
    local items = PhunMart.defs.items

    for _, v in ipairs(pool.items) do

        if not v.keys then
            v.keys = {}
        end
        if not v.filters then
            v.filters = {}
        end

        local itemList = {}

        if v.filters.files then
            -- filter items down to those that are in the specified files
            itemList = PhunMart:filterItemListByFile(v.filters.files)
        else
            -- default to ALL items
            itemList = items
        end

        if v.filters.tags then
            -- filter items down to those that have the specified tags
            itemList = PhunMart:filterItemListByTags(v.filters.tags, not v.filters.excludeTagless, itemList)
        end

        if v.filters.level then
            -- filter items down to those that have the specified level
            itemList = PhunMart:filterItemListByLevel(v.filters.level, itemList)
        end

        for itemKey, item in pairs(itemList) do
            if not item.abstract and item.enabled then
                table.insert(v.keys, itemKey)
            end
        end
    end

end

function PhunMart:formatShop(data)

    local base = {}
    if data.inherits then
        local b = self.defs.shops[data.inherits]
        if b then
            base = b
        end
    end

    -- if data.key == "shop-weapons-3" or data.key == "shop-fish" then
    --     PhunTools:printTable(data)
    -- end

    local formatted = {
        key = data.key,
        label = data.label or base.label or "Vending Machine",
        fills = data.fills or base.fills or nil,
        probability = data.probability or base.probability or nil,
        restock = data.restock or base.restock or nil,
        backgroundImage = data.backgroundImage or base.backgroundImage or "machine-none",
        layout = data.layout or base.layout or nil,
        pools = data.pools,
        methods = data.methods or base.methods or {},
        zones = base.zones or nil,
        difficulty = data.difficulty or base.difficulty or nil,
        file = data.file or nil,
        mod = data.mod or base.mod or nil,
        abstract = data.abstract,
        sprites = data.sprites or base.sprites or {},
        reservations = data.reservations or base.reservations or {},
        currency = data.currency or base.currency or "Base.Money",
        basePrice = data.basePrice or base.basePrice or 0,
        inflationBase = data.inflationBase or base.inflationBase or 0,
        maxRestock = data.maxRestock or base.maxRestock or 0, -- maximum number of restocks before shop will re-roll. nil or 0 for never
        -- minimum distance between duplicate instances
        minDistance = data.minDistance or base.minDistance,
        type = data.type or base.type or nil,
        generate = true,
        enabled = data.enabled ~= false, -- do not inherit enabled and default to true
        requiresPower = (data.requiresPower == true or data.requiresPower == false) and data.requiresPower or
            (base.requiresPower == true or base.requiresPower == false) and base.requiresPower or false
    }

    if data.generate == false or base.generated == false then
        formatted.generate = false
    end

    if data.sprites then
        for k, v in pairs(data.sprites) do
            formatted.sprites[k] = v
        end
    end

    if data.zones then
        formatted.zones = formatted.zones or {}
        for k, v in pairs(data.zones) do
            formatted.zones[k] = v
        end
    end

    if formatted.reservations and #formatted.reservations > 0 then
        for _, v in ipairs(formatted.reservations) do
            if formatted.enabled then
                self.reservations[v] = formatted.key
            else
                print("PhunMart: Skipping reservation " .. v .. " for " .. formatted.key .. " as it is not enabled")
            end
        end
    else
        formatted.reservations = false
    end

    formatted.pools = PhunTools:mergeTables(base.pools, buildPool(data))
    -- if base.pools then
    --     pools = PhunTools:deepCopyTable(base.pools)
    -- end
    -- if data.pools then
    --     if pools == nil then
    --         pools = data.pools
    --     else
    --         if data.pools.items then
    --             if pools.items == nil then
    --                 pools.items = data.pools.items
    --             else
    --                 for i, v in ipairs(data.pools.items) do
    --                     if pools.items[i] then
    --                         for k, vv in pairs(v) do
    --                             print(k, " <-------------")
    --                             pools.items[i][k] = vv
    --                         end
    --                     else
    --                         pools.items[i] = v
    --                     end
    --                     table.insert(pools.items, v)
    --                 end
    --             end
    --         end
    --     end
    -- end

    -- map out sprites for quick id of shop type and direction
    formatted.spriteMap = {}
    if formatted.sprites and formatted.sprites.sheet and formatted.sprites.row then

        local row = (formatted.sprites.row - 1) * 8
        local direction = {"east", "south", "west", "north", "east", "south", "west", "north"}
        for j = 0, 7 do
            formatted.spriteMap["phunmart_0" .. formatted.sprites.sheet .. "_" .. (row + j)] = direction[j + 1]
            self.spriteMap["phunmart_0" .. formatted.sprites.sheet .. "_" .. (row + j)] = direction[j + 1]
        end

    end

    if not formatted.abstract then
        populatePoolItems(formatted.pools)
    end

    return formatted
end

--[[

    LOADING QUEUE

]] --

-- add all item files we WANT to load up
function PhunMart:loadFilesForShopQueue()
    -- get list of filename from PhunMart_ShopDefs.ini
    local files = PhunTools:loadLinesIntoTable("PhunMart_ShopDefs.ini")
    if not files then
        -- none were specified so default to PhunMart_Shops
        files = {"PhunMart_Shops"}
    end
    for _, v in ipairs(files or {}) do
        self:queueFileForShopProcessing(v)
    end
    triggerEvent(self.events.OnItemQueueFilesReadyToProcess)
end

-- iterate through file queued and add contents to transform queue
function PhunMart:processFilesToShopQueue()

    for _, v in ipairs(self.loaders.shopFiles) do
        v.status = "processing"
        -- load the contents of the file into queu
        self:loadFileContentsToShopQueue(v.file .. ".lua")
        v.status = "processed"
    end
    triggerEvent(self.events.OnShopQueueFilesReadyToProcess)
end

-- add a file to the item processing queue
function PhunMart:loadFileContentsToShopQueue(file)
    local data = PhunTools:loadTable(file)
    for _, v in ipairs(data) do
        v.file = file
        self:queueRawShopToProcess(v, file)
    end
    triggerEvent(self.events.OnShopQueueProcessed)
end

--[[

    TRANSFORM QUEUE

]] --

-- iterate through raw data to tranform
function PhunMart:processShopTransformQueue()
    local results = {
        all = {},
        files = {}
    }
    -- local tempSpriteMap = {}
    for _, v in ipairs(self.loaders.shops or {}) do
        if v.status == "pending" then
            local f = v.data.file or "none"
            local r = self:transformToShopDef(v.data)
            -- if r and r.sprites then
            --     local tmpKey = tostring(r.sprites.sheet) .. "_" .. tostring(r.sprites.row)
            --     if not tempSpriteMap[tmpKey] then
            --         tempSpriteMap[tmpKey] = {
            --             sheet = r.sprites.sheet,
            --             row = r.sprites.row
            --         }
            --     end
            -- end
            if not results.all[r.status] then
                results.all[r.status] = 0
            end
            results.all[r.status] = results.all[r.status] + 1
            if not results.files[f] then
                results.files[f] = {}
            end
            if not results.files[f][r.status] then
                results.files[f][r.status] = 0
            end
            results.files[f][r.status] = results.files[f][r.status] + 1
            v.status = r.status
        else
            print("PhunMart: Skipping shop as it is not in pending state")
        end
    end

    -- local dir = {"east", "south", "west", "north", "east", "south", "west", "north"}
    -- for k, v in pairs(tempSpriteMap) do
    --     for i = 0, 7 do
    --         self.spriteMap["phunmart_0" .. v.sheet .. "_" .. (v.row + i)] = dir[i + 1]
    --     end
    -- end

    print(" --------- SPRITE MAP --------------")
    PhunTools:printTable(self.spriteMap)

    return results
end

-- transform raw data into item def
function PhunMart:transformToShopDef(data)

    local formatted = self:formatShop(data)
    local status = "success"
    if formatted.abstract then
        formatted.enabled = false
        status = "abstract"
    elseif formatted.mod and not getActivatedMods():contains(formatted.mod) then
        -- we will still leave in defs as something may inherit from it
        formatted.enabled = false
        status = "modinactive"
    end
    -- add to defs
    self.defs.shops[formatted.key] = formatted

    return {
        status = status,
        key = formatted.key,
        data = formatted
    }
end
