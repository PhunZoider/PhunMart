-- PhunMart2/conditions_runtime.lua
require("PhunMart2/core")
local Core = PhunMart

Core.playerAdapters = {}

local function getAdapter(player)

    local PA = {
        player = player
    }

    PA.getPerkLevel = function(self, perkName)
        local perk = Perks[perkName]
        if perk then
            return self.player:getPerkLevel(perk)
        else
            print("PhunMart Error: No perk with name " .. perkName)
            return 0
        end
    end

    PA.getPerkBoost = function(self, perkName)
        local perk = Perks[perkName]
        if perk then
            return self.player:getXp():getPerkBoost(perkName)
        else
            print("PhunMart Error: No perk with name " .. perkName)
            return 0
        end
    end

    PA.hasTrait = function(self, traitName)
        return self.player:HasTrait(traitName)
    end

    PA.getProfession = function(self)
        local prof = self.player:getDescriptor():getProfession()
        return prof and prof:getType() or "unemployed"
    end

    PA.countItem = function(self, fullType)
        return self.player:getInventory():getItemCountRecurse(fullType)
    end

    PA.getWorldAgeHours = function(self)
        return getGameTime():getWorldAgeHours()
    end

    PA.getUsername = function(self)
        return self.player:getUsername()
    end

    function PA:getCharacterName()
        return tostring(self.player:getDescriptor():getForename() .. " " .. self.player:getDescriptor():getSurname())
    end

    function PA:nowSeconds()
        return getTimestamp()
    end

    return PA

end

Core.getPlayerAdapter = function(player)
    if not player then
        return nil
    end
    if not Core.playerAdapters[player:getUsername()] then
        local adapter = getAdapter(player)
        Core.playerAdapters[player:getUsername()] = adapter
    end
    return Core.playerAdapters[player:getUsername()]
end

