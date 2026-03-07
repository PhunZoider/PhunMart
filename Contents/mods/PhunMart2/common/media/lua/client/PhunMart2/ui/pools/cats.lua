if isServer() then
    return
end

local tools = require "PhunMart2/ux/tools"

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)
local FONT_HGT_LARGE = getTextManager():getFontHeight(UIFont.Large)
local FONT_SCALE = FONT_HGT_SMALL / 14
local HEADER_HGT = FONT_HGT_MEDIUM + 2 * 2

local Core = PhunMart
local profileName = "PhunMartUIPoolsCats"
Core.ui.pools_cats = ISPanelJoypad:derive(profileName);
local UI = Core.ui.pools_cats

function UI:new(x, y, width, height, options)
    local opts = options or {}
    local o = ISPanelJoypad:new(x, y, width, height);
    setmetatable(o, self);
    o.player = opts.player or getPlayer()
    o.playerIndex = o.player:getPlayerNum()
    o.listType = options.type or nil
    o.lastSelected = nil
    self.instance = o;
    return o;
end

function UI:click(x, y)
    local list = self.parent.controls.list
    self.selectedProperty = nil
    local row = list:rowAt(x, y)
    if row == nil or row == -1 then
        return
    end
    list:ensureVisible(row)
    local item = list.items[row].item
    local data = list.parent.data.selected
    data[item.label] = data[item.label] == nil and true or nil

    if isShiftKeyDown() and self.lastSelected then
        local start = math.min(row, self.lastSelected)
        local finish = math.max(row, self.lastSelected)
        for i = start, finish do
            data[list.items[i].item.label] = data[item.label]
        end
    end
    self.lastSelected = row
end

function UI:rightClick(x, y)
    local row = self.parent.controls.list:rowAt(x, y)
    if row == -1 then
        return
    end
    if self.selected ~= row then
        self.selected = row
        self.controls.list.selected = row
        self.controls.list:ensureVisible(self.list.selected)
    end
    local item = self.controls.list.items[self.list.selected].item
end

function UI:createChildren()
    ISPanelJoypad.createChildren(self)

    local padding = 10
    local x = 0
    local y = 0
    self.controls = {}
    local list = tools.getListbox(x, y, self:getWidth(), self.height - tools.HEADER_HGT, {"Category"}, {
        draw = self.drawDatas,
        click = self.click,
        rightClick = self.rightClick
    })

    self.controls.list = list
    self:addChild(list)

    -- self.controls.list = ISScrollingListBox:new(x, y, self:getWidth(), self.height - HEADER_HGT);
    -- self.controls.list:initialise();
    -- self.controls.list:instantiate();

    -- self.controls.list:setAnchorRight(true);
    -- self.controls.list:setAnchorBottom(true);

    -- self.controls.list.itemheight = FONT_HGT_SMALL + 6 * 2
    -- self.controls.list.selected = 0;
    -- self.controls.list.joypadParent = self;
    -- self.controls.list.font = UIFont.NewSmall;
    -- self.controls.list.doDrawItem = self.drawDatas;

    -- self.controls.list.onMouseUp = function(list, x, y)
    --     self.selectedProperty = nil
    --     local row = list:rowAt(x, y)
    --     if row == nil or row == -1 then
    --         return
    --     end
    --     list:ensureVisible(row)
    --     local item = list.items[row].item
    --     local data = list.parent.data.selected
    --     data[item.label] = data[item.label] == nil and true or nil

    --     if isShiftKeyDown() and self.lastSelected then
    --         local start = math.min(row, self.lastSelected)
    --         local finish = math.max(row, self.lastSelected)
    --         for i = start, finish do
    --             data[list.items[i].item.label] = data[item.label]
    --         end
    --     end
    --     self.lastSelected = row
    -- end

    -- self.controls.list.onRightMouseUp = function(target, x, y, a, b)
    --     local row = self.list:rowAt(x, y)
    --     if row == -1 then
    --         return
    --     end
    --     if self.selected ~= row then
    --         self.selected = row
    --         self.list.selected = row
    --         self.list:ensureVisible(self.list.selected)
    --     end
    --     local item = self.list.items[self.list.selected].item

    -- end
    -- self.controls.list.drawBorder = true;
    -- self.controls.list:addColumn("Category", 0);
    -- self:addChild(self.controls.list);

    self.data = {
        selected = {}
    }

    if self.listType == Core.consts.itemType.vehicles then
        self.data.categories = Core.getAllVehicleCategories()
    elseif self.listType == Core.consts.itemType.traits then
        self.data.categories = Core.getAllTraitCategories()
    elseif self.listType == Core.consts.itemType.xp then
        self.data.categories = Core.getAllXpCategories()
    elseif self.listType == Core.consts.itemType.boosts then
        self.data.categories = Core.getAllBoostCategories()
    else
        -- assert Core.consts.itemType.items
        self.data.categories = Core.getAllItemCategories()
    end

end

function UI:drawDatas(y, item, alt)
    if y + self:getYScroll() + self.itemheight < 0 or y + self:getYScroll() >= self.height then
        return y + self.itemheight
    end

    local a = 0.9;

    if self.parent.data.selected[item.item.label] then
        self:drawRect(0, (y), self:getWidth(), self.itemheight, 0.4, 0.7, 0.35, 0.15);
    end

    if alt then
        self:drawRect(0, (y), self:getWidth(), self.itemheight, 0.2, 0.6, 0.5, 0.5);
    end

    self:drawRectBorder(0, (y), self:getWidth(), self.itemheight, a, self.borderColor.r, self.borderColor.g,
        self.borderColor.b);

    local iconX = 4
    local iconSize = FONT_HGT_SMALL;
    local xoffset = 10;

    self:drawText(item.text, xoffset, y + 4, 1, 1, 1, a, self.font);

    self.itemsHeight = y + self.itemheight;
    return self.itemsHeight;
end

function UI:setData(data)

    self.controls.list:clear();
    self.lastSelected = nil

    self.data.selected = {}
    -- for k, item in ipairs(data or {}) do
    --     self.data.selected[k] = true
    -- end
    for k, item in pairs(data or {}) do
        self.data.selected[k] = item
    end

    for _, item in ipairs(self.data.categories or {}) do
        self.controls.list:addItem(item.label, item);
    end
end

