if not isServer() then
    return
end
local PM = PhunMart
local sandbox = SandboxVars.PhunMart
require "Map/SGlobalObjectSystem"
SPhunMartSystem = SGlobalObjectSystem:derive("SPhunMartSystem")

SPhunMartSystem.lockedShopIds = {}

function SPhunMartSystem:new()
    local o = SGlobalObjectSystem.new(self, "phunmart")
    return o
end

function SPhunMartSystem.addToWorld(square, shop, direction)

    direction = direction or "south"
    shop.id = square:getX() .. "_" .. square:getY() .. "_" .. square:getZ()

    print("SPhunMartSystem.addToWorld ", tostring(square), " type= ", tostring(shop.key),
        ", id=" .. shop.id .. ", facing ", tostring(direction))

    local isoObject

    isoObject = IsoThumpable.new(square:getCell(), square, "phunmart_01_1", false, {})

    -- if shop.requiresPower then
    --     isoObject:createLightSource(10, 5, 5, 5, 5)
    -- end

    shop.direction = direction

    isoObject:setModData(shop)

    isoObject:setName("PhunMartShop")
    square:AddSpecialObject(isoObject, -1)
    triggerEvent("OnObjectAdded", isoObject)
    isoObject:transmitCompleteItemToClients()
end

function SPhunMartSystem:addFromSprite(x, y, z, sprite)

    -- iterate through shops to get the associated shop
    print("addFromSprite ", tostring(x), ", ", tostring(y), ", ", tostring(z), ", ", sprite)

    local shop = nil
    local dir = nil
    for k, v in pairs(PM.defs.shops) do
        if v.spriteMap and v.spriteMap[sprite] then
            shop = v
            dir = v.spriteMap[sprite]
            break
        end
    end

    -- is there a shop but it is orphaned from the obj?
    local key = tostring(x) .. "_" .. tostring(y) .. "_" .. tostring(z)
    -- if PM.shops[key] then

    --     print("Discovered orphaned shop")
    --     PhunTools:printTable(PM.shops[key])

    --     self:removeLuaObjectAt(x, y, z)
    --     print("Reconnecting orphaned vending machine found at " .. x .. ", " .. y .. " sprite: " .. sprite)
    --     local sq = getCell():getGridSquare(x, y, z)
    --     if not sq then
    --         print("ERROR! square not found for " .. x .. "," .. y .. "," .. z)
    --         return
    --     end
    --     self.addToWorld(sq, PM.shops[key], dir)
    --     return
    -- end

    print("Machine was not generated, attempting to generate from sprite")

    if shop and dir then
        self:removeLuaObjectAt(x, y, z)
        local square = getCell():getGridSquare(x, y, z)
        if square then
            for i = 0, square:getObjects():size() - 1 do
                local object = square:getObjects():get(i)
                if object:getSprite():getName() == sprite then
                    square:RemoveTileObject(object);
                    object:transmitUpdatedSpriteToClients()
                end
            end

            local s = PM:generateShop(square, shop.key)
            if s == nil then
                print("ERROR! shop not found for sprite " .. sprite)
                return
            end
            -- print("Adding " .. shop.key .. " to " .. x .. "," .. y .. "," .. z .. " with sprite " .. sprite ..
            --           " facing " .. dir)

            -- print("Recreating orphan ", key, " from sprite ", sprite, " dir=", dir)
            self.addToWorld(square, s, dir)
        end
    else
        print("ERROR! shop not found for sprite " .. sprite)
    end

end

function SPhunMartSystem:initSystem()

    SGlobalObjectSystem.initSystem(self)
    self.lockedShopIds = {}
    -- Specify GlobalObjectSystem fields that should be saved.
    self.system:setModDataKeys({})

    -- Specify GlobalObject fields that should be saved.
    self.system:setObjectModDataKeys({'id', 'key', 'label', 'fills', 'lastRestock', 'nextRestock', 'location', 'tabs',
                                      'items', 'playerName', 'direction', 'backgroundImage', 'layout', 'requiresPower',
                                      'currency', 'basePrice', 'type', 'lockedBy', 'restocked'})

end

function SPhunMartSystem:isValidModData(modData)
    return modData and modData.restocked
end

function SPhunMartSystem:newLuaObject(globalObject)
    return SPhunMartObject:new(self, globalObject)
end

function SPhunMartSystem:generateRandomShopOnSquare(square, direction, removeOnSuccess)
    direction = direction or "south"
    local shop = PM:generateShop(square)
    if shop ~= nil then
        square:transmitRemoveItemFromSquare(removeOnSuccess)
        self.addToWorld(square, shop, direction)
    end

end

