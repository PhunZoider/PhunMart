if isServer() then
    return
end

require "TimedActions/ISInventoryTransferAction"
local Core = PhunMart
local Wallet = Core.wallet

-- Hook the original New Inventory Transfer Method
local originalNewInventoryTransaferAction = ISInventoryTransferAction.new
function ISInventoryTransferAction:new(player, item, srcContainer, destContainer, time)

    local itemType = item:getFullType()
    local wallet = nil

    if itemType == "PhunMart.DroppedWallet" then
        -- picking up a players dropped wallet
        wallet = item:getModData().PhunWallet
        if wallet then
            local name = player:getUsername()
            if Core.isLocal then
                name = player:getPlayerNum()
            end
            if wallet.wallet and Core.settings.OnlyPickupOwn and name ~= wallet.owner then
                return { ignoreAction = true }
            end
        end
    end

    local action = originalNewInventoryTransaferAction(self, player, item, srcContainer, destContainer, time)

    if wallet and wallet.wallet then
        action:setOnComplete(function()
            -- Merge dropped wallet currencies into player. Cap applies per-adjust call.
            for k, v in pairs(wallet.wallet or {}) do
                Wallet:adjust(player, v.item, v.amount)
            end
            destContainer:DoRemoveItem(item)
            destContainer:setDrawDirty(true)
            getSoundManager():PlaySound("PhunWallet_Pickup", false, 0):setVolume(0.50)
        end)
    elseif Wallet:isCurrency(itemType) then
        action:setOnComplete(function()
            local destType = destContainer:getType()
            if destType ~= "floor" then
                -- Client-side cap gate: only consume the coin if we're not at cap.
                local adjusted, atCap = Wallet:adjust(player, itemType, 1)
                if adjusted then
                    destContainer:DoRemoveItem(item)
                    destContainer:setDrawDirty(true)
                end
                -- If atCap (adjusted=false), coin stays in inventory as a visual cue.
            end
        end)
    end

    return action
end
