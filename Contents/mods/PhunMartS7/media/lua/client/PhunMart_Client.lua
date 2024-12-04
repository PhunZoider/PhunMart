if not isClient() then
    return
end
require "P4HasBeenRead"
local PhunMart = PhunMart

function PhunMart:getDisplayValues(item)

    local display = {}
    display.textureVal = display.textureVal or PhunMart:getTextureFromItem(item.display or {})
    display.labelVal = display.labelVal or PhunMart:getLabelFromItem(item.display or {}) or item.key
    display.overlayVal = display.overlayVal or PhunMart:getOverlayFromItem(item.display or {})
    display.hasBeenReadVal = PhunMart:hasBeenRead(item.display)
    display.descriptionVal = display.descriptionVal or PhunMart:getDescriptionFromItem(item.display or {})
    return display
end

function PhunMart:getHistoricItem(playerObj, item)
    local pd = self:getPlayerData(playerObj)
    local history = pd.purchases or {}
    local historyKey = item.key or item.name
    return history[historyKey] or {}
end

-- Helper for condition check
function PhunMart:getPlayerSkills(playerObj)
    local result = {}
    for i = 0, Perks.getMaxIndex() - 1 do
        local perk = PerkFactory.getPerk(Perks.fromIndex(i))
        if perk and perk:getParent() ~= Perks.None then
            result[perk:getName()] = playerObj:getPerkLevel(Perks.fromIndex(i))
        end
    end
    return result
end

-- Verify if a player meets all conditions to purchase
function PhunMart:canBuy(playerObj, item)

    local summary = {
        passed = true,
        conditions = {}
    }

    for _, condition in ipairs(item.conditions or {}) do

        local result = {}
        for k, v in pairs(condition) do
            --- @type boolean
            local test = self.conditions[k](self, playerObj, item, v, result)
            summary.passed = summary.passed and test
        end
        table.insert(summary.conditions, result)
        if summary.passed then
            return summary
        end
    end

    -- check there is inventory available to sell. 
    -- item.inventory == false == infinite stock
    if item.inventory ~= false and (item.inventory or 0) < 1 then
        summary.passed = false
        table.insert(summary.conditions, {
            type = "inventory",
            passed = false,
            key = "inventory",
            value = item.inventory,
            message = "IGUI_PhunMart.Error.OOS"
        })
    end

    return summary
end

-- submit a request to make a purchase
function PhunMart:purchaseRequest(playerObj, shopKey, item)

    -- recheck that player can buy
    local canBuy = self:canBuy(playerObj, item)

    if canBuy.passed == true then
        -- assert condition 1 is the one Condition that passeed
        -- iterate through each condition and adjust any prices
        for _, v in ipairs(canBuy.conditions[1]) do

            if v.type == "price" then
                local allocations = v.allocations or {}
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
                        local hooks = self.hooks.prePurchase
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
        sendClientCommand(playerObj, self.name, self.commands.buy, {
            id = shopKey,
            item = item
        })
    end
end

