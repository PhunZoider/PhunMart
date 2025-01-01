require "PhunMart/core"
local PM = PhunMart

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

Events.OnInitGlobalModData.Add(function()
    PM:ini()
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
        if PM:isPhunMartSprite(object) then
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
        if PM:isPhunMartSprite(object) then
            object:setHighlighted(true, false);
            _lastHighlighted = object
        end
    end
end)
