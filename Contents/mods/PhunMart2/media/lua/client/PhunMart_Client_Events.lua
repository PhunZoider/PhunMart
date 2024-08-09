local PhunMart = PhunMart

local function setup()
    Events.EveryOneMinute.Remove(setup)
    if FAVendingMachine and FAVendingMachine.doBuildMenu then
        FAVendingMachine.doBuildMenu = function(player, menu, square, VendingMachine)
        end
        FAVendingMachine.onUseVendingMachine = function(junk, player, VendingMachine, tempSetting)
        end
    end
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
