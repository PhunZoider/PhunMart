if not isClient() then
    return
end
require "PhunMart_UX"

local PhunMart = PhunMart

function PhunMart:setDisplayValues(item)

    local display = item.display or {}
    display.textureVal = display.textureVal or PhunMart:getTextureFromItem(display)
    display.labelVal = display.labelVal or PhunMart:getLabelFromItem(display) or item.key
    display.overlayVal = display.overlayVal or PhunMart:getOverlayFromItem(display)
    display.descriptionVal = display.descriptionVal or PhunMart:getDescriptionFromItem(display)
    item.display = display
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

    for _, condition in ipairs(item.conditions) do

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
    if item.inventory ~= false and item.inventory < 1 then
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

                local key = v.key
                local val = tonumber(v.value)

                local hooks = self.hooks.prePurchase
                for _, v in ipairs(hooks) do
                    if v then
                        -- should mutate val if handled in hook
                        v(playerObj, key, val)
                    end
                end

                if self.currencies[key] then
                    if self.currencies[key].type == "trait" then
                        -- spending a trait
                        playerObj:getTraits():remove(key)
                    elseif self.currencies[key].type == "item" and val > 0 then
                        -- spending an item
                        local item = getScriptManager():getItem(key)
                        if item then
                            local remaining = val
                            -- asserting we have enough to consume or canBuy wouldn't have passed?
                            for i = 1, remaining do
                                local invItem = playerObj:getInventory():getItemFromTypeRecurse(key)
                                if invItem then
                                    invItem:getContainer():DoRemoveItem(invItem)
                                    val = val - 1
                                end
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

-- function PhunMart:restock(vendingMachine)
--     local args = {
--         location = {
--             x = vendingMachine:getX(),
--             y = vendingMachine:getY(),
--             z = vendingMachine:getZ()
--         }
--     }
--     sendClientCommand(getPlayer(), PhunMart.name, PhunMart.commands.requestRestock, args)
-- end

-- Client fixes for other mods
if FA and FA.updateVendingMachine then
    -- Functional Appliances
    -- overwrite their handing of vending machines
    local oldFn = FA.updateVendingMachine
    FA.updateVendingMachine = function(vendingMaching, fill)
        return vendingMaching
    end

end

