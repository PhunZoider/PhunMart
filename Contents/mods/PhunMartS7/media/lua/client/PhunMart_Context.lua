if not isClient() then
    return
end

local PhunMart = PhunMart
local vendingContextMenu = function(playerObj, context, worldobjects, test)

    local player = getSpecificPlayer(playerObj);

    local found = nil
    local square = nil
    local spriteName = nil
    local isVanillaMachine = false
    for _, wObj in ipairs(worldobjects) do -- find object to interact with; code support for controllers
        square = wObj:getSquare()
        if square then
            found = CPhunMartSystem.instance:getLuaObjectOnSquare(square)
            PhunTools:printTable(wObj:getModData())
            local sn = wObj.getSprite and wObj:getSprite():getName()
            if PhunTools:startsWith(sn, "phunmart_") then
                spriteName = sn
            elseif PhunMart.spriteMap[sn] then
                isVanillaMachine = true
                break
            end
            if found then
                break
            end
        end
    end

    if found and found.id then
        local caption = "View vending machine "
        local option = context:addOptionOnTop(caption, player, function()
            found:open(player)
        end)

        local toolTip = ISToolTip:new();
        toolTip:setVisible(false);
        toolTip:setName(found.label or "View Vending Machine");
        option.notAvailable = false

        if found.lockedBy and found.lockedBy ~= player:getUsername() then
            toolTip.description = (found.lockedBy and found.lockedBy ~= player:getUsername() and
                                      "This vending machine is currently in use by " .. found.lockedBy) or ""
            option.notAvailable = true
        elseif found.requiresPower then
            if not square:haveElectricity() then
                if SandboxVars.ElecShutModifier > -1 and GameTime:getInstance():getNightsSurvived() >
                    SandboxVars.ElecShutModifier then
                    toolTip.description = "This vending machine requires power."
                    option.notAvailable = true
                end
            end
        end

        if option.notAvailable and isAdmin() then
            option.notAvailable = false
        end

        option.toolTip = toolTip;
    elseif spriteName then
        player:Say("It is jammed, let me try that again.")
        print("Orphaned vending machine found at " .. square:getX() .. ", " .. square:getY() .. " with sprite=" ..
                  tostring(spriteName))
        local args = {
            location = {
                x = square:getX(),
                y = square:getY(),
                z = square:getZ()
            },
            sprite = spriteName
        }
        sendClientCommand(player, PhunMart.name, PhunMart.commands.addFromSprite, args)

    end

    if isAdmin() then

        local adminOption = context:addOption("PhunVend", worldobjects, nil)
        local adminSubMenu = ISContextMenu:getNew(context)

        adminSubMenu:addOption("Locations", player, function()
            PhunMartUIAdminShops.OnOpenPanel(player)
        end)

        if spriteName then
            if found then
                adminSubMenu:addOption("PhunMart: Reroll", player, function()
                    CPhunMartSystem.instance:reroll({
                        ignoreDistance = true,
                        location = {
                            x = square:getX(),
                            y = square:getY(),
                            z = square:getZ()
                        }
                    })
                end)
            end

        elseif isVanillaMachine then
            adminSubMenu:addOption("PhunMart: Convert", player, function()
                local args = {
                    location = {
                        x = square:getX(),
                        y = square:getY(),
                        z = square:getZ()
                    },
                    sprite = spriteName
                }
                sendClientCommand(player, PhunMart.name, PhunMart.commands.addFromSprite, args)
            end)
        end
        context:addSubMenu(adminOption, adminSubMenu)
    end

end

Events.OnPreFillWorldObjectContextMenu.Add(vendingContextMenu);

Events.OnFillInventoryObjectContextMenu.Add(function(playerNum, context, items)
    local item = nil
    local playerObj = getSpecificPlayer(playerNum)
    for i = 1, #items do
        if not instanceof(items[i], "InventoryItem") then
            item = items[i].items[1]
        else
            item = items[i]
        end

        if item then
            local itemType = item:getType()
            if itemType == "VehicleKeySpawner" then
                local text = "Car"
                local modData = item:getModData()
                if modData.PhunMart and modData.PhunMart.text then
                    text = modData.PhunMart.text
                end
                if modData.PhunMart and modData.PhunMart.playername and modData.PhunMart.playername ==
                    playerObj:getUsername() then
                    context:addOptionOnTop(getText("IGUI_PhunMart.CallForX", text), playerObj, function()
                        local building = playerObj:getBuilding()
                        if building then
                            playerObj:Say(getText("IGUI_PhunMart.CannotCallForXInside", text))
                        else
                            sendClientCommand(playerObj, PhunMart.name, PhunMart.commands.spawnVehicle, modData.PhunMart)
                            playerObj:getInventory():DoRemoveItem(item)
                        end
                    end)
                end
            end
        end
    end
end)
