if isServer() then
    return
end

local Core = PhunMart
local ListPanel = require "PhunMart_Client/ui/base/list_panel"
local FormPanel = require "PhunMart_Client/ui/base/form_panel"
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

local function formatPrice(itemDef)
    return itemDef.price or ""
end

-- The def calls this `reward`, but "Reward" is taken: the Rewards tab is about
-- earning tokens, which is a different thing entirely. "Grants" says what the
-- relationship is without borrowing a word that already means something else.
local function formatGrants(itemDef)
    return itemDef.reward or ""
end

local function formatWeight(itemDef)
    if itemDef.offer and itemDef.offer.weight then
        return tostring(itemDef.offer.weight)
    end
    return ""
end

---------------------------------------------------------------------------
-- Edit / Add Modal (FormPanel-based)
---------------------------------------------------------------------------

local function createEditModal(itemKey, itemDef, isNew, cb)
    local def = itemDef or {}

    local items = Core.defs and Core.defs.items or require "PhunMart/defaults/items"
    local prices = Core.defs and Core.defs.prices or require "PhunMart/defaults/prices"
    local priceKeys = {""}
    for _, pk in ipairs(getSortedKeys(prices)) do table.insert(priceKeys, pk) end

    local specials = Core.defs and Core.defs.specials or require "PhunMart/defaults/specials"
    local specialKeys = {""}
    for _, sk in ipairs(getSortedKeys(specials)) do table.insert(specialKeys, sk) end

    local weightDefault = "1.0"
    if def.offer and def.offer.weight then
        weightDefault = tostring(def.offer.weight)
    end

    local stockMinDefault = ""
    local stockMaxDefault = ""
    if def.offer and def.offer.stock then
        stockMinDefault = tostring(def.offer.stock.min or "")
        stockMaxDefault = tostring(def.offer.stock.max or "")
    end

    local titleText = isNew and getText("IGUI_PhunMart_Title_AddItem") or getText("IGUI_PhunMart_Title_EditX", itemKey or "")

    local form = FormPanel:new({
        width = math.floor(380 * FONT_SCALE),
        title = titleText,
        onDelete = (not isNew) and function(f)
            DeleteHelper.confirm("items", itemKey, function()
                if not f._removed then
                    f._removed = true
                    f:close()
                end
            end)
        end or nil,
        onApply = function(f)
            local key = f:getFieldValue("key")

            -- Start from the existing definition so anything this form doesn't
            -- model survives; diffTable drops whatever is unchanged.
            local result = Core.utils.deepCopy(def)
            result.offer = result.offer or {}

            local priceVal = f:getFieldValue("price")
            result.price = (priceVal ~= "") and priceVal or nil

            local specialVal = f:getFieldValue("special")
            result.reward = (specialVal ~= "") and specialVal or nil

            result.offer.weight = f:getFieldNumber("weight") or 1.0

            local stockMin, stockMax = f:getFieldRange("stock")
            if stockMin and stockMax then
                result.offer.stock = {
                    min = math.floor(stockMin),
                    max = math.floor(stockMax)
                }
            else
                -- Blank stock means unlimited; clear any previous limit.
                result.offer.stock = nil
            end

            -- Written explicitly rather than only on false, so re-enabling is a
            -- real change the override layer can carry.
            result.enabled = f:getFieldValue("enabled") and true or false

            -- Cleared rather than written false, so an ordinary entry does not
            -- carry a key it has no use for.
            result.template = f:getFieldValue("template") and true or nil

            if cb then cb(key, result) end
            f:close()
        end,
    })

    form:addTextField("key", getText("IGUI_PhunMart_Lbl_Key"), {
        default = itemKey or "", editable = isNew,
        required = true,
        validate = isNew and function(value)
            if items[value] then
                return getText("IGUI_PhunMart_Err_KeyInUse")
            end
        end or nil,
    })
    form:addComboField("price", getText("IGUI_PhunMart_Lbl_Price"), {
        options = priceKeys, selected = def.price or priceKeys[1],
        hint = getText("IGUI_PhunMart_Hint_OptionalDefault"),
    })
    form:addComboField("special", getText("IGUI_PhunMart_Lbl_Grants"), {
        options = specialKeys, selected = def.reward or specialKeys[1],
        hint = getText("IGUI_PhunMart_Hint_OptionalDefault"),
    })
    form:addTextField("weight", getText("IGUI_PhunMart_Lbl_Weight"), {
        default = weightDefault,
        hint = getText("IGUI_PhunMart_Hint_Weight"),
        numeric = true, min = 0,
    })
    form:addRangeField("stock", getText("IGUI_PhunMart_Lbl_Stock"), {
        minDefault = stockMinDefault, maxDefault = stockMaxDefault,
        hint = getText("IGUI_PhunMart_Hint_UnlimitedStock"),
        integer = true, min = 0, requireBoth = true,
    })
    form:addCheckField("enabled", getText("IGUI_PhunMart_Lbl_Enabled"), {
        checked = def.enabled ~= false,
        text = getText("IGUI_PhunMart_Lbl_Enabled_Checkbox"),
    })
    -- Items could always be templates, the form just never let you see or set
    -- it, so the shipped ones were only editable by hand. Same field and
    -- wording as the specials form.
    form:addCheckField("template", getText("IGUI_PhunMart_Lbl_IsTemplate"), {
        checked = def.template == true,
        text = getText("IGUI_PhunMart_Lbl_IsTemplate"),
    })

    form:initialise()
    form:addToUIManager()
    form:bringToTop()
    return form
