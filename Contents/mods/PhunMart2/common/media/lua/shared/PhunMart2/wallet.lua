require "PhunMart2/core"
local Core = PhunMart

-- Currency items map to pools. Each coin adds its value (in cents or count) to the pool.
-- Pools are what get stored and checked against prices.
Core.wallet = {
    name = "PhunMart_Wallet",
    log  = "wallet.log",

    -- Coin items: define which pool they feed and how much value each pickup adds.
    currencies = {
        ["PhunMart.Nickel"]  = { pool = "change", value = 5,  bound = false },
        ["PhunMart.Dime"]    = { pool = "change", value = 10, bound = false },
        ["PhunMart.Quarter"] = { pool = "change", value = 25, bound = false },
        ["PhunMart.Token"]   = { pool = "tokens", value = 1,  bound = true  },
    },

    -- Pool definitions. bound=true pools are preserved on reset.
    pools = {
        change = { label = "Change", format = "cents", bound = false },
        tokens = { label = "Tokens", format = "count", bound = true  },
    },
}

-- Returns the cap for a given pool, read from sandbox settings.
function Core.wallet:getCap(pool)
    if pool == "change" then
        return Core.settings.ChangeCapCents or 9999
    elseif pool == "tokens" then
        return Core.settings.TokenCap or 99
    end
    return nil
end

function Core.wallet:isCurrency(item)
    return Core.wallet.currencies[item] ~= nil
end

function Core.wallet:isBound(item)
    return (Core.wallet.currencies[item] or {}).bound == true
end

-- Returns (or creates) the wallet record for a player.
-- Balance stored as pool totals: { current={change=0,tokens=0}, bound={tokens=0}, purchases={} }
function Core.wallet:get(player)
    if self.data == nil then
        self.data = ModData.getOrCreate(self.name)
    end
    local key
    if Core.isLocal then
        key = 0
    elseif type(player) == "string" then
        key = player
    else
        key = player:getUsername()
    end
    if key ~= nil then
        if not self.data[key] then
            self.data[key] = {
                current   = { change = 0, tokens = 0 },
                bound     = { tokens = 0 },
                purchases = {}
            }
        end
        return self.data[key]
    end
end

function Core.wallet:setPlayerData(player, data)
    self:get(player) -- ensure default record exists first
    self.data[player] = data
end

-- Reset: zeroes unbound pools, restores bound pools to their bound amount.
function Core.wallet:reset(player)
    local name = type(player) == "string" and player or player:getUsername()

    if isClient() then
        sendClientCommand(Core.name, Core.commands.resetWallet, { username = name })
    end

    local w = self:get(name)
    for pool, def in pairs(self.pools) do
        local cur = w.current[pool] or 0
        if cur > 0 then
            Core.tools.logTo(self.log, name, pool, -cur)
            w.current[pool] = 0
        end
        if def.bound then
            local boundAmt = w.bound[pool] or 0
            if boundAmt > 0 then
                w.current[pool] = boundAmt
                Core.tools.logTo(self.log, name, pool, boundAmt)
            end
        end
    end
end

-- Direct pool adjustment — used by admin commands and purchase deduction.
-- walletType is "current" or "bound".
function Core.wallet:adjustByPool(player, walletType, pool, amount)
    local name = type(player) == "string" and player or player:getUsername()
    local w = self:get(name)
    if w then
        w[walletType][pool] = (w[walletType][pool] or 0) + amount
        Core.tools.logTo(self.log, name, pool .. "(" .. walletType .. ")", amount)
    end
end

-- Adjust by coin item type (converts item → pool + value).
-- Returns: adjusted (bool), atCap (bool).
-- If already at cap, returns false, true and the coin is NOT consumed — leave it in inventory.
function Core.wallet:adjust(player, item, amount)
    local currency = self.currencies[item]
    if not currency then return false, false end

    local name = type(player) == "string" and player or player:getUsername()
    local w = self:get(name)
    if not w then return false, false end

    local pool    = currency.pool
    local value   = currency.value * (amount or 1)
    local cap     = self:getCap(pool)
    local current = w.current[pool] or 0

    if cap and current >= cap then
        return false, true
    end

    local toAdd = value
    if cap then
        toAdd = math.min(value, cap - current)
    end

    w.current[pool] = current + toAdd

    if currency.bound then
        w.bound[pool] = (w.bound[pool] or 0) + toAdd
    end

    if isClient() then
        if not self.queue then
            self.queue = require "PhunMart2/itemqueue"
            self.queue.module = Core.name
            self.queue.sendCommand = Core.commands.addToWallet
        end
        self.queue:add(player, item, amount or 1)
    end

    Core.tools.logTo(self.log, name, item, toAdd)

    local atCap = cap ~= nil and (w.current[pool] >= cap)
    return true, atCap
end

-- Returns the current balance for a given pool.
function Core.wallet:getBalance(player, pool)
    local w = self:get(player)
    if w then return w.current[pool] or 0 end
    return 0
end
