require "TimedActions/ISBaseTimedAction"

PM_OpenAction = ISBaseTimedAction:derive("PM_OpenAction");
local PhunMart = PhunMart

function PM_OpenAction:isValid()
    return true
end

function PM_OpenAction:waitToStart()
    self.character:faceLocation(self.machine.x, self.machine.y)
    return self.character:shouldBeTurning()
end

function PM_OpenAction:update()
    self.character:faceThisObject(self.trailer)
end

function PM_OpenAction:start()
    self:setActionAnim("Loot")
    self.character:SetVariable("LootPosition", "Mid")
    sendClientCommand(self.character, PhunMart.name, PhunMart.commands.requestShop, {
        key = self.key
    })
end

function PM_OpenAction:stop()
    ISBaseTimedAction.stop(self);
end

function PM_OpenAction:perform()
    self.machine:setVisible(true)
    ISBaseTimedAction.perform(self);
end

function PM_OpenAction:new(character, machine, time)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    o.character = character;
    o.key = machine.id
    o.machine = machine;
    o.stopOnWalk = true;
    o.stopOnRun = true;
    o.maxTime = time;
    if o.character:isTimedActionInstant() then
        o.maxTime = 1;
    end
    return o;
end
