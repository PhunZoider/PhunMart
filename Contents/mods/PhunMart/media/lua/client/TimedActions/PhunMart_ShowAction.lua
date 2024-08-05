require "TimedActions/ISBaseTimedAction"

PhunMart_ShowAction = ISBaseTimedAction:derive("PhunMart_ShowAction");
local PhunMart = PhunMart

function PhunMart_ShowAction:isValid()
    return true
end

function PhunMart_ShowAction:perform()
    ISBaseTimedAction.perform(self);
    PhunMartShopWindow.OnOpenPanel(self.character, self.shopObj)
end

function PhunMart_ShowAction:new(character, shopObj)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    o.character = character;
    o.shopObj = shopObj;
    o.maxTime = 1;
    return o;
end
