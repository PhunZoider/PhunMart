PhunMart = {
    name = "PhunMart",
    inied = false,
    consts = {
        shops = "PhunMartShops",
        players = "PhunMartPlayers",
        history = "PhunMartHistory"
    },
    commands = {
        buy = "buy",
        requestShopGenerate = "requestShopGenerate",
        requestShopDefs = "requestShopDefs",
        requestItemDefs = "requestItemDefs",
        requestShop = "requestShop",
        closedShop = "closedShop",
        shopChanged = "shopChanged",
        updateShop = "updateShop",
        restock = "restock",
        spawnVehicle = "spawnVehicle",
        payWithInventory = "payWithInventory",
        updateHistory = "updateHistory",
        rebuildExportItems = "rebuildExportItems",
        rebuildVehicles = "rebuildVehicles",
        rebuildTraits = "rebuildTraits",
        rebuildPerks = "rebuildPerks",
        modifyTraits = "modifyTraits",
        defsUpdated = "defsUpdated",
        serverPurchaseFailed = "serverPurchaseFailed",
        dump = "dump",
        itemDump = "itemDump",
        reloadItems = "reloadItems",
        reloadShops = "reloadShops",
        reloadAll = "reloadAll",
        restockAllShops = "restockAllShops",
        rerollAllShops = "rerollAllShops",
        closeAllShops = "closeAllShops",
        closeShop = "closeShop",
        requestLock = "requestLock",
        addFromSprite = "addFromSprite",
        requestLocations = "PhunMartRequestLocations"

    },
    events = {
        OnWindowOpened = "OnPhunMartWindowOpened",
        OnWindowClosed = "OnPhunMartWindowClosed",
        onInitialized = "OnPhunMartInitialized",
        OnItemQueueReadyToProcess = "OnPhunMartItemQueueReadyToProcess",
        OnItemQueueFilesReadyToProcess = "OnPhunMartItemQueueFilesReadyToProcess",
        OnItemQueueProcessed = "OnPhunMartItemQueueProcessed",
        OnShopQueueReadyToProcess = "OnPhunMartShopQueueReadyToProcess",
        OnShopQueueFilesReadyToProcess = "OnPhunMartShopQueueFilesReadyToProcess",
        OnShopQueueProcessed = "OnPhunMartShopQueueProcessed",
        OnShopDefsReloaded = "OnPhunMartShopDefsReloaded",
        OnShopItemDefsReloaded = "OnPhunMartOnShopItemDefsReloaded",
        OnShopLocationsReceived = "OnPhunMartShopLocationsReceived"
    },
    hooks = {
        currencyLabel = {},
        preSatisfyPrice = {},
        postSatisfyPrice = {},
        prePurchase = {},
        purchase = {},
        receiveItem = {},
        getLabel = {},
        getTexture = {}
    },
    settings = {
        debug = true
    },
    shops = {},
    players = {},
    history = {},
    defs = {},
    reservations = {},
    currencies = {}, -- a cache for different types of currencies and their types
    cache = {
        labels = {
            currency = {},
            traits = {},
            professions = {}
        },
        textures = {}
    },
    loaders = {
        itemFiles = {},
        items = {},
        shopFiles = {},
        shops = {}
    },
    targetSprites = {
        ["location_shop_accessories_01_29"] = "north",
        ["location_shop_accessories_01_31"] = "north",
        ["location_shop_accessories_01_17"] = "south",
        ["location_shop_accessories_01_19"] = "south",
        ["location_shop_accessories_01_16"] = "east",
        ["location_shop_accessories_01_18"] = "east",
        ["location_shop_accessories_01_30"] = "west",
        ["location_shop_accessories_01_28"] = "west",
        ["DylansRandomFurniture02_23"] = "south",
        ["DylansRandomFurniture02_22"] = "east",
        -- LC
        ["LC_Random_20"] = "south",
        ["LC_Random_23"] = "south",
        ["LC_Random_28"] = "south",
        ["LC_Random_32"] = "south",

        ["LC_Random_21"] = "east",
        ["LC_Random_22"] = "east",
        ["LC_Random_29"] = "east",
        ["LC_Random_33"] = "east",

        ["LC_Random_30"] = "north",
        ["LC_Random_34"] = "north",

        ["LC_Random_31"] = "west",
        ["LC_Random_35"] = "west"
    }
}

local Core = PhunMart

Core.settings = SandboxVars["PhunMart"]

-- Setup any events
for _, event in pairs(PhunMart.events) do
    if not Events[event] then
        LuaEventManager.AddEvent(event)
    end
end

function Core:debug(...)

    local args = {...}
    for i, v in ipairs(args) do
        if type(v) == "table" then
            self:printTable(v)
        else
            print(tostring(v))
        end
    end

end

function Core:printTable(t, indent)
    indent = indent or ""
    for key, value in pairs(t or {}) do
        if type(value) == "table" then
            print(indent .. key .. ":")
            Core:printTable(value, indent .. "  ")
        elseif type(value) ~= "function" then
            print(indent .. key .. ": " .. tostring(value))
        end
    end
end

