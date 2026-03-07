if isServer() then
    return
end

local Core = PhunMart

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)
local FONT_HGT_LARGE = getTextManager():getFontHeight(UIFont.Large)

local FONT_SCALE = FONT_HGT_SMALL / 14
local HEADER_HGT = FONT_HGT_MEDIUM + 2 * 2
local BUTTON_HGT = FONT_HGT_SMALL + 6

local profileName = "PhunMartUIPoolsFiltersMain"

Core.ui.pools_filters_main = ISCollapsableWindowJoypad:derive(profileName);
local UI = Core.ui.pools_filters_main
local instances = {}

function UI:refreshAll()
    self.controls.items:setData(self.data.items or {})
    self.controls.vehicles:setData(self.data.vehicles or {})
    self.controls.traits:setData(self.data.traits or {})
    self.controls.xp:setData(self.data.xp or {})
    self.controls.boosts:setData(self.data.boosts or {})
end

function UI.open(player, data, cb)

    local playerIndex = player:getPlayerNum()

    local core = getCore()
    local width = 400 * FONT_SCALE
    local height = 400 * FONT_SCALE

    local x = (core:getScreenWidth() - width) / 2
    local y = (core:getScreenHeight() - height) / 2

    local instance = UI:new(x, y, width, height, player, playerIndex);
    instance.data = data
    instance.cb = cb

    instance:initialise();

    ISLayoutManager.RegisterWindow(profileName, UI, instance)

    instance.shopKey = shopKey or nil
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
    o.shopKey = shopKey
    o.zOffsetLargeFont = 25;
    o.zOffsetMediumFont = 20;
    o.zOffsetSmallFont = 6;
    o:setWantKeyEvents(true)
    o:setTitle("pools_filters_main")
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
    local x = 0
    local y = th
    local w = self.width
    local h = self.height - rh - th

    self.controls = {}

    local panel = ISPanel:new(x, y, w, h);
    panel:initialise();
    panel:instantiate();
    panel:setAnchorLeft(true);
    panel:setAnchorRight(true);
    panel:setAnchorTop(true);
    panel:setAnchorBottom(true);

    self:addChild(panel);
    self.controls._panel = panel;

    self.controls.tabPanel = ISTabPanel:new(x, y, w, h - y - (padding * 2) - BUTTON_HGT);
    self.controls.tabPanel:initialise()
    self.controls.tabPanel:instantiate()
    self.controls.tabPanel:setAnchorLeft(true)
    self.controls.tabPanel:setAnchorRight(true)
    self.controls.tabPanel:setAnchorTop(true)
    self.controls.tabPanel:setAnchorBottom(true)
    panel:addChild(self.controls.tabPanel)

    h = self.controls.tabPanel.height - (HEADER_HGT - 5)

    self.controls.items = Core.ui.pools_group:new(0, 0, w, h, {
        player = self.player,
        type = Core.consts.itemType.items
    });

    self.controls.vehicles = Core.ui.pools_group:new(0, 0, w, h, {
        player = self.player,
        type = Core.consts.itemType.vehicles
    });

    self.controls.traits = Core.ui.pools_group:new(0, 0, w, h, {
        player = self.player,
        type = Core.consts.itemType.traits
    });

    self.controls.xp = Core.ui.pools_group:new(0, 0, w, h, {
        player = self.player,
        type = Core.consts.itemType.xp
    });

    self.controls.boosts = Core.ui.pools_group:new(0, 0, w, h, {
        player = self.player,
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
    if self.controls.ok.enableAcceptColor then
        self.controls.ok:enableAcceptColor()
    end
    self:addChild(self.controls.ok);

    self:refreshAll()
end

function UI:isKeyConsumed(key)
    return key == Keyboard.KEY_ESCAPE
end

function UI:onKeyRelease(key)
    if key == Keyboard.KEY_ESCAPE then
        self:close()
    end
end

function UI:prerender()

    ISCollapsableWindowJoypad.prerender(self);
    local ok = self.controls.ok
    self.controls.ok:setX(ok.parent.width - ok.width - 10)
    self.controls.ok:setY(ok.parent.height - ok.height - self:resizeWidgetHeight() - 10)

end

function UI:onOK()

    local selected = {
        items = self.controls.items:getSelected(),
        vehicles = self.controls.vehicles:getSelected(),
        traits = self.controls.traits:getSelected(),
        xp = self.controls.xp:getSelected(),
        boosts = self.controls.boosts:getSelected()
    }

    self.cb(selected)
    self:close()

end
