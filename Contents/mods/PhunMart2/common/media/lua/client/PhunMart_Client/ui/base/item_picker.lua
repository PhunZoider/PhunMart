if isServer() then
    return
end

local PickerPanel = require "PhunMart_Client/ui/base/picker_panel"

local FONT_HGT_SMALL = PickerPanel.FONT_HGT_SMALL
local FONT_SCALE = PickerPanel.FONT_SCALE
local PAD = PickerPanel.PAD
local ROW_H = PickerPanel.ROW_H
local CHECK_SZ = PickerPanel.CHECK_SZ
local ICON_SZ = FONT_HGT_SMALL
local BUTTON_HGT = PickerPanel.BUTTON_HGT

local ItemPicker = PickerPanel:derive("PhunMartItemPicker")

function ItemPicker:populateItems()
    local items = getScriptManager():getAllItems()
    local catSet = {}
    for i = 0, items:size() - 1 do
        local item = items:get(i)
        if item then
            local ok, key, display, cat, tex = pcall(function()
                return item:getFullName(),
                       item:getDisplayName() or "",
                       item:getDisplayCategory() or "",
                       item:getNormalTexture()
            end)
            if ok and key then
                self:addPickerItem(key, display, {category = cat, texture = tex})
                if cat and cat ~= "" then
                    catSet[cat] = true
                end
            end
        end
    end

    -- Sort alphabetically by display name
    table.sort(self._allItems, function(a, b)
        return a.display:lower() < b.display:lower()
    end)

    -- Build category list for combo filter
    self._categories = {}
    for cat in pairs(catSet) do
        table.insert(self._categories, cat)
    end
    table.sort(self._categories)
end

function ItemPicker:createChildren()
    PickerPanel.createChildren(self)

    -- Add category combo inline after the filter entry
    local catLblW = getTextManager():MeasureStringX(UIFont.Small, getText("IGUI_PhunMart_Admin_Category")) + 8
    self._catLabel = ISLabel:new(0, PAD, BUTTON_HGT, getText("IGUI_PhunMart_Admin_Category"), 0.8, 0.8, 0.8, 1, UIFont.Small, true)
    self._catLabel:initialise()
    self._mainPanel:addChild(self._catLabel)

    local catComboW = math.floor(120 * FONT_SCALE)
    self._catCombo = ISComboBox:new(0, PAD, catComboW, BUTTON_HGT, self, function()
        self:applyFilter()
    end)
    self._catCombo:initialise()
    self._mainPanel:addChild(self._catCombo)
    self._catComboW = catComboW
    self._catLblW = catLblW

    -- Populate combo
    self._catCombo:addOption(getText("IGUI_PhunMart_Lbl_None"))  -- "All" slot
    for _, cat in ipairs(self._categories or {}) do
        self._catCombo:addOption(cat)
    end

    self._lastCatSelected = 1
end

function ItemPicker:getSelectedCategory()
    if not self._catCombo or self._catCombo.selected <= 1 then
        return nil
    end
    return self._catCombo:getSelectedText()
end

function ItemPicker:getFilterText(itemData)
    local extra = itemData.extra or {}
    return (itemData.key .. " " .. itemData.display .. " " .. (extra.category or "")):lower()
end

function ItemPicker:applyFilter()
    local filterText = self._filterEntry:getText():lower()
    self._lastFilterText = filterText
    self._lastCatSelected = self._catCombo and self._catCombo.selected or 1
    local catFilter = self:getSelectedCategory()

    self._list:clear()
    for _, entry in ipairs(self._allItems) do
        local passText = true
        local passCat = true

        if filterText ~= "" then
            local searchable = self:getFilterText(entry)
            if not searchable:find(filterText, 1, true) then
                passText = false
            end
        end

        if catFilter then
            local extra = entry.extra or {}
            if extra.category ~= catFilter then
                passCat = false
            end
        end

        if passText and passCat then
            self._list:addItem(entry.display, entry)
        end
    end
end

