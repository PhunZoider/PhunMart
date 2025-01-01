if isServer() then
    return
end
local PhunMart = PhunMart

PhunMart.transactionQueue = {}

function PhunMart:addTransaction(playerObj, item)

    if not PhunMart.transactionQueue[playerObj:getUsername()] then
        PhunMart.transactionQueue[playerObj:getUsername()] = {}
    end

    local q = PhunMart.transactionQueue[playerObj:getUsername()]

    table.insert(q, {
        playerIndex = playerObj:getPlayerNum(),
        item = item
    })

end

function PhunMart:completeTransaction(args)

    if type(args) == "table" and args.playerIndex and args.success == true then

        local playerObj = getSpecificPlayer(args.playerIndex)

        if playerObj then
            local hooks = self.hooks.purchase
            local canBuy = self:canBuy(playerObj, args.item)

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
                                for i = 1, remaining do
                                    local invItem = playerObj:getInventory():getItemFromTypeRecurse(a.currency)
                                    if invItem then
                                        invItem:getContainer():DoRemoveItem(invItem)
                                    end
                                end
                            end
                        else
                            -- assert its a hook
                            local hooks = self.hooks.purchase
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

            for _, v in ipairs(args.item.receive) do
                if self.applyReceipt[v.type] then
                    self.applyReceipt[v.type](playerObj, v)
                else
                    for _, hook in ipairs(hooks) do
                        if hook then
                            hook(playerObj, v)
                        end
                    end
                end
            end
        end
    end

end
function PhunMart:processTransactionQueue(playerObj)
    local queue = PhunMart.transactionQueue[playerObj:getUsername()]
    if queue and #queue > 0 then
        if playerObj:hasTimedActions() then
            return
        end
        local item = queue[1]
        sendClientCommand(playerObj, PhunMart.name, PhunMart.commands.buy, item)
    end
end
