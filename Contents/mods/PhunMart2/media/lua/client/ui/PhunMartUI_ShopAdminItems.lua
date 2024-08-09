if not isClient() then
    return
end

require "ISUI/ISPanel"
PhunMartUIShopAdminItems = ISPanel:derive("PhunMartUIShopAdminItems");

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)
local FONT_HGT_LARGE = getTextManager():getFontHeight(UIFont.Large)

local HEADER_HGT = FONT_HGT_MEDIUM + 2 * 2

local cache = {
    label = {},
    texture = {}
}

function PhunMartUIShopAdminItems:initialise()
    ISPanel.initialise(self);
end

function PhunMartUIShopAdminItems:new(x, y, width, height, viewer, key)
    local o = ISPanel:new(x, y, width, height);
    setmetatable(o, self);
    o.listHeaderColor = {
        r = 0.4,
        g = 0.4,
        b = 0.4,
        a = 0.3
    };
    o.borderColor = {
        r = 0.4,
        g = 0.4,
        b = 0.4,
        a = 0
    };
    o.backgroundColor = {
        r = 0,
        g = 0,
        b = 0,
        a = 1
    };
    o.buttonBorderColor = {
        r = 0.7,
        g = 0.7,
        b = 0.7,
        a = 0.5
    };
    o.totalResult = 0;
    o.filterWidgets = {};
    o.filterWidgetMap = {}
    o.key = key
    o.items = {};
    PhunMartUIShopAdminItems.instance = o;
    return o;
end

function PhunMartUIShopAdminItems:GridDoubleClick(item)
    if isAdmin() then
        PhunInfoAdminPlayersUI.OnOpenPanel(item)
    end
end

function PhunMartUIShopAdminItems:createChildren()
    ISPanel.createChildren(self);

    self.datas = ISScrollingListBox:new(0, HEADER_HGT, self.width, self.height - HEADER_HGT);
    self.datas:initialise();
    self.datas:instantiate();
    self.datas.itemheight = FONT_HGT_SMALL + 4 * 2
    self.datas.selected = 0;
    self.datas.joypadParent = self;
    self.datas.font = UIFont.NewSmall;
    self.datas.doDrawItem = self.drawDatas;
    self.datas.onMouseMove = self.doOnMouseMove
    self.datas.onMouseMoveOutside = self.doOnMouseMoveOutside
    self.datas:setOnMouseDoubleClick(self, self.GridDoubleClick)
    self.datas.drawBorder = true;
    self.datas:addColumn("Item", 0);
    self.datas:addColumn("Price", 200);
    self:addChild(self.datas);

    self.tooltip = ISToolTip:new();
    self.tooltip:initialise();
    self.tooltip:setVisible(false);
    self.tooltip:setAlwaysOnTop(true)
    self.tooltip.description = "";
    self.tooltip:setOwner(self.datas)

end

function PhunMartUIShopAdminItems:rebuild(pools)

    local items = {}
    local pm = PhunMart

    if pools and pm.defs and pm.defs.items then
        for _, poolItem in ipairs(pools.items) do
            for _, item in ipairs(poolItem.keys) do
                if not items[item] and pm.defs.items[item] then
                    local def = pm.defs.items[item]
                    local clone = PhunTools:deepCopyTable(def)
                    -- PhunMart:setDisplayValues(clone)
                    table.insert(items, clone)
                end
            end

        end
    end

    self.items = items

    table.sort(items, function(a, b)
        return (a.display or {}).labelVal < (b.display or {}).labelVal
    end)
    self.datas:clear();
    for _, item in ipairs(items) do
        self.datas:addItem(item.display and (item.display.labelVal or item.display.label) or "??", item)
    end
end

function PhunMartUIShopAdminItems:doTooltip()
    local rectWidth = 10;

    local title = "Hello";
    local description = "Tooltop desc"
    local heightPadding = 2
    local rectHeight = 100 + 100 + (heightPadding * 3);

    local x = self:getMouseX() + 20;
    local y = self:getMouseY() + 20;

    self:drawRect(x, y, rectWidth + 100, rectHeight, 1.0, 0.0, 0.0, 0.0);
    self:drawRectBorder(x, y, rectWidth + 100, rectHeight, 0.7, 0.4, 0.4, 0.4);
    self:drawText(title or "???", x + 2, y + 2, 1, 1, 1, 1);
    self:drawText(description or "???", x + 2, y + 100 + (heightPadding * 2), 1, 1, 1, 0.7);
end

function PhunMartUIShopAdminItems:doOnMouseMoveOutside(dx, dy)
    local tooltip = self.parent.tooltip
    tooltip:setVisible(false)
    tooltip:removeFromUIManager()
end

function PhunMartUIShopAdminItems:doOnMouseMove(dx, dy)

    local showInvTooltipForItem = nil
    local item = nil
    local tooltip = nil

    if not self.dragging and self.rowAt then

    end

end

function PhunMartUIShopAdminItems:drawDatas(y, item, alt)
    if y + self:getYScroll() + self.itemheight < 0 or y + self:getYScroll() >= self.height then
        return y + self.itemheight
    end

    local a = 0.9;

    if self.selected == item.index then
        self:drawRect(0, (y), self:getWidth(), self.itemheight, 0.3, 0.7, 0.35, 0.15);
    end

    if alt then
        self:drawRect(0, (y), self:getWidth(), self.itemheight, 0.3, 0.6, 0.5, 0.5);
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

    local value = tostring(item.item.key)
    local color = {
        r = 1,
        g = 1,
        b = 1,
        a = 0.9
    }

    self:setStencilRect(clipX, clipY, clipX2 - clipX, clipY2 - clipY)
    self:drawText(item.item.display.labelVal or item.item.display.label, xoffset, y + 4, color.r, color.g, color.b,
        color.a, self.font);
    self:clearStencilRect()

    local viewer = self.parent.viewer
    local valueWidth = getTextManager():MeasureStringX(self.font, value)
    local w = self.width
    local cw = self.columns[2].size
    self:drawText(value, w - valueWidth - xoffset - 4, y + 4, color.r, color.g, color.b, color.a, self.font);
    return y + self.itemheight;
end

