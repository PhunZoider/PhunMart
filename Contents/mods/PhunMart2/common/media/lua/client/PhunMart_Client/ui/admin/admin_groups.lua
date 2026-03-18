if isServer() then
    return
end

local Core = PhunMart
local ListPanel = require "PhunMart_Client/ui/base/list_panel"
local FormPanel = require "PhunMart_Client/ui/base/form_panel"
local CategoryPicker = require "PhunMart_Client/ui/base/category_picker"
local ItemPicker = require "PhunMart_Client/ui/base/item_picker"
local KeyPicker = require "PhunMart_Client/ui/base/key_picker"

local PAD = ListPanel.PAD
local ROW_H = ListPanel.ROW_H
local FONT_SCALE = ListPanel.FONT_SCALE
local FONT_HGT_SMALL = ListPanel.FONT_HGT_SMALL
local FONT_HGT_MEDIUM = ListPanel.FONT_HGT_MEDIUM
local SCROLLBAR_W = ListPanel.SCROLLBAR_W

---------------------------------------------------------------------------
-- Helpers
---------------------------------------------------------------------------

local function getSortedKeys(tbl)
    local keys = {}
    for k in pairs(tbl) do
        table.insert(keys, k)
    end
    table.sort(keys)
    return keys
end

-- Format the price column.
local function formatPrice(def)
    if def.defaults and def.defaults.price then
        return def.defaults.price
    end
    return ""
end

