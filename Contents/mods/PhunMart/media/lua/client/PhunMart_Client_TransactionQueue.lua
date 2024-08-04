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

            if hooks and #hooks > 0 then
                if args.item.conditions[1] and args.item.conditions[1].price then
                    for key, val in pairs(args.item.conditions[1].price) do
                        for _, v in ipairs(hooks) do
                            if v then
                                -- should mutate val if handled in hook
                                v(playerObj, key, tonumber(val))
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
