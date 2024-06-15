if not isClient() then
    return
end
local PhunMart = PhunMart

local textureCache = {}
local labelCache = {}
local descriptionCache = {}
local overlayCache = {}
local carKeyTexture = getTexture("Item_CarKey")

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
        elseif typeName == "PORT" then
            textureCache[typeName][textureName] = getTexture("media/textures/perk-Aiming.png")
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
            textureCache[typeName][textureName] = false
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
    if labelCache[typeName][labelName] == nil then

        if typeName == "ITEM" then
            local itemInstance = getScriptManager():getItem(labelName)
            if itemInstance and itemInstance.getDisplayName then
                labelCache[typeName][labelName] = itemInstance:getDisplayName() or false
            else
                labelCache[typeName][labelName] = false
            end
        elseif typeName == "PORT" then
            labelCache[typeName][labelName] = getText("IGUI_PhunMart.PortToX", labelName)
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
            labelCache[typeName][labelName] = false
        end

    end
    if labelCache[typeName][labelName] == false then
        return nil
    end
    return labelCache[typeName][labelName]
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