function SPhunMartSystem:reroll(location, target, ignoreDistance)

    local shopObj = self:getLuaObjectAt(location.x, location.y, location.z)
    local shop = PM:generateShop(location, target, ignoreDistance == true)
    shopObj:fromModData(shop)
    shopObj:changeSprite(true)
    shopObj:saveData()
    sendServerCommand(PM.name, PM.commands.updateShop, {
        id = shop.id,
        location = shop.location
    })

end

function SPhunMartSystem:rerollAll()

    for i = 1, self:getLuaObjectCount() do
        local obj = self:getLuaObjectByIndex(i)
        if obj then
            self:reroll(obj.location)
        end
    end

end

function SPhunMartSystem:restockAll()

    for i = 1, self:getLuaObjectCount() do
        local obj = self:getLuaObjectByIndex(i)
        if obj then
            obj.lastRestock = 0
        end
    end

end

function SPhunMartSystem:resyncAll()
    -- really for use when moving from old system to new

    -- first, check for any shops that do not have lua Objects
    local shops = PM.shops or {}
    for k, v in pairs(shops) do
        local obj = self:getLuaObjectAt(v.location.x, v.location.y, v.location.z)
        if not obj then
            self:newLuaObjectAt(v.location.x, v.location.y, v.location.z)
        end
    end

    for i = 1, self:getLuaObjectCount() do
        local obj = self:getLuaObjectByIndex(i)
        if obj then
            obj:saveData()
        end
    end
end

function SPhunMartSystem:newLuaObjectAt(x, y, z)
    print("===============> SPhunMartSystem:newLuaObjectAt", tostring(x), tostring(y), tostring(z))
    self:noise("adding luaObject " .. x .. ',' .. y .. ',' .. z)
    local globalObject = self.system:newObject(x, y, z)
    return self:newLuaObject(globalObject)
end

function SPhunMartSystem:isValidIsoObject(isoObject)
    return instanceof(isoObject, "IsoThumpable") and isoObject:getName() == "PhunMartShop"
end

function SPhunMartSystem:purchase(location, itemId, playerObj)

    local shop = self:getLuaObjectAt(location.x, location.y, location.z)
    if not shop then
        print("ERROR! shop not found for " .. location.location.x .. "," .. location.location.y .. "," ..
                  location.location.z)
        return false
    end

    local item = shop.items[itemId]
    if not item then
        print("ERROR! item not found for " .. itemId)
        return false
    end

    if item then
        if item.inventory ~= false then
            if item.inventory < 1 then
                sendServerCommand(playerObj, PM.name, PM.commands.serverPurchaseFailed, {
                    playerIndex = playerObj:getPlayerNum(),
                    message = "OOS"
                })
                return false
            end
            item.inventory = item.inventory - 1
            shop:saveData()
        end

        -- add to players purchase history
        PM:addToPurchaseHistory(playerObj, item)

        -- push shop changes to client
        -- self:requestShop(shopId, playerObj)

        sendServerCommand(playerObj, PM.name, PM.commands.buy, {
            playerIndex = playerObj:getPlayerNum(),
            success = true,
            shopId = shop.id,
            location = shop.location,
            item = item
        })

        return true
    end

end

function SPhunMartSystem:requestShop(location, playerObj, forceRestock)

    local shop = self:getLuaObjectAt(location.x, location.y, location.z)

    if not shop then
        print("ERROR! shop not found for " .. shop.id)
        return
    end

    if shop.lockedBy and shop.lockedBy ~= playerObj:getUsername() then
        print("ERROR! shop locked by " .. shop.lockedBy)
        return
    end

    local lastRestocked = shop.lastRestock or 0
    local frequency = PM.defs.shops[shop.key].restock or 24
    local hoursSinceLastRestock = GameTime:getInstance():getWorldAgeHours() - lastRestocked
    local times = math.floor(hoursSinceLastRestock / frequency)
    local newRestock = lastRestocked + (times * frequency)
    shop.nextRestock = newRestock + frequency

    if lastRestocked == nil then
        PM:generateShopItems(shop, sandbox.CumulativeItemGeneration == true)
        shop.nextRestock = GameTime:getInstance():getWorldAgeHours() + frequency
    elseif forceRestock then
        PM:generateShopItems(shop, sandbox.CumulativeItemGeneration == true)
    else
        print("hoursSinceLastRestock ", tostring(hoursSinceLastRestock), " frequency", tostring(frequency))
        if hoursSinceLastRestock > frequency then
            -- shop should have been restocked by now

            -- now restock
            PM:generateShopItems(shop, sandbox.CumulativeItemGeneration == true)
            -- now overwrite the last restock time to our newRetock figure
            shop.lastRestock = newRestock
            print("times missed restock ", tostring(times), " newRestock ", tostring(newRestock))
        end
    end

    -- obj:fromModData(shop)
    shop:lock(playerObj)
    table.insert(self.lockedShopIds, {
        shopId = shop.id,
        playerName = shop.lockedBy or "???",
        location = shop.location
    })
    sendServerCommand(playerObj, PM.name, PM.commands.updateShop, {
        id = shop.id,
        location = shop.location
    })

