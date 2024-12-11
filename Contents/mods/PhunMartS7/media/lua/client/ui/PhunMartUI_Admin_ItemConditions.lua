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
PhunMartUIAdminItemConditions = ISPanelJoypad:derive("PhunMartUIAdminItemConditions");
local UI = PhunMartUIAdminItemConditions

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

    self.condition = ISComboBox:new(padding, y, self:getWidth() - (padding * 2), FONT_HGT_MEDIUM, self, function()
        self:setSelection(self.condition.selected)
    end);
    self.condition:initialise()
    self:addChild(self.condition)

    y = y + self.condition.height + padding + HEADER_HGT

    self.tabPanel = ISTabPanel:new(x, y, self.width, self.height - y);
    self.tabPanel:initialise()
    self:addChild(self.tabPanel)

    -- self.filters = PhunMartUIAdminPoolFilters:new(x, y, self.tabPanel:getWidth(),
    --     self.tabPanel:getHeight() - HEADER_HGT, {
    --         player = self.player
    --     });
    -- self.tabPanel:addView("Filters", self.filters);

    -- self.keys = PhunMartUIAdminPoolKeys:new(x, y, self.tabPanel:getWidth(), self.tabPanel:getHeight() - HEADER_HGT, {
    --     player = self.player
    -- });
    -- self.tabPanel:addView("Keys", self.keys);

end

function UI:setSelection(selection)
    self.pool.selected = selection
    local opts = self.pool.options[self.pool.selected]
    local data = opts.data

end

function UI:setData(data)

    self.condition:clear()
    self.condition:addOption(" ")
    self.condition.selected = 1

    if not data or not data.condition or not data.condition.items then
        return
    end

    for i, v in ipairs(data.condition.items) do
        self.pool:addOptionWithData("Pool #" .. tostring(i), v)
    end

    if #data.condition.items > 0 then
        self:setSelection(2)
    end

end

function UI:setItems(items)
    self.items = items
end
