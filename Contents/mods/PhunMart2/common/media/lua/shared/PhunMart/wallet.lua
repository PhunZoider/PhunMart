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
    },

    -- Item types that carry a balance in their own modData rather than a fixed
    -- value. Deliberately not in currencies above: an entry there maps a type
    -- to one flat pool amount, and these hold whatever they were built with.
    -- Adding one to currencies would make isCurrency true for it, at which
    -- point the coin path treats it as a fixed pickup and grantConfigReward
    -- credits a constant for it.
    --
    -- Change is named for the pool label the shop UI already prices everything
    -- in, and carries its own icon rather than the wallet's: most zombies spawn
    -- holding a vanilla Wallet, and two items both reading "Wallet" in one
    -- corpse, only one of which pays out, is the confusion the whole mode
    -- exists to avoid.
    walletItems = {
        -- Somebody's balance, dropped where they died. Carries their name.
        ["PhunMart.DroppedWallet"] = true,
        -- Came off a zombie, so it belongs to whoever finds it.
        ["PhunMart.Change"] = true
    }
}

--- The ceiling for a pool, in that pool's own units, or nil for no ceiling.
---
--- Zero means unlimited rather than a cap of nothing. Both options declare
--- min = 0 in sandbox-options.txt, so an admin can pick it, and read literally
--- it meant players could never hold a cent: coin pickups were refused outright
--- and left on the ground, while the wallet and Change paths credited nothing
--- and consumed the item anyway, destroying the money. "Nobody has any money"
--- is what EnableChangePool = false says properly, so a 0 here is far more
--- likely to be somebody reaching for "no limit".
---
--- nil is what every caller already tests for. The `cap and ...` guards through
--- the pickup paths were written expecting it, but until now getCap only
--- returned nil for a pool it did not recognise, so those branches never ran.
function Core.wallet:getCap(pool)
    local cap
    if pool == "change" then
        cap = Core.settings.ChangeCapCents or 9999
    elseif pool == "tokens" then
        cap = Core.settings.TokenCap or 99
    end
    if cap == 0 then
        return nil
    end
    return cap
end

function Core.wallet:isCurrency(item)
    return Core.wallet.currencies[item] ~= nil
end

--- True for the items that carry a balance in modData: a dropped wallet, or the
--- change off a zombie. Both ride the same pickup path, which reads the amount
--- off the item rather than off a lookup table.
function Core.wallet:isWalletItem(item)
    return Core.wallet.walletItems[item] == true
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

--- Builds the item a balance travels in, without placing it anywhere.
---
--- Split out of spawnDroppedItem because a zombie's payout goes into the
--- corpse's inventory rather than onto a square. Everything up to the placement
--- is the same for both.
---
--- opts.itemType picks the vessel and defaults to DroppedWallet. Pass nil for
--- ownerValue and ownerName to get the anonymous kind: no owner to check
--- OnlyPickupOwn against, and no name override, so it shows the DisplayName
--- from its item script instead of being called somebody's wallet.
function Core.wallet:makeWalletItem(entries, ownerValue, ownerName, opts)
    opts = opts or {}
    local itemType = opts.itemType or "PhunMart.DroppedWallet"
    local item = instanceItem(itemType)
    if not item then
        error("instanceItem returned nil for " .. tostring(itemType))
    end
    if ownerName then
        -- getText is client-side only; on a dedicated server it returns the raw
        -- key, which then gets transmitted to clients as the item name. Only
        -- translate in SP (where isLocal is true); in MP leave the plain string.
        local walletName = ownerName .. "'s Wallet"
        if Core.isLocal then
            pcall(function()
                walletName = getText("IGUI_PhunMart_CharsWallet", ownerName)
            end)
        end
        item:setName(walletName)
    end
    item:getModData().PhunWallet = {
        owner = ownerValue,
        wallet = entries,
        anyone = opts.anyone == true or nil
    }
    return item
end

--- What a Change item calls itself: "Change ($0.40)".
---
--- The amount is on the label because the item is looted out of a corpse, where
--- the only thing the player has to go on is the name in the list. Coins mode
--- never had this problem, a Quarter says what it is worth, and an unlabelled
--- Change item would be the one thing in the loot window whose value you can
--- only learn by taking it.
---
--- Same getText handling as the wallet name below it: client-side only, so a
--- dedicated server would transmit the raw key as the item's name. Translate in
--- singleplayer, plain string in multiplayer.
local function changeItemName(entries)
    local parts = {}
    for _, entry in ipairs(entries or {}) do
        local poolDef = Core.wallet.pools[entry.pool]
        local amount = tonumber(entry.amount) or 0
        if poolDef and amount > 0 then
            if poolDef.format == "cents" then
                table.insert(parts, Core.utils.formatCents(amount))
            else
                table.insert(parts, amount .. " " .. tostring(poolDef.label))
            end
        end
    end
    if #parts == 0 then
        return nil
    end

    local amounts = table.concat(parts, ", ")
    local name = "Change (" .. amounts .. ")"
    if Core.isLocal then
        pcall(function()
            name = getText("IGUI_PhunMart_ChangeAmount", amounts)
        end)
    end
    return name
end

--- Puts an anonymous Change item into a container, which is how a zombie's
--- payout reaches the player: they loot it off the corpse like anything else.
---
--- anyone is forced on rather than left to the caller. OnlyPickupOwn compares a
--- pickup against the item's owner field, and change off a zombie has no owner,
--- so without the flag a server running that option would let nobody take it.
---
--- AddItem paired with sendAddItemToContainer, the same as grantConfigReward:
--- on a dedicated server AddItem alone builds the item in the server's copy of
--- the container and the client never hears about it.
--- Only call from a server/SP context.
function Core.wallet:addChangeToContainer(container, entries)
    if not container or not entries or #entries == 0 then
        return
    end
    local ok, err = pcall(function()
        local item = self:makeWalletItem(entries, nil, nil, {
            itemType = "PhunMart.Change",
            anyone = true
        })
        local name = changeItemName(entries)
        if name then
            item:setName(name)
        end
        local added = container:AddItem(item)
        if added then
            sendAddItemToContainer(container, added)
        end
    end)
    if not ok then
        Core.debugLn("addChangeToContainer failed: " .. tostring(err))
    end
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
        local item = self:makeWalletItem(entries, ownerValue, username, opts)
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
