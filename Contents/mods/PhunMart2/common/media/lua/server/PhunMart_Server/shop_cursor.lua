require "BuildingObjects/ISBuildingObject"

local Core = PhunMart
local objectName = "PhunMartCursor"
local Obj = ISBuildingObject:derive(objectName)
PhunMartCursor = Obj

function Obj:create(x, y, z, north, sprite)
    local cell = getWorld():getCell();
    self.sq = cell:getGridSquare(x, y, z);
    self.javaObject = IsoThumpable.new(cell, self.sq, sprite, north, self);
    buildUtil.setInfo(self.javaObject, self);
    buildUtil.consumeMaterial(self);
    self.javaObject:setMaxHealth(self:getHealth());
    self.javaObject:setHealth(self.javaObject:getMaxHealth());
    self.javaObject:setBreakSound("BreakObject");
    self.sq:AddSpecialObject(self.javaObject);
    self.javaObject:setSpecialTooltip(true)
    self.javaObject:transmitCompleteItemToServer();
    triggerEvent("OnObjectAdded", self.javaObject)
end

function Obj:new(player, sprite, waterMax)

    local o = {};
    setmetatable(o, self);
    self.__index = self;
    o:init();
    -- the number of sprites can be up to 4, one for each direction, you ALWAYS need at least 2 sprites, south (Sprite) and north (NorthSprite)
    -- here we're not gonna be able to rotate our building (it's a barrel, so every face are the same), so we set that the south sprite = north sprite
    o:setSprite(sprite);
    o:setNorthSprite(sprite);
    o.name = objectName;
    o.player = player;
    return o;
end

function Obj:getHealth()
    return 200 + buildUtil.getWoodHealth(self);
end

function Obj:isValid(square)
    if not square then
        return false
    end
    if square:isSolid() or square:isSolidTrans() then
        return false
    end
    if square:HasStairs() then
        return false
    end
    if square:HasTree() then
        return false
    end
    if not square:getMovingObjects():isEmpty() then
        return false
    end
    if not square:TreatAsSolidFloor() then
        return false
    end
    if not self:haveMaterial(square) then
        return false
    end
    for i = 1, square:getObjects():size() do
        local obj = square:getObjects():get(i - 1)
        if self:getSprite() == obj:getTextureName() then
            return false
        end
    end
    if buildUtil.stairIsBlockingPlacement(square, true) then
        return false;
    end
    if square:isVehicleIntersecting() then
        return false
    end
    return true
end

function Obj:render(x, y, z, square)
    ISBuildingObject.render(self, x, y, z, square)
end
