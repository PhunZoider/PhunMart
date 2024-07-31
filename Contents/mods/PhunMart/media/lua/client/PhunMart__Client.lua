if not isClient() then
    return
end
require "PhunMart_UX"
require 'ISInventoryTransferAction'

local PhunMart = PhunMart

local cachedBindInventoryItems = nil
-- Hook the original New Inventory Transfer Method
local originalNewInventoryTransaferAction = ISInventoryTransferAction.new
function ISInventoryTransferAction:new(player, item, srcContainer, destContainer, time)

    local itemType = item:getFullType()

    if itemType == "PhunMart.VehicleKeySpawner" or itemType == "PhunMart.SafehousePaint" then
        -- prevent transfering this anywhere. Its only meant for this person!
        return {
            ignoreAction = true
        }
    end

    -- otherwise, just do the transfer by passing parms back to original method
    return originalNewInventoryTransaferAction(self, player, item, srcContainer, destContainer, time)
end

PhunMart.transactionQueue = {}

function PhunMart:setDisplayValues(item)

    local display = item.display or {}
    display.textureVal = display.textureVal or PhunMart:getTextureFromItem(display)
    display.labelVal = display.labelVal or PhunMart:getLabelFromItem(display) or item.key
    display.overlayVal = display.overlayVal or PhunMart:getOverlayFromItem(display)
    display.descriptionVal = display.descriptionVal or PhunMart:getDescriptionFromItem(display)
    item.display = display
end

function PhunMart:addTransaction(playerObj, item)
    local q = PhunMart.transactionQueue[playerObj:getUsername()]
    if not q then
        q = {}
    end
    table.insert(q, {
        playerIndex = playerObj:getPlayerNum(),
        item = item
    })
end
function PhunMart:completeTransaction(args)

    local playerObj = getSpecificPlayer(args.playerIndex)
    local name = playerObj:getUsername()

    if args.success == true then
        local playerObj = getSpecificPlayer(args.playerIndex)

        local hooks = self.hooks.purchase
        if hooks and #hooks > 0 then
            if args.item.conditions[1] and args.item.conditions[1].price then
                for key, val in pairs(args.item.conditions[1].price) do
                    for _, v in ipairs(hooks) do
                        if v then
                            -- should mutate val if handled in hook
                            v(playerObj, key, tonumber(val))
                        end
                    end

                end
            end
        end

        for _, v in ipairs(args.item.receive) do
            if v.type == "ITEM" then
                print("PROCESSING " .. tostring(v.name) .. " -- " .. tostring(v.label) .. " -- " .. tostring(v.quantity))
                if PhunWallet and PhunWallet.currencies[v.label] then
                    PhunWallet.queue:add(playerObj, v.label, v.quantity)
                else
                    playerObj:getInventory():AddItem(v.name, v.quantity)
                end

            elseif v.type == "PERK" then
                local perk = PerkFactory.getPerkFromName(v.name or v.label)
                local qty = v.quantity or 1
                playerObj:getXp():AddXP(perk, qty, true, false, false)
            elseif v.type == "BOOST" then
                local perk = PerkFactory.getPerkFromName(v.name or v.label)
                local existing = playerObj:getXp():getPerkBoost(perk) or 0
                playerObj:getXp():setPerkBoost(perk, v.quantity + existing);
            elseif v.type == "TRAIT" then
                local trait = TraitFactory.getTrait(v.name or v.label)
                if v.tag == "REMOVE" then
                    playerObj:getTraits():remove(trait:getType())
                else
                    playerObj:getTraits():add(trait:getType())
                end
            elseif v.type == "VEHICLE" then
                local item = InventoryItemFactory.CreateItem("PhunMart.VehicleKeySpawner")
                local VehicleScript = getScriptManager():getVehicle(v.name or v.label)
                local named = getText("IGUI_VehicleName" .. VehicleScript:getName())
                item:setName(getText("IGUI_PhunMart.CallForX", named))
                item:getModData().PhunMart = {
                    text = named,
                    name = v.name or v.label
                }
                playerObj:getInventory():AddItem(item)
            else

                local hooks = self.hooks.receiveItem
                for _, hook in ipairs(hooks) do
                    if hook then
                        hook(playerObj, v)
                    end
                end
            end
        end
    end
    PhunMartUpdateShop(args.key, args.shop)
end

function PhunMart:processTransactionQueue(playerObj)
    local queue = PhunMart.transactionQueue[playerObj:getUsername()]
    if queue and #queue > 0 then
        if playerObj:hasTimedActions() then
            return
        end
        local item = queue[1]
        sendClientCommand(playerObj, PhunMart.name, PhunMart.commands.buy, item)
    end
end

function PhunMart:getHistoricItem(playerObj, item)
    local pd = self:getPlayerData(playerObj)
    local history = pd.purchases or {}
    local historyKey = item.key or item.name
    return history[historyKey] or {}
end

-- Helper for condition check
function PhunMart:getPlayerSkills(playerObj)
    local result = {}
    for i = 0, Perks.getMaxIndex() - 1 do
        local perk = PerkFactory.getPerk(Perks.fromIndex(i))
        if perk and perk:getParent() ~= Perks.None then
            result[perk:getName()] = playerObj:getPerkLevel(Perks.fromIndex(i))
        end
    end
    return result
end

