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
local HEADER_H = ROW_H

local ItemPicker = PickerPanel:derive("PhunMartItemPicker")

-- Display names are not unique. A mod can ship two items both called "Jacket"
-- where only one is meant to be handed out, and the other throws tooltip errors
-- once it exists. From the name alone the two rows were identical, so the
-- picker now shows what tells them apart: the script name, and whether the game
-- itself ever crafts, forages or loots the item. The same three flags vanilla's
-- Items List shows. An item that is none of them is usually the one to leave
-- alone.

--- How the game itself hands this item out, as the words to print. nil when the
--- engine could not say, which blanks the column rather than dropping the row.
local function obtainedFor(item, words)
    local ok, craft, forage, loot = pcall(function()
        return item:isCraftRecipeProduct(), item:canBeForaged(), item:canSpawnAsLoot()
    end)
    if not ok then
        return nil
    end
    local parts = {}
    if craft then
        table.insert(parts, words.craft)
    end
    if forage then
        table.insert(parts, words.forage)
    end
    if loot then
        table.insert(parts, words.loot)
    end
    if #parts == 0 then
        return {text = words.none, none = true}
    end
    return {text = table.concat(parts, ", ")}
end

function ItemPicker:populateItems()
    local items = getScriptManager():getAllItems()
    local catSet = {}
    local words = {
        craft = getText("IGUI_PhunMart_Obtain_Craft"),
        forage = getText("IGUI_PhunMart_Obtain_Forage"),
        loot = getText("IGUI_PhunMart_Obtain_Loot"),
        none = getText("IGUI_PhunMart_Obtain_None"),
    }
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
                self:addPickerItem(key, display, {
                    category = cat,
                    texture = tex,
                    obtained = obtainedFor(item, words),
                })
                if cat and cat ~= "" then
                    catSet[cat] = true
                end
            end
        end
    end

    -- Sort alphabetically by display name, then by script name so duplicate
    -- names always come out in the same order.
    table.sort(self._allItems, function(a, b)
        local an, bn = a.display:lower(), b.display:lower()
        if an ~= bn then
            return an < bn
        end
        return a.key < b.key
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

    -- Column headings, drawn on the content panel in the strip prerender leaves
    -- above the list. The list's own rows scroll, so they cannot carry them.
    local mainRender = self._mainPanel.render
    self._mainPanel.render = function(panel)
        mainRender(panel)
        self:drawHeader(panel)
    end
end

--- Where each column starts, relative to the list's left edge. Shared by the
--- header and the rows so the two cannot drift apart.
function ItemPicker:columnLayout(listW)
    local nameX = PAD + CHECK_SZ + PAD
    if not self._noIcons then
        nameX = nameX + ICON_SZ + PAD
    end
    if self._noObtained then
        return {
            name = nameX,
            type = math.floor(listW * 0.42),
            category = math.floor(listW * 0.72),
            right = listW - PAD,
        }
    end
    return {
        name = nameX,
        type = math.floor(listW * 0.33),
        category = math.floor(listW * 0.58),
        obtained = math.floor(listW * 0.77),
        right = listW - PAD,
    }
end

function ItemPicker:drawHeader(panel)
    local list = self._list
    local cols = self:columnLayout(list:getWidth())
    local x0 = list:getX()
    local top = list:getY() - HEADER_H
    local ty = top + math.floor((HEADER_H - FONT_HGT_SMALL) / 2)

    panel:drawRect(x0, top, list:getWidth(), HEADER_H, 0.3, 0.4, 0.4, 0.4)
    panel:drawText(getText("IGUI_PhunMart_Col_Name"), x0 + cols.name, ty, 0.8, 0.8, 0.8, 1, UIFont.Small)
    panel:drawText(getText("IGUI_PhunMart_Col_Type"), x0 + cols.type, ty, 0.8, 0.8, 0.8, 1, UIFont.Small)
    panel:drawText(getText("IGUI_PhunMart_Col_Category"), x0 + cols.category, ty, 0.8, 0.8, 0.8, 1, UIFont.Small)
    if cols.obtained then
        panel:drawText(getText("IGUI_PhunMart_Col_Obtained"), x0 + cols.obtained, ty, 0.8, 0.8, 0.8, 1, UIFont.Small)
    end
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
    local cols = self:columnLayout(listSelf:getWidth())

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

    -- Icon. A subclass whose rows have no textures at all sets _noIcons and
    -- gets the space back, rather than a column of empty placeholders that
    -- reads as broken artwork.
    if not self._noIcons then
        local iy = y + math.floor((ROW_H - ICON_SZ) / 2)
        if extra.texture then
            listSelf:drawTextureScaledAspect(extra.texture, cx, iy, ICON_SZ, ICON_SZ, 0.9, 1, 1, 1)
        else
            listSelf:drawRect(cx, iy, ICON_SZ, ICON_SZ, 0.9, 0.20, 0.20, 0.20)
        end
    end

    local ty = y + math.floor((ROW_H - FONT_HGT_SMALL) / 2)
    local r, g, b = 1, 1, 1
    if isChecked then
        r, g, b = 0.7, 1.0, 0.7
    end

    -- Each text column is clipped to its own width, the way vanilla's Items
    -- List does it. A long name or script name would otherwise print into the
    -- next column. Clip rects are in unscrolled coordinates.
    local clipY = math.max(0, y + listSelf:getYScroll())
    local clipY2 = math.min(listSelf.height, y + listSelf:getYScroll() + ROW_H)
    local function cell(text, x, nextX, cr, cg, cb, ca)
        if not text or text == "" then
            return
        end
        listSelf:setStencilRect(x, clipY, math.max(0, nextX - PAD - x), clipY2 - clipY)
        listSelf:drawText(text, x, ty, cr, cg, cb, ca, UIFont.Small)
        listSelf:clearStencilRect()
    end

    cell(entry.display, cols.name, cols.type, r, g, b, 0.9)
    cell(entry.key, cols.type, cols.category, 0.6, 0.75, 0.9, 0.8)
    cell(extra.category, cols.category, cols.obtained or cols.right, 0.5, 0.5, 0.5, 0.7)
    if cols.obtained and extra.obtained then
        if extra.obtained.none then
            cell(extra.obtained.text, cols.obtained, cols.right, 0.9, 0.55, 0.3, 0.9)
        else
            cell(extra.obtained.text, cols.obtained, cols.right, 0.6, 0.8, 0.6, 0.8)
        end
    end
    listSelf:repaintStencilRect(0, clipY, listSelf.width, clipY2 - clipY)

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

    -- Room for the column headings. The base places the list every frame, so
    -- this moves it down after that rather than once.
    local listY = PAD + BUTTON_HGT + PAD
    local listH = self._list:getHeight()
    self._list:setY(listY + HEADER_H)
    self._list:setHeight(listH - HEADER_H)

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
    -- Wider than the rest: this one carries a category dropdown on the filter
    -- row and four text columns per row.
    local w, h = PickerPanel.sizeFor(820, 600)
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
