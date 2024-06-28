if not isClient() then
    return
end

require "ISUI/ISPanel"
PhunMartUIItemsPanel = ISPanelJoypad:derive("PhunMartUIItemsPanel");
local sandbox = SandboxVars.PhunMart

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)
local FONT_HGT_LARGE = getTextManager():getFontHeight(UIFont.Large)
local FONT_SCALE = FONT_HGT_SMALL / 14

function PhunMartUIItemsPanel:initialise()
    ISPanel.initialise(self);
end

function PhunMartUIItemsPanel:new(x, y, width, height, options)
    local opts = options or {}
    local o = ISPanelJoypad:new(x, y, width, height);
    setmetatable(o, self);
    o.listHeaderColor = opts.listHeaderColor or {
        r = 0.4,
        g = 0.4,
        b = 0.4,
        a = 0.3
    };
    o.borderColor = opts.borderColor or {
        r = 0.4,
        g = 0.4,
        b = 0.4,
        a = 0
    };
    o.backgroundColor = opts.backgroundColor or {
        r = 0,
        g = 0,
        b = 0,
        a = 1
    };
    o.noPowerBackgroundColor = opts.noPowerBackgroundColor or {
        r = 0,
        g = 0,
        b = 0,
        a = 0.9
    };
    o.buttonBorderColor = opts.buttonBorderColor or {
        r = 0.7,
        g = 0.7,
        b = 0.7,
        a = 0.5
    };
    o.viewer = opts.viewer or getPlayer()
    o.tabFont = opts.tabFont or UIFont.Medium
    o.selections = {}
    o.shop = opts.shop or {}
    o.tabHeight = opts.tabHeight or FONT_HGT_MEDIUM + 6
    PhunMartUIItemsPanel.instance = o;
    return o;
end

function PhunMartUIItemsPanel:getSelected()
    if not self.shop.isUnplugged then
        if self.tabPanel and self.tabPanel.activeView then
            return self.tabPanel.activeView.view.items[self.tabPanel.activeView.view.selected]
        end
    end
end

function PhunMartUIItemsPanel:setShop(shop)

    self:removeViews()
    local firstTab = nil
    local firstRow = nil
    for _, tabName in pairs(shop.tabKeys) do

        local scrollingList = ISScrollingListBox:new(1, 0, self.tabPanel.width - 2,
            self.tabPanel.height - self.tabPanel.tabHeight)

        scrollingList.itemPadY = 10 * FONT_SCALE
        scrollingList.itemheight = FONT_HGT_LARGE + scrollingList.itemPadY * 2 + 1 * FONT_SCALE + FONT_HGT_SMALL
        scrollingList.textureHeight = scrollingList.itemheight - scrollingList.itemPadY * 2
        scrollingList.mouseoverselected = -1
        scrollingList.background = false
        scrollingList:initialise()
        scrollingList.doDrawItem = self.doDrawItem
        scrollingList.selectionMode = "single"
        scrollingList.onMouseDown = self.onMouseDown
        scrollingList.onMouseMove = self.doOnMouseMove
        scrollingList.onMouseMoveOutside = self.doOnMouseMoveOutside
        self.tabPanel:addView(tabName, scrollingList)

        for _, entry in ipairs(shop.tabs[tabName].items) do
            if firstRow == nil then
                firstRow = entry
                firstTab = tabName
            end
            if not entry.type then
                entry.type = "ITEM"
            end
            local row = scrollingList:addItem(entry.type, entry)
        end
    end
    self.shop = shop
end

