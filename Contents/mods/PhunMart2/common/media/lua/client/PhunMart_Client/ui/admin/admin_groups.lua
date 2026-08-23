if isServer() then
    return
end

local Core = PhunMart
local ListPanel = require "PhunMart_Client/ui/base/list_panel"
local FormPanel = require "PhunMart_Client/ui/base/form_panel"
local CategoryPicker = require "PhunMart_Client/ui/base/category_picker"
local ItemPicker = require "PhunMart_Client/ui/base/item_picker"
local VehiclePicker = require "PhunMart_Client/ui/base/vehicle_picker"
local KeyPicker = require "PhunMart_Client/ui/base/key_picker"
local DeleteHelper = require "PhunMart_Client/ui/base/delete_helper"
local PendingRestock = require "PhunMart_Client/ui/admin/pending_restock"

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
-- Vehicle scripts by their in-game labels, so the field reads as cars rather
-- than as script identifiers.
local function formatVehicleList(keys)
    if not keys or #keys == 0 then
        return getText("IGUI_PhunMart_Lbl_None")
    end
    local names = {}
    local limit = math.min(#keys, 3)
    for i = 1, limit do
        names[i] = VehiclePicker.labelFor(keys[i])
    end
    local text = table.concat(names, ", ")
    if #keys > limit then
        text = text .. " +" .. tostring(#keys - limit) .. " more"
    end
    return text
end

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

    local groups = Core.defs and Core.defs.groups or require "PhunMart/defaults/groups"
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
    -- `items` holds two different kinds of key: inventory item types, and
    -- vehicle script names. They go to different pickers because neither can
    -- list the other, and they are recombined on save. A key that resolves as
    -- neither (a typo, or a mod that is not loaded) is treated as an item, so
    -- it stays in the list rather than being quietly dropped.
    local selectedItems = {}
    local selectedVehicles = {}
    if def.items then
        for _, item in ipairs(def.items) do
            if VehiclePicker.isVehicleScript(item) then
                table.insert(selectedVehicles, item)
            else
                table.insert(selectedItems, item)
            end
        end
    end
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
        onDelete = (not isNew) and function(f)
            DeleteHelper.confirm("groups", groupKey, function()
                if not f._removed then
                    f._removed = true
                    f:close()
                end
            end)
        end or nil,
        -- A group with nothing to draw from produces no offers. Every shipped
        -- group has exactly one source, so requiring one blocks nothing real.
        validate = function(f)
            if #selectedCats == 0 and #selectedItems == 0 and #selectedVehicles == 0 and #selectedSpecialItems == 0 and
                #selectedSpecialCats == 0 then
                return getText("IGUI_PhunMart_Err_NeedItemOrCat")
            end
        end,
        onApply = function(f)
            local key = f:getFieldValue("key")

            -- Start from the existing definition so anything this form doesn't
            -- model survives; diffTable drops whatever is unchanged.
            local result = Core.utils.deepCopy(def)
            result.defaults = result.defaults or {}
            result.defaults.offer = result.defaults.offer or {}

            local priceText = f:getFieldValue("price")
            result.defaults.price = (priceText ~= "") and priceText or nil

            result.defaults.reward = (selectedSpecial and selectedSpecial ~= "") and selectedSpecial or nil

            result.defaults.offer.weight = f:getFieldNumber("weight") or 1.0

            local labelText = f:getFieldValue("label")
            result.label = (labelText ~= "") and labelText or nil

            result.categories = #selectedCats > 0 and selectedCats or nil
            -- Back into one list, the shape the compiler expects.
            local allItems = {}
            for _, k in ipairs(selectedItems) do table.insert(allItems, k) end
            for _, k in ipairs(selectedVehicles) do table.insert(allItems, k) end
            result.items = #allItems > 0 and allItems or nil
            result.specials = #selectedSpecialItems > 0 and selectedSpecialItems or nil
            result.specialCategories = #selectedSpecialCats > 0 and selectedSpecialCats or nil

            local fbTex = f:getFieldValue("fallbackTexture")
            result.fallbackTexture = (fbTex ~= "") and fbTex or nil
            local fbCat = f:getFieldValue("fallbackCategory")
            result.fallbackCategory = (fbCat ~= "") and fbCat or nil

            result.blacklist = #selectedBlItems > 0 and selectedBlItems or nil
            result.blacklistCategories = #selectedBlCats > 0 and selectedBlCats or nil

            -- Only written when disabled. Absent already means enabled, so
            -- writing true put a key in the override that said nothing and
            -- differed from a default that simply omits it. Re-enabling still
            -- carries: clearing the key tombstones it, which strips whatever
            -- was underneath and restores the implicit true.
            result.enabled = f:getFieldValue("enabled") and nil or false

            local title = f:getFieldValue("title")
            result.title = (title ~= "") and title or nil

            if cb then cb(key, result) end
            f:close()
        end,
    })

    form:addTextField("key", getText("IGUI_PhunMart_Lbl_Key"), {
        default = groupKey or "", editable = isNew,
        required = true,
        validate = isNew and function(value)
            if groups[value] then
                return getText("IGUI_PhunMart_Err_KeyInUse")
            end
        end or nil,
    })
    form:addTextField("title", getText("IGUI_PhunMart_Lbl_Title"), {
        default = def.title or "",
        hint = getText("IGUI_PhunMart_Hint_Title"),
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
    form:addPickerField("vehicles", getText("IGUI_PhunMart_Lbl_Vehicles"), {
        value = selectedVehicles,
        display = formatVehicleList(selectedVehicles),
        hint = getText("IGUI_PhunMart_Hint_GroupVehicles"),
        onPick = function(f, field)
            VehiclePicker.open(getSpecificPlayer(0), selectedVehicles, function(keys)
                selectedVehicles = keys or {}
                f:setPickerValue("vehicles", selectedVehicles, formatVehicleList(selectedVehicles))
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
    -- These two are the group's defaults, applied to every item it contains.
    -- Their hints both used to read "(optional) Leave blank for default",
    -- which is circular on a field called Default Price and says nothing at all
    -- about the far more surprising one below it: that this is what buying
    -- anything in the group actually hands the player.
    form:addComboField("price", getText("IGUI_PhunMart_Lbl_DefaultPrice"), {
        options = priceOpts, selected = defaults.price or "",
        hint = getText("IGUI_PhunMart_Hint_GroupPrice"),
    })
    form:addPickerField("special", getText("IGUI_PhunMart_Lbl_Grants"), {
        value = selectedSpecial, display = selectedSpecial or getText("IGUI_PhunMart_Lbl_None"),
        hint = getText("IGUI_PhunMart_Hint_GroupGrants"),
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
        numeric = true, min = 0,
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
UI._defKind = "groups"

--- Build this panel as a view for the tabbed shell. The shell owns the size
--- and position, so both are placeholders until its first layout pass.
function UI.createTab(player)
    local playerIndex = player:getPlayerNum()
    local instance = UI.instances[playerIndex]
    if not instance then
        instance = UI:new(0, 0, 100, 100, player)
        instance.description = getText("IGUI_PhunMart_Desc_GroupDefs")
        instance:initialise()
        UI.instances[playerIndex] = instance
    end
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
        if inst and inst:isLive() then
            inst:refreshGroups()
        end
    end)
end

function UI:createChildren()
    ListPanel.createChildren(self)

    self.list.doDrawItem = ListPanel.defaultDrawRow
    self.list:setOnMouseDoubleClick(self, self.onDoubleClick)

    self:addNameColumn(function(d)
        if not d.enabled then
            return 0.5, 0.5, 0.5
        end
    end)
    self:addListColumn(getText("IGUI_PhunMart_Col_Price"), 0.25, {field = "price"})
    self:addListColumn(getText("IGUI_PhunMart_Col_Include"), 0.42, {field = "include"})
    self:addListColumn(getText("IGUI_PhunMart_Col_Blacklisted"), 0.75, {
        field = "blacklist",
        color = {0.9, 0.5, 0.5}
    })
    self:addListColumn(getText("IGUI_PhunMart_Col_Weight"), 0.87, {field = "weight"})

    self:addBottomButton(getText("IGUI_PhunMart_Btn_New"), self.onAddClick)
    self:addBottomButton(getText("IGUI_PhunMart_Btn_Edit"), self.onEditClick, true)
    self:addBottomButton(getText("IGUI_PhunMart_Btn_Delete"), self.onDeleteClick, true)
end

function UI:onDeleteClick()
    if not self.list.selected or self.list.selected == 0 then
        return
    end
    local selectedItem = self.list.items[self.list.selected]
    if not selectedItem then
        return
    end
    DeleteHelper.confirm("groups", selectedItem.item.key, function()
        self:refreshGroups()
    end)
end

function UI:getFilterText(itemData)
    return itemData.key .. " " .. (itemData.title or "") .. " " .. itemData.price .. " " .. itemData.include
end

function UI:refreshGroups()
    self:clearList()

    local groups = Core.defs and Core.defs.groups or require "PhunMart/defaults/groups"

    local keys = {}
    for k in pairs(groups) do
        table.insert(keys, k)
    end
    self:sortKeysByName(keys, groups)

    for _, key in ipairs(keys) do
        local def = groups[key]
        local markers = {}
        if def.enabled == false then table.insert(markers, "[off]") end
        local name, title = self:rowName(key, def, markers)
        self:addListItem(name, {
            key = key,
            name = name,
            title = title,
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
    PendingRestock.note("groups", key)
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

UI.refresh = UI.refreshGroups