--- Main logic for checking player meets all conditions to buy an item
--- @param playerObj IsoPlayer The player object
--- @param item The item we are checking against
--- @return table
function PhunMart:canBuy(playerObj, item)

    --- @class summaryConditionResult
    --- @field passed boolean
    --- @field conditions table<satisfiedConditionResult>
    local summary = {
        passed = true,
        conditions = {}
    }

    for _, condition in ipairs(item.conditions) do

        --- @type table<satisfiedConditionResult>
        local result = {}
        for k, v in pairs(condition) do
            --- @type boolean
            local test = self.conditions[k](self, playerObj, item, v, result)
            summary.passed = summary.passed and test
        end
        table.insert(summary.conditions, result)
        if summary.passed then
            return summary
        end
    end

    if item.inventory ~= false and item.inventory < 1 then
        summary.passed = false
        table.insert(summary.conditions, {
            type = "inventory",
            passed = false,
            key = "inventory",
            value = item.inventory,
            message = "IGUI_PhunMart.Error.OOS"
        })
    end

    return summary
end

function PhunMart:purchase(playerObj, shopKey, item)
    local canBuy = self:canBuy(playerObj, item)
    if canBuy.passed == true then
        -- adjust shit
        -- assert condition 1 is the one Condition that passeed
        -- iterate through each condition and adjust any prices
        for _, v in ipairs(canBuy.conditions[1]) do

            if v.type == "price" then

                local key = v.key
                local val = tonumber(v.value)

                local hooks = self.hooks.prePurchase
                for _, v in ipairs(hooks) do
                    if v then
                        -- should mutate val if handled in hook
                        v(playerObj, key, val)
                    end
                end

                if self.currencies[key] then
                    if self.currencies[key].type == "trait" then
                        -- spending a trait
                        playerObj:getTraits():remove(key)
                    elseif self.currencies[key].type == "item" and val > 0 then
                        -- spending an item
                        local item = getScriptManager():getItem(key)
                        if item then
                            local remaining = val
                            -- asserting we have enough to consume or canBuy wouldn't have passed?
                            for i = 1, remaining do
                                local invItem = playerObj:getInventory():getItemFromTypeRecurse(key)
                                if invItem then
                                    invItem:getContainer():DoRemoveItem(invItem)
                                    val = val - 1
                                end
                            end

                        end
                    end
                end
            end
        end
        sendClientCommand(playerObj, self.name, self.commands.buy, {
            shopKey = shopKey,
            item = item
        })
    end
end

function PhunMart:restock(vendingMachine)
    local args = {
        location = {
            x = vendingMachine:getX(),
            y = vendingMachine:getY(),
            z = vendingMachine:getZ()
        }
    }
    sendClientCommand(getPlayer(), PhunMart.name, PhunMart.commands.requestRestock, args)
end

local function setup()
    Events.EveryOneMinute.Remove(setup)
    ModData.request(PhunMart.consts.shoplist)
    if FAVendingMachine and FAVendingMachine.doBuildMenu then
        FAVendingMachine.doBuildMenu = function(player, menu, square, VendingMachine)
        end
        FAVendingMachine.onUseVendingMachine = function(junk, player, VendingMachine, tempSetting)
        end
    end
end
Events.EveryOneMinute.Add(setup)

local Commands = {}

Commands[PhunMart.commands.serverPurchaseFailed] = function(arguments)
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

Commands[PhunMart.commands.updateHistory] = function(arguments)
    local player = getSpecificPlayer(arguments.playerIndex)
    PhunMart.players[player:getUsername()] = arguments.history
end

Commands[PhunMart.commands.buy] = function(arguments)
    PhunMart:completeTransaction(arguments)
end

Commands[PhunMart.commands.payWithInventory] = function(arguments)
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

Commands[PhunMart.commands.closeAllShops] = function()
    PhunMartCloseAll()
end

Commands[PhunMart.commands.openWindow] = function(arguments)
    local vendingMachine = PhunMart:getMachineByLocation(getPlayer(), arguments.x, arguments.y, arguments.z)
    if vendingMachine then
        PhunMart:show(vendingMachine)
    end
end

Commands[PhunMart.commands.requestShop] = function(arguments)
    PhunMart.shops[arguments.key] = arguments.shop
    PhunMartUpdateShop(arguments.key, arguments.shop)
end

Commands[PhunMart.commands.modifyTraits] = function(arguments)
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

Commands[PhunMart.commands.requestShopDefs] = function(arguments)
    PhunMart.defs.shops = arguments.shops
    triggerEvent(PhunMart.events.OnShopDefsReloaded, arguments.shops)
end

Commands[PhunMart.commands.requestItemDefs] = function(arguments)

    print("Receiving ", arguments.row, " of ", arguments.totalRows)

    if arguments.firstSend then
        PhunMart.defs.items = arguments.items
    else
        for k, v in pairs(arguments.items) do
            PhunMart.defs.items[k] = v
        end
    end

    if arguments.completed then
        triggerEvent(PhunMart.events.OnShopItemDefsReloaded, PhunMart.defs.items)
        print("Received all item defs")
    end
end

-- Request each local players purchase history
-- TODO: verify this works with shared screen players
local function requestHistory()
    for i = 0, getOnlinePlayers():size() - 1 do
        local p = getOnlinePlayers():get(i)
        if p:isLocalPlayer() then
            sendClientCommand(p, PhunMart.name, PhunMart.commands.updateHistory, {})
        end
    end
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

-- Listen for commands from the server
Events.OnServerCommand.Add(function(module, command, arguments)
    if module == PhunMart.name and Commands[command] then
        Commands[command](arguments)
    end
end)

-- received moddata table
Events.OnReceiveGlobalModData.Add(function(tableName, tableData)
    if tableName == PhunMart.consts.shoplist then
        PhunMart.shoplist = tableData
    end

end)

-- Client fixes for other mods
if FA and FA.updateVendingMachine then
    -- Functional Appliances
    -- overwrite their handing of vending machines
    local oldFn = FA.updateVendingMachine
    FA.updateVendingMachine = function(vendingMaching, fill)
        return vendingMaching
    end

end

