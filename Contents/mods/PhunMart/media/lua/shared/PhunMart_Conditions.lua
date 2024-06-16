require "PhunMart_Core"
require "PhunWallet_Core"

local PhunWallet = PhunWallet
local Conditions = {}

local RICH_PREFIX = "<LINE> <INDENT:4> "
local RICH_PREFIX_RED = "<LINE> <INDENT:4> <RED> "

--- a local, clientside cache of profession labels
--- @type table<string, string>
local _professionLabels = {}

--- @class satisfiedConditionResult
--- @field passed boolean
--- @field type string
--- @field key string
--- @field value any
--- @field text string
--- @field richText string
--- @field tooltipText string

--- Check players skill against the item and specific condition
--- mutating the results table by adding additional information for use in the UI
--- @param playerObj IsoPlayer
--- @param item table
--- @param condition any
--- @param results table<satisfiedConditionResult>
--- @return boolean of the results of the test (true if passed, false if failed )
Conditions.skills = function(self, playerObj, item, condition, results)
    local hasPassed = true
    local skills = self:getPlayerSkills(playerObj)
    for k, v in pairs(condition) do
        local min = nil
        local max = nil
        local isPassed = false
        local richText = ""
        local tooltip = ""

        if type(v) == "number" then
            -- value is min and expressed as "Strength": 5
            if v >= skills[k] then
                isPassed = true
                richText = RICH_PREFIX .. getText("IGUI_PhunMart.SkillRequiredDesc", k, v)
            else
                isPassed = false
                richText = RICH_PREFIX_RED .. getText("IGUI_PhunMart.SkillRequiredDesc", k, v)
                tooltip = getText("IGUI_PhunMart.SkillRequiredDesc", k, v)
            end

        elseif v.min and v.max then
            if v.min >= skills[k] and skills[k] <= v.max then
                isPassed = true
                richText = RICH_PREFIX .. getText("IGUI_PhunMart.SkillRequiredBetweenDesc", k, v.min, v.max)
            else
                isPassed = false
                richText = RICH_PREFIX_RED .. getText("IGUI_PhunMart.SkillRequiredBetweenDesc", k, v.min, v.max)
                tooltip = getText("IGUI_PhunMart.SkillRequiredBetweenDesc", k, v.min, v.max)
            end
        elseif v.min then
            if v.min >= skills[k] then
                isPassed = true
                richText = RICH_PREFIX .. getText("IGUI_PhunMart.SkillRequiredDesc", k, v.min)
            else
                isPassed = false
                richText = RICH_PREFIX_RED .. getText("IGUI_PhunMart.SkillRequiredDesc", k, v.min)
                tooltip = getText("IGUI_PhunMart.SkillRequiredDesc", k, v.min)
            end
        elseif v.max then
            if skills[k] <= v.max then
                isPassed = true
                richText = RICH_PREFIX .. getText("IGUI_PhunMart.SkillRequiredLessThanDesc", k, v.max)
            else
                isPassed = false
                richText = RICH_PREFIX_RED .. getText("IGUI_PhunMart.SkillRequiredLessThanDesc", k, v.max)
                tooltip = getText("IGUI_PhunMart.SkillRequiredLessThanDesc", k, v.max)
            end

        end

        table.insert(results, {
            passed = isPassed,
            type = "skills",
            key = k,
            value = v,
            text = k,
            richText = richText,
            tooltipText = tooltip
        })

    end
    return hasPassed
end

