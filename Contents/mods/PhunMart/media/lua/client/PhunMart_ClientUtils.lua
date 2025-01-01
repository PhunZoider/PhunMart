if isServer() then
    return
end
local PhunMart = PhunMart

local textureCache = {}
local labelCache = {}
local descriptionCache = {}
local overlayCache = {}
local carKeyTexture = getTexture("Item_CarKey")

local p4 = nil
local p4Textures = {}
local p4Options = {}

-- returns the display.label on client side for an item
function PhunMart:getTextureFromItem(item)

    local typeName = item.textureType
    local textureName = item.texture

    if not typeName or not textureName then
        return nil
    end

    if not textureCache[typeName] then
        textureCache[typeName] = {}
    end
    if textureCache[typeName][textureName] == nil then

        if typeName == "ITEM" then
            local itemInstance = getScriptManager():getItem(textureName)
            if itemInstance and itemInstance.getNormalTexture then
                textureCache[typeName][textureName] = itemInstance:getNormalTexture() or false
            else
                textureCache[typeName][textureName] = false
            end
        elseif typeName == "VEHICLE" then
            -- always display a key for vehicles
            textureCache[typeName][textureName] = carKeyTexture
        elseif typeName == "PERK" or typeName == "BOOST" then
            local perk = PerkFactory.getPerkFromName(textureName)
            if perk then
                textureCache[typeName][textureName] = getTexture("media/textures/perk-" .. textureName .. ".png") or
                                                          false
                if not textureCache[typeName][textureName] then
                    print("-------------------------")
                    print("PhunMart: Missing Perk Texture: " .. textureName)
                    print("-------------------------")
                end
            else
                textureCache[typeName][textureName] = false
            end
        elseif typeName == "TRAIT" then
            local trait = TraitFactory.getTrait(textureName)
            if trait then
                textureCache[typeName][textureName] = trait:getTexture()
            end
        else
            local res = false
            local hooks = self.hooks.getTexture
            if hooks and #hooks > 0 then
                for i = 1, #hooks do
                    res = hooks[i](typeName, textureName)
                    if res then
                        break
                    end
                end
            end
            textureCache[typeName][textureName] = res
        end
    end
    if textureCache[typeName][textureName] == false then
        return nil
    end
    return textureCache[typeName][textureName]
end

function PhunMart:getLabelFromItem(item)

    local typeName = item.type
    local labelName = item.label

    if not typeName or not labelName then
        return nil
    end

    if not labelCache[typeName] then
        labelCache[typeName] = {}
    end
    local itemInstance = nil
    if labelCache[typeName][labelName] == nil then

        if typeName == "ITEM" then
            itemInstance = getScriptManager():getItem(labelName)
            if itemInstance and itemInstance.getDisplayName then
                labelCache[typeName][labelName] = itemInstance:getDisplayName() or false
            else
                labelCache[typeName][labelName] = false
            end
        elseif typeName == "VEHICLE" then
            local vehicle = getScriptManager():getVehicle(labelName)
            if vehicle and vehicle.getName then
                labelCache[typeName][labelName] = getText("IGUI_VehicleName" .. vehicle:getName()) or false
            else
                labelCache[typeName][labelName] = false
            end
        elseif typeName == "PERK" or typeName == "BOOST" then
            local perk = PerkFactory.getPerkFromName(labelName)
            if perk then
                local txt = "?"
                if typeName == "PERK" then
                    labelCache[typeName][labelName] = getText("IGUI_PhunMartPerkItem", perk:getName())
                else
                    labelCache[typeName][labelName] = getText("IGUI_PhunMartPerkBoost", perk:getName())
                end
            end
        elseif typeName == "TRAIT" then
            local trait = TraitFactory.getTrait(labelName)
            if trait then
                labelCache[typeName][labelName] = trait:getLabel()
            end
        else
            local res = false
            local hooks = self.hooks.getLabel
            if hooks and #hooks > 0 then
                for i = 1, #hooks do
                    res = hooks[i](typeName, labelName)
                    if res then
                        break
                    end
                end
            end
            labelCache[typeName][labelName] = res
        end

    end
    if labelCache[typeName][labelName] == false then
        return nil
    end

    return labelCache[typeName][labelName]
