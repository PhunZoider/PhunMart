if isServer() then
    return
end

local Core = PhunMart
local ListPanel = require "PhunMart_Client/ui/base/list_panel"
local FormPanel = require "PhunMart_Client/ui/base/form_panel"
local KeyPicker = require "PhunMart_Client/ui/base/key_picker"
local DeleteHelper = require "PhunMart_Client/ui/base/delete_helper"
local PendingRestock = require "PhunMart_Client/ui/admin/pending_restock"

local PAD = ListPanel.PAD
local ROW_H = ListPanel.ROW_H
local FONT_SCALE = ListPanel.FONT_SCALE
local FONT_HGT_SMALL = ListPanel.FONT_HGT_SMALL
local FONT_HGT_MEDIUM = ListPanel.FONT_HGT_MEDIUM

Core.ui.admin_pools = ListPanel:derive("PhunPoolsAdminUI")
Core.ui.admin_pools.instances = {}
local UI = Core.ui.admin_pools
UI._defKind = "pools"

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
-- Bare count under a column headed "Groups". It used to read "1 groups" under
-- a column headed "Sources", which was both ungrammatical and repeated the same
-- word down fifty rows to say nothing.
local function formatSources(def)
    if def.sources and def.sources.groups and #def.sources.groups > 0 then
        return tostring(#def.sources.groups)
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

-- Collect sorted price keys for combo. The leading blank is the "no default
-- price" option, and lets an existing one be cleared.
local function getPriceKeys()
    local prices = Core.defs and Core.defs.prices or require "PhunMart/defaults/prices"
    local keys = {}
    for k, v in pairs(prices) do
        if not v.template then
            table.insert(keys, k)
        end
    end
    table.sort(keys)
    table.insert(keys, 1, "")
    return keys
end

-- Resolve a blacklist entry's display name. Entries may be item IDs or special
-- keys, so fall back to the raw key when the script manager doesn't know it.
local function resolveEntryName(key)
    local si = getScriptManager():getItem(key)
    return si and si:getDisplayName() or key
end

-- Options for the pool blacklist picker: everything currently blacklisted, plus
-- everything the pool can currently offer. Seeding with the existing entries
-- matters: a blacklisted item is compiled out of pool.offers entirely, so
-- without this the picker couldn't represent it and unticking would be the only
-- way to lose it.
local function getBlacklistOptions(poolKey, current)
    local seen, opts = {}, {}
    local function add(key)
        if key and key ~= "" and not seen[key] then
            seen[key] = true
            table.insert(opts, {
                key = key,
                display = resolveEntryName(key)
            })
        end
    end
    for _, k in ipairs(current or {}) do
        add(k)
    end
    local pool = poolKey and Core.runtime and Core.runtime.pools and Core.runtime.pools[poolKey]
    for _, offer in pairs(pool and pool.offers or {}) do
        add(offer.item)
    end
    table.sort(opts, function(a, b)
        return a.display:lower() < b.display:lower()
    end)
    return opts
end

-- Format the blacklist picker's summary line using display names.
local function formatBlacklistDisplay(keys)
    if not keys or #keys == 0 then
        return getText("IGUI_PhunMart_Lbl_None")
    end
    local limit = math.min(#keys, 3)
    local names = {}
    for i = 1, limit do
        names[i] = resolveEntryName(keys[i])
    end
    local text = table.concat(names, ", ")
    if #keys > limit then
        text = text .. " +" .. tostring(#keys - limit) .. " more"
    end
    return text
end

-- Reject anything in the zones field that isn't a plain number.
local function validateZones(value)
    if not value or value == "" then
        return nil
    end
    for s in value:gmatch("[^,]+") do
        if not tonumber(s:match("^%s*(.-)%s*$")) then
            return getText("IGUI_PhunMart_Err_Numeric")
        end
    end
    return nil
end

local function createEditModal(poolKey, poolDef, isNew, cb)
    local def = poolDef or {}
    local allPools = Core.defs and Core.defs.pools or require "PhunMart/defaults/pools"

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
    local selectedBlacklist = {}
    if def.blacklist then
        for _, b in ipairs(def.blacklist) do table.insert(selectedBlacklist, b) end
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
        -- Only offered on an existing entry; there is nothing to remove on an
        -- Add form. The list refreshes itself once the recompile lands.
        onDelete = (not isNew) and function(f)
            DeleteHelper.confirm("pools", poolKey, function()
                if not f._removed then
                    f._removed = true
                    f:close()
                end
            end)
        end or nil,
        onApply = function(f)
            local key = f:getFieldValue("key")

            -- Start from the existing definition so keys this form doesn't model
            -- survive the edit. Pool blacklists, written by the in-shop menu,
            -- are the ones that bite. diffTable drops anything unchanged
            -- before it reaches the override file, and emits a tombstone for
            -- anything we clear below.
            local result = Core.utils.deepCopy(def)

            -- Sources (groups only)
            result.sources = #selectedGroups > 0 and {groups = selectedGroups} or nil

            -- Emptying the blacklist relies on the tombstone: nil here makes
            -- diffTable unset the key, which is what restores a pool that was
            -- blacklisted from the in-shop menu.
            result.blacklist = #selectedBlacklist > 0 and selectedBlacklist or nil

            -- Defaults price (optional)
            local priceVal = f:getFieldValue("defaultsPrice")
            if priceVal and priceVal ~= "" then
                result.defaults = result.defaults or {}
                result.defaults.price = priceVal
            elseif result.defaults then
                result.defaults.price = nil
            end

            -- Zones (optional)
            local zones = parseCSVNumbers(f:getFieldValue("zones"))
            result.zones = zones and {difficulty = zones} or nil

            -- Fallback texture / category (optional)
            local fbTex = f:getFieldValue("fallbackTexture")
            result.fallbackTexture = (fbTex ~= "") and fbTex or nil

            local fbCat = f:getFieldValue("fallbackCategory")
            result.fallbackCategory = (fbCat ~= "") and fbCat or nil

            result.sticky = f:getFieldValue("sticky") and true or nil

            -- Only written when disabled; absent already means enabled.
            -- Clearing the key tombstones it, so re-enabling still carries.
            result.enabled = f:getFieldValue("enabled") and nil or false

            -- Cleared rather than stored empty, so an unnamed definition does
            -- not carry the key at all and falls back to showing its key.
            local title = f:getFieldValue("title")
            result.title = (title ~= "") and title or nil

            if cb then cb(key, result) end
            f:close()
        end,
    })

    form:addTextField("key", getText("IGUI_PhunMart_Lbl_Key"), {
        default = poolKey or "", editable = isNew,
        required = true,
        validate = isNew and function(value)
            if allPools[value] then
                return getText("IGUI_PhunMart_Err_KeyInUse")
            end
        end or nil,
    })
    form:addTextField("title", getText("IGUI_PhunMart_Lbl_Title"), {
        default = def.title or "",
        hint = getText("IGUI_PhunMart_Hint_Title"),
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
    form:addPickerField("blacklist", getText("IGUI_PhunMart_Lbl_BlacklistItems"), {
        value = selectedBlacklist,
        display = formatBlacklistDisplay(selectedBlacklist),
        hint = getText("IGUI_PhunMart_Hint_PoolBlacklist"),
        onPick = function(f, field)
            KeyPicker.open(getSpecificPlayer(0), getBlacklistOptions(poolKey, selectedBlacklist), selectedBlacklist,
                function(keys)
                    selectedBlacklist = keys or {}
                    f:setPickerValue("blacklist", selectedBlacklist, formatBlacklistDisplay(selectedBlacklist))
                end, {
                    title = getText("IGUI_PhunMart_Admin_PickBlacklist")
                })
        end,
    })
    form:addTextField("zones", getText("IGUI_PhunMart_Lbl_Zones"), {
        default = zonesDefault,
        hint = getText("IGUI_PhunMart_Hint_Zones"),
        validate = validateZones,
    })
    form:addComboField("defaultsPrice", getText("IGUI_PhunMart_Lbl_DefaultPrice"), {
        options = priceKeys, selected = currentPrice,
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
    PendingRestock.note("pools", key)
    if not Core.isLocal and Core.defs and Core.defs.pools then
        Core.defs.pools[key] = def
    end
end

--- Build this panel as a view for the tabbed shell. The shell owns the size
--- and position, so both are placeholders until its first layout pass.
function UI.createTab(player)
    local playerIndex = player:getPlayerNum()
    local instance = UI.instances[playerIndex]
    if not instance then
        instance = UI:new(0, 0, 100, 100, player)
        instance.description = getText("IGUI_PhunMart_Desc_PoolDefs")
        instance:initialise()
        UI.instances[playerIndex] = instance
    end
    return instance
end

function UI:createChildren()
    ListPanel.createChildren(self)

    self:addNameColumn(function(d)
        if not d.enabled then
            return 0.5, 0.5, 0.5
        elseif d.sticky then
            return 0.9, 0.85, 0.3
        end
    end)
    self:addListColumn(getText("IGUI_PhunMart_Col_Groups"), 0.46, {field = "sources"})
    -- Blank rather than 0 when there is no blacklist. Most pools have none, and
    -- a column of zeros reads as data when it is really the absence of it.
    self:addListColumn(getText("IGUI_PhunMart_Col_Blacklisted"), 0.60, {
        field = "blacklist",
        color = {0.9, 0.5, 0.5}
    })
    self:addListColumn(getText("IGUI_PhunMart_Col_Zones"), 0.74, {field = "zones", color = {0.7, 0.9, 0.7}})

    self.list.doDrawItem = ListPanel.defaultDrawRow

    -- Double-click to edit
    self.list:setOnMouseDoubleClick(self, self.GridDoubleClick)

    -- Bottom buttons: New, Edit (requires selection), View (requires selection)
    self:addBottomButton(getText("IGUI_PhunMart_Btn_New"), UI.onAddClick, false)
    self:addBottomButton(getText("IGUI_PhunMart_Btn_Edit"), UI.onEditClick, true)
    self:addBottomButton(getText("IGUI_PhunMart_Btn_View"), UI.onViewClick, true)
    self:addBottomButton(getText("IGUI_PhunMart_Btn_Delete"), UI.onDeleteClick, true)
end

function UI:getFilterText(itemData)
    -- Both, so a filter matches whichever of the two the admin thinks in.
    local text = (itemData.key or "") .. " " .. (itemData.title or "") .. " " .. (itemData.sources or "")
    if itemData.sticky then
        text = text .. " sticky"
    end
    if itemData.blacklist ~= "" then
        text = text .. " blacklist"
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
    self:sortKeysByName(keys, pools)

    for _, key in ipairs(keys) do
        local def = pools[key]
        local markers = {}
        if def.sticky then table.insert(markers, "[S]") end
        if def.enabled == false then table.insert(markers, "[off]") end
        local name, title = self:rowName(key, def, markers)
        self:addListItem(name, {
            key = key,
            name = name,
            title = title,
            sticky = def.sticky == true,
            enabled = def.enabled ~= false,
            sources = formatSources(def),
            blacklist = def.blacklist and #def.blacklist > 0 and tostring(#def.blacklist) or "",
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

function UI:onDeleteClick()
    if not self.list.selected or self.list.selected == 0 then
        return
    end
    local selectedItem = self.list.items[self.list.selected]
    if not selectedItem then
        return
    end
    DeleteHelper.confirm("pools", selectedItem.item.key, function()
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
        -- Refresh an open Pools list, matching what OnEditGroup / OnEditItem do;
        -- without this an edit made from the in-shop menu leaves the list stale.
        local inst = UI.instances[player:getPlayerNum()]
        if inst and inst:isLive() then
            inst:refreshPools()
        end
        Core.debugLn("[PhunMart] Pool " .. (isNew and "added" or "updated") .. ": " .. key)
    end)
end

UI.refresh = UI.refreshPools
