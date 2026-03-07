if isServer() then
    return
end
require "TimedActions/ISBaseTimedAction"
local Core = PhunMart
Core.actions.openShop = ISBaseTimedAction:derive("PhunMart_Actions_OpenShop");
local action = Core.actions.openShop

function action:isValidStart()
    local txt = nil
    if self.shopObj.powered then
        if not self.shopObj:getSquare():haveElectricity() and SandboxVars.ElecShutModifier > -1 and
            GameTime:getInstance():getNightsSurvived() > SandboxVars.ElecShutModifier then
            txt = getText("IGUI_PhunMart_Open_X_nopower_tooltip", getText("IGUI_PhunMart_Shop_" .. self.shopObj.type))
        end
    end

    if txt then
        self.character:Say(txt)
        return false
    end

    return true
end

function action:isValid()
    return true
end

function action:waitToStart()

    self.character:faceLocation(self.shopObj.x, self.shopObj.y)
    return self.character:isTurning() or self.character:shouldBeTurning()

end

function action:update()

    -- fires every tick (I think). Once complete, we will start checking to see if we have recieved inventory
    -- from the server. If not, we will keep ticking until we do

    if self:getJobDelta() == 1 then
        self.isReady = true
    end

    if self.isReady then
        self.data = Core:getInstanceInventory(self.shopObj:getKey())
        if not self.data then
            self:resetJobDelta()
            return true
        else
            self.delta = 1
        end
    end
end

function action:start()
    self:setActionAnim("Loot")
    self.character:SetVariable("LootPosition", "Mid")
    -- clear any local cache of the instance inventory
    Core:resetInstanceInventory(self.shopObj:getKey())
    -- request a lock and the inventory
    Core.ClientSystem.instance:openShop(self.character, self.shopObj)

end

function action:stop()
    ISBaseTimedAction.stop(self);

end

function action:perform()
    Core.ui.client.shop.open(self.character, self.shopObj)
    ISBaseTimedAction.perform(self);
end

function action:new(character, shopObj, time)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    o.character = character;
    o.shopObj = shopObj;
    o.stopOnWalk = true;
    o.stopOnRun = true;
    o.maxTime = time or 15;
    if o.character:isTimedActionInstant() then
        o.maxTime = 1;
    end
    return o;
end

local function getOpeningPositions(playerObj, shopObj)

    local front = {
        x = shopObj.x,
        y = shopObj.y,
        z = shopObj.z
    }

    local squares = {}
    local px = playerObj:getSquare():getX()
    local py = playerObj:getSquare():getY()
    -- get front square
    if shopObj.direction == "N" then
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
    elseif shopObj.direction == "W" then
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
    elseif shopObj.direction == "E" then
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

function action:open(playerObj, shopObj)

    -- get the squares we can open from
    local squares = getOpeningPositions(playerObj, shopObj)
    local square = nil
    local pSquare = playerObj:getSquare()
    -- grab the first free one
    for i = 1, #squares do
        local s = getSquare(squares[i].x, squares[i].y, squares[i].z)
        if s then
            if pSquare == s or s:isFree(true) then
                square = s
                break
            end
        end
    end

    -- if there is no free square then we can't open the shop
    if not square then
        playerObj:Say("Cannot get to shop to open it")
        return
    end

    -- refresh shop
    -- sendClientCommand(playerObj, Core.name, Core.commands.requestShop, {
    --     id = shopObj.id,
    --     location = shopObj.location
    -- })

    ISTimedActionQueue.add(shopObj.getFrontSquare())
    ISTimedActionQueue.add(Core.actions.doopen:new(playerObj, shopObj, 15))

end