end

---------------------------------------------------------------------------
-- Main Items Panel (ListPanel subclass)
---------------------------------------------------------------------------

Core.ui.admin_items = ListPanel:derive("PhunItemsAdminUI")
Core.ui.admin_items.instances = {}
local UI = Core.ui.admin_items
UI._defKind = "items"

--- Build this panel as a view for the tabbed shell. The shell owns the size
--- and position, so both are placeholders until its first layout pass.
function UI.createTab(player)
    local playerIndex = player:getPlayerNum()
    local instance = UI.instances[playerIndex]
    if not instance then
        instance = UI:new(0, 0, 100, 100, player)
        instance.description = getText("IGUI_PhunMart_Desc_ItemDefs")
        instance:initialise()
        UI.instances[playerIndex] = instance
    end
    return instance
end

function UI.OnEditItem(player, itemKey)
    local items = Core.defs and Core.defs.items or require "PhunMart/defaults/items"
    local def = items[itemKey]
    if not def then
        return
    end
    createEditModal(itemKey, def, false, function(key, editedDef)
        sendClientCommand(Core.name, Core.commands.upsertItemDef, {key = key, def = editedDef})
        PendingRestock.note("items", key)
        if not Core.isLocal and Core.defs and Core.defs.items then
            Core.defs.items[key] = editedDef
        end
        local inst = UI.instances[player:getPlayerNum()]
        if inst and inst:isLive() then
            inst:refreshItems()
        end
    end)
end

function UI:createChildren()
    ListPanel.createChildren(self)

    self.list.doDrawItem = ListPanel.defaultDrawRow
    self.list:setOnMouseDoubleClick(self, self.onDoubleClick)

    -- Key carries the [T] and [off] suffixes, matching what pools already do
    -- with [S]. A template is not an offer any shop can roll, and until now
    -- nothing here read `template` at all, so the four shipped ones sat in the
    -- list looking exactly like live entries.
    self:addListColumn(getText("IGUI_PhunMart_Col_Key"), 0, {
        text = function(d)
            return (not d.enabled or d.template) and d.displayKey or d.key
        end,
        color = function(d)
            if not d.enabled then
                return 0.5, 0.5, 0.5
            elseif d.template then
                return 0.9, 0.85, 0.3
            end
        end
    })
    self:addListColumn(getText("IGUI_PhunMart_Col_Price"), 0.38, {field = "price"})
    self:addListColumn(getText("IGUI_PhunMart_Col_Grants"), 0.58, {field = "grants"})
    self:addListColumn(getText("IGUI_PhunMart_Col_Weight"), 0.80, {field = "weight"})

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
    DeleteHelper.confirm("items", selectedItem.item.key, function()
        self:refreshItems()
    end)
end

function UI:getFilterText(itemData)
    local text = itemData.key .. " " .. itemData.price .. " " .. itemData.grants
    if itemData.template then
        text = text .. " template"
    end
    return text
end

function UI:refreshItems()
    self:clearList()

    local items = Core.defs and Core.defs.items or require "PhunMart/defaults/items"

    local keys = {}
    for k in pairs(items) do
        table.insert(keys, k)
    end
    table.sort(keys)

    for _, key in ipairs(keys) do
        local def = items[key]
        local displayKey = key
        if def.template then
            displayKey = displayKey .. " [T]"
        end
        if def.enabled == false then
            displayKey = displayKey .. " [off]"
        end
        self:addListItem(key, {
            key = key,
            displayKey = displayKey,
            template = def.template == true,
            -- Enabled lost its column. It was a wall of "Yes" that told you
            -- nothing, and greying the row with an [off] suffix says the same
            -- thing in the space the column was taking.
            enabled = def.enabled ~= false,
            price = formatPrice(def),
            grants = formatGrants(def),
            weight = formatWeight(def),
            def = def
        })
    end
end

local function saveItemDef(self, key, def)
    sendClientCommand(Core.name, Core.commands.upsertItemDef, {key = key, def = def})
    PendingRestock.note("items", key)
    if not Core.isLocal and Core.defs and Core.defs.items then
        Core.defs.items[key] = def
    end
    self:refreshItems()
end

function UI:onAddClick()
    createEditModal(nil, nil, true, function(key, def)
        saveItemDef(self, key, def)
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
        saveItemDef(self, key, def)
    end)
end

function UI:onDoubleClick(item)
    createEditModal(item.key, item.def, false, function(key, def)
        saveItemDef(self, key, def)
    end)
end

UI.refresh = UI.refreshItems
