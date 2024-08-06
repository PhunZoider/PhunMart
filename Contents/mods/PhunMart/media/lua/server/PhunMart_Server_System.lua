-- ***********************************************************
-- **                    THE INDIE STONE                    **
-- ***********************************************************
if isClient() then
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

    print("SPhunMartSystem.addToWorld ", tostring(square), " t= ", tostring(shop.key), " d=", tostring(direction))
    direction = direction or "south"

    local isoObject

    local sprite = PhunMart.defs.shops[shop.key].sprites[direction]
    print("sprite: ", sprite)

    if not sprite then
        print("no sprite for ", shop.key, " ", direction)
        return
    end
    isoObject = IsoThumpable.new(square:getCell(), square, sprite, false, {})

    shop.id = square:getX() .. "_" .. square:getY() .. "_" .. square:getZ()
    shop.direction = direction

    isoObject:setModData(shop)

    isoObject:setName("PhunMartShop")
    square:AddSpecialObject(isoObject, -1)
    triggerEvent("OnObjectAdded", isoObject)
    isoObject:transmitCompleteItemToClients()
end

function SPhunMartSystem:initSystem()

    SGlobalObjectSystem.initSystem(self)
    self.lockedShopIds = {}
    -- Specify GlobalObjectSystem fields that should be saved.
    self.system:setModDataKeys({})

    -- Specify GlobalObject fields that should be saved.
    self.system:setObjectModDataKeys({'id', 'key', 'label', 'fills', 'lastRestock', 'location', 'tabs', 'items',
                                      'playerName', 'direction', 'backgroundImage', 'layout', 'requiresPower',
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
    print("===============> SPhunMartSystem:generateRandomShopOnSquare ", tostring(square), " d=", tostring(direction))

    local shop = PM:generateShop(square)
    if shop ~= nil then
        square:transmitRemoveItemFromSquare(removeOnSuccess)
        self.addToWorld(square, shop, direction)
    end

end

function SPhunMartSystem:reroll(location, target)

    local shopObj = self:getLuaObjectAt(location.x, location.y, location.z)
    local shop = PM:generateShop(location, target)
    shopObj:fromModData(shop)
    shopObj:changeSprite()
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

    local lastRestocked = shop.lastRestock

    print("lastRestocked ", tostring(lastRestocked))

    if lastRestocked == nil then
        PM:generateShopItems(shop, sandbox.CumulativeItemGeneration == true)
    elseif forceRestock then
        PM:generateShopItems(shop, sandbox.CumulativeItemGeneration == true)
    else
        local frequency = PM.defs.shops[shop.key].restock or 24
        local hoursSinceLastRestock = GameTime:getInstance():getWorldAgeHours() - lastRestocked
        print("hoursSinceLastRestock ", tostring(hoursSinceLastRestock), " frequency", tostring(frequency))
        if hoursSinceLastRestock > frequency then
            -- shop should have been restocked by now
            local times = math.floor(hoursSinceLastRestock / frequency)
            local newRestock = lastRestocked + (times * frequency)
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

function SPhunMartSystem:releaseShop(shopId, location, playerObj)
    local obj = self:getLuaObjectAt(location.x, location.y, location.z)
    SPhunMartSystem.lockedShopIds[shopId] = nil
end

function SPhunMartSystem:restock(shop, playerObj)
    self:requestShop(shop.id, playerObj, true)
end

function SPhunMartSystem:closestShopTypesTo(location)

    local shops = {}
    for i = 1, self:getLuaObjectCount() do
        local obj = self:getLuaObjectByIndex(i)
        if obj then
            local dx = location.x - obj.location.x
            local dy = location.y - obj.location.y
            local distance = math.sqrt(dx * dx + dy * dy)

            if shops[obj.type or obj.key] == nil or shops[obj.type or obj.key].distance < distance then
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
            print("Player ", data.playerName, " no longer on server")
        elseif playerObj:isDead() then
            -- player is dead
            doRemove[data.shopId] = data
            print("Player ", data.playerName, " is dead")
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
                print("Player ", data.playerName, " is too far away from shop ", data.shopId)
                sendServerCommand(playerObj, PM.name, PM.commands.closeShop, {
                    shopId = data.shopId
                })
                doRemove[data.shopId] = data
            end
        end
    end

    for k, v in pairs(doRemove) do
        local obj = self:getLuaObjectAt(v.location.x, v.location.y, v.location.z)
        obj:unlock()
    end
end

function SPhunMartSystem:removeShopIdLockData(shop)
    print("SPhunMartSystem:removeShopIdLockData ", tostring(shop), " t= ", tostring(#self.lockedShopIds))
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
    print("SPhunMartSystem:OnClientCommand ", tostring(command), " p= ", tostring(playerObj), " a=", tostring(args))
    if SPhunMartServerCommands[command] ~= nil then
        SPhunMartServerCommands[command](playerObj, args)
        print("SPhunMartSystem:OnClientCommand ", tostring(command), " not found")
    end
    -- SPhunMartServerCommands[command](playerObj, args)
end

function SPhunMartSystem:receiveCommand(playerObj, command, args)
    print("SPhunMartSystem:receiveCommand ", tostring(playerObj), " c= ", tostring(command), " a=", tostring(args))
    SPhunMartServerCommands[command](playerObj, args)
end

SGlobalObjectSystem.RegisterSystemClass(SPhunMartSystem)

