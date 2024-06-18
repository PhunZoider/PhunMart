if not isServer() then
    return
end

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
                base = 100,
                min = 10,
                max = 50
            }
        }
    }}

    for i = 0, scripts:size() - 1 do
        local script = scripts:get(i)
        local name = script:getName()
        local fullName = script:getFullName()
        local text = "IGUI_VehicleName" .. name
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
