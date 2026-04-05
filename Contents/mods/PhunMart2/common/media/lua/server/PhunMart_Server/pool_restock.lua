local Core = PhunMart

function Core.getCoinChance(zed)
    local chance = Core.getOption("ChanceToDropChange") * 0.01
    local minCents = Core.getOption("MinCoinsToDrop")
    local maxCents = Core.getOption("MaxCoinsToDrop")
    return chance, minCents, maxCents
end

local activeMods = getActivatedMods()
if (activeMods:contains("phunzones2") or activeMods:contains("phunzones2test")) then

    require "PhunZones/core"
    local PZ = PhunZones
    local checkSprinters = false
    if PZ and PZ.fields then

        PZ.fields.coinchance = {
            label = "IGUI_PhunMart_CoinDropChance",
            type = "int",
            tooltip = "IGUI_PhunMart_CoinDropChance_tooltip",
            group = "PhunMart",
            order = 200
        }
        PZ.fields.coinmin = {
            label = "IGUI_PhunMart_CoinMinCents",
            type = "int",
            tooltip = "IGUI_PhunMart_CoinMinCents_tooltip",
            group = "PhunMart",
            order = 201
        }
        PZ.fields.coinmax = {
            label = "IGUI_PhunMart_CoinMaxCents",
            type = "int",
            tooltip = "IGUI_PhunMart_CoinMaxCents_tooltip",
            group = "PhunMart",
            order = 202
        }
        if activeMods:contains("phunsprinters2") or activeMods:contains("phunsprinters2test") then

            checkSprinters = true
            PZ.fields.coinsprinterchance = {
                label = "IGUI_PhunMart_CoinSprinterDropChance",
                type = "int",
                tooltip = "IGUI_PhunMart_CoinSprinterDropChance_tooltip",
                group = "PhunMart",
                order = 203
            }
            PZ.fields.coinsprintermin = {
                label = "IGUI_PhunMart_CoinSprinterMinCents",
                type = "int",
                tooltip = "IGUI_PhunMart_CoinSprinterMinCents_tooltip",
                group = "PhunMart",
                order = 204
            }
            PZ.fields.coinsprintermax = {
                label = "IGUI_PhunMart_CoinSprinterMaxCents",
                type = "int",
                tooltip = "IGUI_PhunMart_CoinSprinterMaxCents_tooltip",
                group = "PhunMart",
                order = 205
            }
        end

        Core.getCoinChance = function(zed)
            local location = PZ.getLocation(zed:getX(), zed:getY())
            local chance = (location.coinchance or Core.getOption("ChanceToDropChange")) * 0.01
            local minCents = location.coinmin or Core.getOption("MinCoinsToDrop")
            local maxCents = location.coinmax or Core.getOption("MaxCoinsToDrop")

            if checkSprinters then
                if (zed:getModData().PhunSprinters or {}).sprinter then
                    chance = (location.coinsprinterchance or Core.getOption("ChanceToDropChange")) * 0.01
                    minCents = location.coinsprintermin or minCents
                    maxCents = location.coinsprintermax or maxCents
                end
            end

            return tonumber(chance), tonumber(minCents), tonumber(maxCents)
        end
    end
end
