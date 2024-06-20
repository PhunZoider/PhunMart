local PhunMart = PhunMart

function PhunMart:getAllVehicles(name)
    local scripts = getScriptManager():getAllVehicleScripts()

    local skips = {"SportsCar_ez", "ModernCar_ez"}

    local results = {{
        abstract = true,
        key = "base-vehicle",
        type = "VEHICLE",
        tab = "Car",
        inventory = {
            min = 1,
            max = 3
        },
        tags = "vehicle-car",
        price = {
            currency = {
                base = 25,
                min = 10,
                max = 50
            }
        }
    }, {
        abstract = true,
        key = "base-vehicle:van",
        inherits = "base-vehicle",
        tab = "Van",
        tags = "vehicle,van",
        price = {
            currency = {
                base = 40,
                min = 10,
                max = 50
            }
        }
    }, {
        abstract = true,
        key = "base-vehicle:truck",
        inherits = "base-vehicle",
        tab = "Truck",
        tags = "vehicle,truck",
        price = {
            currency = {
                base = 40,
                min = 10,
                max = 50
            }
        }
    }}

    for i = 0, scripts:size() - 1 do

        local script = scripts:get(i)
        local name = script:getName()
        local fname = script:getFileName()
        local fullName = script:getFullName()
        -- local test = instanceItem
        local text = "IGUI_VehicleName" .. name
        local inherits = "base-vehicle"
        if string.contains(name, "Van") then
            inherits = "base-vehicle:van"
        elseif string.contains(name, "Truck") then
            inherits = "base-vehicle:truck"
        end
        local key = "vehicle:" .. fullName
        if not skips[fullName] and not string.contains(string.lower(name), "burnt") and
            not string.contains(string.lower(name), "smashed") then

            table.insert(results, {
                name = name,
                inherits = "base-vehicle"
            })
        end
    end

    return results
end

function PhunMart:getAllTrait(defaults)
    defaults = defaults or {}

    -- some of these are the free versions that come with professions
    local skips = {
        Mechanics2 = true,
        Nutritionist2 = true,
        BaseBall2 = true,
        Cook2 = true
    }

    local disables = {
        Emaciated = true,
        Feeble = true,
        Lucky = true,
        NeedsLessSleep = true,
        Obese = true,
        ["Out of Shape"] = true,
        Overweight = true,
        Insomniac = true,
        NeedsMoreSleep = true,
        Underweight = true,
        Unfit = true,
        Unlucky = true,
        ["Very Underweight"] = true,
        Weak = true
    }

    local proExclusions = {
        Axeman = "lumberjack",
        Nutritionist = "fitnessInstructor",
        Cook = {"burgerflipper", "chef"},
        Mechanics = "mechanics",
        Marksman = "policeofficer",
        NightOwl = "securityguard",
        Burglar = "burglar",
        Desensitized = "veteran"
    }

    local languageSubs = {
        BaseballPlayer = "PlaysBaseball",
        Clumsy = "clumsy",
        Underweight = "underweight",
        Brave = "brave",
        Cowardly = "cowardly",
        Gracegul = "graceful",
        ShortSighted = "shortsighted",
        EagleEyed = "eagleeyed",
        HardOfHearing = "hardhear",
        Deaf = "deaf",
        KeenHearing = "keenhearing",
        HeartyAppitite = "heartyappitite",
        LightEater = "lighteater",
        NightOwl = "nightowl",
        Claustophobic = "claustophobic"

    }

    local priceSubs = {
        Axeman = 10,
        Burglar = 3,
        Cook2 = 2,
        Desensitized = 6,
        Marksman = 4,
        NightOwl = 4,
        Nutritionist2 = 4
    }

    local traits = TraitFactory.getTraits()
    local results = {{
        abstract = true,
        key = "base-trait:positive",
        inventory = {
            min = 1,
            max = 3
        },
        tab = "Positive",
        type = "TRAIT",
        tags = "positive"
    }, {
        abstract = true,
        key = "base-trait:negativetrade",
        display = {
            type = "TRAIT",
            overlay = "token-overlay"
        },
        inventory = {
            min = 1,
            max = 3
        },
        maxCharLimit = 1,
        tab = "Negative",
        type = "TRAIT",
        tags = "negativetrade"
    }}

    for i = 0, traits:size() - 1 do
        local trait = traits:get(i)
        local typeName = trait:getType()
        if not skips[typeName] then
            local exclusive = trait:getMutuallyExclusiveTraits()
            local exclusives = {}
            for j = 0, exclusive:size() - 1 do
                table.insert(exclusives, exclusive:get(j))
            end
            local cost = trait:getCost()
            local isPositive = true
            if trait:getCost() < 0 then
                isPositive = false
            end
            local price = {
                ["PhunMart.TraiterToken"] = cost
            }
            local disabled = "disabled = true, -- this could be exploited"
            if not disables[typeName] then
                disabled = nil
            end
            if priceSubs[typeName] then
                price = priceSubs[typeName]
            end

            local otherTraits = {
                [typeName] = not isPositive
            }

            local pex = nil
            if proExclusions[typeName] then
                if type(proExclusions[typeName]) == "table" then
                    pex = {}
                    for _, ex in ipairs(proExclusions[typeName]) do
                        pex[ex] = false
                    end
                else
                    pex = {
                        [proExclusions[typeName]] = false
                    }
                end
            end

            for j = 0, exclusive:size() - 1 do
                local ex = exclusive:get(j)
                if not skips[ex] then
                    otherTraits[ex] = false
                end
                -- otherTraits[ex] = false
            end
            local inherits = "base-trait:positive"
            local receive = nil
            if not isPositive then
                inherits = "base-trait:negativetrade"
                receive = {{
                    type = "trait",
                    name = typeName
                }, {
                    type = "item",
                    name = "PhunMart.TraiterToken",
                    quantity = cost
                }}
                price = nil
            end
            table.insert(results, {
                display = {
                    type = "TRAIT",
                    name = typeName
                },
                disabled = disabled,
                receive = receive,
                price = price,
                type = "TRAIT",
                professions = pex,
                traits = otherTraits
            })
        end
    end
    return results
