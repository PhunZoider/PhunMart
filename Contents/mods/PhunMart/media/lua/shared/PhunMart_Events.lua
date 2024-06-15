require "PhunMart_Core"
local PhunMart = PhunMart

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

Events.OnInitGlobalModData.Add(function()
    PhunMart:ini()
end)

Events.OnGameStart.Add(function()
    AcceptItemFunction.PhunMart = function(container, item)
        return false
    end
end)
