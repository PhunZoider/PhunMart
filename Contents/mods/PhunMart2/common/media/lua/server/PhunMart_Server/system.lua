if isClient() then
    return
end
require "Map/SGlobalObjectSystem"
local Core = PhunMart

local Commands = require "PhunMart_Server/commands"
Core.ServerSystem = SGlobalObjectSystem:derive("SPhunMartSystem")
local ServerSystem = Core.ServerSystem

function ServerSystem:new()
    local o = SGlobalObjectSystem.new(self, "phunmart")
    return o
end

function ServerSystem:removeLuaObject(luaObject)
    Core:removeInstance(luaObject)
    SGlobalObjectSystem.removeLuaObject(self, luaObject)
end

function ServerSystem:removeInvalidInstanceData()

    local checked = {}
    local instanceCount = 0
    for k, v in pairs(Core.instances) do
        checked[k] = true
        instanceCount = instanceCount + 1
    end
    local objectCount = 0
    for i = 1, self:getLuaObjectCount() do
        local obj = self:getLuaObjectByIndex(i)
        checked[obj.x .. "_" .. obj.y .. "_" .. obj.z] = nil
        objectCount = objectCount + 1
    end
    local removed = 0
    for k, v in pairs(checked) do
        Core.instances[k] = nil
        removed = removed + 1
    end
    Core.debugLn("Removed " .. tostring(removed) .. " invalid instances")

end

function ServerSystem.addToWorld(square, shop, direction)
    local index = 4
    if direction == IsoDirections.E then
        index = 1
    elseif direction == IsoDirections.S then
        index = 2
    elseif direction == IsoDirections.W then
        index = 3
    end
    local c = Core
    local sprite = c.shops[shop].sprites[index]
    local isoObject = IsoThumpable.new(square:getCell(), square, sprite, false, {})
    ServerSystem.initializeShopObject(isoObject)
    square:AddSpecialObject(isoObject, -1)
    triggerEvent("OnObjectAdded", isoObject)
    isoObject:transmitCompleteItemToClients()

end

function ServerSystem.initializeShopObject(obj)
    obj:setName("PhunMartVendingMachine")

    local sprite = obj:getSprite()
    local props = sprite:getProperties()
    local customName = props:get("CustomName")

    local data = {
        type = customName,
        facing = tostring(obj:getFacing()),
        created = GameTime:getInstance():getWorldAgeHours(),
        x = obj:getX(),
        y = obj:getY(),
        z = obj:getZ()
    }
    obj:setModData(data)
    Core:addInstance(data)
end

function ServerSystem:initSystem()
    SGlobalObjectSystem.initSystem(self)
    -- Specify GlobalObjectSystem fields that should be saved.
    self.system:setModDataKeys({})

    -- Specify GlobalObject fields that should be saved.
    -- ids = array of all shop ids that have been generated
    -- chunks = array of all chunk coordinates that have shops?
    self.system:setObjectModDataKeys({'type', 'facing', 'created', 'x', 'y', 'z', 'lastRestock', 'offers'})
end

function ServerSystem:isValidIsoObject(isoObject)
    return isoObject:getName() == "PhunMartVendingMachine"
end

function ServerSystem:newLuaObjectAt(x, y, z)
    local globalObject = self.system:newObject(x, y, z)
    return self:newLuaObject(globalObject)
end
function ServerSystem:newLuaObject(globalObject)
    return Core.ServerObject:new(self, globalObject)
end

function ServerSystem:generateRandomShopOnSquare(square, direction)
    direction = direction or "south"
    local shop = Core:generateShop(square)
    if shop ~= nil then
        square:transmitRemoveItemFromSquare(true)
        self.addToWorld(square, shop, direction)
    end
end

-- Resolve a shop object's facing string/enum to an IsoDirections constant.
local function resolveFacing(shopObj)
    local f = shopObj.facing
    if f == "E" or f == IsoDirections.E then
        return IsoDirections.E
    end
    if f == "S" or f == IsoDirections.S then
        return IsoDirections.S
    end
    if f == "W" or f == IsoDirections.W then
        return IsoDirections.W
    end
    return IsoDirections.N
end

-- Build a shop payload table suitable for sending to clients or triggering events.
function ServerSystem.buildShopPayload(shopObj)
    local shopDef = Core.runtime and Core.runtime.shops and Core.runtime.shops[shopObj.type]
    local shopCfg = Core.shops and Core.shops[shopObj.type]
    return {
        key = shopObj:getKey(),
        shopType = shopObj.type,
        location = {
            x = shopObj.x,
            y = shopObj.y,
            z = shopObj.z
        },
        offers = shopObj.offers or {},
        conditionsDefs = Core.runtime and Core.runtime.conditionsDefs,
        background = shopDef and shopDef.background,
        defaultView = shopDef and shopDef.defaultView,
        poolSets = shopDef and shopDef.poolSets,
        lastRestock = shopObj.lastRestock,
        restockFrequency = (shopCfg and shopCfg.restock) or 24
    }
