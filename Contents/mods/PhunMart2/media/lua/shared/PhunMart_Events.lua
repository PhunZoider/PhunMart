require "PhunMart_Core"
local PhunMart = PhunMart

<<<<<<< HEAD:Contents/mods/PhunMart2/media/lua/shared/PhunMart_Events.lua
-- Events.OnLoadedTileDefinitions.Add(function(manager)
--     -- prevent snack and pop vending machines from being movable or scrappable

--     local sprites = {}
--     for i = 1, 3 do
--         for j = 0, 63 do
--             table.insert(sprites, "phunmart_0" .. i .. "_" .. j)
--         end
--     end

--     for i, v in ipairs(sprites) do
--         local sprite = manager:getSprite(v)
--         -- sprite:getProperties():Set("HasLightOnSprite", "");
--     end
-- end)
=======
Events.OnLoadedTileDefinitions.Add(function(manager)
    -- prevent snack and pop vending machines from being movable or scrappable
    for i, v in ipairs(PhunMart.shopSprites) do
        local sprite = manager:getSprite(v)
        sprite:getProperties():UnSet("IsMoveAble");
        sprite:getProperties():UnSet("CanScrap");
        sprite:getProperties():UnSet("container");
        sprite:getProperties():UnSet("ContainerCapacity");
        -- sprite:getProperties():Set("ContainerCapacity", "0");
        sprite:getProperties():UnSet(IsoFlagType.container);
        -- local properties = sprite:getProperties():getPropertyNames()
    end
end)
>>>>>>> main:Contents/mods/PhunMart/media/lua/shared/PhunMart_Events.lua

Events.OnInitGlobalModData.Add(function()
    PhunMart:ini()
end)

local function pickSquare(x, y)
    local playerIndex = self.gameState:fromLua0("getPlayerIndex")
    local z = self.gameState:fromLua0("getZ")
    local worldX = screenToIsoX(playerIndex, self:getMouseX(), self:getMouseY(), z)
    local worldY = screenToIsoY(playerIndex, self:getMouseX(), self:getMouseY(), z)
    return getCell():getGridSquare(worldX, worldY, z), worldX, worldY, z
end

local _lastHighlighted = nil

Events.OnObjectLeftMouseButtonUp.Add(function(object, x, y)
    if _lastHighlighted then
        _lastHighlighted:setHighlighted(false, false);
    end
    if object then
        local sprite = object:getSprite();
        if PhunMart.spriteMap[sprite:getName()] then
            object:setHighlighted(true, false);
            _lastHighlighted = object
        end
    end
end)

Events.OnObjectRightMouseButtonUp.Add(function(object, x, y)
    if _lastHighlighted then
        _lastHighlighted:setHighlighted(false, false);
    end
    if object then
        local sprite = object:getSprite();
        if PhunMart.spriteMap[sprite:getName()] then
            object:setHighlighted(true, false);
            _lastHighlighted = object
        end
    end
end)
