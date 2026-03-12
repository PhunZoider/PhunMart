if isServer() then
    return
end

local Core = PhunMart
local Toast = require "PhunMart2/ui/toast"

local Commands = {}

Commands[Core.commands.updateWallet] = function(args)
    local player = Core.tools.getPlayerByUsername(args.username)
    for k, v in pairs(args.wallet) do
        Core.wallet:adjust(player, k, v)
    end
end

Commands[Core.commands.getWallet] = function(args)
    Core.wallet:setPlayerData(args.username, args.wallet)
end

Commands[Core.commands.openError] = function(args)
    local player = getSpecificPlayer(args.playerIndex)
    local w = 300
    local h = 150
    local message = getTextOrNull("IGUI_PhunMart.Error." .. args.message) or args.message
    local modal = ISModalDialog:new(getCore():getScreenWidth() / 2 - w / 2, getCore():getScreenHeight() / 2 - h / 2, w,
        h, message, false, nil, nil, nil);
    modal:initialise()
    modal:addToUIManager()
end

Commands[Core.commands.getBlackList] = function(args)
    local player = Core.tools.getPlayerByUsername(args.username)
    if player then
        Core.ui.pools_blacklist_main.OnOpenPanel(player, args.data)
    end
end

Commands[Core.commands.serverPurchaseFailed] = function(arguments)
    local player = getSpecificPlayer(arguments.playerIndex)
    local name = player:getUsername()
    local w = 300
    local h = 150
    local message = getTextOrNull("IGUI_PhunMart.Error." .. arguments.message) or arguments.message
    local modal = ISModalDialog:new(getCore():getScreenWidth() / 2 - w / 2, getCore():getScreenHeight() / 2 - h / 2, w,
        h, message, false, nil, nil, nil);
    modal:initialise()
    modal:addToUIManager()

end

Commands[Core.commands.updateHistory] = function(arguments)
    local player = getSpecificPlayer(arguments.playerIndex)
    Core.players[player:getUsername()] = arguments.history
end

Commands[Core.commands.buy] = function(arguments)
    -- Update local wallet copy so balance display stays current
    if arguments.wallet and arguments.wallet.current then
        local username = getSpecificPlayer(arguments.playerIndex or 0)
        if username then
            Core.wallet:setPlayerData(username:getUsername(), arguments.wallet)
        end
    end
    -- Fire event so the open shop window can update stock and buy button
    triggerEvent(Core.events.OnPurchaseComplete, arguments)
end

-- Scans CharacterTraitDefinition.getTraits() to find the def whose type string
-- matches our key (e.g. "base:irongut"). getCharacterTraitDefinition() does NOT
-- accept a plain Lua string — it needs the Java CharacterTrait type object.
local function findTraitDef(traitKey)
    local all = CharacterTraitDefinition.getTraits()
    for i = 0, all:size() - 1 do
        local t = all:get(i)
        if t and tostring(t:getType()) == traitKey then
            return t
        end
    end
    return nil
end

local function applyTrait(player, traitKey, add)
    local def = findTraitDef(traitKey)
    if not def then
        print("[PhunMart2] applyTrait: no definition found for '" .. tostring(traitKey) .. "'")
        return
    end
    local traitType = def:getType()
    if add then
        player:getCharacterTraits():add(traitType)
        player:modifyTraitXPBoost(traitType, false)
    else
        player:getCharacterTraits():remove(traitType)
        player:modifyTraitXPBoost(traitType, true)
    end
    SyncXp(player)
end

-- Trait rewards are applied client-side because CharacterTraitDefinition is
-- only available on the client. Server sends this after deducting payment.
Commands[Core.commands.applyTraitReward] = function(arguments)
    local player = getSpecificPlayer(arguments.playerIndex or 0)
    if not player then
        return
    end
    local ok, err = pcall(applyTrait, player, arguments.trait, arguments.add)
    if not ok then
        print("[PhunMart2] applyTraitReward error: " .. tostring(err))
    end
end

-- SP path: server fires event directly since client and server share Lua state
Events[Core.events.OnApplyTraitReward].Add(function(args)
    if not args or not args.player then
        return
    end
    local ok, err = pcall(applyTrait, args.player, args.trait, args.add)
    if not ok then
        print("[PhunMart2] OnApplyTraitReward error: " .. tostring(err))
    end
end)

Commands[Core.commands.payWithInventory] = function(arguments)
    local player = getSpecificPlayer(arguments.playerIndex)
    for _, v in ipairs(arguments.items) do
        local item = getScriptManager():getItem(v.name)
        for i = 1, v.value do
            local inv = player:getInventory()
            local target = inv:getItemFromTypeRecurse(v.name)
            target:getContainer():DoRemoveItem(target)
        end
    end
end

Commands[Core.commands.onShopChange] = function(args)
    triggerEvent(Core.events.OnShopChange, args.key, args.data, args.replaced == true)
end

Commands[Core.commands.syncPurchases] = function(arguments)
    print("-------------------- SYNC PURCHASES")
    Core.debug(arguments)

    Core.purchases.histories = Core.purchases.histories or {}
    Core.purchases.histories[arguments.username] = arguments.history
end

Commands[Core.commands.requestShop] = function(arguments)
    -- Store data for the open_shop timed action to pick up.
    -- The action polls Core.pendingShopData[key] in its update() loop and
    -- opens the UI once both the animation has finished and this data exists.
    Core.pendingShopData = Core.pendingShopData or {}
    Core.pendingShopData[arguments.key] = arguments.data
end

Commands[Core.commands.getShopList] = function(args)
    local player = Core.tools.getPlayerByUsername(args.username)
    if player then
        Core.ClientSystem.instance:openShopList(player, args.data)
    end
end

Commands[Core.commands.getShopDefinition] = function(args)
    local player = Core.tools.getPlayerByUsername(args.username)
    if player then
        Core.ClientSystem.instance:openShopConfig(player, args.data)
    end

end

Commands[Core.commands.requestShopDefs] = function(arguments)
    Core.defs.shops = arguments.shops
    triggerEvent(Core.events.OnShopDefsReloaded, arguments.shops)
end

Commands[Core.commands.requestItemDefs] = function(arguments)

    print("Receiving ", arguments.row, " of ", arguments.totalRows)

    if arguments.firstSend then
        Core.defs.items = arguments.items
    else
        for k, v in pairs(arguments.items) do
            Core.defs.items[k] = v
        end
    end

    if arguments.completed then
        triggerEvent(Core.events.OnShopItemDefsReloaded, Core.defs.items)
        print("Received all item defs")
    end
end

Commands[Core.commands.requestLocations] = function(args)
    triggerEvent(Core.events.OnShopLocationsReceived, args.locations)
end

-- ---------------------------------------------------------------------------
-- Token reward grant (playtime / kill milestone)
-- ---------------------------------------------------------------------------

-- Shared handler for both MP (server command) and SP (triggered event) paths.
local function handleGrant(args)
    -- Sync the local wallet copy so balance displays stay current.
    if args.wallet and args.username then
        Core.wallet:setPlayerData(args.username, args.wallet)
    end
    -- Show toast notification.
    Toast.show({
        text = args.message or "Reward!"
    })
end

-- MP path: server sends this command after crediting the reward.
Commands[Core.commands.grantReward] = function(args)
    handleGrant(args)
end

-- SP path: server fires the event directly (same Lua state, no network hop).
Events[Core.events.OnRewardGranted].Add(function(args)
    if not args then
        return
    end
    handleGrant(args)
end)

return Commands