--- Check playerss current boosts against the item requirements
--- mutating the results table by adding additional information for use in the UI
--- @param playerObj IsoPlayer
--- @param item table
--- @param condition any
--- @param results table<satisfiedConditionResult>
--- @return boolean of the results of the test (true if passed, false if failed )
Conditions.boosts = function(self, playerObj, item, condition, results)
    local hasPassed = true
    for k, v in pairs(condition) do

        local perk = PerkFactory.getPerkFromName(k)
        local level = playerObj:getXp():getPerkBoost(perk);
        if level == 3 then
            -- player can't go higher without resetting boost so auto-fail?
            table.insert(results, {
                passed = false,
                type = "boosts",
                key = k,
                value = true,
                text = k,
                richText = RICH_PREFIX_RED .. k,
                tooltipText = getText("IGUI_PhunMart.ConditionCategory.boostsMaxed", k)
            })
        elseif v == true then
            -- we are requiring an existing boost for some reason
            if level == 0 then
                -- failed
                table.insert(results, {
                    passed = false,
                    type = "boosts",
                    key = k,
                    value = true,
                    text = k,
                    richText = RICH_PREFIX_RED .. k,
                    tooltipText = getText("IGUI_PhunMart.BoostRequired", k)
                })
                hasPassed = false
            else
                -- passed
                table.insert(results, {
                    passed = true,
                    type = "boosts",
                    key = k,
                    value = true,
                    text = k,
                    richText = RICH_PREFIX .. k
                })
            end
        elseif v == false then
            -- we are saying we don't want a boost at all
            if level == 0 then
                -- passed
                table.insert(results, {
                    passed = true,
                    type = "boosts",
                    key = k,
                    value = true,
                    text = k,
                    richText = RICH_PREFIX .. k
                })
            else
                -- failed
                table.insert(results, {
                    passed = false,
                    type = "boosts",
                    key = k,
                    value = true,
                    text = k,
                    issue = getText("IGUI_PhunMart.BoostPreRequisitMissing", k),
                    richText = RICH_PREFIX_RED .. k,
                    tooltipText = getText("IGUI_PhunMart.BoostPreRequisitMissing", k)
                })
                hasPassed = false
            end
        end

    end
    return hasPassed
end

--- Check players traits against the item and specific condition
--- mutating the results table by adding additional information for use in the UI
--- @param playerObj IsoPlayer
--- @param item table
--- @param condition any
--- @param results table<satisfiedConditionResult>
--- @return boolean of the results of the test (true if passed, false if failed )
Conditions.traits = function(self, playerObj, item, condition, results)
    local hasPassed = true
    for k, v in pairs(condition) do
        if playerObj:HasTrait(k) then
            if v == false then
                table.insert(results, {
                    passed = false,
                    type = "traits",
                    key = k,
                    value = v,
                    text = k,
                    richText = RICH_PREFIX_RED .. k,
                    tooltipText = getText("IGUI_PhunMart.TraitRequired", k)
                })
                hasPassed = false
            else
                table.insert(results, {
                    passed = true,
                    type = "traits",
                    key = k,
                    value = v,
                    text = k,
                    richText = RICH_PREFIX .. k
                })
            end
        else
            if v == true then
                table.insert(results, {
                    passed = false,
                    type = "traits",
                    key = k,
                    text = k,
                    value = v,
                    richText = RICH_PREFIX_RED .. k,
                    tooltipText = getText("IGUI_PhunMart.TraitPreRequisitMissing", k)
                })
                hasPassed = false
            else
                table.insert(results, {
                    passed = true,
                    type = "traits",
                    key = k,
                    value = v,
                    text = k,
                    richText = RICH_PREFIX .. k
                })
            end
        end
    end
    return hasPassed
end

--- Check players profession against the item and specific condition
--- mutating the results table by adding additional information for use in the UI
--- @param playerObj IsoPlayer
--- @param item table
--- @param condition any
--- @param results table<satisfiedConditionResult>
--- @return boolean of the results of the test (true if passed, false if failed )
Conditions.professions = function(self, playerObj, item, condition, results)
    local hasPassed = true
    local profession = playerObj:getDescriptor():getProfession();
    for k, v in pairs(condition) do
        if not _professionLabels[k] then
            _professionLabels[k] = ProfessionFactory.getProfession(k):getLabel()
        end
        if v == true then
            if profession == k then
                table.insert(results, {
                    passed = true,
                    type = "professions",
                    key = k,
                    value = true,
                    text = _professionLabels[k],
                    richText = RICH_PREFIX .. k
                })
            else
                table.insert(results, {
                    passed = false,
                    type = "professions",
                    key = k,
                    value = true,
                    text = _professionLabels[k],
                    richText = RICH_PREFIX_RED .. _professionLabels[k],
                    tooltipText = getText("IGUI_PhunMart.ProfessionRequired", _professionLabels[k])
                })
                hasPassed = false
            end
        else
            if profession == k then
                table.insert(results, {
                    passed = false,
                    type = "professions",
                    key = k,
                    text = k,
                    value = false,
                    richText = RICH_PREFIX_RED .. _professionLabels[k],
                    tooltipText = getText("IGUI_PhunMart.ProfessionPreRequisitMissing", _professionLabels[k])
                })
                hasPassed = false
            else
                table.insert(results, {
                    passed = true,
                    type = "professions",
                    key = k,
                    value = false,
                    text = k,
                    richText = RICH_PREFIX .. _professionLabels[k]
                })
            end
        end
    end
    return hasPassed
