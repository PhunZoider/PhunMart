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
local BUTTON_HGT = FONT_HGT_SMALL + 6

local profileName = "PhunMartUIShopListing"

Core.ui.shop_selector = ISCollapsableWindowJoypad:derive(profileName);
local UI = Core.ui.shop_selector
local instances = {}

function UI:refreshAll()
    self.controls.list:clear()
    self.controls.list.instanceCounts = {}
    local shops = Core.runtime and Core.runtime.shops or {}
    for shopType, shopDef in pairs(shops) do
        self.controls.list:addItem(getTextOrNull("IGUI_PhunMart_Shop_" .. shopType) or shopType, {
            type = shopType,
            enabled = shopDef.enabled ~= false
        })
    end

    -- Fetch instance counts
    if Core.isLocal then
        local counts = {}
        for _, v in pairs(Core.instances or {}) do
            counts[v.type] = (counts[v.type] or 0) + 1
        end
        self.controls.list.instanceCounts = counts
    else
        sendClientCommand(Core.name, Core.commands.getInstanceList, {})
    end
end

function UI:setInstanceCounts(list)
    local counts = {}
    for _, v in ipairs(list) do
        counts[v.type] = (counts[v.type] or 0) + 1
    end
    self.controls.list.instanceCounts = counts
end

-- Class-level: update all open selector instances with instance counts
function UI.updateInstanceCounts(list)
    for _, inst in pairs(instances) do
        if inst.setInstanceCounts then
            inst:setInstanceCounts(list)
        end
    end
end

function UI.open(player)
    local playerIndex = player:getPlayerNum()
    local instance = instances[playerIndex]

    if not instance then
        local core = getCore()
        local width = 350 * FONT_SCALE
        local height = 300 * FONT_SCALE

        local x = (core:getScreenWidth() - width) / 2
        local y = (core:getScreenHeight() - height) / 2

        instances[playerIndex] = UI:new(x, y, width, height, player, playerIndex);
        instance = instances[playerIndex]
        instance:initialise();

        ISLayoutManager.RegisterWindow(profileName, UI, instance)
    end
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
    o:setTitle(getText("IGUI_PhunMart_Title_Shops"))
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
    self:addChild(panel);
    self.controls._panel = panel;

    local listPanel = ISPanel:new(0, 0, w, h - BUTTON_HGT + 20);
    listPanel:initialise();
    listPanel:instantiate();
    self.controls._panel:addChild(listPanel);
    self.controls._listPanel = listPanel;

    local controlPanel = ISPanel:new(0, listPanel:getHeight() - BUTTON_HGT + 20, w, BUTTON_HGT + 20);
    controlPanel:initialise();
    controlPanel:instantiate();
    controlPanel:setAnchorRight(true)
    controlPanel:setAnchorLeft(true)
    controlPanel:setAnchorTop(true)
    controlPanel:setAnchorBottom(true)
    self.controls._panel:addChild(controlPanel);
    self.controls._controlPanel = controlPanel;

    local list = ISScrollingListBox:new(0, HEADER_HGT, w, h);
    list:initialise();
    list:instantiate();
    list.itemheight = FONT_HGT_SMALL + 6 * 2
    list.selected = 0;
    list.joypadParent = self;
    list.font = UIFont.NewSmall;
    list.doDrawItem = self.drawDatas;

    list:setOnMouseDoubleClick(self, self.onEdit);
    list.onMouseUp = function(list, x, y)
        local row = list:rowAt(x, y)
        if row == nil or row == -1 then
            return
        end
        list:ensureVisible(row)
        local item = list.items[row].item
        list.selected = row
    end

    list.onRightMouseUp = function(target, x, y)
        local row = target:rowAt(x, y)
        if row == -1 then
            return
        end
        target.selected = row
        target:ensureVisible(row)
        local item = target.items[row].item
        self:onRowContextMenu(item, getMouseX(), getMouseY())
    end
    list.drawBorder = true;
    list.onMouseMove = self.doOnMouseMove
    list.onMouseMoveOutside = self.doOnMouseMoveOutside

    list:addColumn(getText("IGUI_PhunMart_Col_Shop"), 0);
    list:addColumn(getText("IGUI_PhunMart_Col_InWorld"), 150);
    self.controls.list = list;
    self.controls._listPanel:addChild(list);

    local btnClose = ISButton:new(0, 10, 80, BUTTON_HGT, getText("IGUI_PhunMart_Btn_Close"), self, self.close);
    btnClose.internal = "CLOSE";
    btnClose:initialise();
    btnClose:instantiate();
    if btnClose.enableCancelColor then
        btnClose:enableCancelColor()
    end
    self.controls.btnClose = btnClose;
    self.controls._controlPanel:addChild(btnClose);

    local btnAdmin = ISButton:new(0, 10, 100, BUTTON_HGT, getText("IGUI_PhunMart_Btn_AdminTools"), self,
        self.onAdminToolsMenu);
    btnAdmin.internal = "ADMIN";
    btnAdmin:initialise();
    btnAdmin:instantiate();
    self.controls.btnAdmin = btnAdmin;
    self.controls._controlPanel:addChild(btnAdmin);

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

function UI:onEdit(item)
    local shop = self.controls.list.items[self.controls.list.selected].item
    if shop and shop.type then
        Core.ui.admin_shops.OnOpenPanel(self.player, shop.type)
    end
end

function UI:onRowContextMenu(item, screenX, screenY)
    local context = ISContextMenu.get(self.playerIndex, screenX, screenY)
    context:addOption(getText("IGUI_PhunMart_Btn_Locations"), self, function()
        Core.ui.shop_instances.open(self.player, item.type)
    end)
    if isAdmin() or isDebugEnabled() then
        context:addOption(getText("IGUI_PhunMart_Btn_Config"), self, function()
            Core.ui.admin_shops.OnOpenPanel(self.player, item.type)
        end)
    end
