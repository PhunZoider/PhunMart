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

    -- What death does to a balance, per the WalletOnDeath sandbox option. One
    -- setting rather than the DropOnDeath boolean and a second one beside it,
    -- because the two could be set to contradict each other: dropping moves the
    -- balance out of the wallet and into an item, so drop-and-keep together
    -- would put the same money in two places and a death would double it.
    -- Three exclusive states say what an admin actually gets to choose between.
    local DEATH_DROP = 1 -- a wallet on the body, scaled by ReturnRate
    local DEATH_KEEP = 2 -- straight over to the next character
    local DEATH_LOSE = 3 -- gone
    local onDeath = Core.getOption("WalletOnDeath", DEATH_DROP)

    -- Move the balance onto the body, scaled by ReturnRate. Whatever the rate
    -- holds back is left in the wallet for the reset below to wipe.
    if onDeath == DEATH_DROP then
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

    if onDeath == DEATH_KEEP then
        -- reset would zero the unbound pools, which is the one thing this mode
        -- exists to prevent. It also tops bound pools back up though, a separate
        -- mechanic that has nothing to do with the choice being made here, so
        -- run that half on its own: a spent token allowance still refills on
        -- death rather than the setting quietly carrying that off with it.
        Core.wallet:restoreBound(character)
    else
        -- DEATH_LOSE, and anything unrecognised. Zero the unbound pools and
        -- restore the bound ones, which is also what DEATH_DROP wants for the
        -- remainder the return rate held back.
        Core.wallet:reset(character)
    end
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

-- How a zombie's payout reaches the player, per the ChangeDropMode sandbox
-- option. The mode picks the vessel and nothing else: the roll that decides
-- whether there is a payout and how big it is runs first and identically for
-- all three, so ChanceToDropChange, the min/max, and the per-zone and sprinter
-- tuning that PhunZones layers onto getCoinChance apply the same either way.
-- That was the whole reason for putting the switch here rather than turning the
-- drop off and paying through the kill rewards, which know none of that.
local DROP_COINS = 1 -- loose quarters, dimes and nickels in the corpse
local DROP_CHANGE = 2 -- one Change item in the corpse, holding the lot
local DROP_AUTO = 3 -- straight into the killer's wallet, no item at all

--- Split an amount of cents into the fewest coins and put them in a container.
local function addCoins(container, totalCents)
    local rem = totalCents
    local quarters = math.floor(rem / 25);
    rem = rem - quarters * 25
    local dimes = math.floor(rem / 10);
    rem = rem - dimes * 10
    local nickels = math.floor(rem / 5)

    for _ = 1, quarters do
        container:AddItem("PhunMart.Quarter")
    end
    for _ = 1, dimes do
        container:AddItem("PhunMart.Dime")
    end
    for _ = 1, nickels do
        container:AddItem("PhunMart.Nickel")
    end
end

--- The player who landed the killing blow, or nil if nothing player-shaped did.
local function killerOf(zombie)
    local killer = zombie:getAttackedBy()
    -- instanceof("IsoPlayer") also matches IsoAnimal in current B42 builds, so
    -- reject animals explicitly before treating this as a player.
    if not killer or not instanceof(killer, "IsoPlayer") or killer:isAnimal() then
        return nil
    end
    return killer
end

--- Tell a player's client its balance moved. Singleplayer shares the one wallet
--- table with the UI, so there is nothing to send there.
local function syncWallet(player)
    if Core.isLocal then
        return
    end
    sendServerCommand(player, Core.name, Core.commands.getWallet, {
        username = player:getUsername(),
        wallet = Core.wallet:get(player)
    })
end

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
    if totalCents <= 0 then
        return
    end

    local mode = Core.getOption("ChangeDropMode", DROP_COINS)
    local inv = character:getInventory()

    if mode == DROP_AUTO then
        local killer = killerOf(character)
        if killer then
            -- Clamped here because adjustByPool does not clamp, unlike the coin
            -- and wallet-item pickup paths that the other two modes go through.
            -- Without this, choosing this mode would quietly switch
            -- ChangeCapCents off. Overflow is discarded rather than left behind
            -- as an item, since being at cap already means more money than
            -- there is anything to spend it on.
            local cap = Core.wallet:getCap("change")
            local bal = Core.wallet:getBalance(killer, "change")
            local toAdd = cap and math.min(totalCents, cap - bal) or totalCents
            if toAdd > 0 then
                Core.wallet:adjustByPool(killer, "current", "change", toAdd)
                syncWallet(killer)
            end
            return
        end
        -- Nothing player-shaped killed it, so there is nobody to credit. Fall
        -- back to an item rather than voiding the payout: a zombie burned or run
        -- over still earned what the roll gave it, and the corpse is where
        -- whoever arranged that will come looking.
        Core.wallet:addChangeToContainer(inv, {{
            pool = "change",
            amount = totalCents
        }})
        return
    end

    if mode == DROP_CHANGE then
        Core.wallet:addChangeToContainer(inv, {{
            pool = "change",
            amount = totalCents
        }})
        return
    end

    addCoins(inv, totalCents)
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
