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
PhunMartUIAdminPools = ISPanelJoypad:derive("PhunMartUIAdminPools");
local UI = PhunMartUIAdminPools

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

    self.pool = ISComboBox:new(padding, y, self:getWidth() - (padding * 2), FONT_HGT_MEDIUM, self, function()
        self:setSelection(self.pool.selected)
    end);
    self.pool:initialise()
    self:addChild(self.pool)

    y = y + self.pool.height + padding + HEADER_HGT

    self.tabPanel = ISTabPanel:new(x, y, self.width, self.height - self.pool.height - padding);
    self.tabPanel:initialise()
    self:addChild(self.tabPanel)

    self.keys = PhunMartUIAdminPoolKeys:new(x, y, self.tabPanel:getWidth(), self.tabPanel:getHeight() - HEADER_HGT, {
        player = self.player
    });
    self.tabPanel:addView("Keys", self.keys);

    self.filters = PhunMartUIAdminPoolFilters:new(x, y, self.tabPanel:getWidth(),
        self.tabPanel:getHeight() - HEADER_HGT, {
            player = self.player
        });
    self.tabPanel:addView("Filters", self.filters);

end

function UI:setSelection(selection)
    self.pool.selected = selection
    local opts = self.pool.options[self.pool.selected]
    local data = opts.data
    self.filters:setData(data)
    self.keys:setData(data, self.items)

end

function UI:setData(data)

    self.pool:clear()
    self.pool:addOption("")
    self.pool.selected = 1
    if not data or not data.pools or not data.pools.items then
        self.filters:setData(nil)
        self.keys:setData(nil, nil)
        return
    end

    for i, v in ipairs(data.pools.items) do
        self.pool:addOptionWithData("Pool #" .. tostring(i), v)
    end
    if #data.pools.items > 0 then
        self:setSelection(2)
    end
end

function UI:setItems(items)
    self.items = items
end
