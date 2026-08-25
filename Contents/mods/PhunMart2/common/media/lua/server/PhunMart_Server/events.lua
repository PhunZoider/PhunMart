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

    -- instanceof("IsoPlayer") also matches IsoAnimal in current B42 builds, so reject animals
    -- explicitly. isAnimal() is public on IsoGameCharacter and is not overridden by IsoAnimal.
    if character:isAnimal() then
        return
    end

    Core.playtimeRewards:getPlayerData(character).previousHours = character:getHoursSurvived()

    -- Drop wallet item if enabled
    if Core.settings.DropOnDeath then
        local walletData = Core.wallet:get(character)
        local current = walletData and walletData.current or {}
        -- ReturnRate, which is what sandbox-options.txt actually declares.
        -- This read WalletReturnRate, which is the translation key rather than
        -- the option name, so it was always nil and always fell through to 100.
        -- Anybody who set the option to keep some of a dead player's money back
        -- has been handing all of it over since the option shipped.
        local rate = Core.settings.ReturnRate
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
            Core.wallet:spawnDroppedItem(character, character:getSquare(), toAdd)
        end
    end

    -- Reset wallet (zero unbound, restore bound)
    Core.wallet:reset(character)
end)

-- The wallet used to be flushed to disk here as well. It lives only in ModData
-- now, which the game persists on its own schedule, so there is nothing to
-- flush and this tick is the playtime check alone.
Events.EveryTenMinutes.Add(function()
    Core.playtimeRewards:tick()
end)

-- How close a player has to be for a machine to hold off rerolling. Far enough
-- that a machine never changes identity in view of the person about to use it,
-- or worse, while they have its shop window open. It only defers: the reroll
-- happens on the next tick after they leave.
local REROLL_KEEP_AWAY = 30

--- True when anyone is standing near enough to see this machine change.
local function playerIsNear(obj)
    local players = Core.utils.onlinePlayers()
    if not players then
        -- No way to tell, so assume someone is watching. Deferring a reroll
        -- costs a minute; doing one in front of a player cannot be undone.
        return true
    end
    local objZ = math.floor(tonumber(obj.z) or 0)
    for i = 0, players:size() - 1 do
        local p = players:get(i)
        if p then
            -- Floored, because a player's Z is a float mid-stair while the
            -- machine's is the integer level it was stored on.
            if math.floor(p:getZ()) == objZ then
                local dx, dy = p:getX() - obj.x, p:getY() - obj.y
                if (dx * dx + dy * dy) <= REROLL_KEEP_AWAY * REROLL_KEEP_AWAY then
                    return true
                end
            end
        end
    end
    return false
end

-- Check power state every minute so sprite swaps within ~1 minute of electricity changing.
-- updateSprite() compares hasPower against self.powered and no-ops when unchanged,
-- so this loop is near-zero cost during steady state.
--
-- Rerolling rides along here rather than on shop open, which is where restocking
-- happens. Restocking on open is invisible; changing the whole shop on open
-- means clicking a hardware store and being handed a pharmacy. Doing it on a
-- tick instead lets a machine change while nobody is watching, which is the
-- only way it reads as the world moving on rather than as a bug.
-- requiresReroll() is a comparison against a stored hour and returns false
-- immediately while the feature is off, so the added cost is nil by default.
Events.EveryOneMinute.Add(function()
    local sys = Core.ServerSystem and Core.ServerSystem.instance
    if not sys then
        return
    end
    for i = 1, sys:getLuaObjectCount() do
        local obj = sys:getLuaObjectByIndex(i)
        if obj then
            if obj.requiresReroll and obj:requiresReroll() and not playerIsNear(obj) then
                obj:reroll()
            end
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