function PhunMartUIItemsPanel:createChildren()
    ISPanel.createChildren(self);
    local w = self.width
    local h = self.height
    self.tabPanel = ISTabPanel:new(0, 0, w, h);
    self.tabPanel.background = false
    self.tabPanel:initialise()
    self.tabPanel.tabFont = self.tabFont
    self.tabPanel.tabHeight = self.tabHeight
    self.tabPanel.activateView = self.activateView
    self.tabPanel.render = self.tabPanelRender
    self.tabPanel.backgroundColor = self.backgroundColor
    self:addChild(self.tabPanel)

    local tabY = 0
    local tabH = h
    if sandbox.PoweredMachinesEnableTabs == true then
        tabY = 12
        tabH = h - self.tabHeight
    end

    -- if sandbox.PoweredMachinesEnabled then
    self.noPower = ISPanel:new(0, tabY, w, tabH);
    self.noPower:initialise();
    self.noPower.backgroundColor = self.noPowerBackgroundColor
    self.noPower.borderColor = self.borderColor

    local noPowerTexture = getTexture("media/textures/no-power.png")
    local maxWidth = w - 100
    local shrinkage = noPowerTexture:getWidth() / maxWidth
    local tw = noPowerTexture:getWidth() / shrinkage
    local th = noPowerTexture:getHeight() / shrinkage
    local noPowerBackgroundColor = self.noPowerBackgroundColor
    noPowerBackgroundColor.a = 0
    if sandbox.PoweredMachinesAlpha and sandbox.PoweredMachinesAlpha > 0 then
        noPowerBackgroundColor.a = sandbox.PoweredMachinesAlpha / 100
    end
    self.noPower.prerender = function(self)
        self:drawRect(0, tabY, w, tabH, noPowerBackgroundColor.a, noPowerBackgroundColor.r, noPowerBackgroundColor.g,
            noPowerBackgroundColor.b)
        self:drawTextureScaledAspect(noPowerTexture, (w / 2) - (tw / 2), (h / 2) - (th / 2), tw, th, 1, 1, 1, 1)
    end
    self:addChild(self.noPower);
    self.noPower:setVisible(false)
    -- end

    self.tooltip = ISToolTip:new();
    self.tooltip:initialise();
    self.tooltip:setVisible(false);
    -- self.tooltip:setName("Summary");
    self.tooltip:setAlwaysOnTop(true)
    self.tooltip.description = "";
    self.tooltip:setOwner(self.tabPanel)

    local itemInstance = getScriptManager():getItem("Base.Money")
    local invItem = instanceItem("Base.Money")
    self.invTooltip = ISToolTipInv:new(invItem);
    self.invTooltip:initialise()
    self.invTooltip:addToUIManager()
    self.invTooltip:setVisible(true)
    self.invTooltip:setOwner(self.tabPanel)
    self.invTooltip:setCharacter(self.viewer)
end

function PhunMartUIItemsPanel:setSelected(tabName, row)
    self.selections[tabName] = row.index
end

function PhunMartUIItemsPanel:addView(key, list)
    self.tabPanel:addView(key, list)
end

function PhunMartUIItemsPanel:removeViews()
    if self.tabPanel.viewList then
        for i, v in ipairs(self.tabPanel.viewList or {}) do
            self.tabPanel:removeView(v.view)
        end
    end
end

function PhunMartUIItemsPanel:activateView(viewname)
    ISTabPanel.activateView(self, viewname)
end

function PhunMartUIItemsPanel:tabPanelRender()
    ISScrollingListBox.render(self)
    local inset = 1
    local x = inset + self.scrollX
    local widthOfAllTabs = self:getWidthOfAllTabs()
    local overflowLeft = self.scrollX < 0
    local overflowRight = x + widthOfAllTabs > self:getWidth()
    if widthOfAllTabs > self:getWidth() then
        self:setStencilRect(0, 0, self:getWidth(), self.tabHeight)
    end
    for i, viewObject in ipairs(self.viewList) do
        local tabWidth = self.equalTabWidth and self.maxLength or viewObject.tabWidth
        local activeView = self.activeView
        if viewObject == activeView then
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
    self:drawRect(0, self.height, self:getWidth(), 1, 1, 0.4, 0.4, 0.4)

end

