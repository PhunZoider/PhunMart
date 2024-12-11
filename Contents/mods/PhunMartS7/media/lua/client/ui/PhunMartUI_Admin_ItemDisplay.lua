if not isClient() then
    return
end

local sandbox = SandboxVars.PhunMart

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)
local FONT_HGT_LARGE = getTextManager():getFontHeight(UIFont.Large)
local FONT_SCALE = FONT_HGT_SMALL / 14
local HEADER_HGT = FONT_HGT_MEDIUM + 2 * 2

local PM = PhunMart
PhunMartUIAdminItemDisplay = ISPanelJoypad:derive("PhunMartUIAdminItemDisplay");
local UI = PhunMartUIAdminItemDisplay

function UI:new(x, y, width, height, options)
    local opts = options or {}
    local o = ISPanelJoypad:new(x, y, width, height);
    setmetatable(o, self);
    o.player = opts.player or getPlayer()
    o.playerIndex = o.player:getPlayerNum()
    self.instance = o;
    return o;
end

function UI:createChildren()
    ISPanelJoypad.createChildren(self)

    local padding = 10
    local x = 0
    local y = HEADER_HGT - 1

end

function UI:setData(data)

    if not data or not data.display then
        return
    end

end

