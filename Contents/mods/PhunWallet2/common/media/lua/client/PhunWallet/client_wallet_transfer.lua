if isServer() then
    return
end

require "TimedActions/ISInventoryTransferAction"
local Core = PhunWallet

-- Hook the original New Inventory Transfer Method
local originalNewInventoryTransaferAction = ISInventoryTransferAction.new
function ISInventoryTransferAction:new(player, item, srcContainer, destContainer, time)

    local itemType = item:getFullType()
    local wallet = nil

    -- if srcContainer and instanceof(srcContainer:getParent(), "IsoDeadBody") then
    if itemType == "PhunWallet.DroppedWallet" then
        -- picking up a players wallet
        wallet = item:getModData().PhunWallet
        if wallet then
            local name = player:getUsername()
            if Core.isLocal then
                name = player:getPlayerNum()
            end
            if wallet.wallet and (not Core.settings.OnlyPickupOwn or name == wallet.owner) then
            elseif wallet.wallet and Core.settings.OnlyPickupOwn and name ~= wallet.owner then
                return {
                    ignoreAction = true
                }
            end
        end
    end
    -- end

    local action = originalNewInventoryTransaferAction(self, player, item, srcContainer, destContainer, time)

    if wallet and wallet.wallet then
        action:setOnComplete(function()
            -- add the items in the dropped wallet to the player
            for k, v in pairs(wallet.wallet or {}) do
                Core:adjust(player, v.item, v.amount)
            end
            -- destContainer:removeItemOnServer(item);
            destContainer:DoRemoveItem(item)
            destContainer:setDrawDirty(true);
            -- local invItem = player:getInventory():getItemFromTypeRecurse("PhunMart.DroppedWallet")
            -- if invItem then -- ?
            --     invItem:getContainer():DoRemoveItem(invItem)
            -- end
            getSoundManager():PlaySound("PhunWallet_Pickup", false, 0):setVolume(0.50);

        end)
    elseif Core:isCurrency(itemType) then
        action:setOnComplete(function()
            local destType = destContainer:getType()
            if destType ~= "floor" then
                Core:adjust(player, itemType, 1)
                destContainer:DoRemoveItem(item)
                destContainer:setDrawDirty(true);
            end
        end)
    end

    return action
end
