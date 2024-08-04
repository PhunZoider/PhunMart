require "Map/CGlobalObject"

CPhunMartObject = CGlobalObject:derive("CPhunMartObject")

function CPhunMartObject:new(luaSystem, globalObject)
    local o = CGlobalObject.new(self, luaSystem, globalObject)
    return o
end

function CPhunMartObject:getObject()
    print("CPhunMartObject:getObject")
    return self:getIsoObject()
end

function CPhunMartObject:restock()
    CPhunMartSystem.instance:restock(self)
end
