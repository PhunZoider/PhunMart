if isServer() then
    return
end

local Core = PhunMart
local Commands = require "PhunMart2/client_commands"
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
                                    invItem:getContainer():DoRemoveItem(invItem)
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
    self:sendCommand(playerObj or getSpecificPlayer(0), PM.commands.restock, {
        shopId = shop.id,
        location = shop.location
    })
end

function ClientSystem:reroll(shop, target, playerObj)
    self:sendCommand(playerObj or getSpecificPlayer(0), PM.commands.requestShopGenerate, {
        shopId = shop.id,
        target = target,
        location = shop.location,
        ignoreDistance = shop.ignoreDistance == true
    })
end

function ClientSystem:close(shop, playerObj)
    self:sendCommand(playerObj or getSpecificPlayer(0), PM.commands.closeShop, {
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

function ClientSystem:checkLocals()
    for i = 1, self:getLuaObjectCount() do

    end
end

function ClientSystem:prepareShopList(player)
    self:sendCommand(player or getSpecificPlayer(0), Core.commands.getShopList, {})
end

function ClientSystem:openShopList(player, data)
    Core.ui.shop_selector.open(player or getSpecificPlayer(0), data)
end

function ClientSystem:prepareOpenShopConfig(player, shopType)

    self:sendCommand(player or getSpecificPlayer(0), Core.commands.getShopDefinition, {
        type = shopType
    })

end

function ClientSystem:openShopConfig(player, data)
    Core.ui.shop_config.open(player, data)
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
