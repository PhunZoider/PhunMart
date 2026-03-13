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
                return {
                    ignoreAction = true
                }
            end
        end
    end

    local action = originalNewInventoryTransaferAction(self, player, item, srcContainer, destContainer, time)

    if wallet and wallet.wallet then
        action:setOnComplete(function()
            -- Merge dropped wallet pool balances into player, respecting caps.
            for _, entry in ipairs(wallet.wallet or {}) do
                if entry.pool and entry.amount and entry.amount > 0 then
                    local cap = Wallet:getCap(entry.pool)
                    local bal = Wallet:getBalance(player, entry.pool)
                    local toAdd = cap and math.min(entry.amount, cap - bal) or entry.amount
                    if toAdd > 0 then
                        Wallet:adjustByPool(player, "current", entry.pool, toAdd)
                    end
                end
            end
            destContainer:DoRemoveItem(item)
            destContainer:setDrawDirty(true)
            getSoundManager():PlaySound("PhunMart_WalletPickup", false, 0):setVolume(0.50)
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
