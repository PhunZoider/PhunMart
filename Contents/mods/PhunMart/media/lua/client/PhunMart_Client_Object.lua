require "Map/CGlobalObject"

CPhunMartObject = CGlobalObject:derive("CPhunMartObject")
local inc = 0
function CPhunMartObject:new(luaSystem, globalObject)
    inc = inc + 1
    print("+++++++++++CPhunMartObject:new ", tostring(inc))
    local o = CGlobalObject.new(self, luaSystem, globalObject)

    return o
end

function CPhunMartObject:getObject()
    print("CPhunMartObject:getObject")
    return self:getIsoObject()
end

function CPhunMartObject:getTabKey()
    local keys = {}
    for k, v in pairs(self.tabs) do
        table.insert(keys, k)
    end
    return table.concat(keys, ",")
end

function CPhunMartObject:restock()
    CPhunMartSystem.instance:restock(self)
end
