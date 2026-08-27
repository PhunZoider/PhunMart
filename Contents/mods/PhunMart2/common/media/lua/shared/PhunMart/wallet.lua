require "PhunMart/core"
local Core = PhunMart

-- Named once rather than repeated in load and save. A pair of literals that
-- disagreed would read from one file and write to another, which is a silent
-- way to lose everybody's balances.
local SAVE_FILE = "PhunMart_Wallet.json"

-- The key single-player stores its wallet under. In multiplayer the key is the
-- username; single-player has no stable one, because getUsername() returns the
-- character name and that changes per playthrough.
--
-- Deliberately the string "0" and not the number 0, which is what it used to
-- be. JSON object keys are strings, so a table keyed by a number cannot be
-- encoded at all: every save of the wallet file failed outright in SP.
--
-- "0" rather than something readable like "singleplayer" because that is what
-- the number turns into when an old PhunMart_Wallet.txt goes through the
-- converter. Keeping the same spelling means converted data still lines up.
local SP_KEY = "0"

--- Move any record filed under a non-string key to its string equivalent.
---
--- One numeric key anywhere in this table stops the whole file saving, so it is
--- not enough to write strings from here on: a save made before the change
--- still holds the old number, and it has to come out. Handled on the way in
--- rather than at save time, where the only options left are failing or
--- dropping somebody's balance.
local function normaliseKeys(data)
    -- Keys collected first. Assigning a new key during pairs() is undefined.
    local numeric = {}
    for key in pairs(data) do
        if type(key) ~= "string" then
            table.insert(numeric, key)
        end
    end
    for _, key in ipairs(numeric) do
        local asString = tostring(key)
        -- Only if nothing is there already. If both exist the string one was
        -- written later, so it is the live record and the number is a leftover.
        if data[asString] == nil then
            data[asString] = data[key]
        end
        data[key] = nil
    end
    return #numeric
end

--- Bind self.data to ModData, tidying old keys the first time.
local function bindData(self)
    if self.data == nil then
        self.data = ModData.getOrCreate(self.name)
    end
    if not self.keysNormalised then
        self.keysNormalised = true
        local moved = normaliseKeys(self.data)
        if moved > 0 then
            print("[PhunMart] wallet: moved " .. tostring(moved) ..
                      " record(s) off a numeric key so the file can be written")
        end
    end
    return self.data
end

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

-- Returns (or creates) the wallet record for a player.
-- Balance stored as pool totals: { current={change=0,tokens=0}, bound={tokens=0}, purchases={} }
function Core.wallet:get(player)
    bindData(self)
    local key
    if Core.isLocal then
        key = SP_KEY
    elseif type(player) == "string" then
        key = player
    else
        key = player:getUsername()
    end
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
    self.data[player] = data
end

-- Reset: zeroes unbound pools, restores bound pools to their bound amount.
function Core.wallet:reset(player)
    local name = type(player) == "string" and player or player:getUsername()

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

-- Direct pool adjustment — used by admin commands and purchase deduction.
-- walletType is "current" or "bound".
function Core.wallet:adjustByPool(player, walletType, pool, amount)
    local name = type(player) == "string" and player or player:getUsername()
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
-- If already at cap, returns false, true and the coin is NOT consumed — leave it in inventory.
function Core.wallet:adjust(player, item, amount)
    local currency = self.currencies[item]
    if not currency then
        return false, false
    end

    local name = type(player) == "string" and player or player:getUsername()
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

-- File-based persistence (server-only, mirrors purchases pattern).
-- Survives server crashes between game saves.
function Core.wallet:save()
    if Core.fileUtils then
        Core.fileUtils.saveTable(SAVE_FILE, self.data or {})
    end
end

function Core.wallet:load()
    if not Core.fileUtils then
        return
    end
    local saved = Core.fileUtils.loadTable(SAVE_FILE)
    if not saved then
        return
    end
    -- Merge file-backed data into ModData, preferring higher balances
    -- so a crash between file-save and game-save doesn't lose progress.
    -- bindData first, so a save still holding the old numeric key has been
    -- moved across before the file's "0" is merged onto it.
    bindData(self)
    for key, fileWallet in pairs(saved) do
        local mdWallet = self.data[key]
        if not mdWallet then
            self.data[key] = fileWallet
        else
            -- Take the higher of each pool balance
            for _, wType in ipairs({"current", "bound"}) do
                if fileWallet[wType] then
                    mdWallet[wType] = mdWallet[wType] or {}
                    for pool, val in pairs(fileWallet[wType]) do
                        if (val or 0) > (mdWallet[wType][pool] or 0) then
                            mdWallet[wType][pool] = val
                        end
                    end
                end
            end
        end
    end
end
