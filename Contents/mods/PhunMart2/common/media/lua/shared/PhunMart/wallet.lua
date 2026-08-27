require "PhunMart/core"
local Core = PhunMart

-- Currency items map to pools. Each coin adds its value (in cents or count) to the pool.
-- Pools are what get stored and checked against prices.
Core.wallet = {
    name = "PhunMart_Wallet",
    log = "wallet.log",

    -- Coin items: define which pool they feed and how much value each pickup adds.
    currencies = {
        ["PhunMart.Nickel"] = {
            pool = "change",
            value = 5,
            bound = false
        },
        ["PhunMart.Dime"] = {
            pool = "change",
            value = 10,
            bound = false
        },
        ["PhunMart.Quarter"] = {
            pool = "change",
            value = 25,
            bound = false
        },
        ["PhunMart.Token"] = {
            pool = "tokens",
            value = 1,
            bound = true
        }
    },

    -- Pool definitions. bound=true pools are preserved on reset.
    pools = {
        change = {
            label = "Change",
            format = "cents",
            bound = false
        },
        tokens = {
            label = "Tokens",
            format = "count",
            bound = true
        }
    }
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

--- Whatever a caller passed in, as a name string. A player object, a username,
--- or a raw key off self.data, which in singleplayer is the number 0. Shared
--- because three functions each had their own "a string, or else call
--- getUsername on it", which turns an integer key into a crash.
function Core.wallet:nameOf(player)
    if type(player) == "string" or type(player) == "number" then
        return tostring(player)
    end
    return player and player:getUsername() or nil
end

--- The key singleplayer files its one wallet under.
---
--- The string "0" and not the number 0, which is what it used to be. JSON
--- object keys are strings, so a table holding a number key cannot be encoded
--- at all. Nothing here writes JSON today, since wallets live in ModData, but
--- the legacy import reads a converted PhunMart_Wallet.json whose keys are
--- necessarily strings, and a number on this side would never match them.
---
--- "0" rather than something readable like "singleplayer" for that same
--- reason: it is what the old number turns into through the converter.
local SP_KEY = "0"

--- The key a wallet record is filed under.
---
--- Singleplayer keeps one record under SP_KEY, because there is only ever one
--- wallet and the name a call happens to pass in is not always the same string.
--- Multiplayer files by username. Every read and write has to agree on this,
--- which is the whole reason it is a function rather than four lines repeated
--- at each call site: setPlayerData had its own copy that skipped the
--- singleplayer case, so it filed under the username while get read from the
--- singleplayer key and the same character ended up with two records.
function Core.wallet:keyFor(player)
    if Core.isLocal then
        return SP_KEY
    elseif type(player) == "string" then
        return player
    elseif player then
        return player:getUsername()
    end
    return nil
end

--- Fold stray records back into the one this game actually reads.
---
--- Any save made before keyFor existed carries the duplicates described above.
--- They were invisible until the admin wallet grid started listing rows rather
--- than filling a dropdown, at which point the same character appeared twice.
---
--- Balances merge by taking the larger of each pair rather than picking a
--- winner outright. In every case seen the two records hold the same figures,
--- so the merge is a no-op; where they could differ, crediting the higher one
--- is the harmless direction to be wrong in, and silently deleting somebody's
--- balance is not.
---
--- Singleplayer only: multiplayer files by username at both ends and never had
--- the problem. Idempotent, since it leaves no stray keys behind.
---
--- A record left under the old numeric 0 is a stray like any other now that
--- SP_KEY is a string, so it folds in here without needing its own pass.
function Core.wallet:repairKeys()
    if not Core.isLocal or not self.data then
        return
    end
    -- Collected before anything is touched. Assigning self.data[SP_KEY] inside
    -- the traversal would be adding a key during pairs(), which Lua leaves
    -- undefined; clearing keys is allowed, but doing both is not worth the
    -- argument.
    local strays = {}
    for key, w in pairs(self.data) do
        if key ~= SP_KEY and type(w) == "table" then
            table.insert(strays, {
                key = key,
                wallet = w
            })
        end
    end
    if #strays == 0 then
        return
    end

    local keep = self.data[SP_KEY]
    for _, stray in ipairs(strays) do
        local w = stray.wallet
        if not keep then
            -- Nothing under SP_KEY yet, so the first record simply moves there.
            keep = w
            self.data[SP_KEY] = w
        elseif w ~= keep then
            for _, walletType in ipairs({"current", "bound"}) do
                keep[walletType] = keep[walletType] or {}
                for pool, amount in pairs(w[walletType] or {}) do
                    if (amount or 0) > (keep[walletType][pool] or 0) then
                        keep[walletType][pool] = amount
                    end
                end
            end
        end
    end
    for _, stray in ipairs(strays) do
        self.data[stray.key] = nil
    end
end

-- Returns (or creates) the wallet record for a player.
-- Balance stored as pool totals: { current={change=0,tokens=0}, bound={tokens=0}, purchases={} }
function Core.wallet:get(player)
    if self.data == nil then
        self.data = ModData.getOrCreate(self.name)
        -- Once, as the table is first pulled in, so no caller has to know the
        -- repair exists and a save that has already been through it pays only
        -- the cost of finding nothing to do.
        self:repairKeys()
    end
    local key = self:keyFor(player)
    if key ~= nil then
        if not self.data[key] then
            self.data[key] = {
                current = {
                    change = 0,
                    tokens = 0
                },
                bound = {
                    tokens = 0
                },
                purchases = {}
            }
        end
        return self.data[key]
    end
end

function Core.wallet:setPlayerData(player, data)
    self:get(player) -- ensure default record exists first
    -- keyFor, not the name as given. See the note on keyFor.
    local key = self:keyFor(player)
    if key ~= nil then
        self.data[key] = data
    end
end

-- Reset: zeroes unbound pools, restores bound pools to their bound amount.
--
-- Accepts a player, a username, or a raw key from the wallet table. That last
-- one matters because singleplayer files everything under the number 0, so a
-- caller walking self.data hands this a number.
function Core.wallet:reset(player)
    local name = self:nameOf(player)

    if isClient() and not Core.isLocal then
        sendClientCommand(Core.name, Core.commands.resetWallet, {
            username = name
        })
        return
    end

    local w = self:get(name)
    for pool, def in pairs(self.pools) do
        local cur = w.current[pool] or 0
        if cur > 0 then
            if Core.fileUtils then
                Core.fileUtils.logTo(self.log, name, pool, -cur)
            end
            w.current[pool] = 0
        end
        if def.bound then
            local boundAmt = w.bound[pool] or 0
            if boundAmt > 0 then
                w.current[pool] = boundAmt
                if Core.fileUtils then
                    Core.fileUtils.logTo(self.log, name, pool, boundAmt)
                end
            end
        end
    end
end

-- Direct pool adjustment, used by admin commands and purchase deduction.
-- walletType is "current" or "bound".
function Core.wallet:adjustByPool(player, walletType, pool, amount)
    local name = self:nameOf(player)
    local w = self:get(name)
    if w then
        w[walletType][pool] = (w[walletType][pool] or 0) + amount
        if Core.fileUtils then
            Core.fileUtils.logTo(self.log, name, pool .. "(" .. walletType .. ")", amount)
        end
    end
end

-- Adjust by coin item type (converts item → pool + value).
-- Returns: adjusted (bool), atCap (bool).
-- If already at cap, returns false, true and the coin is NOT consumed, leave it in inventory.
function Core.wallet:adjust(player, item, amount)
    local currency = self.currencies[item]
    if not currency then
        return false, false
    end

    local name = self:nameOf(player)
    local w = self:get(name)
    if not w then
        return false, false
    end

    local pool = currency.pool
    local value = currency.value * (amount or 1)
    local cap = self:getCap(pool)
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

    if Core.fileUtils then
        Core.fileUtils.logTo(self.log, name, item, toAdd)
    end

    local atCap = cap ~= nil and (w.current[pool] >= cap)
    return true, atCap
end

-- Returns the current balance for a given pool.
function Core.wallet:getBalance(player, pool)
    local w = self:get(player)
    if w then
        return w.current[pool] or 0
    end
    return 0
end

-- Spawns a DroppedWallet item containing the given pool amounts on the square.
-- entries = { {pool="change", amount=500}, ... }. Caller deducts balances first.
-- opts.anyone = true lets any player pick it up regardless of OnlyPickupOwn.
-- Only call from a server/SP context (uses world-spawn APIs).
function Core.wallet:spawnDroppedItem(player, square, entries, opts)
    if not square or not entries or #entries == 0 then
        return
    end
    opts = opts or {}

    local username
    local ownerValue
    if type(player) == "string" then
        username = player
        ownerValue = player
    else
        username = player:getUsername()
        ownerValue = Core.isLocal and player:getPlayerNum() or username
    end

    local ok, err = pcall(function()
        local item = instanceItem("PhunMart.DroppedWallet")
        if not item then
            error("instanceItem returned nil for PhunMart.DroppedWallet")
        end
        -- getText is client-side only; on a dedicated server it returns the raw
        -- key, which then gets transmitted to clients as the item name. Only
        -- translate in SP (where isLocal is true); in MP leave the plain string.
        local walletName = username .. "'s Wallet"
        if Core.isLocal then
            pcall(function()
                walletName = getText("IGUI_PhunMart_CharsWallet", username)
            end)
        end
        item:setName(walletName)
        item:getModData().PhunWallet = {
            owner = ownerValue,
            wallet = entries,
            anyone = opts.anyone == true or nil
        }
        -- Mirror ISDropWorldItemAction's spawn pattern exactly so the resulting
        -- world object is tracked like any other dropped item and the standard
        -- ISInventoryTransferAction pickup path cleans it off the square
        -- properly. Calling transmitCompleteItemToClients without first setting
        -- extendedPlacement=false was leaving a ghost on the floor in MP.
        local worldItem = square:AddWorldInventoryItem(item, 0, 0, 0, false)
        if worldItem then
            if worldItem.setWorldZRotation then
                worldItem:setWorldZRotation(0)
            end
            if worldItem:getWorldItem() then
                worldItem:getWorldItem():setIgnoreRemoveSandbox(true)
                worldItem:getWorldItem():setExtendedPlacement(false)
                worldItem:getWorldItem():transmitCompleteItemToClients()
            end
        end
    end)
    if not ok then
        Core.debugLn("spawnDroppedItem failed: " .. tostring(err))
    end
end

--- Bind to the store. ModData is the whole of it; there is nothing to read off
--- disk and nothing to write back.
---
--- There used to be a mirror in PhunMart_Wallet.txt, saved on a ten minute
--- tick, so a crash between game saves would not cost anybody their balance.
--- It cost more than it saved, in two ways.
---
--- The file lives beside the mod rather than inside the save, so it outlived
--- the world it described: wiping the map left everybody's money behind, and
--- opening a second save merged the first one's balances into it.
---
--- And the two stores were reconciled by preferring the higher of each pair,
--- which can only ever create currency. Spend a hundred, let the world save,
--- restart before the next ten minute tick, and the merge hands the hundred
--- back while the goods stay bought.
---
--- What that resilience was worth is also less than it looks: a crash already
--- rolls back the player's inventory, skills and position. A wallet more
--- durable than the item it bought is precisely what made the duplication
--- possible. The save's own granularity is the correct one.
function Core.wallet:load()
    if self.data == nil then
        self.data = ModData.getOrCreate(self.name)
        self:repairKeys()
    end
end
