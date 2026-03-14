if isServer() then
    return
end
local tools = require "PhunMart_Client/ui/ui_utils"
local sandbox = SandboxVars.PhunMart

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)
local FONT_HGT_LARGE = getTextManager():getFontHeight(UIFont.Large)
local FONT_SCALE = FONT_HGT_SMALL / 14
local HEADER_HGT = FONT_HGT_MEDIUM + 2 * 2
local BUTTON_HGT = FONT_HGT_SMALL + 6
local LABEL_HGT = FONT_HGT_MEDIUM + 6

local Core = PhunMart
local profileName = "PhunMartUIItems"
Core.ui.pools_items = ISPanelJoypad:derive(profileName);
local UI = Core.ui.pools_items

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
    data[item.type] = data[item.type] == nil and true or nil

    -- range select
    if isShiftKeyDown() and self.lastSelected then
        local start = math.min(row, self.lastSelected)
        local finish = math.max(row, self.lastSelected)
        for i = start, finish do
            data[list.items[i].item.type] = data[item.type]
        end
    end

    -- remember last selected for range select
    self.lastSelected = row
end

function UI:rightClick(x, y)
    local list = self.parent.controls.list
    local row = list:rowAt(x, y)
    local row = list:rowAt(x, y)
    if row == -1 then
        return
    end
    if list.selected ~= row then
        list.selected = row
        list.selected = row
        list:ensureVisible(list.selected)
    end
    local item = list.items[list.selected].item
end

function UI:createChildren()
    ISPanelJoypad.createChildren(self)

    local padding = 10
    local x = 0
    local y = 0

    self.controls = {}
    local filtersPanelH = LABEL_HGT + BUTTON_HGT + padding * 3
    local filtersPanel = ISPanel:new(0, self.height - filtersPanelH, self.width, filtersPanelH);
    filtersPanel.drawBorder = false
    filtersPanel:initialise();
    filtersPanel:instantiate();
    filtersPanel.backgroundColor = {
        r = 0.1,
        g = 0.1,
        b = 0.1,
        a = 0.8
    }

    self.controls.filtersPanel = filtersPanel
    self:addChild(filtersPanel);

    local list = tools.getListbox(x, y, self:getWidth(), filtersPanel.y, {"Item", "Category"}, {
        draw = self.drawDatas,
        click = self.click,
        rightClick = self.rightClick
    })

    list.drawBorder = false
    self.controls.list = list
    self:addChild(list)

    local lblFilter = tools.getLabel("Filter", padding, padding)
    filtersPanel:addChild(lblFilter)

    local inputY = padding + FONT_HGT_SMALL + padding
    local filter = ISTextEntryBox:new("", padding, inputY, filtersPanel.width - 200, BUTTON_HGT);
    filter.onTextChange = function()
        self:refreshData()
    end
    self.controls.filter = filter
    filter:initialise();
    filter:instantiate();
    filtersPanel:addChild(filter);

    local left = filter.x + filter.width + padding

    local lblFilterCategory = tools.getLabel("Category", filtersPanel.width - x - left, padding)
    filtersPanel:addChild(lblFilterCategory)
    self.controls.lblFilterCategory = lblFilterCategory
    local filterCategory = ISComboBox:new(left, inputY, filtersPanel.width - x - left, FONT_HGT_MEDIUM, self, function()
        self:refreshData()
    end);
    filterCategory:initialise();
    filterCategory:instantiate();

    self.controls.filterCategory = filterCategory
    filtersPanel:addChild(filterCategory);

    self.data = {
        selected = {}
    }
    if self.listType == Core.consts.itemType.vehicles then
        self.data.categories = Core.getAllVehicleCategories()
        self.data.items = Core.getAllVehicles()
        self.tooltip = nil

        -- Split layout: list takes left 55%, preview takes right 45%
        local listW = math.floor(self.width * 0.55)
        list:setWidth(listW)

        local previewX = listW + 4
        local previewW = self.width - previewX
        local preview = ISUI3DScene:new(previewX, 0, previewW, filtersPanel.y)
        preview:initialise()
        preview.rotX = 22
        preview.rotY = 45
        preview.initialized = false
        preview.vehicleName = nil

        -- Left drag: rotate
        preview.onMouseDown = function(p, mx, my)
            p._dragX = mx;
            p._dragY = my
            p._rotX0 = p.rotX;
            p._rotY0 = p.rotY
        end
        preview.onMouseUp = function(p, mx, my)
            p._dragX = nil
        end
        preview.onMouseMove = function(p, dx, dy)
            if not p._dragX then
                return
            end
            local mx, my = p:getMouseX(), p:getMouseY()
            p.rotY = p._rotY0 + (mx - p._dragX) * 0.5
            p.rotX = p._rotX0 - (my - p._dragY) * 0.5
            p.javaObject:fromLua3("setViewRotation", p.rotX, p.rotY, 0)
        end
        -- Release drag state when cursor leaves the panel
        preview.onMouseMoveOutside = function(p, dx, dy)
            p._dragX = nil
        end

        self.previewPanel3d = preview
        self:addChild(preview)

        -- Wire list hover to update the 3D preview (capture panel ref in closure)
        local panel = self
        list.doOnMouseMove = function(lself, ddx, ddy)
            local p = panel.previewPanel3d
            if not p then
                return
            end
            local row = lself:rowAt(lself:getMouseX(), lself:getMouseY())
            if not (row and row > 0 and lself.items[row]) then
                return
            end
            local item = lself.items[row].item
            if not item or item.type == p.vehicleName then
                return
            end
            if not p.initialized then
                p.initialized = true
                p.javaObject:fromLua1("setDrawGrid", false)
                p.javaObject:fromLua1("createVehicle", "vehicle")
            end
            -- Reset view on every new vehicle
            p.rotX = 22;
            p.rotY = 45
            p._dragX = nil
            p.javaObject:fromLua3("setViewRotation", p.rotX, p.rotY, 0)
            p.javaObject:fromLua1("setView", "UserDefined")
            p.javaObject:fromLua1("setZoom", 3)
            p.vehicleName = item.type
            p.javaObject:fromLua2("setVehicleScript", "vehicle", item.type)
        end

    elseif self.listType == Core.consts.itemType.traits then
        self.data.categories = Core.getAllTraitCategories()
        self.data.items = Core.getAllTraits()
        self.tooltip = ISToolTip:new();
    elseif self.listType == Core.consts.itemType.xp then
        self.data.categories = Core.getAllXpCategories()
        self.data.items = Core.getAllXp()
        self.tooltip = ISToolTip:new();
    elseif self.listType == Core.consts.itemType.boosts then
        self.data.categories = Core.getAllBoostCategories()
        self.data.items = Core.getAllBoosts()
        self.tooltip = ISToolTip:new();
    else
        self.data.categories = Core.utils.getAllItemCategories()
        self.data.items = Core.utils.getAllItems()
        self.tooltip = ISToolTipInv:new();
    end

    if self.tooltip then
        self.tooltip:initialise();
        self.tooltip:setVisible(false);
        self.tooltip:setAlwaysOnTop(true)
        self.tooltip.description = "";
        self.tooltip:setOwner(self.controls.list)
    end

    local catMap = {}
    local categories = {}
    filterCategory:clear()
    filterCategory:addOption("")
    for _, item in ipairs(self.data.items) do
        if not catMap[item.category] then
            catMap[item.category] = true
            table.insert(categories, item.category)
        end
    end

    table.sort(categories, function(a, b)
        return a:lower() < b:lower()
    end)

    for _, category in ipairs(categories) do
        filterCategory:addOption(category)
    end

    self:refreshData()
