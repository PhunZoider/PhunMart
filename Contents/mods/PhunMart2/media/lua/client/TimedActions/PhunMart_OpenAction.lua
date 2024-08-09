require "TimedActions/ISBaseTimedAction"
local PM = PhunMart
PhunMart_OpenAction = ISBaseTimedAction:derive("PhunMart_OpenAction");
local PhunMart = PhunMart

function PhunMart_OpenAction:isValid()
    return not self.shopObj.lockedBy or self.shopObj.lockedBy == self.character:getUsername()
end

function PhunMart_OpenAction:waitToStart()
    self.character:faceLocation(self.shopObj.location.x, self.shopObj.location.y)
    return self.character:shouldBeTurning()
end

function PhunMart_OpenAction:update()
    self.character:faceThisObject(self.trailer)
end

function PhunMart_OpenAction:start()
    self:setActionAnim("Loot")
    self.character:SetVariable("LootPosition", "Mid")
    -- sendClientCommand(self.character, PhunMart.name, PhunMart.commands.requestShop, {
    --     id = self.machine.shopObj.id,
    --     location = self.machine.shopObj.location
    -- })
end

function PhunMart_OpenAction:stop()
    ISBaseTimedAction.stop(self);
end

function PhunMart_OpenAction:perform()
    ISBaseTimedAction.perform(self);
end

function PhunMart_OpenAction:new(character, shopObj, time)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    o.character = character;
    o.shopObj = shopObj;
    o.stopOnWalk = true;
    o.stopOnRun = true;
    o.maxTime = time;
    if o.character:isTimedActionInstant() then
        o.maxTime = 1;
    end
    return o;
end

local function getOpeningPositions(playerObj, shopObj)

    local front = {
        x = shopObj.location.x,
        y = shopObj.location.y,
        z = shopObj.location.z
    }

    local squares = {}
    local px = playerObj:getSquare():getX()
    local py = playerObj:getSquare():getY()
    -- get front square
    if shopObj.direction == "north" then
        table.insert(squares, {
            x = front.x,
            y = front.y - 1,
            z = front.z
        })
        table.insert(squares, {
            x = front.x - 1,
            y = front.y - 1,
            z = front.z
        })
        table.insert(squares, {
            x = front.x + 1,
            y = front.y - 1,
            z = front.z
        })
    elseif shopObj.direction == "west" then
        table.insert(squares, {
            x = front.x - 1,
            y = front.y,
            z = front.z
        })
        table.insert(squares, {
            x = front.x - 1,
            y = front.y - 1,
            z = front.z
        })
        table.insert(squares, {
            x = front.x - 1,
            y = front.y + 1,
            z = front.z
        })
    elseif shopObj.direction == "east" then
        table.insert(squares, {
            x = front.x + 1,
            y = front.y,
            z = front.z
        })
        table.insert(squares, {
            x = front.x + 1,
            y = front.y - 1,
            z = front.z
        })
        table.insert(squares, {
            x = front.x + 1,
            y = front.y + 1,
            z = front.z
        })
    else
        table.insert(squares, {
            x = front.x,
            y = front.y + 1,
            z = front.z
        })
        table.insert(squares, {
            x = front.x - 1,
            y = front.y + 1,
            z = front.z
        })
        table.insert(squares, {
            x = front.x + 1,
            y = front.y + 1,
            z = front.z
        })
    end

    for i = 1, #squares do
        squares[i].distance = math.sqrt((squares[i].x - px) ^ 2 + (squares[i].y - py) ^ 2)
    end

    table.sort(squares, function(a, b)
        return a.distance < b.distance
    end)

    return squares

end

function PhunMart_OpenAction:openShop(playerObj, shopObj)

    if shopObj.lockedBy and shopObj.lockedBy ~= playerObj:getUsername() then
        playerObj:Say("Shop is being used by " .. shopObj.lockedBy)
        return
    end

    -- get the squares we can open from
    local squares = getOpeningPositions(playerObj, shopObj)
    local square = nil
    local pSquare = playerObj:getSquare()
    -- grab the first free one
    for i = 1, #squares do
        local s = getSquare(squares[i].x, squares[i].y, squares[i].z)
        if pSquare == s or s:isFree(true) then
            square = s
            break
        end
    end

    -- if there is no free square then we can't open the shop
    if not square then
        playerObj:Say("Cannot get to shop to open it")
        return
    end

    -- refresh shop
    sendClientCommand(playerObj, PM.name, PM.commands.requestShop, {
        id = shopObj.id,
        location = shopObj.location
    })

    -- walk to shop
    local action = ISWalkToTimedAction:new(playerObj, square)
    local open = PhunMart_OpenAction:new(playerObj, shopObj, 15)
    local show = PhunMart_ShowAction:new(playerObj, shopObj)

    ISTimedActionQueue.add(action)
    ISTimedActionQueue.add(open)
    ISTimedActionQueue.add(show)
end