end

function ServerSystem:reroll(location, ignoreDistance)
    local shopObj = self:getLuaObjectAt(location.x, location.y, location.z)
    local square = shopObj:getIsoObject():getSquare()
    local facing = resolveFacing(shopObj)
    local shopname = self:getRandomShop(square:getX(), square:getY())
    square:transmitRemoveItemFromSquare(shopObj:getIsoObject())
    self.addToWorld(square, shopname, facing)
end

function ServerSystem:changeTo(shopName, location)
    local shopObj = self:getLuaObjectAt(location.x, location.y, location.z)
    local square = shopObj:getIsoObject():getSquare()
    local facing = resolveFacing(shopObj)
    square:transmitRemoveItemFromSquare(shopObj:getIsoObject())
    self.addToWorld(square, shopName, facing)
end

function ServerSystem:rerollAll()
    for i = 1, self:getLuaObjectCount() do
        local obj = self:getLuaObjectByIndex(i)
        if obj then
            self:reroll(obj.location)
        end
    end
end

function ServerSystem:openShop(player, args, forceRestock)
    local shop = self:getLuaObjectAt(args.x, args.y, args.z)

    if not shop then
        Core.debugLn("openShop: no shop at " .. args.x .. "," .. args.y .. "," .. args.z)
        return
    end

    if shop:requiresPower() then
        local key = shop:getKey()
        if Core.isLocal then
            Core.pendingShopData = Core.pendingShopData or {}
            Core.pendingShopData[key] = {
                error = "requiresPower"
            }
        else
            sendServerCommand(player, Core.name, Core.commands.openError, {
                key = key,
                message = "requiresPower"
            })
        end
        Core.debugLn("openShop: shop requires power")
        return
    end

    if shop:requiresRestock() or forceRestock then
        -- restock builds offers, saves, and transmits modData to all clients
        shop:restock()
    end

    local inventoryData = ServerSystem.buildShopPayload(shop)

    if Core.isLocal then
        Core.pendingShopData = Core.pendingShopData or {}
        Core.pendingShopData[inventoryData.key] = inventoryData
    else
        sendServerCommand(player, Core.name, Core.commands.requestShop, {
            playerIndex = player:getPlayerNum(),
            key = inventoryData.key,
            data = inventoryData
        })
    end

end

function ServerSystem:getLoadedObjects()
    local result = {}
    for i = 1, self:getLuaObjectCount() do
        local obj = self:getLuaObjectByIndex(i)
        if obj and obj.key then
            table.insert(result, obj)
        end
    end
    return result
end

function ServerSystem:closestShopKeysTo(x, y)

    local shops = {}
    for k, v in pairs(Core.shops) do
        if Core.settings["ShopProbability" .. k] > 0 then
            -- set default distance to max per group
            shops[k] = 9999999
        end
    end

    for i = 1, self.system:getObjectCount() do
        local obj = self.system:getObjectByIndex(i)
        if obj then
            local data = obj:getModData()
            local dx = x - obj.x
            local dy = y - obj.y
            local distance = math.sqrt(dx * dx + dy * dy)
            if distance < shops[data.type] then
                shops[data.type] = distance
            end
        end
    end
    return shops

end

-- Returns true if at least one pool in the shop's poolSets passes the zone filter at (x, y).
local function shopHasEligiblePool(shopDef, x, y)
    local fn = Core.poolPassesZoneFilter
    for _, poolSet in ipairs(shopDef.poolSets or {}) do
        for _, poolRef in ipairs(poolSet.keys or {}) do
            local poolKey = type(poolRef) == "table" and poolRef.key or poolRef
            local pool = Core.runtime.pools and Core.runtime.pools[poolKey]
            if pool and (not fn or fn(pool, x, y)) then
                return true
            end
        end
    end
    return false
end

