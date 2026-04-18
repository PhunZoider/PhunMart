local Core = PhunMart

local function squareHasShopSprite(square)
    if not square then
        return false
    end
    local objects = square:getObjects()
    if not objects then
        return false
    end
    for i = 0, objects:size() - 1 do
        local iso = objects:get(i)
        local sprite = iso and iso:getSprite()
        if sprite and sprite.getProperties then
            local cn = sprite:getProperties():get("CustomName")
            if cn and Core.shops and Core.shops[cn] then
                return true
            end
        end
    end
    return false
end

local oldDestroyStuffAction = ISDestroyStuffAction["isValid"]
ISDestroyStuffAction["isValid"] = function(self)
    local target = self.item
    local square = target and target.getSquare and target:getSquare()
    if not square and self.character then
        square = self.character:getSquare()
    end
    if squareHasShopSprite(square) then
        return false
    end
    return oldDestroyStuffAction(self)
end

if ISDestroyCursor then
    local oldISDestroyIsValid = ISDestroyCursor.isValid
    function ISDestroyCursor:isValid(square)
        if squareHasShopSprite(square) then
            return false
        end
        return oldISDestroyIsValid(self, square)
    end
end
