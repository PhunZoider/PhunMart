PhunMart = {
    name = "PhunMart",
    inied = false,
    consts = {
        shops = "PhunMart_Shops",
        shopsLuaFile = "PhunMart_Shops.json",
        players = "PhunMart_Players",
        history = "PhunMart_History",
        east = 0,
        south = 1,
        west = 2,
        north = 3,
        unpoweredEast = 4,
        unpoweredSouth = 5,
        unpoweredWest = 6,
        unpoweredNorth = 7,
        itemType = {
            items = "ITEMS",
            vehicles = "VEHICLES",
            traits = "TRAITS",
            xp = "XP",
            boosts = "BOOSTS"
        }
    },
    commands = {
        -- Shop admin
        setBlacklist = "PhunMartSetBlacklist",
        compile = "PhunMartCompileShops",
        reroll = "PhunMartReroll",
        rerollAllShops = "PhunMartRerollAllShops",
        restockAllShops = "PhunMartRestockAllShops",
        restockShopTypes = "PhunMartRestockShopTypes",
        changeTo = "PhunMartChangeShopType",
        restock = "PhunMartRestockShop",
        closeShop = "PhunMartCloseShop",
        closeAllShops = "PhunMartCloseAllShops",
        updateShop = "PhunMartUpdateShop",
        requestShopGenerate = "PhunMartRequestShopGenerate",
        upsertShopDefinition = "PhunMartUpsertShopDefinition",
        upsertGroupDef = "PhunMartUpsertGroupDef",
        upsertItemDef = "PhunMartUpsertItemDef",
        upsertPriceDef = "PhunMartUpsertPriceDef",
        upsertSpecialDef = "PhunMartUpsertSpecialDef",
        upsertPoolDef = "PhunMartUpsertPoolDef",
        upsertConditionDef = "PhunMartUpsertConditionDef",
        deleteDefinition = "PhunMartDeleteDefinition",
        revertDefinition = "PhunMartRevertDefinition",
        getShopList = "PhunMartGetShopList",
        getInstanceList = "PhunMartGetInstanceList",
        getShopData = "PhunMartGetShopData",
        requestShopDefs = "PhunMartRequestShopDefs",
        requestLocations = "PhunMartRequestLocations",
        requestItemDefs = "PhunMartRequestItemDefs",
        requestPool = "PhunMartRequestPool",
        requestGroup = "PhunMartRequestGroup",
        quickBlacklist = "PhunMartQuickBlacklist",
        blacklistInPool = "PhunMartBlacklistInPool",
        getGlobalBlacklist = "PhunMartGetGlobalBlacklist",
        setGlobalBlacklistEntry = "PhunMartSetGlobalBlacklistEntry",
        updateOfferWeight = "PhunMartUpdateOfferWeight",
        moveOffers = "PhunMartMoveOffers",
        -- Shop player flow
        playerSetup = "PhunMartPlayerSetup",
        openShop = "PhunMartOpenShop",
        requestShop = "PhunMartRequestShop",
        requestLock = "PhunMartRequestLock",
        onShopChange = "PhunMartOnShopChange",
        openError = "PhunMartOpenError",
        -- Purchase
        buy = "PhunMartBuy",
        applyTraitReward = "PhunMartApplyTraitReward",
        serverPurchaseFailed = "PhunMartServerPurchaseFailed",
        payWithInventory = "PhunMartPayWithInventory",
        modifyTraits = "PhunMartModifyTraits",
        spawnVehicle = "PhunMartSpawnVehicle",
        spawnAnimal = "PhunMartSpawnAnimal",
        -- History / misc
        updateHistory = "PhunMartUpdateHistory",
        syncPurchases = "PhunMartSyncPurchases",
        unlockShop = "PhunMartUnlockShop",
        -- Token rewards
        reportKills = "PhunMartReportKills",
        grantReward = "PhunMartGrantReward",
        -- Wallet
        addToWallet = "PhunMartAddToWallet",
        getWallet = "PhunMartGetWallet",
        resetWallet = "PhunMartResetWallet",
        updateWallet = "PhunMartUpdateWallet",
        consumeCoin = "PhunMartConsumeCoin",
        consumeDroppedWallet = "PhunMartConsumeDroppedWallet",
        dropWallet = "PhunMartDropWallet",
        -- Admin wallet. One reply carries every player's balances; the editor
        -- used to ask for the names and then for one wallet at a time, which is
        -- why getPlayerList and getPlayersWallet are no longer here.
        getAllWallets = "PhunMartGetAllWallets",
        -- Clearing wallets, purchase history and reward tracking
        getPlayerDataStatus = "PhunMartGetPlayerDataStatus",
        resetPlayerData = "PhunMartResetPlayerData",
        adjustPlayerWallet = "PhunMartAdjustPlayerWallet",
        claimVehicle = "PhunMartClaimVehicle",
        claimAnimal = "PhunMartClaimAnimal",
        -- Token rewards admin
        getTokenRewards = "PhunMartGetTokenRewards",
        saveTokenRewards = "PhunMartSaveTokenRewards",
        relocateShop = "PhunMartRelocateShop"
    },
    events = {
        OnReady = "OnPhunMartOnReady",
        receivedInventory = "OnPhunMartReceivedInventory",
        OnShopChange = "OnPhunMartShopChange",
        OnPurchaseComplete = "OnPhunMartPurchaseComplete",
        OnApplyTraitReward = "OnPhunMartApplyTraitReward",
        OnRewardGranted = "OnPhunMartRewardGranted",
        OnDefsUpdated = "OnPhunMartDefsUpdated",
        -- Both of these were being triggered without ever being declared, so
        -- every item-def stream and every locations reply called triggerEvent
        -- with a nil name. Declared rather than removed: the calls sit at the
        -- end of two live round trips and are the natural place for anything
        -- that wants to know the data has landed.
        OnShopItemDefsReloaded = "OnPhunMartShopItemDefsReloaded",
        OnShopLocationsReceived = "OnPhunMartShopLocationsReceived"
    },
    utils = require "PhunMart/utils",
    settings = {},
    defs = {}, -- legacy: populated by requestItemDefs chunked transfer
    shops = {}, -- populated after Core.compile() on the server
    spriteToShop = {},
    opensquares = {},
    actions = {},
    ui = {
        client = {},
        admin = {}
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

Core.isLocal = not isClient() and not isServer() and not isCoopHost()
local sb = SandboxVars
Core.settings = sb["PhunMart"]
Core.settings.ReplacementKey = "PhunMart6"
for _, event in pairs(PhunMart.events) do
    if not Events[event] then
        LuaEventManager.AddEvent(event)
    end
end

function Core.getOption(name, default)
    local n = Core.name .. "." .. name
    local val = getSandboxOptions():getOptionByName(n) and getSandboxOptions():getOptionByName(n):getValue()
    if val == nil then
        return default
    end
    return val
end

function Core.debugLn(str)
    if Core.settings.Debug then
        print("[" .. Core.name .. "] " .. str)
    end
end

function Core.debug(...)
    if Core.settings.Debug then
        for _, v in ipairs({...}) do
            if type(v) == "table" then
                Core.utils.printTable(v)
            else
                print("[PhunMart] " .. tostring(v))
            end
        end
    end
end

function Core:reloadShopDefinitions()
    -- Rebuild spriteToShop index from whatever is currently in Core.shops.
    -- On the server this is called after Core.compile() sets Core.shops = runtime.shops.
    self.spriteToShop = {}
    for k, v in pairs(self.shops or {}) do
        for _, sprite in ipairs(v.sprites or {}) do
            self.spriteToShop[sprite] = k
        end
        for _, sprite in ipairs(v.unpoweredSprites or {}) do
            self.spriteToShop[sprite] = k
        end
    end
    return self.shops
end

function Core:ini()
    self.inied = true
    if not isClient() then
        self:reloadShopDefinitions()
    end
    triggerEvent(self.events.OnReady, self)
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

function Core.hasPower(square)
    if square and SandboxVars.ElecShutModifier > -1 then
        return square:haveElectricity() or GameTime:getInstance():getNightsSurvived() >
                   getSandboxOptions():getOptionByName("ElecShutModifier"):getValue()
    end
    return false
end

function Core:resetInstanceInventory(key)
    if Core.instanceInventory == nil then
        Core.instanceInventory = {}
    end
    if Core.instanceInventory[key] then
        Core.instanceInventory[key] = nil
    end
end

function Core:updateInstanceInventory(key, data)
    if Core.instanceInventory == nil then
        Core.instanceInventory = {}
    end
    Core.debug("Updating instance inventory for " .. key, data)
    Core.instanceInventory[key] = data
end

function Core:getInstanceInventory(key)
    if Core.instanceInventory == nil then
        Core.instanceInventory = {}
    end
    if Core.instanceInventory[key] then
        return Core.instanceInventory[key]
    end
    return nil
end

function Core.getAllVehicleCategories()

    if Core.vehicleCategories == nil then
        Core.getAllVehicles()
    end

    return Core.vehicleCategories

end

function Core.getAllVehicles(refresh)

    if Core.vehiclesAll ~= nil and not refresh then
        return Core.vehiclesAll
    end
    Core.vehiclesAll = {}
    Core.vehicleCategories = {}
    Core.vehicleLabelCache = {}
    local catMap = {}

    local itemList = getScriptManager():getAllVehicleScripts()
    for i = 0, itemList:size() - 1 do
        local script = itemList:get(i)
        local name = script:getName()
        local fullName = script:getFullName()
        local vehicleObj = getScriptManager():getVehicle(fullName)
        local label
        if vehicleObj and vehicleObj.getName then
            local key = "IGUI_VehicleName" .. vehicleObj:getName()
            local translated = getText(key)
            -- getText returns the key itself when no translation exists
            label = (translated ~= key) and translated or name
        else
            label = name
        end
        Core.vehicleLabelCache[fullName] = label

        local cat
        if string.find(name, "Smashed") then
            cat = "Smashed"
        elseif string.find(name, "Burnt") then
            cat = "Burnt"
        elseif string.find(name, "Trailer") then
            cat = "Trailer"
        elseif string.find(name, "Van") then
            cat = "Van"
        elseif string.find(name, "Truck") then
            cat = "Truck"
        elseif string.find(name, "SUV") then
            cat = "SUV"
        elseif string.find(name, "OffRoad") then
            cat = "Off-Road"
        elseif string.find(name, "Car") then
            cat = "Car"
        else
            cat = "Other"
        end

        if cat ~= "" and catMap[cat] == nil then
            catMap[cat] = true
            table.insert(Core.vehicleCategories, {
                label = cat
            })
        end
        table.insert(Core.vehiclesAll, {
            type = fullName,
            label = label,
            -- texture = item:getNormalTexture(),
            category = cat
        })

    end

    table.sort(Core.vehiclesAll, function(a, b)
        return a.label:lower() < b.label:lower()
    end)
    table.sort(Core.vehicleCategories, function(a, b)
        return a.label:lower() < b.label:lower()
    end)

    return Core.vehiclesAll
end

-- Returns true if a vehicle script exists in the game's script database.
-- Accepts bare names ("CarNormal") or full types ("Base.CarNormal").
-- Returns true defensively when getScriptManager is unavailable (e.g. early init).
function Core.vehicleScriptExists(scriptName)
    if not getScriptManager then
        return true
    end
    local sm = getScriptManager()
    if not sm or not sm.getVehicle then
        return true
    end
    local fullType = scriptName:find("%.") and scriptName or ("Base." .. scriptName)
    return sm:getVehicle(fullType) ~= nil
end

-- Claim-token weights for livestock (symbolic crates, not live encumbrance).
Core.animalClaimWeights = {
    small = 1.0,
    medium = 5.0,
    large = 15.0
}

-- True if animalType exists in AnimalDefinitions (Lua table).
function Core.animalTypeExists(animalType)
    if not animalType or animalType == "" then
        return false
    end
    if not AnimalDefinitions or not AnimalDefinitions.animals then
        return true -- defensive during early init
    end
    return AnimalDefinitions.animals[animalType] ~= nil
end

-- True if breed is valid for the animal type's group.
function Core.animalBreedExists(animalType, breedName)
    if not Core.animalTypeExists(animalType) then
        return false
    end
    if not breedName or breedName == "" then
        return false
    end
    if not AnimalDefinitions or not AnimalDefinitions.animals then
        return true
    end
    local animalDef = AnimalDefinitions.animals[animalType]
    local breeds = animalDef and animalDef.breeds
    if not breeds then
        local group = animalDef and animalDef.group
        breeds = group and AnimalDefinitions.breeds and AnimalDefinitions.breeds[group] and
                     AnimalDefinitions.breeds[group].breeds
    end
    return breeds ~= nil and breeds[breedName] ~= nil
end

-- Resolve breed table entry for icon lookup.
local function getAnimalBreedDef(animalType, breedName)
    if not AnimalDefinitions or not AnimalDefinitions.animals then
        return nil
    end
    local animalDef = AnimalDefinitions.animals[animalType]
    if not animalDef then
        return nil
    end
    local breeds = animalDef.breeds
    if not breeds then
        local group = animalDef.group
        breeds = group and AnimalDefinitions.breeds and AnimalDefinitions.breeds[group] and
                     AnimalDefinitions.breeds[group].breeds
    end
    return breeds and breeds[breedName] or nil
end

-- Live inventory icon for an animal type+breed (Item_* texture name), or nil.
function Core.getAnimalIcon(animalType, breedName)
    local breed = getAnimalBreedDef(animalType, breedName)
    if not breed then
        return nil
    end
    local animalDef = AnimalDefinitions.animals[animalType]
    if animalDef and animalDef.female == true then
        return breed.invIconFemale or breed.invIconMale or breed.invIconBaby
    end
    -- Babies typically have a babyType on the adult, and are themselves the babyType of another stage.
    if animalDef and animalDef.babyType == nil and animalDef.female == nil then
        -- Ambiguous; prefer baby icon when the type name looks juvenile, else male.
        local t = tostring(animalType)
        if t:find("chick") or t:find("calf") or t:find("lamb") or t:find("piglet") or t:find("kitten") or
            t:find("poult") or t:find("pup") or t:find("kit") or t:find("fawn") or t:find("baby") then
            return breed.invIconBaby or breed.invIconFemale or breed.invIconMale
        end
        return breed.invIconMale or breed.invIconFemale or breed.invIconBaby
    end
    if animalDef and animalDef.female == false then
        return breed.invIconMale or breed.invIconFemale or breed.invIconBaby
    end
    return breed.invIconBaby or breed.invIconFemale or breed.invIconMale
end

-- Human-readable label using vanilla IGUI_AnimalType_* / IGUI_Breed_* keys.
function Core.getAnimalLabel(animalType, breedName)
    local typeLabel = animalType or "?"
    if animalType then
        local key = "IGUI_AnimalType_" .. animalType
        local translated = getText(key)
        if translated ~= key then
            typeLabel = translated
        end
    end
    if breedName and breedName ~= "" then
        local bkey = "IGUI_Breed_" .. breedName
        local btranslated = getText(bkey)
        local breedLabel = (btranslated ~= bkey) and btranslated or breedName
        return breedLabel .. " " .. typeLabel
    end
    return typeLabel
end

-- Returns a human-readable label for a vehicle full type (e.g. "Base.CarNormal").
-- Populates the cache via getAllVehicles() on first call.
-- Falls back to the bare script name if no translation exists.
function Core.getVehicleLabel(fullType)
    if Core.vehicleLabelCache == nil then
        Core.getAllVehicles()
    end
    -- offer.item values are bare script names (e.g. "CarLuxury"); cache is keyed by
    -- full name (e.g. "Base.CarLuxury"), so try both forms.
    local lookupKey = fullType:find("%.") and fullType or ("Base." .. fullType)
    if Core.vehicleLabelCache[lookupKey] then
        return Core.vehicleLabelCache[lookupKey]
    end
    if Core.vehicleLabelCache[fullType] then
        return Core.vehicleLabelCache[fullType]
    end
    -- Direct lookup for types not yet in cache
    local vehicleObj = getScriptManager():getVehicle(lookupKey)
    if vehicleObj and vehicleObj.getName then
        local key = "IGUI_VehicleName" .. vehicleObj:getName()
        local translated = getText(key)
        return (translated ~= key) and translated or vehicleObj:getName()
    end
    -- Last resort: strip the module prefix from the full type
    return fullType:match("%.(.+)$") or fullType
end

function Core.getAllTraitCategories()

    if Core.traitCategories == nil then
        Core.getAllTraits()
    end
    return Core.traitCategories

end

function Core.getAllTraits(refresh)

    if Core.traitsAll ~= nil and not refresh then
        return Core.traitsAll
    end
    Core.traitsAll = {}
    Core.traitCategories = {}
    local catMap = {}

    local traits = CharacterTraitDefinition.getTraits()
    for i = 0, traits:size() - 1 do
        local trait = traits:get(i)

        local cat = trait:getCost() < 0 and "Negative" or "Positive"
        if cat ~= "" and catMap[cat] == nil then
            catMap[cat] = true
            table.insert(Core.traitCategories, {
                label = cat
            })
        end

        table.insert(Core.traitsAll, {
            type = trait:getType(),
            label = trait:getLabel(),
            cost = trait:getCost(),
            tooltip = {
                description = trait:getDescription()
            },
            texture = trait:getTexture(),
            exclusives = trait:getMutuallyExclusiveTraits(),
            category = trait:getCost() < 0 and "Negative" or "Positive"
        })

    end
    table.sort(Core.traitsAll, function(a, b)
        return a.label:lower() < b.label:lower()
    end)

    return Core.traitsAll
end

function Core.getAllXpCategories()

    if Core.xpCategories == nil then
        Core.xpCategories = {}
        for i = 1, 10 do
            table.insert(Core.xpCategories, {
                label = "Level " .. tostring(i)
            })
        end
    end
    return Core.xpCategories

end

function Core.getAllXp(refresh)

    if Core.xpAll ~= nil and not refresh then
        return Core.xpAll
    end
    Core.xpAll = {}
    for i = 0, Perks.getMaxIndex() - 1 do
        local perk = PerkFactory.getPerk(Perks.fromIndex(i))
        local name = perk:getName()
        if name ~= "None" then

            for lvl = 1, 10 do
                table.insert(Core.xpAll, {
                    type = lvl,
                    label = name,
                    level = lvl,
                    xpForLevel = perk:getXpForLevel(lvl),
                    tooltip = {
                        description = ""
                    },
                    category = "Level " .. tostring(lvl)
                })
            end
        end

    end

    table.sort(Core.xpAll, function(a, b)
        if a.label:lower() ~= b.label:lower() then
            return a.label:lower() < b.label:lower()
        end
        return a.level < b.level
    end)

    return Core.xpAll
end

function Core.getAllBoostCategories()

    if Core.boostsCategories == nil then
        Core.boostsCategories = {}
        for i = 1, 3 do
            table.insert(Core.boostsCategories, {
                label = "Level " .. tostring(i)
            })
        end
    end
    return Core.boostsCategories

end

function Core.getAllBoosts(refresh)

    if Core.boostsAll ~= nil and not refresh then
        return Core.boostsAll
    end
    Core.boostsAll = {}
    Core.boostsCategories = {}
    local catMap = {}

    for i = 0, Perks.getMaxIndex() - 1 do
        local perk = PerkFactory.getPerk(Perks.fromIndex(i))
        local name = perk:getName()
        if name ~= "None" then
            for lvl = 1, 3 do
                table.insert(Core.boostsAll, {
                    type = lvl,
                    label = name,
                    level = lvl,
                    tooltip = {
                        description = ""
                    },
                    category = "Level " .. tostring(lvl)
                })
            end
        end

    end

    table.sort(Core.boostsAll, function(a, b)
        if a.label:lower() ~= b.label:lower() then
            return a.label:lower() < b.label:lower()
        end
        return a.level < b.level
    end)

    return Core.boostsAll
end

function Core.getAllSkills(refresh)

    if Core.skillsAll ~= nil and not refresh then
        return Core.skillsAll
    end
    Core.skillsAll = {}

    local checked = {}
    for i = 0, Perks.getMaxIndex() - 1 do
        local perk = PerkFactory.getPerk(Perks.fromIndex(i))
        if perk and perk:getParent() ~= Perks.None then
            local name = perk:getName()
            if not checked[name] then
                checked[name] = true
                table.insert(Core.skillsAll, {
                    type = name,
                    label = perk.translation
                })
            end
        end
    end
    table.sort(Core.skillsAll, function(a, b)
        return (a.label or a.type):lower() < (b.label or b.type):lower()
    end)
    return Core.skillsAll
end

function Core.getAllProfessions(refresh)

    if Core.professionsAll ~= nil and not refresh then
        return Core.professionsAll
    end
    Core.professionsAll = {}
    local checked = {}

    local professionList = ProfessionFactory.getProfessions();
    for i = 0, professionList:size() - 1 do
        local prof = professionList:get(i)
        table.insert(Core.professionsAll, {
            type = prof:getType(),
            label = prof:getLabel(),
            texture = prof:getTexture(),
            tooltip = {
                description = prof:getDescription()
            }
        })

    end
    table.sort(Core.professionsAll, function(a, b)
        return (a.label or a.type):lower() < (b.label or b.type):lower()
    end)
    return Core.professionsAll
end

-- ─── Shared compile ───────────────────────────────────────────────────────────
-- Core.compileWith(overrides) is callable from both server and client.
-- On the server, Core.compile() in server/main.lua reads override files from
-- disk and calls this. On the client, the requestShopDefs handler receives the
-- override tables from the server and calls this. The client never touches the FS.

local _deepMerge = Core.utils.deepMerge
local _stripRemoved = Core.utils.stripRemoved

local function _loadDefaults(path)
    local ok, result = pcall(require, path)
    if not ok then
        Core.debugLn("Warning: could not load defaults '" .. path .. "': " .. tostring(result))
        return {}
    end
    return result or {}
end

-- Which default modules feed each definition category. Single source of truth:
-- compileWith builds the base context from these, and the admin UI uses them to
-- tell an admin-created key (deletable) from one that ships with the mod (only
-- maskable, never removable).
Core.defaultPaths = {
    prices = {"PhunMart/defaults/prices"},
    specials = {"PhunMart/defaults/specials", "PhunMart/defaults/xp_rewards", "PhunMart/defaults/animal_rewards"},
    conditionsDefs = {"PhunMart/defaults/conditions", "PhunMart/defaults/xp_conditions"},
    items = {"PhunMart/defaults/items", "PhunMart/defaults/xp_items"},
    groups = {"PhunMart/defaults/groups"},
    pools = {"PhunMart/defaults/pools"},
    shops = {"PhunMart/defaults/shops"}
}

--- Shop-definition fields carried through compilation and out to the client on
--- top of the ones the compiler names for itself.
---
--- The compiler builds each `runtime.shops` entry from an explicit list of
--- fields, which is what keeps a compiled shop small and predictable, and what
--- stops an admin override smuggling arbitrary keys into the runtime. The cost
--- is that a flag another mod invents is dropped silently somewhere between the
--- definition that declared it and the table anything actually reads, leaving
--- no evidence beyond a condition that never fires.
---
--- Appending a name here is how a mod keeps its own flag. It has to happen
--- before the first compile, which for a mod's shared file means load time, the
--- same window `Core.defaultPaths` is extended in:
---
---     table.insert(Core.shopDefPassthrough, "consignment")
---
--- PhunMart declares none of its own, so the list ships empty: everything the
--- base mod needs is named in the compiler already.
Core.shopDefPassthrough = {}

--- Tabs in the admin shell.
---
--- `module` is a key on `Core.ui` rather than the panel table itself, because
--- the shell resolves it when the window opens rather than when this list is
--- built, and a panel registers itself as its own file loads. That indirection
--- is what lets a tab be registered before the panel behind it exists.
---
--- `order` places a tab in the strip. The shipped ones are spaced ten apart so
--- another mod can sit between any two without renumbering, and Tools sits far
--- out at 1000 because it belongs last whatever else arrives.
---
--- `admin = false` marks the one tab a non-editor may see. Every other tab is
--- shown only to a player who passes `Core.canEditConfig`.
Core.ui.adminTabs = {}

--- Add a tab to the admin shell, or replace one by key.
---
--- Replacing is deliberate: re-registering a shipped key is the only way to
--- swap a panel out without editing this mod, and a mod that does it has said
--- so explicitly rather than ending up with two tabs of the same name.
function Core.registerAdminTab(spec)
    if type(spec) ~= "table" or type(spec.key) ~= "string" or spec.key == "" then
        Core.debugLn("registerAdminTab: ignored a spec with no key")
        return false
    end
    spec.order = tonumber(spec.order) or 0
    for i, existing in ipairs(Core.ui.adminTabs) do
        if existing.key == spec.key then
            Core.ui.adminTabs[i] = spec
            return true
        end
    end
    table.insert(Core.ui.adminTabs, spec)
    return true
end

--- The registered tabs, in the order they should be drawn.
---
--- Sorted on read rather than on registration, so a mod may register at any
--- point before the window first opens. The registration index carries through
--- as the tiebreak because `table.sort` is not stable: without it, two tabs
--- sharing an order would be free to swap places between one opening and the
--- next.
function Core.adminTabsInOrder()
    local decorated = {}
    for i, spec in ipairs(Core.ui.adminTabs) do
        decorated[i] = {
            spec = spec,
            seq = i
        }
    end
    table.sort(decorated, function(a, b)
        if a.spec.order ~= b.spec.order then
            return a.spec.order < b.spec.order
        end
        return a.seq < b.seq
    end)
    local ordered = {}
    for i, entry in ipairs(decorated) do
        ordered[i] = entry.spec
    end
    return ordered
end

--- Modes in the shop window: what the machine can be asked to do.
---
--- Every machine has bought its stock before the player arrives, so the window
--- has only ever had one job and never needed to say which one it was doing.
--- A machine that also takes goods in has two, and the player has to be able to
--- say which. Modes are how that choice is offered, and registering one is how
--- a mod adds a job to a window it does not own.
---
--- A mode spec:
---   key      unique; also what setMode takes
---   label    text key for the strip button
---   order    position in the strip, shipped ones spaced ten apart
---   flag     optional; a field on the shop payload that must be truthy for
---            this mode to appear. The usual way to scope a mode to one machine
---   applies  optional; function(data) for anything a flag cannot express
---
--- Declaring neither `flag` nor `applies` puts the mode on every machine in the
--- game, which is what Buy wants and almost never what anything else does.
---
--- The behaviour hooks are all optional, and the window falls back to its own
--- buying behaviour for each one a mode leaves out:
---   onEnter(ui) / onExit(ui)    switching to and away from this mode
---   getGridData(ui)             what the item grid should render
---   actionLabel(ui, offer)      title for the action button
---   canAction(ui, offer, id)    whether that button is live
---   onAction(ui)                the button was pressed
Core.ui.shopModes = {}

--- Add a mode to the shop window, or replace one by key.
function Core.registerShopMode(spec)
    if type(spec) ~= "table" or type(spec.key) ~= "string" or spec.key == "" then
        Core.debugLn("registerShopMode: ignored a spec with no key")
        return false
    end
    spec.order = tonumber(spec.order) or 0
    for i, existing in ipairs(Core.ui.shopModes) do
        if existing.key == spec.key then
            Core.ui.shopModes[i] = spec
            return true
        end
    end
    table.insert(Core.ui.shopModes, spec)
    return true
end

--- The modes that apply to one shop payload, in strip order.
---
--- Takes the payload rather than the definition because the window has nothing
--- else: it is handed a payload when it opens and never sees a shop def. That
--- is also why a mode's `flag` has to be named in Core.shopDefPassthrough to be
--- worth testing -- otherwise it is dropped before it reaches here, and the
--- mode silently never appears.
function Core.shopModesFor(data)
    local decorated = {}
    for i, spec in ipairs(Core.ui.shopModes) do
        local ok = true
        if spec.flag and not (data and data[spec.flag]) then
            ok = false
        end
        if ok and spec.applies and not spec.applies(data) then
            ok = false
        end
        if ok then
            table.insert(decorated, {
                spec = spec,
                seq = i
            })
        end
    end
    table.sort(decorated, function(a, b)
        if a.spec.order ~= b.spec.order then
            return a.spec.order < b.spec.order
        end
        return a.seq < b.seq
    end)
    local ordered = {}
    for i, entry in ipairs(decorated) do
        ordered[i] = entry.spec
    end
    return ordered
end

--- Which files on disk hold the overrides for each category. Server-side only
--- in practice, but declared here beside defaultPaths because two things now
--- need the same list: the compile that reads them, and the migrations that
--- rewrite them. Having it in one place is what stops those two disagreeing.
---
--- These are JSON as of B42.20.4, which removed loadstring and with it any way
--- to read the Lua-table format they used to be in. Old files are left alone
--- and reported at startup rather than migrated in place: converting them needs
--- a Lua parser, which is the thing the runtime no longer has.
Core.overridePaths = {
    prices = {"PhunMart_Prices.json"},
    specials = {"PhunMart_Specials.json", "PhunMart_XP_Rewards.json"},
    conditionsDefs = {"PhunMart_Conditions.json", "PhunMart_XP_Conditions.json"},
    items = {"PhunMart_Items.json", "PhunMart_XP_Items.json"},
    groups = {"PhunMart_Groups.json"},
    pools = {"PhunMart_Pools.json"},
    shops = {"PhunMart_Shops.json"}
}

--- The file an edit of `kind` is written back to.
---
--- A kind can be assembled from several override files, but only ever writes to
--- the first: the extra ones exist so a hand-maintained split stays readable,
--- and picking one to write to is what keeps an edit from landing in two files
--- at once. The editors used to carry their own copy of this mapping, which is
--- the kind of duplicate that survives a rename only by luck.
function Core.primaryOverride(kind)
    local names = Core.overridePaths[kind]
    return names and names[1] or nil
end

--- The mutable files that are not per-kind overrides. Here rather than beside
--- their readers so that every filename the mod writes is in one place, which
--- is what makes a format change like the move to JSON checkable.
Core.configFiles = {
    -- Mod state: which migrations have run, whether the legacy import happened.
    state = "PhunMart.json",
    blacklist = "PhunMart_Blacklist.json",
    tokenRewards = "PhunMart_TokenRewards.json"
}

--- Where the migrations put a copy of the overrides before touching them.
function Core.backupFileFor(version)
    return "PhunMart_Backup_v" .. tostring(version) .. ".json"
end

--- Bump when a change to the SHIPPED definitions changes what a machine would
--- put on its shelves, and existing machines should roll again rather than wait
--- out their restock timer.
---
--- Separate from the migration version, which counts changes to an admin's
--- override FILES. A server that never wrote an override runs no migrations and
--- still needs this, because the defaults moved underneath it.
---
--- A machine bakes its offers at restock: prices, stock and a full copy of the
--- reward. So until it rolls again it keeps selling what the old definitions
--- said, which is stale rather than broken.
Core.defsRevision = 1

--- Which shop types that revision affects, or nil for all of them.
---
--- Named rather than assumed, because forcing every machine in the world to
--- reroll takes stock out from under players standing at shops the change never
--- touched. Revision 1 is the vehicle rework: groups carry their own price band
--- and fuel now, and only WrentAWreck sells cars.
Core.defsRevisionShops = {"WrentAWreck"}

--- What to call a shop type on screen.
---
--- Shipped shops are named by a translation key, which a shop an admin creates
--- can never have: nothing writes to the translation files. So a definition may
--- carry its own `title`, and that is what the wizard fills in. Without this
--- fallback a new shop would be labelled by its key everywhere it appeared,
--- which made the wizard's name field decorative.
---
--- Order is deliberate. The translation wins so a shipped shop stays
--- translated even if someone sets a title on it, and the key is the last
--- resort rather than an error.
function Core.shopLabel(shopType)
    if not shopType or shopType == "" then
        return ""
    end
    local translated = getTextOrNull("IGUI_PhunMart_Shop_" .. shopType)
    if translated then
        return translated
    end
    local def = Core.defs and Core.defs.shops and Core.defs.shops[shopType]
    if def and def.title and def.title ~= "" then
        return def.title
    end
    return shopType
end

--- True when `key` is defined by the mod's own defaults for `kind`.
--- Such a key can be disabled but never deleted: the override layer sits on top
--- of the defaults, so removing the override just restores the shipped version.
function Core.isShippedKey(kind, key)
    if not key then
        return false
    end
    for _, path in ipairs(Core.defaultPaths[kind] or {}) do
        if _loadDefaults(path)[key] ~= nil then
            return true
        end
    end
    return false
end

--- May this player open the definition editor?
---
--- One predicate for every entry point. There were three, which disagreed: the
--- debug menu checked nothing at all, the admin panel button checked only the
--- Is this entry from the instance table an actual machine?
---
--- Core.instances is a raw ModData table, so anything else stored under the
--- same name lands in it and every walk sees it. That has already happened
--- once, with the forced-restock stamps, and cost a crash in the distance
--- calculation and a phantom row in the locations list. The stamps have moved
--- out; this is so the next one costs nothing.
function Core.isShopInstance(v)
    return type(v) == "table" and v.type ~= nil and v.x ~= nil and v.y ~= nil
end

--- EditorRole sandbox option, and the Admin Tools button inside checked only
--- isAdmin. So EditorRole could be bypassed by using a different door.
---
--- EditorRole narrows within the admin population rather than granting access
--- to non-admins, matching its own tooltip: empty allows everyone with
--- debug/admin access, set restricts to a role among them. It is a policy
--- control, not a security boundary. The boundary is the server, which checks
--- isAdmin on every command it accepts.
function Core.canEditConfig(player)
    if Core.isLocal then
        return true
    end
    if not Core.utils.isAdmin(player) then
        return false
    end
    local required = Core.getOption("EditorRole", "")
    if not required or required == "" then
        return true
    end
    local role = player and player.getRole and player:getRole()
    local roleName = role and role.getName and role:getName()
    if not roleName or roleName == "" then
        return false
    end
    return roleName:lower() == required:lower()
end

--- True when `key` has an entry in the override files, meaning someone changed
--- it. Independent of isShippedKey: together they give three states, a stock
--- definition, a shipped one that has been edited, and one an admin created.
function Core.isOverriddenKey(kind, key)
    if not key or not Core.overrides then
        return false
    end
    local t = Core.overrides[kind]
    return (t and t[key] ~= nil) or false
end

function Core.compileWith(overrides)
    overrides = overrides or {}
    Core.compiler = Core.compiler or require "PhunMart/compiler"

    local function mergeCtx(kind, override)
        local base = {}
        for _, path in ipairs(Core.defaultPaths[kind] or {}) do
            for k, v in pairs(_loadDefaults(path)) do
                base[k] = v
            end
        end
        -- Overrides may carry tombstones (utils.REMOVED) marking keys the editor
        -- cleared. Strip them here so the compiled context sees the key as absent
        -- rather than set to a sentinel string.
        return _stripRemoved(_deepMerge(base, override or {}))
    end

    local ctx = {
        prices = mergeCtx("prices", overrides.prices),
        specials = mergeCtx("specials", overrides.specials),
        conditionsDefs = mergeCtx("conditionsDefs", overrides.conditionsDefs),
        items = mergeCtx("items", overrides.items),
        groups = mergeCtx("groups", overrides.groups),
        pools = mergeCtx("pools", overrides.pools),
        shops = mergeCtx("shops", overrides.shops)
    }

    local runtime, log = Core.compiler.compileAll(ctx)
    Core.runtime = runtime
    Core.defs = ctx
    -- Kept, not just consumed. Core.defs is defaults and overrides already
    -- merged, so it cannot answer "did someone change this?". The raw override
    -- tables can, and the editors use them to mark customised rows.
    Core.overrides = overrides
    Core.shops = runtime.shops
    Core:reloadShopDefinitions()
    Core.debug("Warn", log.warnings, "Errors", log.errors)
    triggerEvent(Core.events.OnDefsUpdated)
    return runtime, log
end

