if isServer() then
    return
end

local Core = PhunMart
local ListPanel = require "PhunMart_Client/ui/base/list_panel"
local FormPanel = require "PhunMart_Client/ui/base/form_panel"
local KeyPicker = require "PhunMart_Client/ui/base/key_picker"

local PAD = ListPanel.PAD
local ROW_H = ListPanel.ROW_H
local FONT_SCALE = ListPanel.FONT_SCALE
local FONT_HGT_SMALL = ListPanel.FONT_HGT_SMALL
local FONT_HGT_MEDIUM = ListPanel.FONT_HGT_MEDIUM

Core.ui.admin_pools = ListPanel:derive("PhunPoolsAdminUI")
Core.ui.admin_pools.instances = {}
local UI = Core.ui.admin_pools

-- Collect sorted keys from a table.
local function getSortedKeys(tbl)
    local keys = {}
    for k in pairs(tbl) do
        table.insert(keys, k)
    end
    table.sort(keys)
    return keys
end

-- Format sources summary.
local function formatSources(def)
    if def.sources and def.sources.groups then
        return getText("IGUI_PhunMart_NGroups", tostring(#def.sources.groups))
    end
    return ""
end

-- Format zones summary.
local function formatZones(def)
    if def.zones and def.zones.difficulty then
        local nums = {}
        for _, d in ipairs(def.zones.difficulty) do
            table.insert(nums, tostring(d))
        end
        return table.concat(nums, ",")
    end
    return ""
end

-- Parse a comma-separated string of numbers into an integer array. Returns nil for empty input.
local function parseCSVNumbers(text)
    if not text or text == "" then
        return nil
    end
    local result = {}
    for s in text:gmatch("[^,]+") do
        s = s:match("^%s*(.-)%s*$")
        local n = tonumber(s)
        if n then
            table.insert(result, math.floor(n))
        end
    end
    if #result == 0 then
        return nil
    end
    return result
end

---------------------------------------------------------------------------
-- Edit / Add Modal (FormPanel-based)
---------------------------------------------------------------------------

-- Format a key list as "key1, key2, key3 +X more" or "(none)".
local function formatKeyList(keys, limit)
    limit = limit or 3
    if not keys or #keys == 0 then
        return getText("IGUI_PhunMart_Lbl_None")
    end
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

-- Collect sorted price keys for combo.
local function getPriceKeys()
    local prices = Core.defs and Core.defs.prices or require "PhunMart/defaults/prices"
    local keys = {}
    for k, v in pairs(prices) do
        if not v.template then
            table.insert(keys, k)
        end
    end
    table.sort(keys)
    return keys
end

local function createEditModal(poolKey, poolDef, isNew, cb)
    local def = poolDef or {}

    local zonesDefault = ""
    if def.zones and def.zones.difficulty then
        local nums = {}
        for _, d in ipairs(def.zones.difficulty) do
            table.insert(nums, tostring(d))
        end
        zonesDefault = table.concat(nums, ", ")
    end

    -- Copy arrays for picker mutations
    local selectedGroups = {}
    if def.sources and def.sources.groups then
        for _, g in ipairs(def.sources.groups) do table.insert(selectedGroups, g) end
    end

    -- Collect available group keys for picker
    local groups = Core.defs and Core.defs.groups or require "PhunMart/defaults/groups"
    local groupOptions = getSortedKeys(groups)

    -- Price combo options
    local priceKeys = getPriceKeys()
    local currentPrice = def.defaults and def.defaults.price or ""

    local titleText = isNew and getText("IGUI_PhunMart_Title_AddPool") or getText("IGUI_PhunMart_Title_EditX", poolKey or "")

    local form = FormPanel:new({
        width = math.floor(520 * FONT_SCALE),
        title = titleText,
        onApply = function(f)
            local key = f:getFieldValue("key")
            if not key or key == "" then return end

            local result = {}

            -- Sources (groups only)
            if #selectedGroups > 0 then
                result.sources = { groups = selectedGroups }
            end

            -- Defaults price (optional)
            local priceVal = f:getFieldValue("defaultsPrice")
            if priceVal and priceVal ~= "" then
                result.defaults = result.defaults or {}
                result.defaults.price = priceVal
            end

            -- Zones (optional)
            local zones = parseCSVNumbers(f:getFieldValue("zones"))
            if zones then
                result.zones = { difficulty = zones }
            end

            -- Fallback Texture (optional)
            local fbTex = f:getFieldValue("fallbackTexture")
            if fbTex and fbTex ~= "" then
                result.fallbackTexture = fbTex
            end

            -- Fallback Category (optional)
            local fbCat = f:getFieldValue("fallbackCategory")
            if fbCat and fbCat ~= "" then
                result.fallbackCategory = fbCat
            end

            -- Sticky
            if f:getFieldValue("sticky") then
                result.sticky = true
            end

            -- Enabled
            if not f:getFieldValue("enabled") then
                result.enabled = false
            end

            if cb then cb(key, result) end
            f:close()
        end,
    })

    form:addTextField("key", getText("IGUI_PhunMart_Lbl_Key"), {
        default = poolKey or "", editable = isNew,
    })
    form:addCheckField("sticky", getText("IGUI_PhunMart_Lbl_Sticky"), {
        checked = def.sticky == true,
        text = getText("IGUI_PhunMart_Hint_Sticky"),
    })
    form:addPickerField("groups", getText("IGUI_PhunMart_Lbl_Groups"), {
        value = selectedGroups, display = formatKeyList(selectedGroups),
        onPick = function(f, field)
            KeyPicker.open(getSpecificPlayer(0), groupOptions, selectedGroups, function(keys)
                selectedGroups = keys or {}
                f:setPickerValue("groups", selectedGroups, formatKeyList(selectedGroups))
            end, { title = getText("IGUI_PhunMart_Admin_PickGroups") })
        end,
    })
    form:addTextField("zones", getText("IGUI_PhunMart_Lbl_Zones"), {
        default = zonesDefault,
        hint = getText("IGUI_PhunMart_Hint_Zones"),
    })
    form:addComboField("defaultsPrice", getText("IGUI_PhunMart_Lbl_DefaultPrice"), {
        options = priceKeys, default = currentPrice, allowEmpty = true,
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
-- Main Pools Panel
---------------------------------------------------------------------------

local function savePoolDef(key, def)
    sendClientCommand(Core.name, Core.commands.upsertPoolDef, {key = key, def = def})
    if not Core.isLocal and Core.defs and Core.defs.pools then
        Core.defs.pools[key] = def
    end
end

function UI.OnOpenPanel(player)
    local playerIndex = player:getPlayerNum()
    local instance = UI.instances[playerIndex]
    if not instance then
        local core = getCore()
        local width = math.floor(700 * FONT_SCALE)
        local height = math.floor(500 * FONT_SCALE)
        local x = (core:getScreenWidth() - width) / 2
        local y = (core:getScreenHeight() - height) / 2
        instance = UI:new(x, y, width, height, player)
        instance:setTitle(getText("IGUI_PhunMart_Title_PoolDefs"))
        instance.description = getText("IGUI_PhunMart_Desc_PoolDefs")
        instance:initialise()
        UI.instances[playerIndex] = instance
    end
    instance:addToUIManager()
    instance:setVisible(true)
    instance:refreshPools()
    return instance
end

function UI:createChildren()
    ListPanel.createChildren(self)

    -- Columns: Key, Sources, Zones
    self:addListColumn(getText("IGUI_PhunMart_Col_Key"), 0)
    self:addListColumn(getText("IGUI_PhunMart_Col_Sources"), 0.40)
    self:addListColumn(getText("IGUI_PhunMart_Col_Zones"), 0.80)

    -- Custom row renderer
    self.list.doDrawItem = self.drawDatas

    -- Double-click to edit
    self.list:setOnMouseDoubleClick(self, self.GridDoubleClick)

    -- Bottom buttons: New, Edit (requires selection), View (requires selection)
    self:addBottomButton(getText("IGUI_PhunMart_Btn_Add"), UI.onAddClick, false)
    self:addBottomButton(getText("IGUI_PhunMart_Btn_Edit"), UI.onEditClick, true)
    self:addBottomButton(getText("IGUI_PhunMart_Btn_View"), UI.onViewClick, true)
end

function UI:getFilterText(itemData)
    local text = (itemData.key or "") .. " " .. (itemData.sources or "")
    if itemData.sticky then
        text = text .. " sticky"
    end
    return text
end

function UI:refreshPools()
    self:clearList()

    local pools = Core.defs and Core.defs.pools or require "PhunMart/defaults/pools"

    local keys = {}
    for k in pairs(pools) do
        table.insert(keys, k)
    end
    table.sort(keys)

    for _, key in ipairs(keys) do
        local def = pools[key]
        local displayKey = key
        if def.sticky then displayKey = displayKey .. " [S]" end
        if def.enabled == false then displayKey = displayKey .. " [off]" end
        self:addListItem(key, {
            key = key,
            displayKey = displayKey,
            sticky = def.sticky == true,
            enabled = def.enabled ~= false,
            sources = formatSources(def),
            zones = formatZones(def),
            def = def
        })
    end
end

function UI:onAddClick()
    createEditModal(nil, nil, true, function(key, def)
        savePoolDef(key, def)
        self:refreshPools()
    end)
end

function UI:onViewClick()
    if not self.list.selected or self.list.selected == 0 then
        return
    end
    local selectedItem = self.list.items[self.list.selected]
    if not selectedItem then
        return
    end
    local poolKey = selectedItem.item.key
    local poolData = Core.runtime and Core.runtime.pools and Core.runtime.pools[poolKey]
    if poolData then
        Core.ui.client.poolViewer.open(self.player, poolKey, poolData)
    end
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
        savePoolDef(key, def)
        self:refreshPools()
    end)
end

function UI:GridDoubleClick(item)
    local data = item
    createEditModal(data.key, data.def, false, function(key, def)
        savePoolDef(key, def)
        self:refreshPools()
    end)
end

function UI:drawDatas(y, item, alt)
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
    local clipY = math.max(0, y + self:getYScroll())
    local clipY2 = math.min(self.height, y + self:getYScroll() + self.itemheight)

    -- Key column (sticky = gold, disabled = dimmed)
    self:setStencilRect(col1X, clipY, col2X - col1X, clipY2 - clipY)
    if not data.enabled then
        self:drawText(data.displayKey, xoffset, textY, 0.5, 0.5, 0.5, a, self.font)
    elseif data.sticky then
        self:drawText(data.displayKey, xoffset, textY, 0.9, 0.85, 0.3, a, self.font)
    else
        self:drawText(data.key, xoffset, textY, 1, 1, 1, a, self.font)
    end
    self:clearStencilRect()

    -- Sources column
    self:setStencilRect(col2X, clipY, col3X - col2X, clipY2 - clipY)
    self:drawText(data.sources, col2X + 4, textY, 0.8, 0.8, 0.8, a, self.font)
    self:clearStencilRect()

    -- Zones column
    if data.zones ~= "" then
        self:drawText(data.zones, col3X + 4, textY, 0.7, 0.9, 0.7, a, self.font)
    end

    self.itemsHeight = y + self.itemheight
    return self.itemsHeight
end

function UI:close()
    ISCollapsableWindowJoypad.close(self)
    UI.instances[self.playerIndex] = nil
end

-- Open the edit modal directly for a specific pool key (used by shop_main context menu).
-- Pass nil poolKey to open in "Add" mode.
function UI.OnEditPool(player, poolKey)
    local poolDef = nil
    local isNew = true
    if poolKey then
        local pools = Core.defs and Core.defs.pools or require "PhunMart/defaults/pools"
        poolDef = pools[poolKey]
        if not poolDef then
            return
        end
        isNew = false
    end
    createEditModal(poolKey, poolDef, isNew, function(key, def)
        savePoolDef(key, def)
        print("[PhunMart] Pool " .. (isNew and "added" or "updated") .. ": " .. key)
    end)
end
