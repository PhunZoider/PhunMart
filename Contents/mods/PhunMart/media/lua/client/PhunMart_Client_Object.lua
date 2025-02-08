if isServer() then
    return
end
require "Map/CGlobalObject"
local PM = PhunMart
CPhunMartObject = CGlobalObject:derive("CPhunMartObject")

function CPhunMartObject:new(luaSystem, globalObject)
    local o = CGlobalObject.new(self, luaSystem, globalObject)
    o.poop = true
    return o
end

function CPhunMartObject:fromModData(modData)
    for k, v in pairs(modData) do
        self[k] = v
    end
end

function CPhunMartObject:getObject()
    return self:getIsoObject()
end

function CPhunMartObject:restock()
    CPhunMartSystem.instance:restock(self)
end

function CPhunMartObject:reroll(target)
    CPhunMartSystem.instance:reroll(self, target)
end

function CPhunMartObject:open(playerObj)
    CPhunMartSystem.instance:requestLock(self, playerObj)
    PhunMart_OpenAction:openShop(playerObj, self)
end

function CPhunMartObject:insufficientPower()
    if self.requiresPower and SandboxVars.ElecShutModifier > -1 then
        local square = self:getSquare()
        local hasElectricity = square:haveElectricity()
        local nightsSurvived = GameTime:getInstance():getNightsSurvived()
        local elecShutModifier = getSandboxOptions():getOptionByName("ElecShutModifier"):getValue()
        return not (hasElectricity or nightsSurvived < elecShutModifier)
    end
    return false
end
