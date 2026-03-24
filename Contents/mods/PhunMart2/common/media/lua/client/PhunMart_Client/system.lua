if isServer() then
    return
end

local Core = PhunMart
local Commands = require "PhunMart_Client/commands"
Core.ClientSystem = CGlobalObjectSystem:derive("CPhunMartSystem")
local ClientSystem = Core.ClientSystem

function ClientSystem:new()
    local o = CGlobalObjectSystem.new(self, "phunmart")
    o.loadedShops = {}
    return o
end

function ClientSystem:isValidIsoObject(isoObject)
    return instanceof(isoObject, "IsoThumpable") and isoObject:getName() == "PhunMartVendingMachine"
end

function ClientSystem:newLuaObject(globalObject)
    local o = Core.ClientObject:new(self, globalObject)
    return o
end

function ClientSystem:openShop(player, obj)
    obj:updateFromIsoObject()
    self:sendCommand(player or getSpecificPlayer(0), Core.commands.openShop, {
        key = obj:getKey(),
        type = obj.type,
        x = obj.x,
        y = obj.y,
        z = obj.z
    })
end

function ClientSystem:requestPurchase(obj, itemId, playerObj)

    local item = obj.items[itemId]
    if not item then
        return
    end

    -- recheck that player can buy
    local canBuy = Core:canBuy(playerObj, item)

    if canBuy.passed == true then
        -- assert condition 1 is the one Condition that passeed
        -- iterate through each condition and adjust any prices
        for _, v in ipairs(canBuy.conditions[1]) do

            if v.type == "price" then
                local allocations = v.allocation or {}
                for _, a in ipairs(allocations) do
                    if a.type == "trait" then
                        playerObj:getTraits():remove(a.currency)
                    elseif a.type == "item" and a.value > 0 then
                        local item = getScriptManager():getItem(a.currency)
                        if item then
                            local remaining = a.value
                            -- asserting we have enough to consume or canBuy wouldn't have passed?
                            for i = 1, remaining do
                                local invItem = playerObj:getInventory():getItemFromTypeRecurse(a.currency)
                                if invItem then
                                    local container = invItem:getContainer()
                                    container:Remove(invItem)
                                    sendRemoveItemFromContainer(container, invItem)
                                end
                            end
                        end
                    else
                        -- assert its a hook
                        local hooks = Core.hooks.prePurchase
                        for _, v in ipairs(hooks) do
                            if v then
                                -- should mutate val if handled in hook
                                v(playerObj, a.type, a.currency, a.value)
                            end
                        end
                    end
                end
            end
        end
        self:sendCommand(playerObj, Core.commands.buy, {
            shopId = obj.id,
            itemId = itemId,
            location = obj.location
        })
    end

end

function ClientSystem:restock(shop, playerObj)
    self:sendCommand(playerObj or getSpecificPlayer(0), Core.commands.restock, {
        x = shop.x,
        y = shop.y,
        z = shop.z
    })
end

function ClientSystem:changeTo(shop, playerObj, to)
    self:sendCommand(playerObj or getSpecificPlayer(0), Core.commands.changeTo, {
        shopId = shop.id,
        type = shop.type,
        location = {
            x = shop.x,
            y = shop.y,
            z = shop.z
        },
        to = to
    })
end

function ClientSystem:reroll(shop, target, playerObj)
    self:sendCommand(playerObj or getSpecificPlayer(0), Core.commands.reroll, {
        location = {
            x = shop.x,
            y = shop.y,
            z = shop.z
        }
    })
end

function ClientSystem:close(shop, playerObj)
    self:sendCommand(playerObj or getSpecificPlayer(0), Core.commands.closeShop, {
        shopId = shop.id,
        location = shop.location
    })
end

function ClientSystem:updateShop(location)
    local obj = self:getLuaObjectAt(location.x, location.y, location.z)
    obj:updateFromIsoObject()
end

function ClientSystem:OnServerCommand(command, args)
    if Commands[command] then
        Commands[command](args)
    end
end

function ClientSystem:newLuaObjectAt(x, y, z)
    local globalObject = self.system:newObject(x, y, z)
    return self:newLuaObject(globalObject)
end

function ClientSystem:checkObjectAdded(obj)
    if not obj then
        return
    end
    local sprite = obj:getSprite()
    if not sprite then
        return
    end
    local customName = sprite:getProperties():get("CustomName")
    local name = obj:getName()
    local spriteName = sprite:getName() or "nil"

    Core.debugLn(
        "CLIENT checkObjectAdded: sprite=" .. spriteName .. " customName=" .. tostring(customName) .. " name=" ..
            tostring(name))

    -- Match by sprite CustomName (like the server does), not by isValidIsoObject,
    -- because the object may arrive on the client before the server has set its name.
    if not customName or not Core.shops[customName] then
        return
    end

    -- Ensure the object is named so the engine's isValidIsoObject can find it later.
    if name ~= "PhunMartVendingMachine" then
        obj:setName("PhunMartVendingMachine")
        Core.debugLn("CLIENT checkObjectAdded: set name to PhunMartVendingMachine")
    end

    local x, y, z = obj:getX(), obj:getY(), obj:getZ()
    local existing = self:getLuaObjectAt(x, y, z)
    Core.debugLn("CLIENT checkObjectAdded: pos=" .. x .. "," .. y .. "," .. z .. " existingLuaObj=" ..
                     tostring(existing ~= nil))

    if not existing then
        local luaObj = self:newLuaObjectAt(x, y, z)
        Core.debugLn("CLIENT checkObjectAdded: newLuaObjectAt result=" .. tostring(luaObj ~= nil))
        if luaObj then
            luaObj:stateFromIsoObject(obj)
        end
    end
end

function ClientSystem:checkLocals()
    for i = 1, self:getLuaObjectCount() do

    end
end

function ClientSystem:prepareShopList(player)
    Core.ui.shop_selector.open(player or getSpecificPlayer(0))
end

function ClientSystem:openShopList(player)
    Core.ui.shop_selector.open(player or getSpecificPlayer(0))
end

function ClientSystem:upsertShopDefinition(args, player)

    self:sendCommand(player or getSpecificPlayer(0), Core.commands.upsertShopDefinition, {
        shopId = args.shopId,
        location = args.location,
        type = args.type,
        data = args.data
    })

end

CGlobalObjectSystem.RegisterSystemClass(Core.ClientSystem)

Events.EveryOneMinute.Add(function()
    Core.ClientSystem.instance:checkLocals()
end)
