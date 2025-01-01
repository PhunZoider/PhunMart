if isServer() then
    return
end
PhunMartUIShopAdmin = ISPanelJoypad:derive("PhunMartUIShopAdmin");
PhunMartUIShopAdmin.instance = nil;
local PhunMart = PhunMart
local PhunTools = PhunTools
local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)
local FONT_HGT_LARGE = getTextManager():getFontHeight(UIFont.Large)

local function requestShopDefs()
    sendClientCommand(PhunMart.name, PhunMart.commands.requestShopDefs, {})
    sendClientCommand(PhunMart.name, PhunMart.commands.requestItemDefs, {})
end

function PhunMartUIShopAdmin.OnOpenPanel(playerObj, key)
    if isAdmin() then
        if PhunMartUIShopAdmin.instance == nil then
            PhunMartUIShopAdmin.instance = PhunMartUIShopAdmin:new(100, 100, 400, 400, playerObj, key);
            PhunMartUIShopAdmin.instance:initialise();
            PhunMartUIShopAdmin.instance:instantiate();
            if not PhunMart.defs or not PhunMart.defs.shops then
                requestShopDefs()
            end
        end

        -- PhunMartUIShopAdmin.instance.key = key
        ISLayoutManager.RegisterWindow('PhunMartUIShopAdmin', PhunMartUIShopAdmin, PhunMartUIShopAdmin.instance)
        PhunMartUIShopAdmin.instance:addToUIManager();
        PhunMartUIShopAdmin.instance:setVisible(true);
        return PhunMartUIShopAdmin.instance;
    end
end

function PhunMartUIShopAdmin:promptForValue(playerName, walletType, currencyType, value)
    local modal = ISTextBox:new(0, 0, 280, 180, currencyType .. "(" .. walletType .. ") for " .. playerName,
        tostring(value), nil, function(target, button, obj)
            if button.internal == "OK" then

            end

        end, self.viewer:getPlayerNum())
    modal:initialise()
    modal:addToUIManager()
end

function PhunMartUIShopAdmin:refreshData()
    local pm = PhunMart
    local current = pm:getShop(self.key)

    self.box:clear()
    if pm.defs.shops then
        local i = 0
        for k, v in pairs(pm.defs.shops) do
            i = i + 1
            self.box:addOptionWithData(v.label, v)
            if current and current.key == k then
                self.box.selected = i
            end
        end
    end

    local selected = self.box.options[self.box.selected]
    if selected and self.itemsPanel then
        self.itemsPanel:rebuild(selected.data.pools)
    end
end

function PhunMartUIShopAdmin:refreshItems(items)
    self.items = items
    local selected = self.box.options[self.box.selected]
    if selected and self.itemsPanel then
        self.itemsPanel:rebuild(selected.data.pools, items)
    end
end

