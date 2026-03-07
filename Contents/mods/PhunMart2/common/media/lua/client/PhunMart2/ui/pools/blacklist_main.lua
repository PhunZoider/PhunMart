if isServer() then
    return
end

require "ISUI/ISCollapsableWindowJoypad"
local Core = PhunMart

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)
local FONT_HGT_LARGE = getTextManager():getFontHeight(UIFont.Large)

local FONT_SCALE = FONT_HGT_SMALL / 14
local HEADER_HGT = FONT_HGT_MEDIUM + 2 * 2

local profileName = "PhunMartUIPoolsBlacklistMain"
PhunMartUIPoolsBlacklistMain = ISCollapsableWindowJoypad:derive(profileName);
local UI = PhunMartUIPoolsBlacklistMain
local instances = {}
Core.ui.pools_blacklist_main = UI

function UI.OnOpenPanel(playerObj, blacklist)

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

        ISLayoutManager.RegisterWindow(profileName, UI, instance)
    end

    instance.data = blacklist or {}

    instance:addToUIManager();
    instance:setVisible(true);
    instance:ensureVisible()
    instance:refreshAll()
    return instance;

end

function UI:new(x, y, width, height, player, playerIndex)
    local o = {};
    o = ISCollapsableWindowJoypad:new(x, y, width, height, player);
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
    o.controls = {}
    o.data = {}
    o.moveWithMouse = false;
    o.anchorRight = true
    o.anchorBottom = true
    o.player = player
    o.playerIndex = playerIndex
    o.zOffsetLargeFont = 25;
    o.zOffsetMediumFont = 20;
    o.zOffsetSmallFont = 6;
    o:setWantKeyEvents(true)
    o:setTitle("pools_blacklist_main")
    return o;
end

function UI:RestoreLayout(name, layout)

    -- ISLayoutManager.DefaultRestoreWindow(self, layout)
    -- if name == profileName then
    --     ISLayoutManager.DefaultRestoreWindow(self, layout)
    --     self.userPosition = layout.userPosition == 'true'
    -- end
    self:recalcSize();
end

function UI:SaveLayout(name, layout)
    ISLayoutManager.DefaultSaveWindow(self, layout)
    if self.userPosition then
        layout.userPosition = 'true'
    else
        layout.userPosition = 'false'
    end
end

function UI:close()
    if not self.locked then
        ISCollapsableWindowJoypad.close(self);
    end
end

function UI:createChildren()

    ISCollapsableWindowJoypad.createChildren(self);
    local th = self:titleBarHeight()
    local rh = self:resizeWidgetHeight()

    local padding = 10
    local x = padding
    local y = th + padding
    local w = self.width - x - padding
    local h = self.height - rh - padding - FONT_HGT_SMALL - 4

    self.controls.tabPanel = ISTabPanel:new(x, y, w, h - y);
    self.controls.tabPanel:initialise()
    self:addChild(self.controls.tabPanel)

    self.controls.items = Core.ui.pools_group:new(0, 100, w, self.controls.tabPanel.height - th, {
        player = self.player,
        blacklist = true,
        type = Core.consts.itemType.items
    });

    self.controls.vehicles = Core.ui.pools_group:new(0, 100, w, self.controls.tabPanel.height - th, {
        player = self.player,
        blacklist = true,
        type = Core.consts.itemType.vehicles
    });

    self.controls.traits = Core.ui.pools_group:new(0, 100, w, self.controls.tabPanel.height - th, {
        player = self.player,
        blacklist = true,
        type = Core.consts.itemType.traits
    });

    self.controls.xp = Core.ui.pools_group:new(0, 100, w, self.controls.tabPanel.height - th, {
        player = self.player,
        blacklist = true,
        type = Core.consts.itemType.xp
    });

    self.controls.boosts = Core.ui.pools_group:new(0, 100, w, self.controls.tabPanel.height - th, {
        player = self.player,
        blacklist = true,
        type = Core.consts.itemType.boosts
    });

    self.controls.tabPanel:addView(Core.consts.itemType.items, self.controls.items)
    self.controls.tabPanel:addView(Core.consts.itemType.vehicles, self.controls.vehicles)
    self.controls.tabPanel:addView(Core.consts.itemType.traits, self.controls.traits)
    self.controls.tabPanel:addView(Core.consts.itemType.xp, self.controls.xp)
    self.controls.tabPanel:addView(Core.consts.itemType.boosts, self.controls.boosts)

    self.controls.ok = ISButton:new(padding, self.height - rh - padding - FONT_HGT_SMALL, 100, FONT_HGT_SMALL + 4, "OK",
        self, UI.onOK);
    self.controls.ok:initialise();
    self.controls.ok:instantiate();
    self:addChild(self.controls.ok);

    self:refreshAll()
end

function UI:refreshAll()

    for k, v in pairs(self.controls) do
        if v.setData then
            v:setData(self.data[k] or {
                categories = {},
                exclude = {}
            })
        end
    end
end

function UI:prerender()

    ISCollapsableWindowJoypad.prerender(self);

    self.controls.ok:setX(self.width - self.controls.ok.width - 10)
    self.controls.ok:setY(self.height - self.controls.ok.height - self:resizeWidgetHeight() - 10)
    self.controls.tabPanel:setWidth(self.width - 20)
    self.controls.tabPanel:setHeight(self.controls.ok.y - self.controls.tabPanel.y - 50)
end

function UI:onOK()

    local selected = {}
    for k, v in pairs(self.controls) do
        if v.getSelected then
            selected[k] = v:getSelected()
        end
    end

    if Core.isLocal then
        Core.setBlacklist(selected)
    else
        sendClientCommand(Core.name, Core.commands.setBlacklist, selected)
    end
    self:close()

end
