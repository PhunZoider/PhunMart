local allShops = require "PhunMart2/data/shops"

PhunMart = {
    name = "PhunMart",
    inied = false,
    consts = {
        shops = "PhunMart_Shops",
        shopsLuaFile = "PhunMart_Shops.lua",
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
        getBlackList = "PhunMartGetBlacklist",
        setBlacklist = "PhunMartSetBlacklist",
        playerSetup = "PhunMartPlayerSetup",
        getShopList = "PhunMartGetShopList",
        getShopData = "PhunMartGetShopData",
        openShop = "PhunMartOpenShop",
        openError = "PhunMartOpenError",
        unlockShop = "PhunMartUnlockShop",
        upsertShopDefinition = "PhunMartUpsertShopDefinition",
        getShopDefinition = "PhunMartGetShopDefinition",
        compile = "PhunMartCompileShops",
        reroll = "PhunMartReroll",
        rerollAllShops = "PhunMartRerollAllShops"

    },
    events = {
        OnReady = "OnPhunMartOnReady",
        recievedInventory = "OnPhunMartRecievedInventory"
    },
    tools = require "PhunMart2/tools",
    settings = {},
    shops = allShops,
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
    if Core.consts.debug then
        print("[PhunMart2][ServerSystem]", ...)
    end
end

function Core:reloadShopDefinitions()
    local file = nil
    if file then
        self.shops = file
    else
        self.shops = allShops
    end
    self.spriteToShop = {}
    for k, v in pairs(Core.shops or {}) do
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

local tid = nil
function Core.getCategory(item)
    -- from the awesome BetterSorting mod by Blindcoder,
    -- but modified to return the category rather than just set it

    if tid == nil then
        if TweakItemData then
            tid = TweakItemData
        else
            tid = false
        end
    end
    if tid then
        local test = TweakItemData[item:getFullName()]["DisplayCategory"] or
                         TweakItemData[item:getFullName()]["displaycategory"]
        if test then
            return test
        end
    end

    local category = tostring(item:getDisplayCategory());

    if item.fluidContainer then
        local fluid = item.fluidContainer:getFluidContainer():getPrimaryFluid();
        if fluid and item:getFluidContainer():getAmount() > 0 then
            if fluid:isCategory(FluidCategory.Alcoholic) then
                category = "FoodA";
            elseif fluid:isCategory(FluidCategory.Beverage) then
                category = "FoodB";
            elseif fluid:isCategory(FluidCategory.Fuel) then
                category = "Fuel"
            end
        else
            category = "Container";
        end
    elseif item.getCanStoreWater and item:getCanStoreWater() then
        if item:getTypeString() ~= "Drainable" then
            category = "Container";
        else
            category = "FoodB";
        end

    elseif item:getDisplayCategory() == "Water" then
        category = "FoodB";

    elseif item:getTypeString() == "Food" then
        if item:getDaysTotallyRotten() > 0 and item:getDaysTotallyRotten() < 1000000000 then
            category = "FoodP";
        else
            category = "FoodN";
        end

    elseif item:getTypeString() == "Literature" then
        if string.len(item:getSkillTrained()) > 0 then
            category = "LitS";
        elseif item:getTeachedRecipes() and not item:getTeachedRecipes():isEmpty() then
            category = "LitR";
        elseif item:getStressChange() ~= 0 or item:getBoredomChange() ~= 0 or item:getUnhappyChange() ~= 0 then
            category = "LitE";
        else
            category = "LitW";
        end

    elseif item:getTypeString() == "Weapon" then
        if item:getDisplayCategory() == "Explosives" or item:getDisplayCategory() == "Devices" then
            category = "WepBomb";
        end

        -- Tsar's True Music Cassette and Vinyls
    elseif string.find(item:getFullName(), "Tsarcraft.Cassette") or string.find(item:getFullName(), "Tsarcraft.Vinyl") then
        category = "MediaA";

        -- Tsar's True Actions Dance Cards
    elseif item:getTypeString() == "Normal" and item:getModuleName() == "TAD" then
        category = "Misc";
    end

    return category or "Unknown"
end

function Core.getAllItemCategories()

    if Core.itemCategories == nil then
        Core.getAllItems()
    end

    return Core.itemCategories

end

function Core.getAllItems(refresh)

    if Core.itemsAll ~= nil and not refresh then
        return Core.itemsAll
    end
    Core.itemsAll = {}
    Core.itemCategories = {}
    local catMap = {}

    local itemList = getScriptManager():getAllItems()
    for i = 0, itemList:size() - 1 do
        local item = itemList:get(i)
        if not item:getObsolete() and not item:isHidden() then

            local cat = Core.getCategory(item)
            if cat ~= "" and catMap[cat] == nil then
                catMap[cat] = true
                table.insert(Core.itemCategories, {
                    label = cat,
                    type = ""
                })
            end
            table.insert(Core.itemsAll, {
                type = item:getFullName(),
                label = item:getDisplayName(),
                texture = item:getNormalTexture(),
                category = cat
            })
        end
    end

    table.sort(Core.itemsAll, function(a, b)
        return a.label:lower() < b.label:lower()
    end)
    table.sort(Core.itemCategories, function(a, b)
        return a.label:lower() < b.label:lower()
    end)

    return Core.itemsAll
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
    local catMap = {}

    local itemList = getScriptManager():getAllVehicleScripts()
    for i = 0, itemList:size() - 1 do
        local item = itemList:get(i)

        local script = itemList:get(i)
        local name = script:getName()
        local fname = script:getFileName()
        local fullName = script:getFullName()
        local text = "IGUI_VehicleName" .. name
        local label = getText(text)
        local cat = "Other"
        if string.contains(name, "Van") then
            cat = "Van"
        elseif string.contains(name, "Truck") then
            cat = "Truck"
        elseif string.contains(name, "Burnt") then
            cat = "Burnt"
        elseif string.contains(name, "Smashed") then
            cat = "Smashed"
        elseif string.contains(name, "Trailer") then
            cat = "Trailer"
        elseif string.contains(name, "Car") then
            cat = "Car"
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

    local traits = TraitFactory.getTraits()
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
    local result = {}
    for i = 0, Perks.getMaxIndex() - 1 do
        local perk = PerkFactory.getPerk(Perks.fromIndex(i))
        local name = perk:getName()
        if name ~= "None" then

            for i = 1, 10 do
                table.insert(Core.xpAll, {
                    type = i,
                    label = name,
                    level = i,
                    xpForLevel = perk:getXpForLevel(i),
                    tooltip = {
                        description = ""
                    },
                    category = "Level " .. tostring(i)
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

    local result = {}
    for i = 0, Perks.getMaxIndex() - 1 do
        local perk = PerkFactory.getPerk(Perks.fromIndex(i))
        local name = perk:getName()
        if name ~= "None" then
            for i = 1, 3 do
                table.insert(Core.boostsAll, {
                    type = i,
                    label = name,
                    level = i,
                    tooltip = {
                        description = ""
                    },
                    category = "Level " .. tostring(i)
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

    if Core.ProfessionsAll ~= nil and not refresh then
        return Core.ProfessionsAll
    end
    Core.ProfessionsAll = {}
    local checked = {}

    local professionList = ProfessionFactory.getProfessions();
    for i = 0, professionList:size() - 1 do
        local prof = professionList:get(i)
        table.insert(Core.ProfessionsAll, {
            type = prof:getType(),
            label = prof:getLabel(),
            texture = prof:getTexture(),
            tooltip = {
                description = prof:getDescription()
            }
        })

    end
    table.sort(Core.ProfessionsAll, function(a, b)
        return (a.label or a.type):lower() < (b.label or b.type):lower()
    end)
    return Core.ProfessionsAll
end