end

function PhunMart:hasBeenRead(item)

    if not item or not item.type == "ITEM" or not item.label then
        return nil
    end

    local typeName = item.type
    local labelName = item.label
    local result = {
        status = nil,
        marking = nil,
        current = nil
    }
    local itemInstance = getScriptManager():getItem(labelName)

    if p4 == nil then
        p4 = false
        local p4data = ModData.get("P4HasBeenRead")
        if p4data then
            local pdata = getPlayer():getModData()
            if not pdata.P4HasBeenRead then
                pdata.P4HasBeenRead = {}
                pdata.P4HasBeenRead.markedMap = {}
            end
            p4 = pdata.P4HasBeenRead.markedMap
            p4Textures.textureBookNR = getTexture("media/ui/P4HasBeenRead_Book_NR.png")
            p4Textures.textureBookNC = getTexture("media/ui/P4HasBeenRead_Book_NC.png")
            p4Textures.textureBookAR = getTexture("media/ui/P4HasBeenRead_Book_AR.png")
            p4Textures.textureBookSM = getTexture("media/ui/P4HasBeenRead_Book_SM.png")
            p4Textures.textureBookCT = getTexture("media/ui/P4HasBeenRead_Book_CT.png")

            p4Textures.notReadTexture = p4Textures.textureBookNR
            p4Textures.notCompletedTexture = p4Textures.textureBookNC
            p4Textures.alreadyReadTexture = nil
            p4Textures.selfMarkingTexture = p4Textures.textureBookSM
            p4Textures.currentTargetTexture = p4Textures.textureBookCT

            p4Options = {
                showNR = true,
                showNC = true,
                showAR = false,
                showNCasNR = false,
                showSM = true,
                showCT = true,
                enableMap = true,
                enableCD = true,
                enableVHS = true,
                enableHVHS = true,
                autoMark = false,
                reverseMarkDisplay = false
            }
        end
    end

    if itemInstance and p4 then
        local category = itemInstance:getDisplayCategory()
        local statusTexture = nil
        local selfMarkingTexture = nil
        local currentTargetTexture = nil
        if category == "SkillBook" then
            local p = p4

            local player = getPlayer()
            local skillBook = SkillBook[itemInstance:getSkillTrained()]
            if skillBook then
                local perkLevel = player:getPerkLevel(skillBook.perk)
                local trained = itemInstance:getSkillTrained()
                local skillBook = SkillBook[trained]
                if not skillBook then
                    statusTexture = p4Textures.notReadTexture
                else
                    statusTexture = p4Textures.alreadyReadTexture
                end

                -- local minLevel = itemInstance:getLvlSkillTrained()
                -- local maxLevel = itemInstance:getMaxLevelTrained()
                -- if (minLevel <= perkLevel + 1) and (perkLevel + 1 <= maxLevel) then
                --     currentTargetTexture = p4Textures.currentTargetTexture
                -- end
                -- local readPages = player:getAlreadyReadPages(itemInstance:getFullType())
                -- if readPages >= itemInstance:getNumberOfPages() then
                --     statusTexture = p4Textures.alreadyReadTexture
                -- elseif perkLevel >= maxLevel then
                --     statusTexture = p4Textures.alreadyReadTexture
                -- elseif readPages > 0 then
                --     statusTexture = p4Textures.notCompletedTexture
                -- else
                --     statusTexture = p4Textures.notReadTexture
                -- end
            elseif itemInstance:getTeachedRecipes() and not itemInstance:getTeachedRecipes():isEmpty() then
                if player:getKnownRecipes():containsAll(itemInstance:getTeachedRecipes()) then
                    statusTexture = p4Textures.alreadyReadTexture
                else
                    statusTexture = p4Textures.notReadTexture
                end
            end

            if p4[labelName] then
                if not p4Options.reverseMarkDisplay then
                    selfMarkingTexture = p4Textures.selfMarkingTexture
                end
            else
                if p4Options.reverseMarkDisplay then
                    selfMarkingTexture = p4Textures.selfMarkingTexture
                end
            end

            result.marked = p[labelName] ~= nil
            -- local player = getPlayer()
            -- if itemInstance.getTeachedRecipes and itemInstance:getTeachedRecipes() and
            --     not itemInstance:getTeachedRecipes():isEmpty() then

            --     local recs = player:getKnownRecipes()
            --     local itemRecs = itemInstance:getTeachedRecipes()
            --     if recs:contains(itemRecs) then
            --         result.read = true
            --     else
            --         result.unread = true
            --     end
            -- else
            --     local trained = itemInstance:getSkillTrained()
            --     local skillBook = SkillBook[trained]

            --     if skillBook then
            --         local perkLevel = player:getPerkLevel(skillBook.perk)
            --         local minLevel = item:getLvlSkillTrained()
            --         local maxLevel = item:getMaxLevelTrained()
            --         if (minLevel <= perkLevel + 1) and (perkLevel + 1 <= maxLevel) then
            --             currentTargetTexture = p4Textures.currentTargetTexture
            --         end
            --         local readPages = player:getAlreadyReadPages(item:getFullType())
            --         if readPages >= item:getNumberOfPages() then
            --             statusTexture = p4Textures.alreadyReadTexture
            --         elseif perkLevel >= maxLevel then
            --             statusTexture = p4Textures.alreadyReadTexture
            --         elseif readPages > 0 then
            --             statusTexture = p4Textures.notCompletedTexture
            --         else
            --             statusTexture = p4Textures.notReadTexture
            --         end
            --     end
            --     result.read = p[labelName] ~= nil

            --     result.unread = not trained and skillBook[trained]
            -- end

        end
        result.status = statusTexture
        result.marking = selfMarkingTexture
        result.current = currentTargetTexture
    end
    return result