function PhunMartUIShopAdmin:createChildren()
    ISPanel.createChildren(self);

    local x = 10
    local y = 10
    local h = FONT_HGT_SMALL;
    local w = self.width - 20;
    self.title = ISLabel:new(x, y, h, "Tools", 1, 1, 1, 1, UIFont.Small, true);
    self.title:initialise();
    self.title:instantiate();
    self:addChild(self.title);

    self.closeButton = ISButton:new(self.width - 25 - x, y, 25, 25, "X", self, function()
        PhunMartUIShopAdmin.OnOpenPanel():close()
    end);
    self.closeButton:initialise();
    self:addChild(self.closeButton);

    y = y + h + x + 20

    self.box = ISComboBox:new(x, y, 200, h, self, function()

    end);
    self.box:initialise()
    self:addChild(self.box)
    self:refreshData()

    self.refreshShopsButton = ISButton:new(x + self.box:getWidth() + 10, y, self.width - self.box:getWidth() - 20 - x,
        self.box.height, "Refresh", self, function()
            requestShopDefs()
        end);
    self.refreshShopsButton:initialise();
    self:addChild(self.refreshShopsButton);

    y = y + h + x

    self.tabPanel = ISTabPanel:new(x, y, self.width - x - x, self.height - y - 45)
    self.tabPanel:initialise()
    self.tabPanel.tabFont = UIFont.Small
    self.tabPanel.tabHeight = FONT_HGT_SMALL + 6
    self.tabPanel.activateView = function(self, viewname)
        ISTabPanel.activateView(self, viewname)
        self.parent:setSelected(viewname, self.activeView.view.selected)
    end
    self.tabPanel.render = self.tabsRender

    self:addChild(self.tabPanel)

    y = y + h + x

    self.adminButton = ISButton:new(x, self.height - 35, 100, 25, "Admin", self, function()
        PhunMartAdminUI.OnOpenPanel()
    end)
    self.adminButton:initialise()
    self:addChild(self.adminButton)

    self.saveButton = ISButton:new(self.width - x - 110, self.height - 35, 100, 25, "Save", self, function()
        PhunMartUIShopAdmin.OnOpenPanel():save()
    end)
    self.saveButton:initialise()
    self:addChild(self.saveButton)

    self.itemsPanel = PhunMartUIShopAdminItems:new(10, 50, self.tabPanel.width, self.tabPanel.height - 50, self.viewer,
        self.key)

    -- add views
    self.tabPanel:addView("All Item Defs", self.itemsPanel)

    local selected = self.box.options[self.box.selected]
    if selected and self.itemsPanel then
        self.itemsPanel:rebuild(selected.data.pools)
    end
end

function PhunMartUIShopAdmin:tabsRender()
    local inset = 1
    local x = inset + self.scrollX
    local widthOfAllTabs = self:getWidthOfAllTabs()
    local overflowLeft = self.scrollX < 0
    local overflowRight = x + widthOfAllTabs > self.width
    if widthOfAllTabs > self:getWidth() then
        self:setStencilRect(0, 0, self:getWidth(), self.tabHeight)
    end
    for i, viewObject in ipairs(self.viewList) do
        local tabWidth = (self.equalTabWidth and self.maxLength or viewObject.tabWidth) + 4
        if viewObject == self.activeView then
            self:drawRect(x, 0, tabWidth, self.tabHeight, 1, 0.4, 0.4, 0.4, 0.7)
        else
            self:drawRect(x + tabWidth, 0, 1, self.tabHeight, 1, 0.4, 0.4, 0.4, 0.9)
            if self:getMouseY() >= 0 and self:getMouseY() < self.tabHeight and self:isMouseOver() and
                self:getTabIndexAtX(self:getMouseX()) == i then
                viewObject.fade:setFadeIn(true)
            else
                viewObject.fade:setFadeIn(false)
            end
            viewObject.fade:update()
            self:drawRect(x, 0, tabWidth, self.tabHeight, 0.2 * viewObject.fade:fraction(), 1, 1, 1, 0.9)
        end
        self:drawTextCentre(viewObject.name, x + (tabWidth / 2), 3, 1, 1, 1, 1, self.tabFont)
        x = x + tabWidth
    end
    self:drawRect(0, self.tabHeight - 1, self:getWidth(), 1, 1, 0.4, 0.4, 0.4)
    local butPadX = 3
    if overflowLeft then
        local tex = getTexture("media/ui/ArrowLeft.png")
        local butWid = tex:getWidthOrig() + butPadX * 2
        self:drawRect(inset, 0, butWid, self.tabHeight - 1, 1, 0, 0, 0)
        self:drawRectBorder(inset, -1, butWid, self.tabHeight + 1, 1, 0.4, 0.4, 0.4)
        self:drawTexture(tex, inset + butPadX, (self.tabHeight - tex:getHeightOrig()) / 2, 1, 1, 1, 1)
    end
    if overflowRight then
        local tex = getTexture("media/ui/ArrowRight.png")
        local butWid = tex:getWidthOrig() + butPadX * 2
        self:drawRect(self:getWidth() - inset - butWid, 0, butWid, self.tabHeight - 1, 1, 0, 0, 0)
        self:drawRectBorder(self:getWidth() - inset - butWid, -1, butWid, self.tabHeight + 1, 1, 0.4, 0.4, 0.4)
        self:drawTexture(tex, self:getWidth() - butWid + butPadX, (self.tabHeight - tex:getHeightOrig()) / 2, 1, 1, 1, 1)
    end
    if widthOfAllTabs > self:getWidth() then
        self:clearStencilRect()
    end
    self:drawRect(0, self.height, self.width, 1, 1, 0.4, 0.4, 0.4)