end

--- Check players previous item purchases (of ALL players characters) against the item and specific condition
--- mutating the results table by adding additional information for use in the UI
--- @param playerObj IsoPlayer
--- @param item table
--- @param condition any
--- @param results table<satisfiedConditionResult>
--- @return boolean of the results of the test (true if passed, false if failed )
Conditions.maxLimit = function(self, playerObj, item, condition, results)
    local hasPassed = true
    local historicItem = self:getHistoricItem(playerObj, item)
    local msg = getText("IGUI_PhunMart.maxLimitDesc", PhunTools:formatWholeNumber(condition))
    if (historicItem.purchases or 0) >= condition then
        table.insert(results, {
            passed = false,
            type = "maxLimit",
            key = "maxLimit",
            value = condition,
            richText = RICH_PREFIX_RED .. msg,
            tooltipText = getText("IGUI_PhunMart.maxLimitMetOrExceeded", PhunTools:formatWholeNumber(condition))
        })
        hasPassed = false
    else
        table.insert(results, {
            passed = true,
            type = "maxLimit",
            key = "maxLimit",
            value = condition,
            text = "",
            richText = RICH_PREFIX .. msg
        })
    end
    return hasPassed
end

--- Check characters previous item purchases against the item and specific condition
--- mutating the results table by adding additional information for use in the UI
--- @param playerObj IsoPlayer
--- @param item table
--- @param condition any
--- @param results table<satisfiedConditionResult>
--- @return boolean of the results of the test (true if passed, false if failed )
Conditions.maxCharLimit = function(self, playerObj, item, condition, results)
    local hasPassed = true
    local historicItem = self:getHistoricItem(playerObj, item)
    local msg = getText("IGUI_PhunMart.maxCharLimitDesc", PhunTools:formatWholeNumber(condition))
    if (historicItem.charPurchases or 0) >= condition then
        table.insert(results, {
            passed = false,
            type = "maxCharLimit",
            key = "maxCharLimit",
            value = condition,
            richText = RICH_PREFIX_RED .. msg,
            tooltipText = getText("IGUI_PhunMart.maxCharLimitMetOrExceeded", PhunTools:formatWholeNumber(condition))
        })
        hasPassed = false
    else
        table.insert(results, {
            passed = true,
            type = "maxCharLimit",
            key = "maxCharLimit",
            value = condition,
            text = "",
            richText = RICH_PREFIX .. msg
        })
    end
    return hasPassed
end

--- Check characters time survived against the item and specific condition
--- mutating the results table by adding additional information for use in the UI
--- @param playerObj IsoPlayer
--- @param item table
--- @param condition any
--- @param results table<satisfiedConditionResult>
--- @return boolean of the results of the test (true if passed, false if failed )
Conditions.minCharTime = function(self, playerObj, item, condition, results)
    local hasPassed = true
    local historicItem = self:getHistoricItem(playerObj, item)
    local hours = playerObj:getHoursSurvived()
    local diff = (hours - (historicItem.charEvo or 0))
    local msg = getText("IGUI_PhunMart.minCharTimeDesc", PhunTools:formatWholeNumber(condition));
    if diff < condition then

        table.insert(results, {
            passed = false,
            type = "minCharTime",
            key = "minCharTime",
            value = condition,
            issue = msg,
            richText = RICH_PREFIX_RED .. msg,
            tooltipText = getText("IGUI_PhunMart.minCharTimeDiffDesc", PhunTools:formatWholeNumber(diff))
        })
        hasPassed = false
    else
        table.insert(results, {
            passed = true,
            type = "minCharTime",
            key = "minCharTime",
            value = condition,
            text = "",
            richText = RICH_PREFIX .. msg
        })
    end
    return hasPassed
