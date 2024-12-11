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
PhunMartUIAdminItemReceive = ISPanelJoypad:derive("PhunMartUIAdminItemReceive");
local UI = PhunMartUIAdminItemReceive

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

    self.receive = ISComboBox:new(padding, y, self:getWidth() - (padding * 2), FONT_HGT_MEDIUM, self, function()
        self:setSelection(self.receive.selected)
    end);
    self.receive:initialise()
    self:addChild(self.receive)

    y = y + self.receive.height + padding + HEADER_HGT

    self.tabPanel = ISTabPanel:new(x, y, self.width, self.height - y);
    self.tabPanel:initialise()
    self:addChild(self.tabPanel)

end

function UI:setSelection(selection)
    self.receive.selected = selection
    local opts = self.receive.options[self.receive.selected]
    local data = opts.data

end

function UI:setData(data)

    self.receive:clear()
    self.receive:addOption("")
    self.receive.selected = 1

    if not data or not data.receive then
        return
    end

    for i, v in ipairs(data.receive) do
        self.receive:addOptionWithData("Receipt #" .. tostring(i), v)
    end

    if #data.receive > 0 then
        self:setSelection(2)
    end

end

