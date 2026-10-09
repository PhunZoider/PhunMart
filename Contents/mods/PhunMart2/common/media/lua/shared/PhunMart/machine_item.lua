require "Moveables/ISMoveableSpriteProps"

local Core = PhunMart

-- A machine as an item, carrying which shop it is.
--
-- On the generic tiles the sprite names no shop, so a machine's type has to
-- travel with it. Vanilla moves a plain IsoObject's modData only as far as
-- modData.movableData when it is picked up, and drops the rest. Going the other
-- way, placing an item that has no movableData copies every key of the item's
-- modData onto the object it makes, and does it before OnObjectAdded fires
-- (ISMoveableSpriteProps:placeMoveableInternal). So a type written on the item
-- as `type` lands on the machine exactly where Core.shopKeyForObject reads it,
-- in time for the server to register the machine as that shop.

--- Mark `item` as a machine of shop `shopKey`.
---
--- Not named after the shop: a moveable's name always comes from its tile
--- (GroupName + CustomName, translated through Translate/EN/Moveables.json), and
--- Moveable.load reads the tile again, so a name set here would not outlive a
--- save. On the generic tiles that name is "Vending Machine".
function Core.stampMachineItem(item, shopKey)
    item:getModData().type = shopKey
end

--- A fresh machine item for `shopKey`, facing south, or nil when the shop is
--- unknown or has no tiles. For shops with no scripted item of their own
--- (PhunMart_Items.txt), which is every shop standing on the generic tiles.
function Core.newMachineItem(shopKey)
    local def = Core.shops and Core.shops[shopKey]
    local sprite = def and def.sprites and (def.sprites[2] or def.sprites[1])
    if not sprite then
        return nil
    end
    local item = instanceItem("Moveables.Moveable")
    if not item then
        return nil
    end
    item:ReadFromWorldSprite(sprite)
    Core.stampMachineItem(item, shopKey)
    return item
end

-- Picking a machine up: the shop is read before vanilla takes the machine off
-- the square, and written on the item vanilla hands back, before the caller puts
-- it in an inventory.
--
-- Returns exactly one value, as vanilla does. Multi-tile furniture (beds,
-- shelves) is collected with table.insert(items, self:pickUpMoveableInternal(...)),
-- and a second return value, even nil, turns that into the three-argument
-- insert, which takes the item as a position and throws.
local oldPickUpInternal = ISMoveableSpriteProps.pickUpMoveableInternal
function ISMoveableSpriteProps:pickUpMoveableInternal(_character, _square, _object, ...)
    local shopKey = Core.shopKeyForObject(_object)
    local item = oldPickUpInternal(self, _character, _square, _object, ...)
    if shopKey and item and item.getModData then
        Core.stampMachineItem(item, shopKey)
    end
    return item
end
