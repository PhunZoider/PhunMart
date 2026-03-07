local Core = PhunMart
local tools = require "PhunMart2/ux/tools"
local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)
local FONT_HGT_LARGE = getTextManager():getFontHeight(UIFont.Large)
local FONT_SCALE = FONT_HGT_SMALL / 14
local HEADER_HGT = FONT_HGT_MEDIUM + 2 * 2
local profileName = "PhunMartUIPoolsGroup"
Core.ui.pools_group = ISPanelJoypad:derive(profileName);
local UI = Core.ui.pools_group
local instances = {}

function UI.OnOpenPanel(playerObj, data)
    local playerIndex = playerObj:getPlayerNum()
    local instance = instances[playerIndex]
    if not instance then
        local core = getCore()
        local width = 450 * FONT_SCALE
        local height = 400 * FONT_SCALE
        local x = (core:getScreenWidth() - width) / 2
        local y = (core:getScreenHeight() - height) / 2
        instances[playerIndex] = UI:new(x, y, width, height, playerObj, playerIndex);
        instance = instances[playerIndex]
        instance:initialise();
    end
    instance.data = data or {}
    instance:refreshAll()
    instance:addToUIManager();
    instance:setVisible(true);
    instance:ensureVisible()
    return instance;
end
function UI:new(x, y, width, height, data)
    local o = {};
    o = ISPanelJoypad:new(x, y, width, height, data.player);
    setmetatable(o, self);
    self.__index = self;
    o.variableColor = {
        r = 0.9,
        g = 0.55,
        b = 0.1,
        a = 1
    };
    o.backgroundColor = {
        r = 0,
        g = 0,
        b = 0,
        a = 0.8
    };
    o.buttonBorderColor = {
        r = 0.7,
        g = 0.7,
        b = 0.7,
        a = 1
    };
    o.data = {}
    o.listType = data.type or nil
    o.blacklist = data.blacklist == true
    o.moveWithMouse = false;
    o.anchorRight = true
    o.anchorBottom = true
    o.player = data.player
    o.playerIndex = o.player:getPlayerNum()
    o.zOffsetLargeFont = 25;
    o.zOffsetMediumFont = 20;
    o.zOffsetSmallFont = 6;
    o:setWantKeyEvents(true)
    return o;
end
function UI:createChildren()
    ISPanelJoypad.createChildren(self);
    local padding = 10
    local x = padding
    local y = 20
    local w = self.width - x - padding
    local h = self.height - y - HEADER_HGT - padding
    self.tabPanel = ISTabPanel:new(x, y, w, h);
    self.tabPanel:initialise()
    self.tabPanel:setAnchorLeft(true)
    self.tabPanel:setAnchorRight(true)
    self.tabPanel:setAnchorTop(true)
    self.tabPanel:setAnchorBottom(true)
    self:addChild(self.tabPanel)

    self.categories = Core.ui.pools_cats:new(0, y, w, self.tabPanel.height, {
        player = self.player,
        type = self.listType
    });
    self.exclusions = Core.ui.pools_items:new(0, y, w, self.tabPanel.height, {
        player = self.player,
        type = self.listType
    });
    if self.blacklist ~= true then
        self.inclusions = Core.ui.pools_items:new(0, y, w, self.tabPanel.height, {
            player = self.player,
            type = self.listType
        });
    end
    self.tabPanel:addView("Categories", self.categories)
    if self.blacklist ~= true then
        self.tabPanel:addView("Inclusions", self.inclusions)
    end
    self.tabPanel:addView("Exclusions", self.exclusions)

end
function UI:prerender()
    ISPanelJoypad.prerender(self)

    local exclusions = self.exclusions
    local inclusions = self.inclusions
    local categories = self.categories

    exclusions:setWidth(exclusions.parent.width)
    exclusions:setHeight(exclusions.parent.height)

    if inclusions then
        inclusions:setWidth(inclusions.parent.width)
        inclusions:setHeight(inclusions.parent.height)
    end

    categories:setWidth(categories.parent.width)
    categories:setHeight(categories.parent.height)

end
function UI:getSelected()
    local data = self.data
    local selected = {
        categories = self.categories.data.selected,
        include = self.blacklist ~= true and self.inclusions.data.selected or nil,
        exclude = self.exclusions.data.selected
    }
    return selected
end
function UI:setData(data)
    self.data = data
    self:refreshAll()
end
function UI:refreshAll()
    self.categories:setData(self.data.categories)
    if self.blacklist ~= true then
        self.inclusions:setData(self.data.include)
    end
    self.exclusions:setData(self.data.exclude)
end
