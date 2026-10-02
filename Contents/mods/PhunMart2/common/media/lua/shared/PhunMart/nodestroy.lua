require "TimedActions/ISDestroyStuffAction"
require "Moveables/ISMoveableSpriteProps"

local Core = PhunMart

-- Machines are protected from players unless the shop, or failing that the
-- ShopsMoveable / ShopsDestructible sandbox options, say otherwise. Admins are
-- never held to either. Everything here is shared so the server checks the
-- same rules when the action arrives, not just the client that started it.

local function isExempt(character)
    return Core.utils.isAdmin(character)
end

-- The key of a machine on this square that may not be destroyed, or nil.
local function protectedShopOn(square)
    local objects = square and square:getObjects()
    if not objects then
        return nil
    end
    for i = 0, objects:size() - 1 do
        local key = Core.shopKeyForObject(objects:get(i))
        if key and not Core.isShopDestructible(key) then
            return key
        end
    end
    return nil
end

-- A protected machine itself, or the floor it stands on. Taking the floor out
-- from under a machine upstairs drops it, which is destroying it by another
-- route.
local function isProtectedTarget(object)
    if not object then
        return false
    end
    local key = Core.shopKeyForObject(object)
    if key then
        return not Core.isShopDestructible(key)
    end
    local props = object.getProperties and object:getProperties()
    if props and props:has(IsoFlagType.solidfloor) then
        return protectedShopOn(object:getSquare()) ~= nil
    end
    return false
end

local oldDestroyStuffIsValid = ISDestroyStuffAction.isValid
function ISDestroyStuffAction:isValid()
    if not isExempt(self.character) and isProtectedTarget(self.item) then
        return false
    end
    return oldDestroyStuffIsValid(self)
end

-- Pickup. The client also strips IsMoveAble off protected sprites so the
-- option never shows (client/commands.lua, ConfigTiles), but that is only the
-- menu. This is the rule, and it runs wherever the action is validated.
local oldCanPickUpInternal = ISMoveableSpriteProps.canPickUpMoveableInternal
function ISMoveableSpriteProps:canPickUpMoveableInternal(_character, _square, _object, _isMulti)
    local key = self.spriteName and Core.spriteToShop[self.spriteName]
    if key and not isExempt(_character) and not Core.isShopMoveable(key) then
        return false
    end
    return oldCanPickUpInternal(self, _character, _square, _object, _isMulti)
end

-- The sledgehammer cursor lives under lua/server, which loads after shared, so
-- it does not exist yet when this file runs. Hooked per object rather than per
-- square so a protected machine drops out of the cycle while the wall behind
-- it can still be knocked down.
Events.OnGameStart.Add(function()
    if not ISDestroyCursor or ISDestroyCursor._phunMartHooked then
        return
    end
    ISDestroyCursor._phunMartHooked = true
    local oldCanDestroy = ISDestroyCursor.canDestroy
    function ISDestroyCursor:canDestroy(object)
        if not self.dismantle and not isExempt(self.character) and isProtectedTarget(object) then
            return false
        end
        return oldCanDestroy(self, object)
    end
end)