-- Format the include summary: categories + items + specials + specialCategories.
local function formatInclude(def)
    local parts = {}
    if def.categories then
        table.insert(parts, table.concat(def.categories, ", "))
    end
    if def.items then
        table.insert(parts, getText("IGUI_PhunMart_NItems", tostring(#def.items)))
    end
    if def.specials then
        table.insert(parts, getText("IGUI_PhunMart_NItems", tostring(#def.specials)) .. " specials")
    end
    if def.specialCategories then
        table.insert(parts, getText("IGUI_PhunMart_NSpecials", tostring(#def.specialCategories)))
    end
    if #parts == 0 then
        return ""
    end
    return table.concat(parts, " + ")
end

-- Collect unique special categories from special defs.
local function getSpecialCategories()
    local specials = Core.defs and Core.defs.specials or require "PhunMart/defaults/specials"
    local catSet = {}
    for _, def in pairs(specials) do
        if def.category and def.category ~= "" then
            catSet[def.category] = true
        end
    end
    local sorted = {}
    for cat in pairs(catSet) do
        table.insert(sorted, cat)
    end
    table.sort(sorted)
    return sorted
end

-- Format the blacklist summary.
local function formatBlacklist(def)
    local count = 0
    if def.blacklist then
        count = count + #def.blacklist
    end
    if def.blacklistCategories then
        count = count + #def.blacklistCategories
    end
    if count == 0 then
        return ""
    end
    return tostring(count)
end

-- Format weight for display.
local function formatWeight(def)
    if def.defaults and def.defaults.offer and def.defaults.offer.weight then
        return tostring(def.defaults.offer.weight)
    end
    return ""
end

---------------------------------------------------------------------------
-- Edit / Add Modal (FormPanel-based)
---------------------------------------------------------------------------

-- Format a list of item keys as "Name1, Name2, Name3 +X more" or "(none)".
local function formatItemList(keys)
    if not keys or #keys == 0 then
        return getText("IGUI_PhunMart_Lbl_None")
    end
    local names = {}
    local limit = math.min(#keys, 3)
    for i = 1, limit do
        local si = getScriptManager():getItem(keys[i])
        names[i] = si and si:getDisplayName() or keys[i]
    end
    local text = table.concat(names, ", ")
    if #keys > 3 then
        text = text .. " +" .. tostring(#keys - 3) .. " more"
    end
    return text
end

local function formatCatList(keys)
    if not keys or #keys == 0 then
        return getText("IGUI_PhunMart_Lbl_None")
    end
    local limit = 3
    local show = math.min(#keys, limit)
    local parts = {}
    for i = 1, show do
        table.insert(parts, keys[i])
    end
    local text = table.concat(parts, ", ")
    if #keys > limit then
        text = text .. " +" .. tostring(#keys - limit) .. " more"
    end
    return text
end

local function createEditModal(groupKey, groupDef, isNew, cb)
    local def = groupDef or {}
    local defaults = def.defaults or {}
    local offer = defaults.offer or {}

    local prices = Core.defs and Core.defs.prices or require "PhunMart/defaults/prices"
    local priceOpts = {""}
    local priceKeys = getSortedKeys(prices)
    for _, pk in ipairs(priceKeys) do table.insert(priceOpts, pk) end

    local specials = Core.defs and Core.defs.specials or require "PhunMart/defaults/specials"
    local specialKeys = getSortedKeys(specials)

    -- Resolve initial special for picker display
    local selectedSpecial = defaults.reward or nil

    -- Copy arrays so picker mutations don't affect original defs
    local selectedCats = {}
    if def.categories then for _, c in ipairs(def.categories) do table.insert(selectedCats, c) end end
    local selectedItems = {}
    if def.items then for _, item in ipairs(def.items) do table.insert(selectedItems, item) end end
    local selectedSpecialItems = {}
    if def.specials then for _, s in ipairs(def.specials) do table.insert(selectedSpecialItems, s) end end
    local selectedSpecialCats = {}
    if def.specialCategories then for _, s in ipairs(def.specialCategories) do table.insert(selectedSpecialCats, s) end end
    local specialCatOptions = getSpecialCategories()
    local selectedBlItems = {}
    if def.blacklist then for _, item in ipairs(def.blacklist) do table.insert(selectedBlItems, item) end end
    local selectedBlCats = {}
    if def.blacklistCategories then for _, c in ipairs(def.blacklistCategories) do table.insert(selectedBlCats, c) end end

    local titleText = isNew and getText("IGUI_PhunMart_Title_AddGroup") or getText("IGUI_PhunMart_Title_EditX", groupKey or "")

    local form = FormPanel:new({
        width = math.floor(480 * FONT_SCALE),
        title = titleText,
        onApply = function(f)
            local key = f:getFieldValue("key")
            if not key or key == "" then return end

            local result = { defaults = { offer = {} } }

            local priceText = f:getFieldValue("price")
            if priceText ~= "" then result.defaults.price = priceText end

            if selectedSpecial and selectedSpecial ~= "" then
                result.defaults.reward = selectedSpecial
            end

            local weight = f:getFieldNumber("weight")
            result.defaults.offer.weight = weight or 1.0

            local labelText = f:getFieldValue("label")
            if labelText ~= "" then result.label = labelText end

            if #selectedCats > 0 then result.categories = selectedCats end
            if #selectedItems > 0 then result.items = selectedItems end
            if #selectedSpecialItems > 0 then result.specials = selectedSpecialItems end
            if #selectedSpecialCats > 0 then result.specialCategories = selectedSpecialCats end

            local fbTex = f:getFieldValue("fallbackTexture")
            if fbTex and fbTex ~= "" then result.fallbackTexture = fbTex end
            local fbCat = f:getFieldValue("fallbackCategory")
            if fbCat and fbCat ~= "" then result.fallbackCategory = fbCat end

            if #selectedBlItems > 0 then result.blacklist = selectedBlItems end
            if #selectedBlCats > 0 then result.blacklistCategories = selectedBlCats end

            -- Enabled
            if not f:getFieldValue("enabled") then
                result.enabled = false
            end

            if cb then cb(key, result) end
            f:close()
        end,
    })

    form:addTextField("key", getText("IGUI_PhunMart_Lbl_Key"), {
        default = groupKey or "", editable = isNew,
    })
    form:addTextField("label", getText("IGUI_PhunMart_Lbl_Label"), {
        default = def.label or "",
        hint = getText("IGUI_PhunMart_Hint_Label"),
    })
    form:addPickerField("items", getText("IGUI_PhunMart_Lbl_Items"), {
        value = selectedItems, display = formatItemList(selectedItems),
        onPick = function(f, field)
            ItemPicker.open(getSpecificPlayer(0), selectedItems, function(keys)
                selectedItems = keys or {}
                f:setPickerValue("items", selectedItems, formatItemList(selectedItems))
            end)
        end,
    })
    form:addPickerField("cats", getText("IGUI_PhunMart_Lbl_Categories"), {
        value = selectedCats, display = formatCatList(selectedCats),
        onPick = function(f, field)
            CategoryPicker.open(getSpecificPlayer(0), selectedCats, function(keys)
                selectedCats = keys or {}
                f:setPickerValue("cats", selectedCats, formatCatList(selectedCats))
            end)
        end,
    })
    form:addPickerField("specialItems", getText("IGUI_PhunMart_Lbl_SpecialItems"), {
        value = selectedSpecialItems, display = formatItemList(selectedSpecialItems),
        onPick = function(f, field)
            KeyPicker.open(getSpecificPlayer(0), specialKeys, selectedSpecialItems, function(keys)
                selectedSpecialItems = keys or {}
                f:setPickerValue("specialItems", selectedSpecialItems, formatItemList(selectedSpecialItems))
            end, { title = getText("IGUI_PhunMart_Admin_PickSpecials") })
        end,
    })
    form:addPickerField("specialCats", getText("IGUI_PhunMart_Lbl_SpecialCats"), {
        value = selectedSpecialCats, display = formatCatList(selectedSpecialCats),
        onPick = function(f, field)
            KeyPicker.open(getSpecificPlayer(0), specialCatOptions, selectedSpecialCats, function(keys)
                selectedSpecialCats = keys or {}
                f:setPickerValue("specialCats", selectedSpecialCats, formatCatList(selectedSpecialCats))
            end, { title = getText("IGUI_PhunMart_Admin_PickSpecialCats") })
        end,
    })
    form:addPickerField("blItems", getText("IGUI_PhunMart_Lbl_BlacklistItems"), {
        value = selectedBlItems, display = formatItemList(selectedBlItems),
        onPick = function(f, field)
            ItemPicker.open(getSpecificPlayer(0), selectedBlItems, function(keys)
                selectedBlItems = keys or {}
                f:setPickerValue("blItems", selectedBlItems, formatItemList(selectedBlItems))
            end)
        end,
    })
    form:addPickerField("blCats", getText("IGUI_PhunMart_Lbl_BlacklistCats"), {
        value = selectedBlCats, display = formatCatList(selectedBlCats),
        onPick = function(f, field)
            CategoryPicker.open(getSpecificPlayer(0), selectedBlCats, function(keys)
                selectedBlCats = keys or {}
                f:setPickerValue("blCats", selectedBlCats, formatCatList(selectedBlCats))
            end)
        end,
    })
    form:addComboField("price", getText("IGUI_PhunMart_Lbl_DefaultPrice"), {
        options = priceOpts, selected = defaults.price or "",
        hint = getText("IGUI_PhunMart_Hint_OptionalDefault"),
    })
    form:addPickerField("special", getText("IGUI_PhunMart_Lbl_Special"), {
        value = selectedSpecial, display = selectedSpecial or getText("IGUI_PhunMart_Lbl_None"),
        hint = getText("IGUI_PhunMart_Hint_OptionalDefault"),
        onPick = function(f, field)
            local initial = selectedSpecial and {selectedSpecial} or {}
            KeyPicker.open(getSpecificPlayer(0), specialKeys, initial, function(key)
                selectedSpecial = key
                f:setPickerValue("special", selectedSpecial, selectedSpecial or getText("IGUI_PhunMart_Lbl_None"))
            end, { title = getText("IGUI_PhunMart_Admin_PickSpecials"), singleSelect = true })
        end,
    })
    form:addTextField("weight", getText("IGUI_PhunMart_Lbl_Weight"), {
        default = tostring(offer.weight or "1.0"),
        hint = getText("IGUI_PhunMart_Hint_WeightOverride"),
    })
    form:addTextField("fallbackTexture", getText("IGUI_PhunMart_Lbl_DefaultTexture"), {
        default = def.fallbackTexture or "",
        hint = getText("IGUI_PhunMart_Hint_DefaultTexture"),
    })
    form:addTextField("fallbackCategory", getText("IGUI_PhunMart_Lbl_DefaultCategory"), {
        default = def.fallbackCategory or "",
        hint = getText("IGUI_PhunMart_Hint_DefaultCategory"),
    })
    form:addCheckField("enabled", getText("IGUI_PhunMart_Lbl_Enabled_Checkbox"), {
        checked = def.enabled ~= false,
    })

    form:initialise()
    form:addToUIManager()
    form:bringToTop()
    return form
end

---------------------------------------------------------------------------
-- Main Groups Panel (ListPanel subclass)
---------------------------------------------------------------------------

Core.ui.admin_groups = ListPanel:derive("PhunGroupsAdminUI")
Core.ui.admin_groups.instances = {}
local UI = Core.ui.admin_groups

function UI.OnOpenPanel(player)
    local playerIndex = player:getPlayerNum()
    local instance = UI.instances[playerIndex]
    if not instance then
        local core = getCore()
        local width = math.floor(620 * FONT_SCALE)
        local height = math.floor(500 * FONT_SCALE)
        local x = (core:getScreenWidth() - width) / 2
        local y = (core:getScreenHeight() - height) / 2
        instance = UI:new(x, y, width, height, player)
        instance:setTitle(getText("IGUI_PhunMart_Title_GroupDefs"))
        instance.description = getText("IGUI_PhunMart_Desc_GroupDefs")
        instance:initialise()
        UI.instances[playerIndex] = instance
    end
    instance:addToUIManager()
    instance:setVisible(true)
    instance:refreshGroups()
    return instance
end

function UI.OnEditGroup(player, groupKey)
    local groups = Core.defs and Core.defs.groups or require "PhunMart/defaults/groups"
    local def = groups[groupKey]
    if not def then return end
    createEditModal(groupKey, def, false, function(key, editedDef)
        sendClientCommand(Core.name, Core.commands.upsertGroupDef, {key = key, def = editedDef})
        if not Core.isLocal and Core.defs and Core.defs.groups then
            Core.defs.groups[key] = editedDef
        end
        local inst = UI.instances[player:getPlayerNum()]
        if inst and inst:isVisible() then
            inst:refreshGroups()
        end
    end)
end

function UI:createChildren()
    ListPanel.createChildren(self)

    self.list.doDrawItem = self.drawRow
    self.list:setOnMouseDoubleClick(self, self.onDoubleClick)

    self:addListColumn(getText("IGUI_PhunMart_Col_Key"), 0)
    self:addListColumn(getText("IGUI_PhunMart_Col_Price"), 0.25)
    self:addListColumn(getText("IGUI_PhunMart_Col_Include"), 0.42)
    self:addListColumn(getText("IGUI_PhunMart_Col_BL"), 0.75)
    self:addListColumn(getText("IGUI_PhunMart_Col_Weight"), 0.87)

    self:addBottomButton(getText("IGUI_PhunMart_Btn_New"), self.onAddClick)
    self:addBottomButton(getText("IGUI_PhunMart_Btn_Edit"), self.onEditClick, true)
end

function UI:getFilterText(itemData)
    return itemData.key .. " " .. itemData.price .. " " .. itemData.include
end

function UI:refreshGroups()
    self:clearList()

    local groups = Core.defs and Core.defs.groups or require "PhunMart/defaults/groups"

    local keys = {}
    for k in pairs(groups) do
        table.insert(keys, k)
    end
    table.sort(keys)

    for _, key in ipairs(keys) do
        local def = groups[key]
        local displayKey = key
        if def.enabled == false then displayKey = displayKey .. " [off]" end
        self:addListItem(key, {
            key = key,
            displayKey = displayKey,
            enabled = def.enabled ~= false,
            price = formatPrice(def),
            include = formatInclude(def),
            blacklist = formatBlacklist(def),
            weight = formatWeight(def),
            def = def
        })
    end
end

local function saveGroupDef(self, key, def)
    sendClientCommand(Core.name, Core.commands.upsertGroupDef, {key = key, def = def})
    if not Core.isLocal and Core.defs and Core.defs.groups then
        Core.defs.groups[key] = def
    end
    self:refreshGroups()
end

function UI:onAddClick()
    createEditModal(nil, nil, true, function(key, def)
        saveGroupDef(self, key, def)
    end)
end

function UI:onEditClick()
    if not self.list.selected or self.list.selected == 0 then
        return
    end
    local selectedItem = self.list.items[self.list.selected]
    if not selectedItem then
        return
    end
    local data = selectedItem.item
    createEditModal(data.key, data.def, false, function(key, def)
        saveGroupDef(self, key, def)
    end)
end

function UI:onDoubleClick(item)
    createEditModal(item.key, item.def, false, function(key, def)
        saveGroupDef(self, key, def)
    end)
end

function UI:close()
    ISCollapsableWindowJoypad.close(self)
    UI.instances[self.playerIndex] = nil
end

function UI:drawRow(y, item, alt)
    if y + self:getYScroll() + self.itemheight < 0 or y + self:getYScroll() >= self.height then
        return y + self.itemheight
    end

    local a = 0.9
    local textY = y + (self.itemheight - FONT_HGT_SMALL) / 2

    if self.selected == item.index then
        self:drawRect(0, y, self:getWidth(), self.itemheight, 0.3, 0.7, 0.35, 0.15)
    end
    if alt then
        self:drawRect(0, y, self:getWidth(), self.itemheight, 0.3, 0.6, 0.5, 0.5)
    end
    self:drawRectBorder(0, y, self:getWidth(), self.itemheight, a, self.borderColor.r, self.borderColor.g,
        self.borderColor.b)

    local xoffset = 10
    local data = item.item

    local col1X = self.columns[1].size
    local col2X = self.columns[2].size
    local col3X = self.columns[3].size
    local col4X = self.columns[4].size
    local col5X = self.columns[5].size
    local clipY = math.max(0, y + self:getYScroll())
    local clipY2 = math.min(self.height, y + self:getYScroll() + self.itemheight)

    -- Key column (disabled = dimmed)
    self:setStencilRect(col1X, clipY, col2X - col1X, clipY2 - clipY)
    if not data.enabled then
        self:drawText(data.displayKey, xoffset, textY, 0.5, 0.5, 0.5, a, self.font)
    else
        self:drawText(data.key, xoffset, textY, 1, 1, 1, a, self.font)
    end
    self:clearStencilRect()

    -- Price column
    self:setStencilRect(col2X, clipY, col3X - col2X, clipY2 - clipY)
    self:drawText(data.price, col2X + 4, textY, 0.8, 0.8, 0.8, a, self.font)
    self:clearStencilRect()

    -- Include column
    self:setStencilRect(col3X, clipY, col4X - col3X, clipY2 - clipY)
    self:drawText(data.include, col3X + 4, textY, 0.8, 0.8, 0.8, a, self.font)
    self:clearStencilRect()

    -- Blacklist column
    self:setStencilRect(col4X, clipY, col5X - col4X, clipY2 - clipY)
    if data.blacklist ~= "" then
        self:drawText(data.blacklist, col4X + 4, textY, 0.9, 0.5, 0.5, a, self.font)
    end
    self:clearStencilRect()

    -- Weight column
    self:drawText(data.weight, col5X + 4, textY, 0.8, 0.8, 0.8, a, self.font)

    self.itemsHeight = y + self.itemheight
    return self.itemsHeight
end
