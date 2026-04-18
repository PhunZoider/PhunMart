if isServer() then
    return
end

require "TimedActions/ISInventoryTransferAction"
local Core = PhunMart
local Wallet = Core.wallet

-- Remove a currency/wallet item after transfer completes.
-- Uses item:getContainer() to find the actual container post-transfer,
-- since destContainer captured at action creation time may be stale.
local function consumeItem(item)
    local container = item:getContainer()
    if container then
        container:Remove(item)
        sendRemoveItemFromContainer(container, item)
    end
    ISInventoryPage.dirtyUI()
end

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
            if wallet.wallet and Core.settings.OnlyPickupOwn and name ~= wallet.owner and not wallet.anyone then
                return {
                    ignoreAction = true
                }
            end
        end
    end

    local action = originalNewInventoryTransaferAction(self, player, item, srcContainer, destContainer, time)

    if wallet and wallet.wallet then
        action:setOnComplete(function()
            if Core.isLocal then
                -- SP: merge dropped wallet pool balances locally, respecting caps.
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
                consumeItem(item)
            else
                local container = destContainer
                if container then
                    container:DoRemoveItem(item)
                end
                -- MP: B42 is server-authoritative for inventory state, so the
                -- server must remove the item. Pass the exact item ID so it
                -- can look up this specific wallet (getFirstTypeRecurse picks
                -- an arbitrary DroppedWallet, which causes ghosts on repeated
                -- pickups). Client does NOT remove locally; the server fires
                -- sendRemoveItemFromContainer which syncs all clients.
                sendClientCommand(Core.name, Core.commands.consumeDroppedWallet, {
                    walletData = wallet.wallet,
                    itemId = item:getID()
                })

            end
            getSoundManager():PlaySound("PhunMart_WalletPickup", false, 0):setVolume(0.50)
        end)
    elseif Wallet:isCurrency(itemType) then
        action:setOnComplete(function()
            local destType = destContainer:getType()
            if destType ~= "floor" then
                if Core.isLocal then
                    -- SP: adjust locally; if at cap leave coin in inventory.
                    local adjusted, atCap = Wallet:adjust(player, itemType, 1)
                    if not adjusted then
                        return
                    end
                    consumeItem(item)
                else
                    -- MP: server adjusts wallet and removes coin.
                    sendClientCommand(Core.name, Core.commands.consumeCoin, {
                        itemType = itemType
                    })
                end
            end
        end)
    end

    return action
end