end

function SPhunMartSystem:requestLock(location, playerObj)
    local obj = self:getLuaObjectAt(location.x, location.y, location.z)
    if obj == nil then
        print("ERROR! shop not found for " .. location.x .. "," .. location.y .. "," .. location.z)
        return
    end
    local success = true
    local lockedBy = false
    if obj.lockedBy then
        success = false
        lockedBy = obj.lockedBy
    else
        self:requestShop(location, playerObj)
    end
    sendServerCommand(playerObj, PM.name, PM.commands.requestLock, {
        id = obj.id,
        location = location,
        success = success,
        lockedBy = lockedBy
    })
end

function SPhunMartSystem:updatePoweredSprites()

    for i = 1, self:getLuaObjectCount() do
        local obj = self:getLuaObjectByIndex(i)
        if obj and obj.requiresPower then
            obj:changeSprite()
        end
    end
end

function SPhunMartSystem:updateSprites()

    for i = 1, self:getLuaObjectCount() do
        local obj = self:getLuaObjectByIndex(i)
        if obj then
            obj:changeSprite()
        end
    end
end

function SPhunMartSystem:releaseShop(shopId, location, playerObj)
    local obj = self:getLuaObjectAt(location.x, location.y, location.z)
    SPhunMartSystem.lockedShopIds[shopId] = nil
end

function SPhunMartSystem:restock(shop, playerObj)
    self:requestShop(shop.id, playerObj, true)
end

function SPhunMartSystem:closestShopTypesTo(location)

    local shops = {}
    print("Getting distances of existing shops to ", location.x, location.y)
    for i = 1, self:getLuaObjectCount() do
        local obj = self:getLuaObjectByIndex(i)
        if obj then
            local dx = location.x - obj.location.x
            local dy = location.y - obj.location.y
            local distance = math.sqrt(dx * dx + dy * dy)
            if shops[obj.type or obj.key] ~= nil then
                print(" ---- distance: ", distance, " type:", tostring(obj.type), " key:", tostring(obj.key), " t=",
                    tostring(shops[obj.type or obj.key].distance))
            end
            if shops[obj.type or obj.key] == nil or distance < shops[obj.type or obj.key].distance then
                shops[obj.type or obj.key] = {
                    distance = distance,
                    key = obj.key,
                    type = obj.type,
                    location = obj.location
                }
            end
        end
    end

    return shops

end

function SPhunMartSystem:checkLocks()
    if #self.lockedShopIds == 0 then
        return
    end

    -- get lookup of online player names
    local players = {}
    for i = 1, getOnlinePlayers():size() do
        local playerObj = getOnlinePlayers():get(i - 1)
        if playerObj then
            players[playerObj:getUsername()] = playerObj
        end
    end
    local doRemove = {}
    for i = #self.lockedShopIds, 1, -1 do

        local data = self.lockedShopIds[i]

        local playerObj = players[data.playerName]
        if not playerObj then
            -- player is no longer on server
            doRemove[data.shopId] = data
        elseif playerObj:isDead() then
            -- player is dead
            doRemove[data.shopId] = data
            sendServerCommand(playerObj, PM.name, PM.commands.closeShop, {
                shopId = data.shopId
            })
        else
            local square = playerObj:getSquare()
            local dx = data.location.x - square:getX()
            local dy = data.location.y - square:getY()
            local distance = math.sqrt(dx * dx + dy * dy)
            if distance > 5 then
                -- player is too far away
                sendServerCommand(playerObj, PM.name, PM.commands.closeShop, {
                    shopId = data.shopId
                })
                doRemove[data.shopId] = data
            end
        end
    end

    for k, v in pairs(doRemove) do
        local obj = self:getLuaObjectAt(v.location.x, v.location.y, v.location.z)
        if obj then
            obj:unlock()
        end
    end
end

function SPhunMartSystem:removeShopIdLockData(shop)
    for i = #self.lockedShopIds, 1, -1 do
        local data = self.lockedShopIds[i]
        if data.shopId == shop.id then
            table.remove(self.lockedShopIds, i)
        end
    end
    sendServerCommand(PM.name, PM.commands.updateShop, {
        id = shop.id,
        location = shop.location
    })
end

function SPhunMartSystem:OnClientCommand(command, playerObj, args)
    if SPhunMartServerCommands[command] ~= nil then
        SPhunMartServerCommands[command](playerObj, args)
    end
end

function SPhunMartSystem:receiveCommand(playerObj, command, args)
    SPhunMartServerCommands[command](playerObj, args)
end

SGlobalObjectSystem.RegisterSystemClass(SPhunMartSystem)