end

function PhunMartUIShopAdmin:save()
    local pm = PhunMart
    local current = pm:getShop(self.key)
    local changes = {}
    local doSave = false
    if self.box.selected > 0 then
        local item = self.box.options[self.box.selected].data
        local key = item.key
        if key ~= self.key then
            changes.shop = key
            doSave = true
        end
    end

    if doSave then
        changes.key = self.key
        sendClientCommand(PhunMart.name, PhunMart.commands.updateShop, changes)
    end

end

function PhunMartUIShopAdmin:close()
    self:setVisible(false);
    self:removeFromUIManager();
    PhunMartUIShopAdmin.instance = nil
end

function PhunMartUIShopAdmin:new(x, y, width, height, player, key)
    local o = {};
    o = ISPanel:new(x, y, width, height, player);
    setmetatable(o, self);
    self.__index = self;
    o.viewer = player
    o.variableColor = {
        r = 0.9,
        g = 0.55,
        b = 0.1,
        a = 1
    };
    o.borderColor = {
        r = 0.4,
        g = 0.4,
        b = 0.4,
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
        a = 0.5
    };
    o.zOffsetSmallFont = 25;
    o.moveWithMouse = true;
    o.key = key;
    o.shops = nil;
    o.shop = PhunMart:getShop(key);
    return o;
end

function PhunMartUIShopAdmin:onMouseDown(x, y)
    self.downX = self:getMouseX()
    self.downY = self:getMouseY()
    return true
end
function PhunMartUIShopAdmin:onMouseUp(x, y)
    self.downY = nil
    self.downX = nil
    if not self.dragging then
        if self.onClick then
            self:onClick()
        end
    else
        self.dragging = false
        self:setCapture(false)
    end
    return true
end

function PhunMartUIShopAdmin:onMouseMove(dx, dy)

    if self.downY and self.downX and not self.dragging then
        if math.abs(self.downX - dx) > 4 or math.abs(self.downY - dy) > 4 then
            self.dragging = true
            self:setCapture(true)
        end
    end

    if self.dragging then
        local dx = self:getMouseX() - self.downX
        local dy = self:getMouseY() - self.downY
        self.userPosition = true
        self:setX(self.x + dx)
        self:setY(self.y + dy)
    end
end

function PhunMartUIShopAdmin:RestoreLayout(name, layout)
    if name == "PhunMartUIShopAdmin" then
        ISLayoutManager.DefaultRestoreWindow(self, layout)
        self.userPosition = layout.userPosition == 'true'
    end
end

function PhunMartUIShopAdmin:SaveLayout(name, layout)
    ISLayoutManager.DefaultSaveWindow(self, layout)
    layout.width = nil
    layout.height = nil
    if self.userPosition then
        layout.userPosition = 'true'
    else
        layout.userPosition = 'false'
    end
end

local Commands = {}

Events[PhunMart.events.OnShopDefsReloaded].Add(function(shops)
    if PhunMartUIShopAdmin.instance then
        PhunMartUIShopAdmin.instance:refreshData()
    end
end)

Events[PhunMart.events.OnShopItemDefsReloaded].Add(function(items)
    if PhunMartUIShopAdmin.instance then
        PhunMartUIShopAdmin.instance:refreshItems(items)
    end
end)