end

function PhunMart:getDescriptionFromItem(item)
    local typeName = item.type
    local textName = item.label

    if not typeName or not textName then
        return nil
    end

    if not descriptionCache[typeName] then
        descriptionCache[typeName] = {}
    end
    if descriptionCache[typeName][textName] == nil then

        if typeName == "ITEM" then
            local itemInstance = getScriptManager():getItem(textName)
            if itemInstance and itemInstance.getDescription then
                descriptionCache[typeName][textName] = itemInstance:getDescription() or false
            else
                descriptionCache[typeName][textName] = false
            end
        elseif typeName == "VEHICLE" then
            local vehicle = getScriptManager():getVehicle(textName)
            if vehicle and vehicle.getDescription then
                descriptionCache[typeName][textName] = vehicle:getDescription() or false
            else
                descriptionCache[typeName][textName] = false
            end
        elseif typeName == "PERK" or typeName == "BOOST" then
            local perk = PerkFactory.getPerkFromName(textName)
            if perk and perk.getDescription then
                descriptionCache[typeName][textName] = perk:getDescription() or false
            else
                descriptionCache[typeName][textName] = false
            end
        elseif typeName == "TRAIT" then
            local trait = TraitFactory.getTrait(textName)
            if trait and trait.getDescription then
                descriptionCache[typeName][textName] = trait:getDescription() or false
            else
                descriptionCache[typeName][textName] = false
            end
        else
            descriptionCache[typeName][textName] = false
        end

    end
    if descriptionCache[typeName][textName] == false then
        return nil
    end
    return descriptionCache[typeName][textName]
end

function PhunMart:getOverlayFromItem(item)
    if not item.overlay then
        return nil
    end
    local name = item.overlay

    if overlayCache[name] == nil then
        overlayCache[name] = getTexture("media/textures/" .. name .. ".png")
    end
    if overlayCache[name] == false then
        return nil
    end
    return overlayCache[name]
end
