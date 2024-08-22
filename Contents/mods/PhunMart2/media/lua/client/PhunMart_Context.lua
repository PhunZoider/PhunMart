if not isClient() then
    return
end

local PhunMart = PhunMart
local vendingContextMenu = function(playerObj, context, worldobjects, test)

    local player = getSpecificPlayer(playerObj);

    local found = nil
    local square = nil
    local spriteName = nil
    for _, wObj in ipairs(worldobjects) do -- find object to interact with; code support for controllers
        square = wObj:getSquare()
        if square then
            found = CPhunMartSystem.instance:getLuaObjectOnSquare(square)
            local sn = wObj.getSprite and wObj:getSprite():getName()
            if PhunMart.spriteMap[sn] or PhunTools:startsWith(sn, "phunmart_") then
                spriteName = sn
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
    elseif found then
        if spriteName then
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

        else
            print("Found vending machine, but it is missing an id and spritename")
        end
    end

    if isAdmin() then
        if spriteName then
            if found then
                context:addOption("PhunMart: Reroll", player, function()
                    CPhunMartSystem.instance:reroll({
                        location = {
                            x = square:getX(),
                            y = square:getY(),
                            z = square:getZ()
                        }
                    })
                end)
            else
                -- not found, but has a sprite. So either a broken one or a virgin one

                local isVirgin = not PhunTools:startsWith(spriteName, "phunmart_")
                if isVirgin then
                    context:addOption("PhunMart: Convert", player, function()

                        -- what dir is spriteName  facing?
                        local dir = {
                            east = 0,
                            south = 1,
                            west = 2,
                            north = 3
                        }
                        local s = spriteName
                        local sm = PhunMart.spriteMap
                        local xx = sm[s]
                        local i = dir[xx]
                        local args = {
                            location = {
                                x = square:getX(),
                                y = square:getY(),
                                z = square:getZ()
                            },
                            sprite = "phunmart_01_" .. tostring((8 + i or 0))
                        }
                        sendClientCommand(player, PhunMart.name, PhunMart.commands.addFromSprite, args)
                    end)

                else
                    context:addOption("PhunMart: Fix", player, function()
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

            end
            -- if not found then
            --     context:addOption("PhunMart: Fix", player, function()
            --         CPhunMartSystem.instance:reroll({
            --             location = {
            --                 x = square:getX(),
            --                 y = square:getY(),
            --                 z = square:getZ()
            --             }
            --         })
            --     end)
            -- end
        end
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