-- returns a random shop key based on x,y location based on its probability
-- it will omit shops that are disabled, whose group/type would be too close to one another,
-- or whose pools are all zone-filtered out at this location
function ServerSystem:getRandomShop(x, y)

    local options = Core:getInstanceDistancesFrom(x, y)
    local candidates = {}

    local shops = Core.shops
    local defaultDistance = Core.settings.DefaultDistance or 200
    local totalProbability = 0
    -- remove options that are too close or have no eligible pools at this location
    for k, v in pairs(options) do
        local shopDef = shops[k]
        local probability = shopDef and (shopDef.probability or 1) or 0
        if shopDef and shopDef.enabled ~= false and probability > 0 then
            local minDist = shopDef.minDistance or defaultDistance
            if minDist <= v and shopHasEligiblePool(shopDef, x, y) then
                table.insert(candidates, {
                    shop = k,
                    p = probability
                })
                totalProbability = totalProbability + probability
            end
        end
    end

    if #candidates == 0 then
        return nil
    end

    local r = ZombRand(totalProbability) + 1
    local sum = 0
    for _, v in ipairs(candidates) do
        sum = sum + v.p
        if sum >= r then
            return v.shop
        end
    end

end

function ServerSystem:getShopList()
    local shops = {}
    for k, v in pairs(Core.shops) do
        table.insert(shops, {
            type = k,
            label = getTextOrNull("IGUI_PhunMart_Shop_" .. k) or k,
            group = v.group or "NONE",
            enabled = v.enabled == false and "false" or "true"
        })
    end
    return shops
end

function ServerSystem:getShopDefinition(shopType)
    local data = Core.shops[shopType] or {}
    data.type = shopType
    return data
end

function ServerSystem:upsertShopDefinition(data)

    -- Load the current override file (only admin-edited entries, not all defaults).
    local override = Core.fileUtils.loadTable("PhunMart_Shops.lua") or {}
    -- Update just this shop's entry in the override.
    override[data.type] = data
    -- Persist the override, then recompile so defaults + override merge correctly.
    Core.fileUtils.saveTable("PhunMart_Shops.lua", override)
    self:recompileShops()

end

function ServerSystem:checkObjectAdded(obj)
    if obj and obj.getSprite then
        local customName = obj:getSprite():getProperties():get("CustomName")
        if customName and Core.shops[customName] then
            if not self:isValidIsoObject(obj) then
                -- is a shop sprite but not an instance?
                self.initializeShopObject(obj)
            end
            -- Register with the global object system immediately so the machine
            -- is live without waiting for a chunk reload.
            local x, y, z = obj:getX(), obj:getY(), obj:getZ()
            if not self:getLuaObjectAt(x, y, z) then
                local luaObj = self:newLuaObjectAt(x, y, z)
                if luaObj then
                    luaObj:stateFromIsoObject(obj)
                end
            end
        end
    end
end

function ServerSystem:loadGridsquare(square)

    local objects = square:getObjects()
    for i = 0, objects:size() - 1 do
        local obj = objects:get(i)
        -- is this sprite a shop
        local sprite = obj:getSprite()
        if sprite and sprite.getProperties then

            if Core.targetSprites[sprite:getName()] then
                -- have we already checked?
                -- has it already been tested?
                local modData = obj:getModData()
                if not modData.PhunMart then
                    modData.PhunMart = {}
                end
                -- if modData.PhunMart.replacementKey ~= Core.settings.ReplacementKey then
                --    modData.PhunMart.replacementKey = Core.settings.ReplacementKey
                if Core.settings.ChanceToConvert > 0 then
                    local chance = ZombRand(100)
                    if chance <= Core.settings.ChanceToConvert then
                        local shopname = self:getRandomShop(square:getX(), square:getY())
                        if shopname then
                            local facing = obj:getFacing()
                            square:transmitRemoveItemFromSquare(obj)
                            self.addToWorld(square, shopname, facing)
                        end
                    end
                end
                -- end
            end
        end

    end
end

function ServerSystem:OnClientCommand(command, playerObj, args)
    if Commands[command] ~= nil then
        Commands[command](playerObj, args)
    end
end

function ServerSystem:recompileShops()
    Core.compile()
    Core.debugLn("Recompiled shop definitions")
    -- Broadcast updated override tables to all connected clients so they recompile.
    if Core._lastOverrides then
        sendServerCommand(Core.name, Core.commands.requestShopDefs, {
            overrides = Core._lastOverrides
        })
    end
end

function ServerSystem:checkObjectRemoved(obj)
    if not obj or not obj.getSprite then
        return
    end
    if not self:isValidIsoObject(obj) then
        return
    end
    local x, y, z = obj:getX(), obj:getY(), obj:getZ()
    local luaObj = self:getLuaObjectAt(x, y, z)
    if luaObj then
        self:removeLuaObject(luaObj)
    else
        -- No global object but may still have instance data from initializeShopObject
        Core:removeInstance({
            x = x,
            y = y,
            z = z
        })
    end
end

SGlobalObjectSystem.RegisterSystemClass(ServerSystem)