function Core:ini()

    self.data = ModData.getOrCreate(self.name)

    if not self.data.templates then
        self.data.defs = {}
    end
    if not self.data.instances then
        self.data.instances = {}
    end
    if not self.data.players then
        self.data.players = {}
    end
    if not self.data.history then
        self.data.history = {}
    end

    self.shops = ModData.getOrCreate(self.consts.shops)

    if not self.shops then
        self.shops = {}
    end

    if not isClient() then

        self.players = ModData.getOrCreate(self.consts.players)
        self.history = ModData.getOrCreate(self.consts.history)
    else
        self.players = {}
    end

    self.settings.debug = self.settings.debug or true
    self.inied = true
    self.inied_time = getTimestamp()
    triggerEvent(self.events.onInitialized, self)
end

function Core:onlinePlayers(all)

    local onlinePlayers;

    if not isClient() and not isServer() and not isCoopHost() then
        onlinePlayers = ArrayList.new();
        local p = getPlayer()
        onlinePlayers:add(p);
    elseif all then
        onlinePlayers = getOnlinePlayers();

    else
        onlinePlayers = ArrayList.new();
        for i = 0, getOnlinePlayers():size() - 1 do
            local player = getOnlinePlayers():get(i);
            if player:isLocalPlayer() then
                onlinePlayers:add(player);
            end
        end
    end

    return onlinePlayers;
end

function Core:isTargetSprite(obj)
    local sprite = obj and obj.getSprite and obj:getSprite():getName();
    local match = self.targetSprites[sprite]
    return match ~= true, self.targetSprites[sprite], sprite
end

function Core:isPhunMartSprite(obj)
    local sprite = obj and obj.getSprite and obj:getSprite():getName();
    if sprite and string.sub(sprite, 1, 9) == "phunmart_" then
        return true, self.targetSprites[sprite]
    end
    return false, nil
end

-- Transforms an objects xyz into a key that SHOULD be unique to that machine
-- as long as the machine is not moved and there isn't more than 1 in the same spot!
function Core:getKey(obj)
    if type(obj) == "string" then
        return obj
    end
    if obj then
        if obj.getX then
            return obj:getX() .. "_" .. obj:getY() .. "_" .. obj:getZ()
        elseif obj.x then
            return obj.x .. "_" .. obj.y .. "_" .. obj.z
        end
    end
end

--- Adds a filename in the Lua folder that contains item definitions that will be loaded at startup.
--- This allows us to break up item defs into multiple files for easier management and sharing
--- It also allows mods to add definitions to the system easily
--- @param file string The name of the file living in the Lua folder (and without the .lua extension)
--- @return boolean
function Core:queueFileForItemProcessing(file)
    if string.len(file or "") < 1 or PhunTools:startsWith(file, "#") then
        return false
    end
    table.insert(self.loaders.itemFiles, {
        file = file,
        status = "pending"
    })
    return true
end

--- Adds a filename in the Lua folder that contains shop definitions that will be loaded at startup
--- This allows us to break up item defs into multiple files for easier management and sharing
--- It also allows mods to add definitions to the system easily
--- @param file string The name of the file living in the Lua folder (and without the .lua extension)
--- @return boolean
function Core:queueFileForShopProcessing(file)
    if string.len(file or "") < 1 or PhunTools:startsWith(file, "#") then
        return false
    end
    table.insert(self.loaders.shopFiles, {
        file = file,
        status = "pending"
    })
    return true
end

--- Adds an item definition to the queue for transforming and validating at startup
--- This is processed at startup
--- This allows mods to add definitions to the system easily
--- @param data table The item definition
--- @param sourceFile string The file that the item definition came from
--- @return boolean
function Core:queueRawItemToProcess(data, sourceFile)
    table.insert(self.loaders.items, {
        data = data,
        status = "pending",
        sourceFile = sourceFile
    })
    return true
end

--- Adds a shop definition to the queue for transforming and validating at startup
--- This allows mods to add definitions to the system easily
--- @param data table The source definition
--- @return boolean
function Core:queueRawShopToProcess(data)
    table.insert(self.loaders.shops, {
        data = data,
        status = "pending"
    })
    return true
end

--- Adds a hook into the system
--- @param hook currencyLabel|preSatisfyPrice|postSatisfyPrice|purchase The name of the hook
function Core:addHook(hook, func)
    if self.hooks[hook] then
        table.insert(self.hooks[hook], func)
    else
        self:debug(" Warning: Hook " .. hook .. " does not exist")
    end
end

-- returns the shop for machine or key
function Core:getShop(machineOrKey)
    local key = ""
    if type(machineOrKey) == "string" then
        key = machineOrKey
    else
        key = self:getKey(machineOrKey)
    end

    return self.shops[key]

end

function Core:getPlayerData(playerObj)
    local key = nil
    if type(playerObj) == "string" then
        key = playerObj
    else
        key = playerObj:getUsername()
    end
    if key and string.len(key) > 0 then
        if not self.players then
            self.players = {}
        end
        if not self.players[key] then
            self.players[key] = {}
        end
        if not self.players[key].purchases then
            self.players[key].purchases = {}
        end
        return self.players[key]
    end
end

function Core:xyzFromKey(key)
    if not key or string.len(key) == 0 then
        return
    end
    local result = {}
    for substring in string.gmatch(key, "[^_]+") do
        table.insert(result, substring)
    end
    return {
        x = tonumber(result[1]),
        y = tonumber(result[2]),
        z = tonumber(result[3])
    }
end

function Core:getZoneInfo(location)

    if self.maps == nil then
        self.maps = PhunZones or false
    end

    if self.maps == false or self.maps == nil or not self.maps.getLocation then
        return nil
    else

        return self.maps:getLocation(location.x, location.y)

    end

end
