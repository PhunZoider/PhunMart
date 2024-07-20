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

    if found and found.shop then
        context:addOption(found.shop.label or "Vending Machine", player, function()
            PhunMartShopWindow.OnOpenPanel(player, found.shop)
        end)
    end

end

Events.OnPreFillWorldObjectContextMenu.Add(vendingContextMenu);

local onSquareLoad = function(square)
    local object = nil;
    local objType = nil;
    local objFound = false;
    local machine = nil;
    if square then
        machine = PhunMart:getMachineFromSquare(square)
        if machine ~= nil then
            return
        end
    end

    if machine == nil then
        return
    end
    local key = PhunMart:getKey(machine)
    local shop = PhunMart:getShop(key)
    if not shop then
        -- first time loading ?
        sendClientCommand(getPlayer(), PhunMart.name, PhunMart.commands.requestShop, {
            key = key
        })
    end

    -- prevent shit from being put into vending machines
    machine:getContainer():emptyIt();
    machine:getContainer():setAcceptItemFunction("AcceptItemFunction.PhunMart");
    machine:setNoPicking(true);
    square:RecalcProperties();
end

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

-- Events.LoadGridsquare.Add(onSquareLoad);
