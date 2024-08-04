require "BuildingObjects/ISBuildingObject"

-- this class extend ISBuildingObject, it's a class to help you drag around/place an item in the world
ISPhunMartShop = ISBuildingObject:derive("ISPhunMartShop");
-- list of our shops in the world

local sprites = {
    goodPhoods = {
        east = "phunmart_01_0",
        south = "phunmart_01_1"
    }
}

function ISPhunMartShop:create(x, y, z, north, sprite)
    print("===============> ISPhunMartShop:create ", tostring(x), tostring(y), tostring(z), tostring(north),
        tostring(sprite))
    local cell = getWorld():getCell();
    self.sq = cell:getGridSquare(x, y, z);

    self.javaObject = IsoThumpable.new(cell, self.sq, sprite, north, self);

    -- add the item to the ground
    self.sq:AddSpecialObject(self.javaObject);
end

function ISPhunMartShop:onMouseLeftClick(x, y)
    print("lefteeee click")
end

function ISPhunMartShop:screate(square, type, direction)
    print(tostring(type), " d=", tostring(direction))
    type = type or "goodPhoods"
    direction = direction or "north"
    print("ISPhunMartShop:screate ", tostring(square), " t= ", tostring(type), " d=", tostring(direction))
    local cell = square:getCell();
    self.sq = square;
    local sprite = sprites[type][direction]
    self.javaObject = IsoThumpable.new(cell, self.sq, sprite, false, {});
    self.sq:AddSpecialObject(self.javaObject);
    self.javaObject:transmitCompleteItemToClients()

    return self.javaObject;
end

function ISPhunMartShop:new(type)
    print("===============> ISPhunMartShop:new ", type)

    local sprite = sprites[type].default
    local north = sprites[type].north

    -- OOP stuff
    -- we create an item (o), and return it
    local o = {};
    setmetatable(o, self);
    self.__index = self;
    o:init();
    -- the number of sprites can be up to 4, one for each direction, you ALWAYS need at least 2 sprites, south (Sprite) and north (NorthSprite)
    -- here we're not gonna be able to rotate our building (it's a barrel, so every face are the same), so we set that the south sprite = north sprite
    o:setSprite(sprite);
    o:setNorthSprite(sprite);
    o.name = "PhunMartShop";
    o.shopType = type;
    o.dismantable = false;
    -- you can't barricade it
    o.canBarricade = false;
    -- the item will block all the square where it placed (not like a wall for example)
    o.blockAllTheSquare = true;
    return o;
end

-- our barrel can be placed on this square ?
-- this function is called everytime you move the mouse over a grid square, you can for example not allow building inside house..
function ISPhunMartShop:isValid(square)
    print("===============> ISPhunMartShop:isValid")
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

-- called after render the ghost objects
-- the ISBuildingObject only render 1 sprite (north, south...), for example for stairs I can render the 2 others tile for stairs here
-- if I return false, the ghost render will be in red and I couldn't build the item
function ISPhunMartShop:render(x, y, z, square)
    print("===============> ISPhunMartShop:render")
    ISBuildingObject.render(self, x, y, z, square)
end

Events.OnObjectAdded.Add(function(object)
    print(tostring(object))
end)