function ItemPicker:doDrawItem(y, item, alt, listSelf)
    if y + listSelf:getYScroll() + listSelf.itemheight < 0
        or y + listSelf:getYScroll() >= listSelf.height then
        return y + listSelf.itemheight
    end

    local entry = item.item
    local isChecked = self._selectedSet[entry.key]
    local extra = entry.extra or {}

    -- Row background
    if isChecked then
        listSelf:drawRect(0, y, listSelf:getWidth(), ROW_H, 0.25, 0.2, 0.5, 0.2)
    elseif alt then
        listSelf:drawRect(0, y, listSelf:getWidth(), ROW_H, 0.15, 0.5, 0.5, 0.5)
    end

    local cx = PAD
    local cy = y + math.floor((ROW_H - CHECK_SZ) / 2)

    -- Checkbox
    listSelf:drawRectBorder(cx, cy, CHECK_SZ, CHECK_SZ, 0.8, 0.7, 0.7, 0.7)
    if isChecked then
        listSelf:drawRect(cx + 2, cy + 2, CHECK_SZ - 4, CHECK_SZ - 4, 0.9, 0.3, 0.8, 0.3)
    end
    cx = cx + CHECK_SZ + PAD

    -- Icon
    local iy = y + math.floor((ROW_H - ICON_SZ) / 2)
    if extra.texture then
        listSelf:drawTextureScaledAspect(extra.texture, cx, iy, ICON_SZ, ICON_SZ, 0.9, 1, 1, 1)
    else
        listSelf:drawRect(cx, iy, ICON_SZ, ICON_SZ, 0.9, 0.20, 0.20, 0.20)
    end
    cx = cx + ICON_SZ + PAD

    local ty = y + math.floor((ROW_H - FONT_HGT_SMALL) / 2)
    local r, g, b = 1, 1, 1
    if isChecked then
        r, g, b = 0.7, 1.0, 0.7
    end

    -- Display name
    local catColW = math.floor(listSelf:getWidth() * 0.3)
    listSelf:drawText(entry.display, cx, ty, r, g, b, 0.9, UIFont.Small)

    -- Category (right-aligned)
    local catX = listSelf:getWidth() - catColW
    if extra.category and extra.category ~= "" then
        listSelf:drawText(extra.category, catX, ty, 0.5, 0.5, 0.5, 0.7, UIFont.Small)
    end

    return y + ROW_H
end

function ItemPicker:prerender()
    PickerPanel.prerender(self)

    -- Layout: [Filter: [____] Category: [combo▼]]  all on one row
    local w = self.width
    local filterLblW = getTextManager():MeasureStringX(UIFont.Small, getText("IGUI_PhunMart_Lbl_Filter")) + 8

    -- Category combo + label on the right end of the filter row
    local catRightEdge = w - PAD * 2
    self._catCombo:setX(catRightEdge - self._catComboW)
    self._catCombo:setY(PAD)
    self._catCombo:setWidth(self._catComboW)
    self._catLabel:setX(catRightEdge - self._catComboW - self._catLblW)
    self._catLabel:setY(PAD)

    -- Shrink the filter text entry to fit before the category label
    local filterRight = catRightEdge - self._catComboW - self._catLblW - PAD
    self._filterEntry:setWidth(filterRight - PAD - filterLblW)

    -- Check if category combo changed
    local currentCat = self._catCombo and self._catCombo.selected or 1
    local currentFilter = self._filterEntry:getText()
    if currentFilter ~= self._lastFilterText or currentCat ~= self._lastCatSelected then
        self:applyFilter()
    end
end

--- Open an item picker modal.
-- @param player        Player object
-- @param selectedKeys  Array of currently selected item keys (e.g. {"Base.Axe"}) or nil
-- @param callback      function(keys) called with array of selected item keys on OK
function ItemPicker.open(player, selectedKeys, callback)
    local core = getCore()
    local sw = core:getScreenWidth()
    local sh = core:getScreenHeight()
    local w = math.min(600, sw - 40)
    local h = math.min(600, sh - 40)
    local x = math.floor((sw - w) / 2)
    local y = math.floor((sh - h) / 2)

    local picker = ItemPicker:new(x, y, w, h, player, selectedKeys, callback)
    picker:setTitle(getText("IGUI_PhunMart_Admin_PickItems"))
    picker:initialise()
    picker:addToUIManager()
    picker:bringToTop()
    return picker
end

return ItemPicker