end

--- Check players total time survived (on all chars) against the item and specific condition
--- mutating the results table by adding additional information for use in the UI
--- @param playerObj IsoPlayer
--- @param item table
--- @param condition any
--- @param results table<satisfiedConditionResult>
--- @return boolean of the results of the test (true if passed, false if failed )
Conditions.minTime = function(self, playerObj, item, condition, results)
    local hasPassed = true
    local historicItem = self:getHistoricItem(playerObj, item)
    local hours = getGameTime():getWorldAgeHours()
    local diff = (hours - (historicItem.charEvo or 0)) - condition
    local msg = getText("IGUI_PhunMart.minTimeDesc", PhunTools:formatWholeNumber(condition));
    if diff < condition then

        table.insert(results, {
            passed = false,
            type = "minTime",
            key = "minTime",
            value = condition,
            richText = RICH_PREFIX_RED .. msg,
            tooltipText = getText("IGUI_PhunMart.minTimeDiffDesc", PhunTools:formatWholeNumber(diff))
        })
        hasPassed = false
    else
        table.insert(results, {
            passed = true,
            type = "minTime",
            key = "minTime",
            value = condition,
            text = "",
            richText = RICH_PREFIX .. msg
        })
    end
    return hasPassed
end

--- Check players weight against an item against the item and specific condition
--- mutating the results table by adding additional information for use in the UI
--- @param playerObj IsoPlayer
--- @param item table
--- @param condition any
--- @param results table<satisfiedConditionResult>
--- @return boolean of the results of the test (true if passed, false if failed )
Conditions.weight = function(self, playerObj, item, condition, results)
    local hasPassed = true
    local totalWeight = item.weight * (item.quantity or 1)
    -- totalWeight = 10
    local inv = playerObj:getInventory()
    local itemObj = getScriptManager():getItem(item.name)
    local hasSpace = (inv:getCapacityWeight() <= inv:getEffectiveCapacity(playerObj));
    local msg = getText("IGUI_PhunMart.ItemIsTooHeavy", itemObj:getDisplayName());
    if not hasSpace or not inv:hasRoomFor(playerObj, totalWeight) then

        table.insert(results, {
            passed = false,
            type = "weight",
            key = "weight",
            value = condition,
            richText = RICH_PREFIX_RED .. msg,
            tooltipText = msg
        })
        hasPassed = false
    else
        table.insert(results, {
            passed = true,
            type = "weight",
            key = "weight",
            value = condition,
            text = ""
            -- no mention in rich text or tooltip if there is no issue
        })
    end
    return hasPassed
end

--- Check players inventory capacity against an item against the item and specific condition
--- mutating the results table by adding additional information for use in the UI
--- @param playerObj IsoPlayer
--- @param item table
--- @param condition any
--- @param results table<satisfiedConditionResult>
--- @return boolean of the results of the test (true if passed, false if failed )
Conditions.inventory = function(self, playerObj, item, condition, results)
    local hasPassed = true
    if item.inventory < (condition or 1) then
        table.insert(results, {
            passed = false,
            type = "inventory",
            key = "inventory",
            value = (condition or 1),
            richText = RICH_PREFIX_RED .. "Insufficient inventory space",
            tooltipText = getText("IGUI_PhunMart.ItemIsOOS")
        })
        hasPassed = false
    else
        table.insert(results, {
            passed = true,
            type = "weight",
            key = "weight",
            value = (condition or 1),
            text = ""
            -- no mention in rich text or tooltip if there is sufficient stock
        })
    end
    return hasPassed
end

