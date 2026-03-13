if isServer() then
    return
end

require "ISUI/ISCollapsableWindowJoypad"
local tools = require "PhunMart_Client/ui/ui_utils"
local Core = PhunMart

local profileName = "PhunMartUIShopConfig"

Core.ui.shop_config = ISCollapsableWindowJoypad:derive(profileName);
local UI = Core.ui.shop_config
local instances = {}

function UI:refreshAll()

    -- copy the Core.shops properties and populate the UI
    local data = Core.utils.deepCopy(self.original_data)
    self.data = data
    self.controls.props:setData(data)
    self.controls.pools:setData(data)
    local title = getTextOrNull("IGUI_PhunMart_Shop_" .. data.type) or data.type or "Locations"
    self:setTitle(title)
    Core.debug("-----", self.shopType, "----", data, "-----")

end

function UI.open(player, data)

    local playerIndex = player:getPlayerNum()

    local core = getCore()
    local width = 450 * tools.FONT_SCALE
    local height = 500 * tools.FONT_SCALE

    local x = (core:getScreenWidth() - width) / 2
    local y = (core:getScreenHeight() - height) / 2

    local instance = UI:new(x, y, width, height, player, playerIndex, data);
    instance.original_data = data
    instance:initialise();
    ISLayoutManager.RegisterWindow(profileName, UI, instance)
    instance:addToUIManager();
    instance:setVisible(true);
    instance:ensureVisible()
    instance:refreshAll()
    return instance;
end

function UI:new(x, y, width, height, player, playerIndex, data)
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
    o.original_data = data or {}
    o.moveWithMouse = false;
    o.anchorRight = true
    o.anchorBottom = true
    o.player = player
    o.playerIndex = playerIndex
    o.zOffsetLargeFont = 25;
    o.zOffsetMediumFont = 20;
    o.zOffsetSmallFont = 6;
    o:setWantKeyEvents(true)
    return o;
end

function UI:RestoreLayout(name, layout)

    -- ISLayoutManager.DefaultRestoreWindow(self, layout)
    -- if name == profileName then
    --     ISLayoutManager.DefaultRestoreWindow(self, layout)
    --     self.userPosition = layout.userPosition == 'true'
    -- end
    -- self:recalcSize();
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

function UI:onResize()
    ISCollapsableWindowJoypad.onResize(self)
    local tabPanel = self.controls.tabPanel
    local padding = 10
    local th = self:titleBarHeight()
    local rh = self:resizeWidgetHeight()
    local fs = tools.FONT_SCALE
    tabPanel:setX(padding)
    tabPanel:setY(th)
    tabPanel:setWidth(self.width - padding * 2)

    tabPanel:setHeight(self.height - (tabPanel.y) - rh - (tools.BUTTON_HGT + (padding * 2)))

    for _, view in ipairs(tabPanel.viewList) do
        view.view:setWidth(tabPanel.width)
        view.view:setHeight(tabPanel.height - tabPanel.tabHeight)
    end

    self.controls.btnCancel:setX(tabPanel.x + tabPanel.width - tools.BUTTON_WID)
    self.controls.btnCancel:setY(tabPanel.y + tabPanel.height + padding)

    self.controls.btnSave:setX(self.controls.btnCancel.x - tools.BUTTON_WID - padding)
    self.controls.btnSave:setY(self.controls.btnCancel.y)
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

    local tabPanel = tools.getTabPanel(x, y, w, h)

    self.controls.tabPanel = tabPanel
    self:addChild(tabPanel)

    local props = Core.ui.propEditor:new(0, 0, w, h, {
        player = self.player
    })
    self.controls.props = props
    self.controls.tabPanel:addView("Props", props)

    local pools = Core.ui.pools:new(0, 100, tabPanel.width, tabPanel.height - tabPanel.tabHeight, {
        player = self.player
    });
    pools:initialise()
    self.controls.pools = pools
    self.controls.tabPanel:addView("Pool Sets", self.controls.pools)

    local btnCancel = ISButton:new(0, 0, tools.BUTTON_WID, tools.BUTTON_HGT, getText("UI_btn_cancel"), self, UI.close)
    btnCancel:initialise()
    if btnCancel.enableCancelColor then
        btnCancel:enableCancelColor()
    end
    self.controls.btnCancel = btnCancel
    self:addChild(btnCancel)

    local btnSave = ISButton:new(0, 0, tools.BUTTON_WID, tools.BUTTON_HGT, getText("UI_btn_save"), self, function()
        self:save()
    end)
    btnSave:initialise()
    if btnSave.enableAcceptColor then
        btnSave:enableAcceptColor()
    end

    self.controls.btnSave = btnSave
    self:addChild(btnSave)

    self:refreshAll()
    self:bringToTop()
end

function UI:save()

    local data = self.controls.props:getData()
    local pools = self.controls.pools:getData()
    data.pools = pools

    Core.debug("----", "Saving shop config", data, "----")

    Core.ClientSystem.instance:sendCommand(self.player, Core.commands.upsertShopDefinition, data)

    self:close()

end

function UI:isKeyConsumed(key)
    return key == Keyboard.KEY_ESCAPE
end

function UI:onKeyRelease(key)
    if key == Keyboard.KEY_ESCAPE then
        self:close()
    end
end
