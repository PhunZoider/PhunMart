if isServer() then
    return
end

require "Map/SGlobalObject"
require "PhunMart_Client/system"
local Core = PhunMart
local ClientSystem = Core.ClientSystem
Core.ClientObject = CGlobalObject:derive("CPhunMartObject")
local ClientObject = Core.ClientObject

function ClientObject:new(luaSystem, globalObject)
    local o = CGlobalObject.new(self, luaSystem, globalObject)
    return o
end

function ClientObject:fromModData(modData)
    for k, v in pairs(modData) do
        self[k] = v
    end
end

function ClientObject:getObject()
    return self:getIsoObject()
end

function ClientObject:restock(playerObj)
    ClientSystem.instance:restock(self, playerObj or getSpecificPlayer(0))
end

function ClientObject:reroll(target)
    ClientSystem.instance:reroll(self, target)
end

function ClientObject:getKey()
    return tostring(self.type) .. "-" .. self.x .. "-" .. self.y .. "-" .. self.z
end

function ClientObject:getFrontSquare()
    local front = {
        x = self.x,
        y = self.y,
        z = self.z
    }

    if self.facing == "N" or self.facing == IsoDirections.N then
        front.y = front.y - 1
    elseif self.facing == "W" or self.facing == IsoDirections.W then
        front.x = front.x - 1
    elseif self.facing == "S" or self.facing == IsoDirections.S then
        front.y = front.y + 1
    elseif self.facing == "E" or self.facing == IsoDirections.E then
        front.x = front.x + 1
    end

    return getSquare(front.x, front.y, front.z)

end

-- Called by the PZ engine when this object's modData is synced from the server.
-- Keeps the client object in step with server state (offers, lastRestock, etc.)
function ClientObject:stateFromIsoObject(isoObject)
    self:fromModData(isoObject:getModData())
end

-- Manual sync — call when you know the underlying IsoObject's modData may have changed.
function ClientObject:updateFromIsoObject()
    local iso = self:getIsoObject()
    if iso then
        self:stateFromIsoObject(iso)
    end
end