--- Check players inventory (and PhunWallet) for ability to pay for item
--- mutating the results table by adding additional information for use in the UI
--- @param playerObj IsoPlayer
--- @param item table
--- @param condition any
--- @param results table<satisfiedConditionResult>
--- @return boolean of the results of the test (true if passed, false if failed )
Conditions.price = function(self, playerObj, item, price, results)
    local hasPassed = true

    --- @type table<string, {value: number, formattedValue: string, label: string}>
    local satisfied = {}

    if not self.currencies then
        --- @type table<string, {type: string, label: string, type: string}>
        self.currencies = {}
    end

    -- aggregate price items
    for k, v in pairs(price) do

        if not self.currencies[k] then
            local hooks = self.hooks.currencyLabels or {}
            for _, v in ipairs(hooks) do
                if v then
                    local label, type = v(k)
                    if label and type then
                        self.currencies[k] = {
                            type = type,
                            label = label
                        }
                    end
                end
            end
        end

        --- cache information about this currency
        if not self.currencies[k] then

            local itemInstance = getScriptManager():getItem(k)

            -- is PhunWallet installed and is it managing this item as a currency?
            -- if PhunWallet and PhunWallet.currencies[k] then
            --     self.currencies[k] = {
            --         type = "PhunWallet"
            --     }
            --     if itemInstance then
            --         self.currencies[k].label = itemInstance:getDisplayName()
            --     else
            --         self.currencies[k].label = k
            --     end
            -- else
            if itemInstance then
                self.currencies[k] = {
                    type = "item",
                    label = itemInstance:getDisplayName()
                }
            elseif not itemInstance then
                -- is this a trait?
                local trait = TraitFactory.getTrait(k)
                if trait then
                    self.currencies[k] = {
                        type = "trait",
                        label = trait:getLabel()
                    }
                end
            else
                self.currencies[k] = {
                    type = "unknown",
                    label = k
                }
            end

        end

        satisfied[k] = {
            value = v,
            formattedValue = PhunTools:formatWholeNumber(price[k]),
            type = self.currencies[k].type,
            label = self.currencies[k].label
        }

    end

    local hooks = self.hooks.preSatisfyPrice or {}
    if #hooks then
        for _, v in ipairs(hooks) do
            if v then
                v(playerObj, item, satisfied)
            end
        end
    end

    -- deduct items that player has in inventory
    for k, v in pairs(satisfied) do
        if v.type == "item" and v.value > 0 then
            local inv = playerObj:getInventory()
            local count = inv:getItemCountRecurse(k) or 0
            if count > v.value then
                v.value = 0
            else
                v.value = v.value - count
            end
            -- elseif v.type == "PhunWallet" and v.value > 0 then
            --     -- assert that PhunWallet is being used to manage this currency
            --     local wallet = PhunWallet:getPlayerData(playerObj).wallet or {}
            --     local current = wallet.current or {}

            --     if current[k] then
            --         if current[k] > v.value then
            --             v.value = 0
            --         else
            --             v.value = v.value - current[k]
            --         end
            --     end
        elseif v.type == "trait" and v.value > 0 then
            -- player is "paying" with a trait
            if playerObj:HasTrait(k) then
                v.value = v.value - 1
            end
        end
    end

    hooks = self.hooks.preSatisfyPrice or {}
    if #hooks then
        for _, v in ipairs(hooks) do
            if v then
                v(playerObj, item, satisfied)
            end
        end
    end

    -- check if anll items can be satisfied
    for k, v in pairs(satisfied) do
        if v.value > 0 then
            table.insert(results, {
                passed = false,
                type = "price",
                key = k,
                current = v.current or false,
                value = v.formattedValue,
                gap = v.value,
                text = v.text,
                richText = RICH_PREFIX_RED .. getText("IGUI_PhunMart.PriceDesc", v.formattedValue, v.label),
                tooltipText = getText("IGUI_PhunMart.PriceDescShortage", PhunTools:formatWholeNumber(v.value), v.label)
            })
            hasPassed = false
        else
            table.insert(results, {
                passed = true,
                type = "price",
                current = v.current or false,
                key = k,
                gap = 0,
                value = v.formattedValue,
                richText = RICH_PREFIX .. getText("IGUI_PhunMart.PriceDesc", v.formattedValue, v.label),
                text = v.text
            })
        end
    end
    return hasPassed
end

PhunMart.conditions = Conditions
