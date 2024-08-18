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
        openWindow = "openWindow",
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
        addFromSprite = "addFromSprite"

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
        OnShopItemDefsReloaded = "OnPhunMartOnShopItemDefsReloaded"
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
    shopSprites = {"location_shop_accessories_01_17", "location_shop_accessories_01_16",
                   "location_shop_accessories_01_28", "location_shop_accessories_01_29",
                   "location_shop_accessories_01_19", "location_shop_accessories_01_18",
                   "location_shop_accessories_01_31", "location_shop_accessories_01_30"}
}

-- Setup any events
for _, event in pairs(PhunMart.events) do
    if not Events[event] then
        LuaEventManager.AddEvent(event)
    end
end

function PhunMart:ini()

    self.shops = ModData.getOrCreate(self.consts.shops)

    if not self.shops then
        self.shops = {}
    end

    if isServer() then

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

function PhunMart:debug(...)
    if self.settings.debug then
        local args = {...}
        PhunTools:debug(args)
    end
end

-- Transforms an objects xyz into a key that SHOULD be unique to that machine
-- as long as the machine is not moved and there isn't more than 1 in the same spot!
function PhunMart:getKey(obj)
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
function PhunMart:queueFileForItemProcessing(file)
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
function PhunMart:queueFileForShopProcessing(file)
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
function PhunMart:queueRawItemToProcess(data, sourceFile)
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
function PhunMart:queueRawShopToProcess(data)
    table.insert(self.loaders.shops, {
        data = data,
        status = "pending"
    })
    return true
end

--- Adds a hook into the system
--- @param hook currencyLabel|preSatisfyPrice|postSatisfyPrice|purchase The name of the hook
function PhunMart:addHook(hook, func)
    if self.hooks[hook] then
        table.insert(self.hooks[hook], func)
    else
        self:debug(" Warning: Hook " .. hook .. " does not exist")
    end
end

-- returns the shop for machine or key
function PhunMart:getShop(machineOrKey)
    local key = ""
    if type(machineOrKey) == "string" then
        key = machineOrKey
    else
        key = self:getKey(machineOrKey)
    end

    return self.shops[key]

end

function PhunMart:getPlayerData(playerObj)
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

function PhunMart:xyzFromKey(key)
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

function PhunMart:getZoneInfo(location)

    if self.maps == nil then
        local mods = getActivatedMods()
        if mods:contains("PhunZones") then
            self.maps = PhunZones
        else
            self.maps = false
        end
    end

    if self.maps == false or self.maps == nil then
        return nil
    else

        return self.maps:getLocation(location.x, location.y)

    end

end

function PhunMart:getMachineByLocation(playerObj, x, y, z)

    local square = playerObj:getCell():getGridSquare(x, y, z)
    if not square then
        return
    end

    for i = 1, square:getObjects():size() do
        local machine = self:isMachine(square:getObjects():get(i - 1))
        if machine then
            return machine
        end
    end

    return nil
end

function PhunMart:isMachine(object)
    local name = object:getSprite():getName()
    for _, v in ipairs(self.shopSprites) do
        if name == v then
            return object
        end
    end
end

-- returns first (and should be only) vending machine in square or nil
function PhunMart:getMachineFromSquare(square)

    local object = nil;
    for i = 1, square:getObjects():size() do
        object = square:getObjects():get(i - 1)
        if self:isMachine(object) then
            return object
        end
    end
    return nil
end

