if isServer() then
    return
end

local Core = PhunWallet

function Core:drop(player)

    local wallet = self:get(player).current or {}
    local toAdd = {}

    if self.settings.DropOnDeath then
        local doAdd = false
        for k, v in pairs(wallet) do
            local currency = self.currencies[k]
            -- skip bound entries
            if not self.currencies[k].bound then
                local rate = 100
                if currency.returnRate then
                    rate = currency.returnRate
                elseif self.settings.WalletReturnRate ~= nil then
                    rate = self.settings.WalletReturnRate
                end
                if rate > 0 then
                    table.insert(toAdd, {
                        item = k,
                        amount = math.floor(v * (rate / 100))
                    })
                end
            end
        end

        if #toAdd > 0 then
            -- drop the wallet
            local square = player:getSquare()
            local item = instanceItem("PhunWallet.DroppedWallet")
            item:setName(getText("IGUI_PhunWallet_CharsWallet", player:getUsername()))
            local data = {
                owner = player:getUsername(),
                wallet = toAdd
            }

            if self.isLocal then
                -- single player (or maybe coop?)
                -- use playerNum instead of username
                data.owner = player:getPlayerNum()
            end

            item:getModData().PhunWallet = data

            local worldItem = square:AddWorldInventoryItem(item, 0, 0, 0)

            if worldItem:getWorldItem() then
                worldItem:getWorldItem():setIgnoreRemoveSandbox(true); -- avoid the item to be removed by the SandboxOption WorldItemRemovalList
                worldItem:getWorldItem():transmitCompleteItemToClients();
            end
            -- if worldItem then
            --     worldItem:setName(getText("IGUI_PhunMart_Wallet_CharsWallet", player:getUsername()))
            --     worldItem:getWorldItem():setIgnoreRemoveSandbox(true); -- avoid the item to be removed by the SandboxOption WorldItemRemovalList
            --     worldItem:getModData().PhunWallet = {
            --         owner = player:getUsername(),
            --         wallet = toAdd
            --     }
            --     worldItem:getWorldItem():transmitCompleteItemToServer();
            -- end
        end
    end
end
