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

    isoObject:setModData({
        key = shop.key,
        id = square:getX() .. "_" .. square:getY() .. "_" .. square:getZ(),
        label = shop.label,
        direction = direction
    })

    isoObject:setName("PhunMartShop")
    square:AddSpecialObject(isoObject, -1)
    triggerEvent("OnObjectAdded", isoObject)
    isoObject:transmitCompleteItemToClients()
end

function SPhunMartSystem:initSystem()

    SGlobalObjectSystem.initSystem(self)
    self.lockedShopIds = {}
    self.system:setModDataKeys({})
    self.system:setObjectModDataKeys({})

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

function SPhunMartSystem:newLuaObjectAt(x, y, z)
    print("===============> SPhunMartSystem:newLuaObjectAt", tostring(x), tostring(y), tostring(z))
    self:noise("adding luaObject " .. x .. ',' .. y .. ',' .. z)
    local globalObject = self.system:newObject(x, y, z)
    return self:newLuaObject(globalObject)
end

function SPhunMartSystem:isValidIsoObject(isoObject)
    return instanceof(isoObject, "IsoThumpable") and isoObject:getName() == "PhunMartShop"
end

function SPhunMartSystem:purchase(shopId, itemId, playerObj)
    local shop = PM:getShop(shopId)
    if shop then
        local item = shop.items[itemId]
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
            end

            -- add to players purchase history
            PM:addToPurchaseHistory(playerObj, item)

            -- push shop changes to client
            self:requestShop(shopId, playerObj)

            sendServerCommand(playerObj, PM.name, PM.commands.buy, {
                playerIndex = playerObj:getPlayerNum(),
                success = true,
                shopId = shopId,
                item = item
            })

            return true
        end
    end
end

function SPhunMartSystem:requestShop(shopId, playerObj, forceRestock)

    local shop = PM:getShop(shopId)
    if not shop then
        print("ERROR! shop not found for " .. shopId)
        return
    end

    if shop.playerName and shop.playerName ~= playerObj:getUsername() then
        print("ERROR! shop locked by " .. shop.playerName)
        return
    end

    local obj = self:getLuaObjectAt(shop.location.x, shop.location.y, shop.location.z)
    obj:lock(playerObj)

    print("shop.restockDeferred ", tostring(shop.restockDeferred), " shop.nextRestock ", tostring(shop.nextRestock),
        " now is ", tostring(GameTime:getInstance():getWorldAgeHours()), " force = ", tostring(forceRestock))

    local lastRestocked = shop.lastRestock

    if lastRestocked == nil then
        PM:generateShopItems(shop, sandbox.CumulativeItemGeneration == true)
    elseif forceRestock then
        PM:generateShopItems(shop, sandbox.CumulativeItemGeneration == true)
    else
        local frequency = PM.defs.shops[shop.key].restock or 24
        local hoursSinceLastRestock = GameTime:getInstance():getWorldAgeHours() - lastRestocked
        if hoursSinceLastRestock > frequency then
            -- shop should have been restocked by now
            local times = math.floor(hoursSinceLastRestock / frequency)
            local newRestock = lastRestocked + (times * frequency)
            -- now restock
            PM:generateShopItems(shop, sandbox.CumulativeItemGeneration == true)
            -- now overwrite the last restock time to our newRetock figure
            shop.lastRestock = newRestock
        end
    end

    shop.playerName = playerObj:getUsername()
    table.insert(self.lockedShopIds, {
        shopId = shopId,
        playerName = shop.playerName,
        location = shop.location
    })
    sendServerCommand(playerObj, PM.name, PM.commands.requestShop, {
        id = shopId,
        shop = shop
    })

end

function SPhunMartSystem:releaseShop(shopId)
    local shop = PM:getShop(shopId)
    if shop then
        local obj = self:getLuaObjectAt(shop.location.x, shop.location.y, shop.location.z)
        SPhunMartSystem.lockedShopIds[shopId] = nil
    end
end

function SPhunMartSystem:restock(shopId, playerObj)
    self:requestShop(shopId, playerObj, true)
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

    PM:debug("Players", #self.lockedShopIds)
    PM:debug("locked", self.lockedShopIds)

    local doRemove = {}
    for i = #self.lockedShopIds, 1, -1 do

        local data = self.lockedShopIds[i]
        print("Checking ", data.playerName, " is near ", data.shopId)
        local shop = PM:getShop(data.shopId)
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
            print("Distance to player ", data.playerName, " is ", distance)
            if distance > 5 then
                -- player is too far away
                print("Player ", data.playerName, " is too far away")
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

function SPhunMartSystem:removeShopIdLockData(shopId)
    print("SPhunMartSystem:removeShopIdLockData ", tostring(shopId), " t= ", tostring(#self.lockedShopIds))
    for i = #self.lockedShopIds, 1, -1 do
        local data = self.lockedShopIds[i]
        if data.shopId == shopId then
            table.remove(self.lockedShopIds, i)
        end
    end
end

function SPhunMartSystem:OnClientCommand(command, playerObj, args)
    print("SPhunMartSystem:OnClientCommand ", tostring(command), " p= ", tostring(playerObj), " a=", tostring(args))
    if SPhunMartServerCommands[command] == nil then
        print("SPhunMartSystem:OnClientCommand ", tostring(command), " not found")
        return
    end
    SPhunMartServerCommands[command](playerObj, args)
end

function SPhunMartSystem:receiveCommand(playerObj, command, args)
    print("SPhunMartSystem:receiveCommand ", tostring(playerObj), " c= ", tostring(command), " a=", tostring(args))
    SPhunMartServerCommands[command](playerObj, args)
end

SGlobalObjectSystem.RegisterSystemClass(SPhunMartSystem)

