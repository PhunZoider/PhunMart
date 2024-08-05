if not isClient() then
    return
end

local PhunMart = PhunMart
local vendingContextMenu = function(playerObj, context, worldobjects)

    local player = getSpecificPlayer(playerObj);

    local found = nil

    for _, wObj in ipairs(worldobjects) do -- find object to interact with; code support for controllers
        local square = wObj:getSquare()
        if square then
            found = CPhunMartSystem.instance:getLuaObjectOnSquare(square)
            break
        end
    end

    if found and found.id then
        context:addOption("View vending machine " .. found.label or "View Vending Machine", player, function()
            found:open(player)
            -- PhunMartShopWindow.OnOpenPanel(player, found)
        end)
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
end)
