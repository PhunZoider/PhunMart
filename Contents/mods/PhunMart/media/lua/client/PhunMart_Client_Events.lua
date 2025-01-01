if isServer() then
    return
end
local PhunMart = PhunMart

local function setup()
    Events.EveryOneMinute.Remove(setup)
    -- sendClientCommand(PhunMart.name, PhunMart.commands.requestShopDefs, {})
    -- if FAVendingMachine and FAVendingMachine.doBuildMenu then
    --     FAVendingMachine.doBuildMenu = function(player, menu, square, VendingMachine)
    --     end
    --     FAVendingMachine.onUseVendingMachine = function(junk, player, VendingMachine, tempSetting)
    --     end
    -- end
end
Events.EveryOneMinute.Add(setup)

-- Request each local players purchase history
local function requestHistory()
    for i = 0, getOnlinePlayers():size() - 1 do
        local p = getOnlinePlayers():get(i)
        if p:isLocalPlayer() then
            sendClientCommand(p, PhunMart.name, PhunMart.commands.updateHistory, {})
        end
    end
    -- wtf is this?
    Events.EveryOneMinute.Remove(requestHistory)
end

Events.OnPlayerUpdate.Add(function(playerObj)
    local name = PhunMart.transactionQueue[playerObj:getUsername()]
    if PhunMart.transactionQueue[name] and #PhunMart.transactionQueue[name] > 0 then
        PhunMart:processTransactionQueue(playerObj)
    end
end)

Events.OnGameStart.Add(function()
    -- one off tick to request purchase history
    Events.EveryOneMinute.Add(requestHistory)

end)

Events[PhunMart.events.OnShopDefsReloaded].Add(function(shops)
    if PhunMartUIAdminShops then
        for _, instance in pairs(PhunMartUIAdminShops.instances) do
            instance:refreshShops(shops or {})
        end
    end
end)
Events[PhunMart.events.OnShopLocationsReceived].Add(function(locations)
    if PhunMartUIAdminShops then
        for _, instance in pairs(PhunMartUIAdminShops.instances) do
            instance:refreshLocations(locations or {})
        end
    end
end)
Events[PhunMart.events.OnShopItemDefsReloaded].Add(function(items)
    if PhunMartUIAdminShops then
        for _, instance in pairs(PhunMartUIAdminShops.instances) do
            instance:refreshItems(items or {})
        end
    end
end)
