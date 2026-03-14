if isClient() then
    return
end
local Core = PhunMart

function Core.getCoinChance(zed)
    local loot = Core.loot or {}
    local chance = loot.chance or 0.30 -- probability a zombie carries change
    local minCents = loot.minCents or 5
    local maxCents = loot.maxCents or 75

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
            order = 200
        }
        PZ.fields.coinmax = {
            label = "IGUI_PhunMart_CoinMaxCents",
            type = "int",
            tooltip = "IGUI_PhunMart_CoinMaxCents_tooltip",
            group = "PhunMart",
            order = 200
        }
        if activeMods:contains("phunsprinters2") or activeMods:contains("phunsprinters2test") then

            checkSprinters = true
            PZ.fields.coinsprinterchance = {
                label = "IGUI_PhunMart_CoinSprinterDropChance",
                type = "int",
                tooltip = "IGUI_PhunMart_CoinSprinterDropChance_tooltip",
                group = "PhunMart",
                order = 200
            }
            PZ.fields.coinsprintermin = {
                label = "IGUI_PhunMart_CoinSprinterMinCents",
                type = "int",
                tooltip = "IGUI_PhunMart_CoinSprinterMinCents_tooltip",
                group = "PhunMart",
                order = 200
            }
            PZ.fields.coinsprintermax = {
                label = "IGUI_PhunMart_CoinSprinterMaxCents",
                type = "int",
                tooltip = "IGUI_PhunMart_CoinSprinterMaxCents_tooltip",
                group = "PhunMart",
                order = 200
            }
        end

        Core.getCoinChance = function(zed)

            local location = PZ.getLocation(zed:getX(), zed:getY())
            local isSprinter = false

            local loot = Core.loot or {
                chance = location.coinchance or 30, -- probability a zombie carries change
                minCents = location.coinmin or 5,
                maxCents = location.coinmax or 75
            }

            local chance = loot.chance
            local minCents = loot.minCents
            local maxCents = loot.maxCents

            if checkSprinters then
                if (zed:getModData().PhunSprinters or {}).sprinter then
                    chance = location.coinsprinterchance or chance
                    minCents = location.coinsprintermin or minCents
                    maxCents = location.coinsprintermax or maxCents
                end
            end

            return tonumber(chance * 0.01), tonumber(minCents), tonumber(maxCents)
        end
    end
end
