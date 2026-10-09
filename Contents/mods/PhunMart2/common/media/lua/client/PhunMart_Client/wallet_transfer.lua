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

    if Wallet:isWalletItem(itemType) then
        -- picking up a dropped wallet, or a zombie's change
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
            -- At the cap nothing in it would be credited, so leave it where it
            -- is. Covers bags too, or a full wallet could still be carried
            -- around as stashed money. Moves between the player's own
            -- containers are left alone so a wallet already carried can be
            -- reorganised. The balance here is the client's copy and can lag
            -- the server, which is why the pickup itself still keeps whatever
            -- does not fit rather than trusting this check.
            local inv = player:getInventory()
            local carried = srcContainer and (srcContainer == inv or srcContainer:isInCharacterInventory(player))
            local intoCarried = destContainer and (destContainer == inv or destContainer:isInCharacterInventory(player))
            if wallet.wallet and intoCarried and not carried and not Wallet:hasRoomFor(player, wallet.wallet) then
                HaloTextHelper.addBadText(player, getText("IGUI_PhunMart_WalletFull"))
                return {
                    ignoreAction = true
                }
            end
        end
    end

    local action = originalNewInventoryTransaferAction(self, player, item, srcContainer, destContainer, time)

    if wallet and wallet.wallet then
        action:setOnComplete(function()
            -- Only process if the destination is the player's own inventory.
            -- Moving it between floor/external containers must not grant currency.
            -- item:getContainer() is unreliable at onComplete time in B42 MP
            -- (client state lags server sync), so check destContainer instead.
            if destContainer ~= player:getInventory() then
                return
            end
            if Core.isLocal then
                -- SP: merge dropped wallet pool balances locally, respecting
                -- caps. Whatever does not fit stays behind as a smaller item.
                local leftover, credited = Wallet:creditEntries(player, wallet.wallet)
                Wallet:settleWalletItem(item, leftover, player:getInventory())
                ISInventoryPage.dirtyUI()
                if not credited then
                    -- Nothing fit, so there is nothing to celebrate.
                    return
                end
            else
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
