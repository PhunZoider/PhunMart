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
    if self.requiresPower then
        if not self:getSquare():haveElectricity() then
            if SandboxVars.ElecShutModifier > -1 and GameTime:getInstance():getNightsSurvived() >
                SandboxVars.ElecShutModifier then
                return true
            end
        end
    end
    return false
end