end

function UI:onAdminToolsMenu(btn)
    local screenX = btn:getAbsoluteX()
    local screenY = btn:getAbsoluteY()

    local context = ISContextMenu.get(self.playerIndex, screenX, screenY)
    context:addOption(getText("IGUI_PhunMart_Btn_Pools"), self, function()
        Core.ui.admin_pools.OnOpenPanel(self.player)
    end)
    context:addOption(getText("IGUI_PhunMart_Btn_Groups"), self, function()
        Core.ui.admin_groups.OnOpenPanel(self.player)
    end)
    context:addOption(getText("IGUI_PhunMart_Btn_Specials"), self, function()
        Core.ui.admin_specials.OnOpenPanel(self.player)
    end)
    context:addOption(getText("IGUI_PhunMart_Btn_Items"), self, function()
        Core.ui.admin_items.OnOpenPanel(self.player)
    end)
    context:addOption(getText("IGUI_PhunMart_Btn_Prices"), self, function()
        Core.ui.admin_prices.OnOpenPanel(self.player)
    end)
    context:addOption(getText("IGUI_PhunMart_Btn_Wallet"), self, function()
        Core.ui.admin.OnOpenPanel(self.player)
    end)
    context:addOption(getText("IGUI_PhunMart_Btn_Rewards"), self, function()
        Core.ui.admin_rewards.OnOpenPanel(self.player)
    end)
    context:addOption(getText("IGUI_PhunMart_Btn_Recompile"), self, function()
        sendClientCommand(Core.name, Core.commands.compile, {})
    end)
    context:addOption(getText("IGUI_PhunMart_Btn_RestockAll"), self, function()
        local w = 300
        local h = 150
        local modal = ISModalDialog:new(getCore():getScreenWidth() / 2 - w / 2, getCore():getScreenHeight() / 2 - h / 2,
            w, h, getText("IGUI_PhunMart_Confirm_RestockAll"), true, self, self.onConfirmRestockAll)
        modal:initialise()
        modal:addToUIManager()
    end)
end

function UI:onConfirmRestockAll(button)
    if button.internal == "YES" then
        sendClientCommand(Core.name, Core.commands.restockAllShops, {})
    end
end

function UI:prerender()
    ISCollapsableWindowJoypad.prerender(self)

    local th = self:titleBarHeight()
    local rh = self:resizeWidgetHeight()

    -- container
    self.controls._panel:setWidth(self.width)
    self.controls._panel:setHeight(self.height - rh - th)

    -- list container
    self.controls._listPanel:setWidth(self.controls._listPanel.parent.width)
    self.controls._listPanel:setHeight(self.controls._listPanel.parent.height - self.controls._controlPanel.height)

    -- list
    self.controls.list:setWidth(self.controls.list.parent.width)
    self.controls.list:setHeight(self.controls.list.parent.height - HEADER_HGT)
    self.controls.list.columns[2].size = self.controls.list.width / 2

    -- control container
    self.controls._controlPanel:setWidth(self.controls._controlPanel.parent.width)
    self.controls._controlPanel:setHeight(BUTTON_HGT + 20)
    self.controls._controlPanel:setY(self.controls._controlPanel.parent.height - self.controls._controlPanel.height)

    -- right side: Close
    self.controls.btnClose:setX(self.controls.btnClose.parent.width - self.controls.btnClose.width - 10)

    -- left side: Admin Tools (admin only)
    local isAdminUser = isAdmin() or isDebugEnabled()
    self.controls.btnAdmin:setVisible(isAdminUser)
    if isAdminUser then
        self.controls.btnAdmin:setX(10)
    end
end

function UI:drawDatas(y, item, alt)

    if y + self:getYScroll() + self.itemheight < 0 or y + self:getYScroll() >= self.height then
        return y + self.itemheight
    end

    local a = 0.9;

    if self.selected == item.index then
        self:drawRect(0, (y), self:getWidth(), self.itemheight, 0.3, 0.7, 0.35, 0.15);
    end

    if alt then
        self:drawRect(0, (y), self:getWidth(), self.itemheight, 0.2, 0.6, 0.5, 0.5);
    end

    self:drawRectBorder(0, (y), self:getWidth(), self.itemheight, a, self.borderColor.r, self.borderColor.g,
        self.borderColor.b);

    local iconX = 4
    local iconSize = FONT_HGT_SMALL;
    local xoffset = 10;

    local clipX = self.columns[1].size
    local clipX2 = self.columns[2].size
    local clipY = math.max(0, y + self:getYScroll())
    local clipY2 = math.min(self.height, y + self:getYScroll() + self.itemheight)

    if item.item.texture then
        local textured = self:drawTextureScaledAspect(item.item.texture, xoffset, y, self.itemheight - 4,
            self.itemheight - 4, 1, 1, 1, 1)
        xoffset = xoffset + self.itemheight + 4
    end

    self:setStencilRect(clipX, clipY, clipX2 - clipX, clipY2 - clipY)
    self:drawText(item.text, xoffset, y + 4, 1, 1, 1, a, self.font);
    self:clearStencilRect()

    local count = (self.instanceCounts or {})[item.item.type] or 0
    local cw = self.columns[2].size
    self:drawText(tostring(count), cw + 4, y + 4, 0.8, 0.8, 0.8, a, self.font);
    self.itemsHeight = y + self.itemheight;
    return self.itemsHeight;
end
