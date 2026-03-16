if isServer() then
    return
end

local Core = PhunMart
local ListPanel = require "PhunMart_Client/ui/base/list_panel"
local FormPanel = require "PhunMart_Client/ui/base/form_panel"

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

local function formatSpecial(itemDef)
    return itemDef.reward or ""
end

local function formatWeight(itemDef)
    if itemDef.offer and itemDef.offer.weight then
        return tostring(itemDef.offer.weight)
    end
    return ""
end

local function formatEnabled(itemDef)
    if itemDef.enabled == false then
        return getText("IGUI_PhunMart_No")
    end
    return getText("IGUI_PhunMart_Yes")
end

---------------------------------------------------------------------------
-- Edit / Add Modal (FormPanel-based)
---------------------------------------------------------------------------

local function createEditModal(itemKey, itemDef, isNew, cb)
    local def = itemDef or {}

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
        onApply = function(f)
            local key = f:getFieldValue("key")
            if not key or key == "" then return end

            local result = {
                price = f:getFieldValue("price"),
                reward = f:getFieldValue("special"),
                offer = {}
            }

            local weight = f:getFieldNumber("weight")
            result.offer.weight = weight or 1.0

            local stockMin, stockMax = f:getFieldRange("stock")
            if stockMin and stockMax then
                result.offer.stock = {
                    min = math.floor(stockMin),
                    max = math.floor(stockMax)
                }
            end

            if not f:getFieldValue("enabled") then
                result.enabled = false
            end

            if cb then cb(key, result) end
            f:close()
        end,
    })

    form:addTextField("key", getText("IGUI_PhunMart_Lbl_Key"), {
        default = itemKey or "", editable = isNew,
    })
    form:addComboField("price", getText("IGUI_PhunMart_Lbl_Price"), {
        options = priceKeys, selected = def.price or priceKeys[1],
        hint = getText("IGUI_PhunMart_Hint_OptionalDefault"),
    })
    form:addComboField("special", getText("IGUI_PhunMart_Lbl_Special"), {
        options = specialKeys, selected = def.reward or specialKeys[1],
        hint = getText("IGUI_PhunMart_Hint_OptionalDefault"),
    })
    form:addTextField("weight", getText("IGUI_PhunMart_Lbl_Weight"), {
        default = weightDefault,
        hint = getText("IGUI_PhunMart_Hint_Weight"),
    })
    form:addRangeField("stock", getText("IGUI_PhunMart_Lbl_Stock"), {
        min = stockMinDefault, max = stockMaxDefault,
        hint = getText("IGUI_PhunMart_Hint_UnlimitedStock"),
    })
    form:addCheckField("enabled", getText("IGUI_PhunMart_Lbl_Enabled"), {
        checked = def.enabled ~= false,
        text = getText("IGUI_PhunMart_Lbl_Enabled_Checkbox"),
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

function UI.OnOpenPanel(player)
    local playerIndex = player:getPlayerNum()
    local instance = UI.instances[playerIndex]
    if not instance then
        local core = getCore()
        local width = math.floor(560 * FONT_SCALE)
        local height = math.floor(500 * FONT_SCALE)
        local x = (core:getScreenWidth() - width) / 2
        local y = (core:getScreenHeight() - height) / 2
        instance = UI:new(x, y, width, height, player)
        instance:setTitle(getText("IGUI_PhunMart_Title_ItemDefs"))
        instance.description = getText("IGUI_PhunMart_Desc_ItemDefs")
        instance:initialise()
        UI.instances[playerIndex] = instance
    end
    instance:addToUIManager()
    instance:setVisible(true)
    instance:refreshItems()
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
        if not Core.isLocal and Core.defs and Core.defs.items then
            Core.defs.items[key] = editedDef
        end
        local inst = UI.instances[player:getPlayerNum()]
        if inst and inst:isVisible() then
            inst:refreshItems()
        end
    end)
end

function UI:createChildren()
    ListPanel.createChildren(self)

    self.list.doDrawItem = self.drawRow
    self.list:setOnMouseDoubleClick(self, self.onDoubleClick)

    self:addListColumn(getText("IGUI_PhunMart_Col_Key"), 0)
    self:addListColumn(getText("IGUI_PhunMart_Col_Price"), 0.38)
    self:addListColumn(getText("IGUI_PhunMart_Col_Special"), 0.55)
    self:addListColumn(getText("IGUI_PhunMart_Col_Weight"), 0.72)
    self:addListColumn(getText("IGUI_PhunMart_Col_Enabled"), 0.85)

    self:addBottomButton(getText("IGUI_PhunMart_Btn_New"), self.onAddClick)
    self:addBottomButton(getText("IGUI_PhunMart_Btn_Edit"), self.onEditClick, true)
end

function UI:getFilterText(itemData)
    return itemData.key .. " " .. itemData.price .. " " .. itemData.special
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
        self:addListItem(key, {
            key = key,
            price = formatPrice(def),
            special = formatSpecial(def),
            weight = formatWeight(def),
            enabled = formatEnabled(def),
            def = def
        })
    end
end

local function saveItemDef(self, key, def)
    sendClientCommand(Core.name, Core.commands.upsertItemDef, {key = key, def = def})
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
    local rightEdge = self.width - SCROLLBAR_W

    local col1X = self.columns[1].size
    local col2X = self.columns[2].size
    local col3X = self.columns[3].size
    local col4X = self.columns[4].size
    local col5X = self.columns[5].size
    local clipY = math.max(0, y + self:getYScroll())
    local clipY2 = math.min(self.height, y + self:getYScroll() + self.itemheight)

    -- Key
    self:setStencilRect(col1X, clipY, col2X - col1X, clipY2 - clipY)
    self:drawText(data.key, xoffset, textY, 1, 1, 1, a, self.font)
    self:clearStencilRect()

    -- Price
    self:setStencilRect(col2X, clipY, col3X - col2X, clipY2 - clipY)
    self:drawText(data.price, col2X + 4, textY, 0.8, 0.8, 0.8, a, self.font)
    self:clearStencilRect()

    -- Special
    self:setStencilRect(col3X, clipY, col4X - col3X, clipY2 - clipY)
    self:drawText(data.special, col3X + 4, textY, 0.8, 0.8, 0.8, a, self.font)
    self:clearStencilRect()

    -- Weight
    self:setStencilRect(col4X, clipY, col5X - col4X, clipY2 - clipY)
    self:drawText(data.weight, col4X + 4, textY, 0.8, 0.8, 0.8, a, self.font)
    self:clearStencilRect()

    -- Enabled
    local enabledColor = data.enabled == getText("IGUI_PhunMart_Yes") and {0.4, 0.9, 0.4} or {0.9, 0.4, 0.4}
    self:drawText(data.enabled, col5X + 4, textY, enabledColor[1], enabledColor[2], enabledColor[3], a, self.font)

    self.itemsHeight = y + self.itemheight
    return self.itemsHeight
end