end

function UI:prerender()

    ISPanelJoypad.prerender(self)
    local padding = 10
    local filterPanel = self.controls.filtersPanel
    filterPanel:setWidth(filterPanel.parent.width)
    filterPanel:setY(filterPanel.parent.height - filterPanel.height)

    local lblFilterCategory = self.controls.lblFilterCategory

    local filterCategory = self.controls.filterCategory
    filterCategory:setX(filterCategory.parent.width - filterCategory.width - padding)
    filterCategory:setY(lblFilterCategory.y + lblFilterCategory.height + padding)
    lblFilterCategory:setX(filterCategory.x)

    local filter = self.controls.filter
    filter:setWidth(filterCategory.x - filter.x - padding)
    filter:setY(lblFilterCategory.y + lblFilterCategory.height + padding)

    local list = self.controls.list
    list:setHeight(filterPanel.y - list.y)

    -- For vehicles, keep list at 55% and preview at 45%
    if self.previewPanel3d then
        local listW = math.floor(self.width * 0.55)
        list:setWidth(listW)
        local p = self.previewPanel3d
        p:setX(listW + 4)
        p:setWidth(self.width - listW - 4)
        p:setHeight(filterPanel.y)
    end

    if #list.columns > 1 and list.width < list.columns[#list.columns].size then
        for i = 2, #list.columns do
            list.columns[i].size = list.width / #list.columns
        end
    end

end

function UI:drawDatas(y, item, alt)
    if y + self:getYScroll() + self.itemheight < 0 or y + self:getYScroll() >= self.height then
        return y + self.itemheight
    end

    local a = 0.9;

    if self.parent.data.selected[item.item.type] then
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

    local clipX = self.columns[1].size
    local clipX2 = self.columns[2].size
    local clipY = math.max(0, y + self:getYScroll())
    local clipY2 = math.min(self.height, y + self:getYScroll() + self.itemheight)

    if item.item.texture then
        local textured = self:drawTextureScaledAspect2(item.item.texture, xoffset, y, self.itemheight - 4,
            self.itemheight - 4, 1, 1, 1, 1)
        xoffset = xoffset + self.itemheight + 4
    end

    self:setStencilRect(clipX, clipY, clipX2 - clipX, clipY2 - clipY)
    self:drawText(item.text, xoffset, y + 4, 1, 1, 1, a, self.font);
    self:clearStencilRect()

    local value = item.item.category

    local valueWidth = getTextManager():MeasureStringX(self.font, value)
    local w = self.width
    local cw = self.columns[2].size
    self:drawText(value, w - valueWidth - xoffset - 4, y + 4, 1, 1, 1, a, self.font);
    self.itemsHeight = y + self.itemheight;
    return self.itemsHeight;
end

function UI:doTooltip()

end

function UI:setData(data)

    self.data.selected = {}
    for k, item in pairs(data or {}) do
        self.data.selected[k] = true
    end
    self:refreshData()

end

function UI:doOnMouseMoveOutside(dx, dy)
    if self.tooltip then
        self.tooltip:setVisible(false)
        self.tooltip:removeFromUIManager()
    end
end

function UI:refreshData()
    self.controls.list:clear();
    self.lastSelected = nil
    local filter = self.controls.filter:getInternalText():lower()
    local category = self.controls.filterCategory:getOptionText(self.controls.filterCategory.selected)
    for _, item in ipairs(self.data.items) do
        if (filter == "" or string.match(item.label:lower(), filter)) and (category == "" or item.category == category) then
            self.controls.list:addItem(item.label, item);
        end
    end
end
