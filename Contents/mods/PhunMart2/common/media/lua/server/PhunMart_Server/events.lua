if isClient() then
    return
end
require "PhunMart/core"
local Commands = require "PhunMart_Server/commands"

local Core = PhunMart

Events.OnServerStarted.Add(function()
    Core:ini()
end)

Events.LoadGridsquare.Add(function(square)
    Core.ServerSystem.instance:loadGridsquare(square)
end)

Events.OnCharacterDeath.Add(function(character)
    if not instanceof(character, "IsoPlayer") then
        return
    end

    Core.playtimeRewards:getPlayerData(character).previousHours = character:getHoursSurvived()

    -- Drop wallet item if enabled
    if Core.settings.DropOnDeath then
        local walletData = Core.wallet:get(character)
        local current = walletData and walletData.current or {}
        local rate = Core.settings.WalletReturnRate
        if rate == nil then
            rate = 100
        end

        local toAdd = {}
        for pool, poolDef in pairs(Core.wallet.pools) do
            if not poolDef.bound then
                local balance = current[pool] or 0
                if balance > 0 then
                    local amount = math.floor(balance * (rate / 100))
                    if amount > 0 then
                        table.insert(toAdd, {
                            pool = pool,
                            amount = amount
                        })
                        Core.wallet:adjustByPool(character, "current", pool, -amount)
                    end
                end
            end
        end

        if #toAdd > 0 then
            local square = character:getSquare()
            local ok, err = pcall(function()
                local item = instanceItem("PhunMart.DroppedWallet")
                if not item then
                    error("instanceItem returned nil for PhunMart.DroppedWallet")
                end
                local walletName = character:getUsername() .. "'s Wallet"
                pcall(function()
                    walletName = getText("IGUI_PhunMart_CharsWallet", character:getUsername())
                end)
                item:setName(walletName)
                item:getModData().PhunWallet = {
                    owner = Core.isLocal and character:getPlayerNum() or character:getUsername(),
                    wallet = toAdd
                }
                local worldItem = square:AddWorldInventoryItem(item, 0, 0, 0)
                if worldItem and worldItem:getWorldItem() then
                    worldItem:getWorldItem():setIgnoreRemoveSandbox(true)
                    worldItem:getWorldItem():transmitCompleteItemToClients()
                end
            end)
            if not ok then
                Core.debugLn("OnCharacterDeath: failed to drop wallet: " .. tostring(err))
            end
        end
    end

    -- Reset wallet (zero unbound, restore bound)
    Core.wallet:reset(character)
    Core.wallet:save()
end)

Events.EveryTenMinutes.Add(function()
    Core.playtimeRewards:tick()
    Core.wallet:save()
end)

-- Check power state every minute so sprite swaps within ~1 minute of electricity changing.
-- updateSprite() compares hasPower against self.powered and no-ops when unchanged,
-- so this loop is near-zero cost during steady state.
Events.EveryOneMinute.Add(function()
    local sys = Core.ServerSystem and Core.ServerSystem.instance
    if not sys then
        return
    end
    for i = 1, sys:getLuaObjectCount() do
        local obj = sys:getLuaObjectByIndex(i)
        if obj then
            obj:updateSprite()
        end
    end
end)

Events.OnZombieDead.Add(function(character)
    if not instanceof(character, "IsoZombie") then
        return
    end

    if Core.getOption("EnableChangePool") == false then
        return
    end

    local chance, minCents, maxCents = Core.getCoinChance(character)

    if ZombRand(100) >= math.floor(chance * 100) then
        return
    end

    -- pick a random nickel-aligned amount in [minCents, maxCents]
    local steps = math.max(0, math.floor((maxCents - minCents) / 5))
    local totalCents = minCents + ZombRand(0, steps + 1) * 5

    -- convert to fewest coins: quarters → dimes → nickels
    local inv = character:getInventory()
    local rem = totalCents
    local quarters = math.floor(rem / 25);
    rem = rem - quarters * 25
    local dimes = math.floor(rem / 10);
    rem = rem - dimes * 10
    local nickels = math.floor(rem / 5)

    for _ = 1, quarters do
        inv:AddItem("PhunMart.Quarter")
    end
    for _ = 1, dimes do
        inv:AddItem("PhunMart.Dime")
    end
    for _ = 1, nickels do
        inv:AddItem("PhunMart.Nickel")
    end
end)

Events.OnClientCommand.Add(function(module, command, playerObj, arguments)
    if module == Core.name then
        if Commands[command] then
            Core.debugLn("Command " .. tostring(command) .. " from " .. playerObj:getUsername())
            Commands[command](playerObj, arguments)
        else
            Core.debugLn("Unknown command " .. tostring(command) .. " from " .. playerObj:getUsername())
        end
    end
end)

Events.OnObjectAdded.Add(function(object)
    Core.ServerSystem.instance:checkObjectAdded(object)
end)

Events.OnObjectAboutToBeRemoved.Add(function(object)
    Core.ServerSystem.instance:checkObjectRemoved(object)
end)

Events.OnDestroyIsoThumpable.Add(function(object)
    Core.ServerSystem.instance:checkObjectRemoved(object)
end)