function PhunMartUIItemsPanel:doDrawItem(y, item, alt)

    local shop = self.parent.parent.shop
    if not shop then
        return
    end

    local inventoryVal = 0
    local itemAlpha = 1
    local textAlpha = 0.5
    local isOutOfStock = false
    local isInfiniteInventory = item.item.inventory == false
    if isInfiniteInventory then
        inventoryVal = " - "
    elseif item.item.inventory == 0 then
        inventoryVal = "out of stock"
        itemAlpha = 0.5
        isOutOfStock = true
    else
        inventoryVal = PhunTools:formatWholeNumber(item.item.inventory)
    end

    local display = item.item.display or {}

    self:drawRectBorder(0, y, self:getWidth(), item.height, 0.5, self.borderColor.r, self.borderColor.g,
        self.borderColor.b)

    if self.selected == item.index then
        self:drawRect(0, (y), self:getWidth(), item.height - 1, 0.3, 0.7, 0.35, 0.15);
    end

    local x = self.itemPadY
    local x2 = self.itemPadY
    -- y = y + self.itemPadY
    if display.textureVal then
        local textured = self:drawTextureScaledAspect2(display.textureVal, x, y + 10, self.textureHeight,
            self.textureHeight, itemAlpha, 1, 1, 1)
    end
    if display.overlayVal then
        local textured = self:drawTextureScaledAspect2(display.overlayVal, x, y + 10, self.textureHeight,
            self.textureHeight, itemAlpha, 1, 1, 1)

    end
    x = x + self.itemPadY + self.textureHeight
    x2 = x

    local txt = nil

    txt = getText("IGUI_PhunMartInventoryAmount", inventoryVal)
    self:drawText(txt, x, (y + FONT_HGT_LARGE + 3 * FONT_SCALE) + 10, 0.7, 0.7, 0.7, 1.0, UIFont.Small)
    x = x + getTextManager():MeasureStringX(UIFont.Small, txt)

    x = x2
    self:drawText(display.labelVal, x, y + 10, 0.7, 0.7, 0.7, 1.0, self.font)

    return y + item.height
end

function PhunMartUIItemsPanel:prerender()
    ISPanel.prerender(self)
    self.noPower:setVisible(self.shop.isUnplugged == true)
end

function PhunMartUIItemsPanel:doOnMouseMoveOutside(dx, dy)
    local tooltip = self.parent.parent.invTooltip
    tooltip:setVisible(false)
    tooltip:removeFromUIManager()
    local tooltip = self.parent.parent.tooltip
    tooltip:setVisible(false)
    tooltip:removeFromUIManager()
end
function PhunMartUIItemsPanel:doOnMouseMove(dx, dy)

    local showInvTooltipForItem = nil
    local item = nil
    local tooltip = nil

    if not self.dragging and self.rowAt then
        if self:isMouseOver() then
            local row = self:rowAt(self:getMouseX(), self:getMouseY())
            if row then
                item = self.items[row] and self.items[row].item
                if item then
                    tooltip = self.parent.parent.tooltip
                    if item.display.type == "ITEM" then
                        showInvTooltipForItem = item
                        tooltip = self.parent.parent.invTooltip
                        local existingName = tooltip.item and tooltip.item.getFullName and tooltip.item:getFullName() or
                                                 nil
                        if showInvTooltipForItem.display.label ~= existingName then
                            local instance = instanceItem(showInvTooltipForItem.display.label)
                            tooltip:setItem(instance)
                            tooltip:setOwner(self)
                        end
                    else
                        tooltip.description = item.display.label
                    end
                end
            end
        end
    end
    if self:isMouseOver() and tooltip then
        if not tooltip:isVisible() then
            tooltip:addToUIManager();
            tooltip:setVisible(true)
        end
        tooltip:bringToTop()
    else
        if self.parent.parent.invTooltip:isVisible() then
            self.parent.parent.invTooltip:setVisible(false)
            self.parent.parent.invTooltip:removeFromUIManager()
        end
        if self.parent.parent.tooltip:isVisible() then
            self.parent.parent.tooltip:setVisible(false)
            self.parent.parent.tooltip:removeFromUIManager()
        end
    end

end

function PhunMartUIItemsPanel:onMouseDown(x, y)
    if #self.items == 0 then
        return
    end
    local row = self:rowAt(x, y)

    self.parent.activeTab = self.parent.activeView.name

    if row > #self.items then
        row = #self.items
    end

    if row < 1 then
        return
    end

    if row == self.selected and self.parent.activeTab == self.parent.activeView.name then
        return
    end

    getSoundManager():playUISound("UISelectListItem")

    self.selected = row

    if self.onmousedown then
        self.onmousedown(self.target, self.items[self.selected].item)
    end
    self.parent.parent:setSelected(self.parent.activeTab, self.items[self.selected])
end