end

function PhunMart:getAllItemTagAndCats()
    local items = ScriptManager.instance:getAllItems()
    local results = {
        tags = {},
        cats = {},
        display = {}
    }
    for i = 1, items:size() do
        local script = items:get(i - 1)
        local tags = script:getTags()
        for ii = 0, tags:size() - 1 do
            ---@type string
            local tag = tags:get(ii)

            results.tags[tag] = true
        end
        local cats = script:getCategories()
        for ii = 0, cats:size() - 1 do
            ---@type string
            local cat = cats:get(ii)

            results.cats[cat] = true
        end
        local displayCategory = script:getDisplayCategory()
        if displayCategory then
            results.display[displayCategory] = true
        end
    end
    return results
end

function PhunMart:getItemsGrouped(excludeExistingDefs)
    local results = {}
    local groups = PhunTools:loadTable("PhunMart_Builders_Groups.lua")
    for group, _ in pairs(groups) do
        results[group] = self:BuildItems(group, excludeExistingDefs)
    end
    return results
end

local function getAllExistingItems()
    local results = {}
    for k, v in pairs(PhunMart.defs.items) do
        if v.display.type == "ITEM" and (v.display.label or v.display.name) then
            results[v.display.label or v.display.name] = true
        end
    end
    return results
end

local function getItemBuildingHelpers(group)

    local results = {}
    local allGroups = PhunTools:loadTable("PhunMart_Builders_Groups.lua") or {}
    local info = allGroups[group] or {}

    local excludes = PhunTools:loadTable("PhunMart_Builders_Excludes.lua") or {}

    -- create a k>v lookup for exlusions/inclusions
    local items = {}
    for _, v in ipairs(excludes) do
        items[v] = false
    end
    for _, v in pairs(info.include or {}) do
        items[v] = true
    end

    -- now get all the INCLUDE value of all OTHER groups and add them to this exclude list
    for k, v in pairs(allGroups) do
        if k ~= group then
            for _, vv in ipairs(v.include or {}) do
                items[vv] = false
            end
        end
    end

    results.items = items or {} -- true == include, false == exclude

    local cats = {} -- use values of hinters to create cats for additional base items
    for _, v in pairs(info.hinters or {}) do
        cats[v] = true
    end
    results.cats = cats or {}

    results.tabs = info.tabs or {}
    results.hinters = info.hinters or {}
    results.itemCategories = info.categories or {}
    results.itemCategories[group] = true

    return results
end

local function resolveHint(itemName, hinters)
    for k, v in pairs(hinters) do
        if string.contains(string.lower(itemName), string.lower(k)) then
            return v
        end
    end
end

function PhunMart:BuildItems(group, skipExistingDefs)

    local doDebug = group == "RadioShack"

    local existingItems = {}
    if skipExistingDefs then
        existingItems = getAllExistingItems()
    end

    if doDebug then
        print("existingItems")
        PhunTools:printTable(existingItems)
    end

    local helpers = getItemBuildingHelpers(group, skipExistingDefs)
    -- get all items in system
    local items = ScriptManager.instance:getAllItems()

    -- create all the relevant base classes
    local results = {{
        abstract = true,
        key = "base-" .. string.lower(group),
        tab = helpers.tabs[k] or group,
        price = {
            currency = {
                base = 1,
                min = 3,
                max = 5
            }
        }
    }}

    for k, v in pairs(helpers.cats) do
        table.insert(results, {
            abstract = true,
            key = "base-" .. string.lower(group) .. "-" .. string.lower(k),
            inherits = "base-" .. string.lower(group),
            tab = helpers.tabs[k] or nil
        })
    end

    if doDebug then
        print(group)
        PhunTools:printTable(helpers)
        print("results")
        PhunTools:printTable(results)
    end

    if doDebug then
        print("allItems")
        PhunTools:printTable(existingItems)
    end

    local toadd = {}
    for i = 1, items:size() do
        local script = items:get(i - 1)
        local item = instanceItem(items:get(i - 1):getFullName())
        local fullType = item:getFullType()
        local displayCategory = item:getDisplayCategory() or ""

        if not existingItems[fullType] and
            (helpers.items[fullType] == true or
                (helpers.itemCategories[displayCategory] and helpers.items[fullType] ~= false)) then

            local hint = string.lower(group)

            if helpers.hinters then
                local test = resolveHint(fullType, helpers.hinters)

                if test then
                    hint = hint .. "-" .. test
                end
            end

            local row = {
                name = fullType,
                inherits = "base-" .. hint
            }
            local modId = item:getModID()
            local mod = modId and modId ~= "pz-vanilla" and modId or nil
            if mod then
                row.mod = mod
            end
            table.insert(toadd, row)

        end
    end
    table.sort(toadd, function(a, b)
        return a.inherits < b.inherits
    end)

    for _, v in ipairs(toadd) do
        table.insert(results, v)
    end
    return results
end
