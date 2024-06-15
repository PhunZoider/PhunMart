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

    if itemType == "PhunMart.VehicleKeySpawner" then
        -- prevent transfering this anywhere. Its only meant to spawn a car!
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
        for _, v in ipairs(args.item.receive) do
            if v.type == "ITEM" then
                -- is item a currency?
                if PhunWallet and PhunWallet.currencies and PhunWallet.currencies[v.name] then
                    PhunWallet.queue:add(playerObj, v.name, v.quantity)
                else
                    playerObj:getInventory():AddItem(v.name, v.quantity)
                end
            elseif args.item.type == "PERK" then
                local perk = PerkFactory.getPerkFromName(v.name)
                local qty = v.quantity or 1
                playerObj:getXp():AddXP(perk, qty, true, false, false)
            elseif args.item.type == "BOOST" then
                local perk = PerkFactory.getPerkFromName(v.name)
                playerObj:getXp():setPerkBoost(perk, v.quantity);
            elseif args.item.type == "TRAIT" then
                local trait = TraitFactory.getTrait(v.name)
                if v.tag == "REMOVE" then
                    playerObj:getTraits():remove(trait:getType())
                else
                    playerObj:getTraits():add(trait:getType())
                end
            elseif v.type == "VEHICLE" then
                local item = InventoryItemFactory.CreateItem("PhunMart.VehicleKeySpawner")
                local VehicleScript = getScriptManager():getVehicle(args.item.name)
                local named = getText("IGUI_VehicleName" .. VehicleScript:getName())
                item:setName(getText("IGUI_PhunMart.CallForX", named))
                item:getModData().PhunMart = {
                    text = named,
                    name = v.name
                }
                playerObj:getInventory():AddItem(item)
            elseif v.type == "PORT" then
                local dest = nil
                if type(v.value) == "table" then

                    if #v.value > 1 then
                        local i = ZombRand(#v.value) + 1
                        dest = v.value[i]
                    elseif #v.value == 1 then
                        dest = v.value[1]
                    end
                end
                if dest then
                    playerObj:setX(dest.x + 0.5)
                    playerObj:setY(dest.y + 0.5)
                    playerObj:setZ(dest.z + 0.5)
                    playerObj:setLx(dest.x + 0.5);
                    playerObj:setLy(dest.y + 0.5);
                    playerObj:setLz(dest.z + 0.5);
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

                if self.currencies[key] then
                    if self.currencies[key].type == "trait" then
                        -- spending a trait
                        playerObj:getTraits():remove(key)
                    elseif self.currencies[key].type == "PhunWallet" then
                        PhunWallet.queue:add(playerObj, key, (tonumber(val) * -1))
                    elseif self.currencies[key].type == "item" then
                        -- spending an item
                        local item = getScriptManager():getItem(key)
                        if item then
                            local remaining = val
                            -- asserting we have enough to consume or canBuy wouldn't have passed?
                            for i = 1, val do
                                local invItem = playerObj:getInventory():getItemFromTypeRecurse(key)
                                invItem:getContainer():DoRemoveItem(invItem)
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

Commands[PhunMart.commands.openWindow] = function(arguments)
    local vendingMachine = PhunMart:getMachineByLocation(getPlayer(), arguments.x, arguments.y, arguments.z)
    if vendingMachine then
        PhunMart:show(vendingMachine)
    end
end

Commands[PhunMart.commands.requestShop] = function(arguments)
    PhunMart.shops[arguments.key] = arguments.shop
    PhunMartUpdateShop(arguments.key, arguments.shop, arguments.wallet)
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

-- Request each local players purchase history
-- TODO: verify this works with shared screen players
local function requestHistory()
    for i = 0, getOnlinePlayers():size() - 1 do
        local p = getOnlinePlayers():get(i)
        sendClientCommand(p, PhunMart.name, PhunMart.commands.updateHistory, {})
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
