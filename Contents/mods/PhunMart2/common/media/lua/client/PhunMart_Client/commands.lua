if isServer() then
    return
end

local Core = PhunMart
local Toast = require "PhunMart_Client/ui/toast"

local Commands = {}

-- itemId (string) → { vehicleScript, condition } — populated by spawnVehicle command
Core._vehicleKeys = Core._vehicleKeys or {}

Commands[Core.commands.updateWallet] = function(args)
    local player = Core.utils.getPlayerByUsername(args.username)
    for k, v in pairs(args.wallet) do
        Core.wallet:adjust(player, k, v)
    end
end

Commands[Core.commands.getWallet] = function(args)
    Core.wallet:setPlayerData(args.username, args.wallet)
end

Commands[Core.commands.openError] = function(args)
    -- Signal the open_shop timed action (if still waiting) to abort early.
    if args.key then
        Core.pendingShopData = Core.pendingShopData or {}
        Core.pendingShopData[args.key] = {
            error = args.message
        }
    end
    local rawMsg = args.message or "Error"
    local message = getTextOrNull("IGUI_PhunMart.Error." .. rawMsg) or rawMsg
    local w = 300
    local h = 150
    local modal = ISModalDialog:new(getCore():getScreenWidth() / 2 - w / 2, getCore():getScreenHeight() / 2 - h / 2, w,
        h, message, false, nil, nil, nil)
    modal:initialise()
    modal:addToUIManager()
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

-- Remove item-based currency from the player's inventory using the proper
-- container sync pattern so the inventory UI updates immediately.
local function removeItemPayment(player, price)
    if not price or price.kind ~= "items" then
        return
    end
    local inv = player:getInventory()
    for _, entry in ipairs(price.items or {}) do
        local remaining = entry.amount
        -- Remove primary items first, then substitutes
        local sources = {entry.item}
        if entry.substitutes then
            for _, sub in ipairs(entry.substitutes) do
                table.insert(sources, sub)
            end
        end
        for _, itemType in ipairs(sources) do
            if remaining <= 0 then
                break
            end
            for i = 1, remaining do
                local target = inv:getItemFromTypeRecurse(itemType)
                if not target then
                    break
                end
                local container = target:getContainer()
                container:Remove(target)
                sendRemoveItemFromContainer(container, target)
                remaining = remaining - 1
            end
        end
    end
    ISInventoryPage.dirtyUI()
end

Commands[Core.commands.buy] = function(arguments)
    -- Update local wallet copy so balance display stays current
    if arguments.wallet and arguments.wallet.current then
        local username = getSpecificPlayer(arguments.playerIndex or 0)
        if username then
            Core.wallet:setPlayerData(username:getUsername(), arguments.wallet)
        end
    end
    -- Remove item-based currency from inventory with proper container sync
    local player = getSpecificPlayer(arguments.playerIndex or 0)
    if player then
        removeItemPayment(player, arguments.price)
    end
    -- Fire event so the open shop window can update stock and buy button
    triggerEvent(Core.events.OnPurchaseComplete, arguments)
end

Commands[Core.commands.payWithInventory] = function(arguments)
    local player = getSpecificPlayer(arguments.playerIndex)
    for _, v in ipairs(arguments.items) do
        local item = getScriptManager():getItem(v.name)
        for i = 1, v.value do
            local inv = player:getInventory()
            local target = inv:getItemFromTypeRecurse(v.name)
            local container = target:getContainer()
            container:Remove(target)
            sendRemoveItemFromContainer(container, target)
        end
    end
    ISInventoryPage.dirtyUI()
end

Commands[Core.commands.onShopChange] = function(args)
    triggerEvent(Core.events.OnShopChange, args.key, args.data, args.replaced == true)
end

Commands[Core.commands.syncPurchases] = function(arguments)
    Core.debug("syncPurchases", arguments)

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
    -- Shop list is now built from Core.runtime.shops compiled locally.
    -- This handler is kept for compatibility but the round-trip is no longer initiated.
    local player = Core.utils.getPlayerByUsername(args.username)
    if player then
        Core.ClientSystem.instance:openShopList(player)
    end
end

Commands[Core.commands.getInstanceList] = function(args)
    local player = Core.utils.getPlayerByUsername(args.username)
    if player then
        Core.ui.shop_instances.setData(player, args.data)
        Core.ui.shop_selector.updateInstanceCounts(args.data)
    end
end

Commands[Core.commands.requestShopDefs] = function(arguments)
    Core.compileWith(arguments.overrides)
end

Commands[Core.commands.requestItemDefs] = function(arguments)

    Core.debugLn("requestItemDefs: receiving chunk " .. arguments.row .. " of " .. arguments.totalRows)

    if arguments.firstSend then
        Core.defs.items = arguments.items
    else
        for k, v in pairs(arguments.items) do
            Core.defs.items[k] = v
        end
    end

    if arguments.completed then
        triggerEvent(Core.events.OnShopItemDefsReloaded, Core.defs.items)
        Core.debugLn("requestItemDefs: received all " .. arguments.totalRows .. " defs")
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

Commands[Core.commands.requestPool] = function(args)
    local player = Core.utils.getPlayerByUsername(args.username)
    if player then
        Core.ui.client.poolViewer.open(player, args.poolKey, args.data)
    end
end

-- Server sends this after granting a VehicleKeySpawner so the client knows the vehicle script
-- without relying on transmitModData (which may not exist in B42).
Commands[Core.commands.spawnVehicle] = function(args)
    if args.itemId then
        Core._vehicleKeys[args.itemId] = {
            vehicleScript = args.vehicleScript,
            condition = args.condition
        }
    end
end

-- Right-click a VehicleKeySpawner to claim the vehicle.
Events.OnFillInventoryObjectContextMenu.Add(function(playerNum, ctx, items)
    for _, v in ipairs(items) do
        local item = type(v) == "table" and v.items and v.items[1] or v
        if item and item.getFullType and item:getFullType() == "PhunMart.VehicleKeySpawner" then
            local md = item:getModData()
            -- modData may be empty if transmitModData failed; fall back to the lookup table
            local keyData = Core._vehicleKeys[tostring(item:getID())]
            local script = (md and md.vehicleScript) or (keyData and keyData.vehicleScript)
            if script then
                local label = Core.getVehicleLabel and Core.getVehicleLabel(script) or script
                local player = getSpecificPlayer(playerNum)
                local inBuilding = player and player:getSquare() and player:getSquare():getBuilding() ~= nil
                local option = ctx:addOption("Claim: " .. label, playerNum, function(pNum)
                    sendClientCommand(Core.name, Core.commands.claimVehicle, {
                        vehicleScript = script
                    })
                end)
                if inBuilding then
                    option.notAvailable = true
                    option.toolTip = ISToolTip:new()
                    option.toolTip:initialise()
                    option.toolTip.description = "You must be outside to claim a vehicle."
                end
            end
        end
    end
end)

return Commands
