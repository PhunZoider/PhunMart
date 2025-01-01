if isServer() then
    return
end

local sandbox = SandboxVars.PhunMart

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)
local FONT_HGT_LARGE = getTextManager():getFontHeight(UIFont.Large)
local FONT_SCALE = FONT_HGT_SMALL / 14
local HEADER_HGT = FONT_HGT_MEDIUM + 2 * 2

local PM = PhunMart
PhunMartUIAdminPoolFilters = ISPanelJoypad:derive("PhunMartUIAdminPoolFilters");
local UI = PhunMartUIAdminPoolFilters

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

    self.lblTags = ISLabel:new(padding, y, FONT_HGT_MEDIUM, "Tags", 1, 1, 1, 1, UIFont.Medium, true);
    self.lblTags:initialise();
    self:addChild(self.lblTags);

    y = y + self.lblTags.height + padding + HEADER_HGT

    self.list = ISScrollingListBox:new(0, y, self:getWidth(), 150);
    self.list:initialise();
    self.list:instantiate();
    self.list.itemheight = FONT_HGT_SMALL + 4 * 2
    self.list.selected = 0;
    self.list.joypadParent = self;
    self.list.font = UIFont.NewSmall;
    self.list.doDrawItem = self.drawDatas;

    self.list.drawBorder = true;
    self.list:addColumn("Location", 0);
    self.list:addColumn("Options", 199);
    self:addChild(self.list);

    y = self.list.y + self.list.height + padding

    self.btnAdd = ISButton:new(self.width - padding - 100, y, 100, 25, "Add Filter", self, function()
        if self.list.selected and self.list.selected > 0 and self.list.items[self.list.selected] then
            local item = self.list.items[self.list.selected].item
            self:doPort(item.location.x, item.location.y, item.location.z or 0)
        end
    end);
    self.btnAdd:initialise();
    self.btnAdd:instantiate();
    self:addChild(self.btnAdd);

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

    self:setStencilRect(clipX, clipY, clipX2 - clipX, clipY2 - clipY)
    self:drawText(item.text, xoffset, y + 4, 1, 1, 1, a, self.font);
    self:clearStencilRect()

    local value = ""

    local valueWidth = getTextManager():MeasureStringX(self.font, value)
    local w = self.width
    local cw = self.columns[2].size
    self:drawText(value, w - valueWidth - xoffset - 4, y + 4, 1, 1, 1, a, self.font);
    self.itemsHeight = y + self.itemheight;
    return self.itemsHeight;
end

local phunZone = nil
function UI:setData(data)

    self.list:clear();
    if not data or not data.filters then
        return
    end

    for i, v in ipairs(data.filters.tags or {}) do
        self.list:addItem(v);
    end

end
