require "PhunMart_Core"
local PhunMart = PhunMart

-- Events.OnLoadedTileDefinitions.Add(function(manager)
--     -- prevent snack and pop vending machines from being movable or scrappable

--     for i, v in ipairs(PhunMart.shopSprites) do
--         local sprite = manager:getSprite(v)
--         sprite:getProperties():UnSet("IsMoveAble");
--         sprite:getProperties():UnSet("CanScrap");
--         sprite:getProperties():UnSet("container");
--         sprite:getProperties():UnSet("ContainerCapacity");
--         -- sprite:getProperties():Set("ContainerCapacity", "0");
--         sprite:getProperties():UnSet(IsoFlagType.container);
--         -- local properties = sprite:getProperties():getPropertyNames()
--     end
-- end)

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
        for i, v in ipairs(PhunMart.shopSprites) do
            if v == sprite:getName() then
                object:setHighlighted(true, false);
                _lastHighlighted = object
                break
            end
        end
    end
end)

Events.OnObjectRightMouseButtonUp.Add(function(object, x, y)
    if _lastHighlighted then
        _lastHighlighted:setHighlighted(false, false);
    end
    if object then
        local sprite = object:getSprite();
        for i, v in ipairs(PhunMart.shopSprites) do
            if v == sprite:getName() then
                object:setHighlighted(true, false);
                _lastHighlighted = object
                break
            end
        end
    end
end)
