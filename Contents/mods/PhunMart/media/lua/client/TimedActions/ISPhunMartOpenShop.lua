require "TimedActions/ISBaseTimedAction"
local PhunMart = PhunMart
ISPhunMartOpenShop = ISBaseTimedAction:derive("ISPhunMartOpenShop");

function ISPhunMartOpenShop:isValid()
    return true
end

function ISPhunMartOpenShop:waitToStart()
    self.character:faceLocation(self.machine.data.location.x, self.machine.data.location.y)
    return self.character:shouldBeTurning()
end

function ISPhunMartOpenShop:update()
    self.character:faceThisObject(self.trailer)
end

function ISPhunMartOpenShop:start()
    self:setActionAnim("Loot")
    self.character:SetVariable("LootPosition", "Mid")
    sendClientCommand(self.character, PhunMart.name, PhunMart.commands.requestShop, {
        key = self.key
    })
end

function ISPhunMartOpenShop:stop()
    ISBaseTimedAction.stop(self);
end

function ISPhunMartOpenShop:perform()
    PhunMartShowinstance(self.character)
    ISBaseTimedAction.perform(self);
end

function ISPhunMartOpenShop:new(character, machine, time)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    o.character = character;
    o.key = PhunMart:getKey(machine.data.location)
    o.machine = machine;
    o.stopOnWalk = true;
    o.stopOnRun = true;
    o.maxTime = time;
    if o.character:isTimedActionInstant() then
        o.maxTime = 1;
    end
    return o;
end
