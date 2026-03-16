if isServer() then
    return
end

require "ISUI/ISCollapsableWindowJoypad"

local Core = PhunMart
local tools = require "PhunMart_Client/ui/ui_utils"
local ListPanel = require "PhunMart_Client/ui/base/list_panel"

local PAD = ListPanel.PAD
local ROW_H = ListPanel.ROW_H
local FONT_SCALE = ListPanel.FONT_SCALE
local FONT_HGT_SMALL = ListPanel.FONT_HGT_SMALL
local FONT_HGT_MEDIUM = ListPanel.FONT_HGT_MEDIUM
local SCROLLBAR_W = ListPanel.SCROLLBAR_W

local windowName = "PhunSpecialsAdminUI"

Core.ui.admin_specials = ListPanel:derive(windowName)
Core.ui.admin_specials.instances = {}
local UI = Core.ui.admin_specials

-- Format the kind/inherit column for display.
local function formatType(def)
    if def.template then
        return getText("IGUI_PhunMart_Template")
    end
    if def.inherit then
        return def.inherit
    end
    return def.kind or "?"
end

-- Format display text column.
local function formatDisplay(def)
    if def.display then
        return def.display.text or def.display.texture or ""
    end
    return ""
end

-- Summarise the first action for the list.
local function formatAction(def)
    if not def.actions or not def.actions[1] then
        return ""
    end
    local act = def.actions[1]
    if act.type == "addTrait" then
        return "+" .. (act.trait or "")
    elseif act.type == "removeTrait" then
        return "-" .. (act.trait or "")
    elseif act.type == "spawnVehicle" then
        return "vehicle:" .. (act.script or (act.scripts and act.scripts[1]) or "")
    elseif act.type == "grantBoundTokens" then
        return tostring(act.amount or 0) .. " tokens"
    end
    return act.type or ""
end

---------------------------------------------------------------------------
-- Edit / Add Modal
---------------------------------------------------------------------------
local EditModal = ISCollapsableWindowJoypad:derive("PhunSpecialEditModal")

local ACTION_TYPES = {"addTrait", "removeTrait", "spawnVehicle", "grantBoundTokens"}
local KIND_OPTIONS = {"trait", "skill", "boost", "vehicle", "collector"}

function EditModal:createChildren()
    ISCollapsableWindowJoypad.createChildren(self)

    local th = self:titleBarHeight()
    local x = PAD
    local y = th + PAD
    local w = self.width - PAD * 2
    local labelW = getTextManager():MeasureStringX(UIFont.Small, "Action Arg: ") + 8

    -- Key entry
    self.keyLabel = ISLabel:new(x, y, ROW_H, getText("IGUI_PhunMart_Lbl_Key"), 1, 1, 1, 1, UIFont.Small, true)
    self.keyLabel:initialise()
    self:addChild(self.keyLabel)

    self.keyEntry = ISTextEntryBox:new(self.specialKey or "", x + labelW, y, w - labelW, ROW_H)
    self.keyEntry:initialise()
    self.keyEntry:instantiate()
    if not self.isNew then
        self.keyEntry:setEditable(false)
    end
    self:addChild(self.keyEntry)
    y = y + ROW_H + PAD

    -- Template checkbox
    self.templateCheck = ISTickBox:new(x, y, w, ROW_H, "")
    self.templateCheck:initialise()
    self.templateCheck:instantiate()
    self.templateCheck:addOption(getText("IGUI_PhunMart_Lbl_IsTemplate"), nil)
    self.templateCheck:setSelected(1, self.specialDef and self.specialDef.template or false)
    self.templateCheck.changeOptionMethod = EditModal.onTemplateChanged
    self.templateCheck.changeOptionTarget = self
    self:addChild(self.templateCheck)
    y = y + ROW_H + PAD

    -- ── Template fields ──

    -- Kind combo
    self.kindLabel = ISLabel:new(x, y, ROW_H, getText("IGUI_PhunMart_Lbl_Kind"), 1, 1, 1, 1, UIFont.Small, true)
    self.kindLabel:initialise()
    self:addChild(self.kindLabel)

    self.kindCombo = ISComboBox:new(x + labelW, y, w - labelW, ROW_H)
    self.kindCombo:initialise()
    local selectedKind = 1
    for i, k in ipairs(KIND_OPTIONS) do
        self.kindCombo:addOption(k)
        if self.specialDef and self.specialDef.kind == k then
            selectedKind = i
        end
    end
    self.kindCombo.selected = selectedKind
    self:addChild(self.kindCombo)
    y = y + ROW_H + PAD

    -- Category entry
    self.categoryLabel = ISLabel:new(x, y, ROW_H, getText("IGUI_PhunMart_Lbl_Category"), 1, 1, 1, 1, UIFont.Small, true)
    self.categoryLabel:initialise()
    self:addChild(self.categoryLabel)

    local catDefault = (self.specialDef and self.specialDef.category) or ""
    self.categoryEntry = ISTextEntryBox:new(catDefault, x + labelW, y, w - labelW, ROW_H)
    self.categoryEntry:initialise()
    self.categoryEntry:instantiate()
    self:addChild(self.categoryEntry)
    y = y + ROW_H + PAD

    -- Texture entry
    self.textureLabel = ISLabel:new(x, y, ROW_H, getText("IGUI_PhunMart_Lbl_Texture"), 1, 1, 1, 1, UIFont.Small, true)
    self.textureLabel:initialise()
    self:addChild(self.textureLabel)

    local texDefault = (self.specialDef and self.specialDef.display and self.specialDef.display.texture) or ""
    self.textureEntry = ISTextEntryBox:new(texDefault, x + labelW, y, w - labelW, ROW_H)
    self.textureEntry:initialise()
    self.textureEntry:instantiate()
    self:addChild(self.textureEntry)
    y = y + ROW_H + PAD

    -- Overlay entry
    self.overlayLabel = ISLabel:new(x, y, ROW_H, getText("IGUI_PhunMart_Lbl_Overlay"), 1, 1, 1, 1, UIFont.Small, true)
    self.overlayLabel:initialise()
    self:addChild(self.overlayLabel)

    local ovlDefault = (self.specialDef and self.specialDef.display and self.specialDef.display.overlay) or ""
    self.overlayEntry = ISTextEntryBox:new(ovlDefault, x + labelW, y, w - labelW, ROW_H)
    self.overlayEntry:initialise()
    self.overlayEntry:instantiate()
    self:addChild(self.overlayEntry)
    y = y + ROW_H + PAD

    -- ── Non-template fields ──

    -- Inherit combo
    self.inheritLabel = ISLabel:new(x, y, ROW_H, getText("IGUI_PhunMart_Lbl_Inherit"), 1, 1, 1, 1, UIFont.Small, true)
    self.inheritLabel:initialise()
    self:addChild(self.inheritLabel)

    self.inheritCombo = ISComboBox:new(x + labelW, y, w - labelW, ROW_H)
    self.inheritCombo:initialise()
    self.inheritCombo:addOption(getText("IGUI_PhunMart_Lbl_None"))
    local specials = Core.defs and Core.defs.specials or require "PhunMart/defaults/specials"
    local templateKeys = {}
    for k, v in pairs(specials) do
        if v.template then
            table.insert(templateKeys, k)
        end
    end
    table.sort(templateKeys)
    local selectedInherit = 1
    for i, tk in ipairs(templateKeys) do
        self.inheritCombo:addOption(tk)
        if self.specialDef and self.specialDef.inherit == tk then
            selectedInherit = i + 1 -- +1 for (none)
        end
    end
    self.inheritCombo.selected = selectedInherit
    self:addChild(self.inheritCombo)
    y = y + ROW_H + PAD

    -- Display text entry
    self.displayLabel = ISLabel:new(x, y, ROW_H, getText("IGUI_PhunMart_Lbl_Display"), 1, 1, 1, 1, UIFont.Small, true)
    self.displayLabel:initialise()
    self:addChild(self.displayLabel)

    local dispDefault = (self.specialDef and self.specialDef.display and self.specialDef.display.text) or ""
    self.displayEntry = ISTextEntryBox:new(dispDefault, x + labelW, y, w - labelW, ROW_H)
    self.displayEntry:initialise()
    self.displayEntry:instantiate()
    self:addChild(self.displayEntry)
    y = y + ROW_H + PAD

    -- Action type combo
    self.actionLabel = ISLabel:new(x, y, ROW_H, getText("IGUI_PhunMart_Lbl_Action"), 1, 1, 1, 1, UIFont.Small, true)
    self.actionLabel:initialise()
    self:addChild(self.actionLabel)

    self.actionCombo = ISComboBox:new(x + labelW, y, w - labelW, ROW_H, self, EditModal.onActionChanged)
    self.actionCombo:initialise()
    local selectedAction = 1
    local curAction = self.specialDef and self.specialDef.actions and self.specialDef.actions[1]
    for i, at in ipairs(ACTION_TYPES) do
        self.actionCombo:addOption(at)
        if curAction and curAction.type == at then
            selectedAction = i
        end
    end
    self.actionCombo.selected = selectedAction
    self:addChild(self.actionCombo)
    y = y + ROW_H + PAD

    -- Action arg entry (trait key, script name, or token amount depending on type)
    self.actionArgLabel = ISLabel:new(x, y, ROW_H, getText("IGUI_PhunMart_Lbl_ActionArg"), 1, 1, 1, 1, UIFont.Small,
        true)
    self.actionArgLabel:initialise()
    self:addChild(self.actionArgLabel)

    local argDefault = ""
    if curAction then
        if curAction.trait then
            argDefault = curAction.trait
        elseif curAction.script then
            argDefault = curAction.script
        elseif curAction.scripts then
            argDefault = table.concat(curAction.scripts, ", ")
        elseif curAction.amount then
            argDefault = tostring(curAction.amount)
        end
    end
    self.actionArgEntry = ISTextEntryBox:new(argDefault, x + labelW, y, w - labelW, ROW_H)
    self.actionArgEntry:initialise()
    self.actionArgEntry:instantiate()
    self:addChild(self.actionArgEntry)
    y = y + ROW_H + 2

    self.actionArgHint = ISLabel:new(x + labelW, y, FONT_HGT_SMALL, "", 0.5, 0.5, 0.5, 1, UIFont.Small, true)
    self.actionArgHint:initialise()
    self:addChild(self.actionArgHint)
    y = y + FONT_HGT_SMALL + PAD * 2

    -- Buttons
    local btnW = math.floor(80 * FONT_SCALE)
    local btnGap = PAD
    local totalBtnW = btnW * 2 + btnGap
    local btnX = (self.width - totalBtnW) / 2

    self.applyBtn = ISButton:new(btnX, y, btnW, ROW_H, getText("IGUI_PhunMart_Btn_Apply"), self, EditModal.onApply)
    self.applyBtn:initialise()
    self:addChild(self.applyBtn)

    self.cancelBtn = ISButton:new(btnX + btnW + btnGap, y, btnW, ROW_H, getText("IGUI_PhunMart_Btn_Cancel"), self,
        EditModal.onCancel)
    self.cancelBtn:initialise()
    self:addChild(self.cancelBtn)

    self:onTemplateChanged()
    self:onActionChanged()
end

function EditModal:onTemplateChanged()
    local isTpl = self.templateCheck:isSelected(1)

    -- Template fields
    self.kindLabel:setVisible(isTpl)
    self.kindCombo:setVisible(isTpl)
    self.categoryLabel:setVisible(isTpl)
    self.categoryEntry:setVisible(isTpl)
    self.textureLabel:setVisible(isTpl)
    self.textureEntry:setVisible(isTpl)
    self.overlayLabel:setVisible(isTpl)
    self.overlayEntry:setVisible(isTpl)

    -- Non-template fields
    self.inheritLabel:setVisible(not isTpl)
    self.inheritCombo:setVisible(not isTpl)
    self.displayLabel:setVisible(not isTpl)
    self.displayEntry:setVisible(not isTpl)
    self.actionLabel:setVisible(not isTpl)
    self.actionCombo:setVisible(not isTpl)
    self.actionArgLabel:setVisible(not isTpl)
    self.actionArgEntry:setVisible(not isTpl)
    self.actionArgHint:setVisible(not isTpl)
end

function EditModal:onActionChanged()
    local actionType = self.actionCombo:getSelectedText()
    if actionType == "addTrait" or actionType == "removeTrait" then
        self.actionArgHint:setName(getText("IGUI_PhunMart_Hint_TraitKey"))
    elseif actionType == "spawnVehicle" then
        self.actionArgHint:setName(getText("IGUI_PhunMart_Hint_ScriptNames"))
    elseif actionType == "grantBoundTokens" then
        self.actionArgHint:setName(getText("IGUI_PhunMart_Hint_TokenAmount"))
    else
        self.actionArgHint:setName("")
    end
end

function EditModal:onApply()
    local key = self.keyEntry:getText()
    if not key or key == "" then
        return
    end

    local def = {}
    local isTpl = self.templateCheck:isSelected(1)

    if isTpl then
        def.template = true
        def.kind = self.kindCombo:getSelectedText()
        local cat = self.categoryEntry:getText()
        if cat ~= "" then
            def.category = cat
        end
        local tex = self.textureEntry:getText()
        local ovl = self.overlayEntry:getText()
        if tex ~= "" or ovl ~= "" then
            def.display = {}
            if tex ~= "" then
                def.display.texture = tex
            end
            if ovl ~= "" then
                def.display.overlay = ovl
            end
        end
    else
        local inheritText = self.inheritCombo:getSelectedText()
        if self.inheritCombo.selected > 1 then
            def.inherit = inheritText
        end
        local dispText = self.displayEntry:getText()
        if dispText ~= "" then
            def.display = {
                text = dispText
            }
        end

        local actionType = self.actionCombo:getSelectedText()
        local argText = self.actionArgEntry:getText()
        if actionType and argText ~= "" then
            local action = {
                type = actionType
            }
            if actionType == "addTrait" or actionType == "removeTrait" then
                action.trait = argText
            elseif actionType == "spawnVehicle" then
                -- Check for comma-separated scripts
                if argText:find(",") then
                    local scripts = {}
                    for s in argText:gmatch("[^,]+") do
                        s = s:match("^%s*(.-)%s*$")
                        if s ~= "" then
                            table.insert(scripts, s)
                        end
                    end
                    action.scripts = scripts
                else
                    action.script = argText
                end
            elseif actionType == "grantBoundTokens" then
                local amt = tonumber(argText)
                if not amt then
                    return
                end
                action.amount = math.floor(amt)
            end
            def.actions = {action}
        end
    end

    if self.cb then
        self.cb(key, def)
    end

    self:close()
end

function EditModal:onCancel()
    self:close()
end

function EditModal:close()
    ISCollapsableWindowJoypad.close(self)
end

function EditModal:new(specialKey, specialDef, isNew, cb)
    local modalW = math.floor(420 * FONT_SCALE)
    -- Tall enough for all fields (template + non-template share vertical space)
    local modalH = PAD * 14 + FONT_HGT_MEDIUM + ROW_H * 11 + FONT_HGT_SMALL + PAD * 2
    local core = getCore()
    local sx = (core:getScreenWidth() - modalW) / 2
    local sy = (core:getScreenHeight() - modalH) / 2

    local o = ISCollapsableWindowJoypad:new(sx, sy, modalW, modalH)
    setmetatable(o, self)
    self.__index = self
    o.specialKey = specialKey or ""
    o.specialDef = specialDef
    o.isNew = isNew
    o.cb = cb
    o.backgroundColor = {
        r = 0.1,
        g = 0.1,
        b = 0.1,
        a = 0.95
    }
    o.resizable = false

    local titleText = isNew and getText("IGUI_PhunMart_Title_AddSpecial") or
                          getText("IGUI_PhunMart_Title_EditX", specialKey or "")
    o.title = titleText

    return o
end

---------------------------------------------------------------------------
-- Main Specials Panel
---------------------------------------------------------------------------

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
        instance:setTitle(getText("IGUI_PhunMart_Title_SpecialDefs"))
        instance.description = getText("IGUI_PhunMart_Desc_SpecialDefs")
        instance:initialise()
        UI.instances[playerIndex] = instance
    end
    instance:addToUIManager()
    instance:setVisible(true)
    instance:refreshSpecials()
    return instance
end

function UI:createChildren()
    ListPanel.createChildren(self)

    -- Columns: Key, Type, Display, Action
    self:addListColumn(getText("IGUI_PhunMart_Col_Key"), 0)
    self:addListColumn(getText("IGUI_PhunMart_Col_Type"), 0.32)
    self:addListColumn(getText("IGUI_PhunMart_Col_Display"), 0.55)
    self:addListColumn(getText("IGUI_PhunMart_Col_Action"), 0.78)

    -- Custom row drawing
    self.list.doDrawItem = self.drawRow

    -- Double-click to edit
    self.list:setOnMouseDoubleClick(self, self.onDoubleClick)

    -- Bottom buttons
    self:addBottomButton(getText("IGUI_PhunMart_Btn_Add"), UI.onAddClick, false)
    self:addBottomButton(getText("IGUI_PhunMart_Btn_Edit"), UI.onEditClick, true)
end

function UI:getFilterText(itemData)
    return (itemData.key or "") .. " " .. (itemData.typeCol or "") .. " " .. (itemData.action or "")
end

function UI:refreshSpecials()
    self:clearList()

    local specials = Core.defs and Core.defs.specials or require "PhunMart/defaults/specials"

    local keys = {}
    for k in pairs(specials) do
        table.insert(keys, k)
    end
    table.sort(keys)

    for _, key in ipairs(keys) do
        local def = specials[key]
        self:addListItem(key, {
            key = key,
            typeCol = formatType(def),
            display = formatDisplay(def),
            action = formatAction(def),
            def = def
        })
    end
end

local function saveSpecialDef(self, key, def)
    sendClientCommand(Core.name, Core.commands.upsertSpecialDef, {
        key = key,
        def = def
    })
    if not Core.isLocal and Core.defs and Core.defs.specials then
        Core.defs.specials[key] = def
    end
    self:refreshSpecials()
end

function UI:onAddClick()
    local modal = EditModal:new(nil, nil, true, function(key, def)
        saveSpecialDef(self, key, def)
    end)
    modal:initialise()
    modal:addToUIManager()
    modal:bringToTop()
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
    local modal = EditModal:new(data.key, data.def, false, function(key, def)
        saveSpecialDef(self, key, def)
    end)
    modal:initialise()
    modal:addToUIManager()
    modal:bringToTop()
end

function UI:onDoubleClick(item)
    local data = item
    local modal = EditModal:new(data.key, data.def, false, function(key, def)
        saveSpecialDef(self, key, def)
    end)
    modal:initialise()
    modal:addToUIManager()
    modal:bringToTop()
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
    local clipY = math.max(0, y + self:getYScroll())
    local clipY2 = math.min(self.height, y + self:getYScroll() + self.itemheight)

    -- Key column (gold for templates)
    local isTemplate = data.def and data.def.template
    local keyR, keyG, keyB = 1, 1, 1
    if isTemplate then
        keyR, keyG, keyB = 0.9, 0.7, 0.3
    end
    self:setStencilRect(col1X, clipY, col2X - col1X, clipY2 - clipY)
    self:drawText(data.key, xoffset, textY, keyR, keyG, keyB, a, self.font)
    self:clearStencilRect()

    -- Type column
    self:setStencilRect(col2X, clipY, col3X - col2X, clipY2 - clipY)
    self:drawText(data.typeCol, col2X + 4, textY, 0.8, 0.8, 0.8, a, self.font)
    self:clearStencilRect()

    -- Display column
    self:setStencilRect(col3X, clipY, col4X - col3X, clipY2 - clipY)
    self:drawText(data.display, col3X + 4, textY, 0.8, 0.8, 0.8, a, self.font)
    self:clearStencilRect()

    -- Action column
    local rightEdge = self.width - SCROLLBAR_W
    self:setStencilRect(col4X, clipY, rightEdge - col4X, clipY2 - clipY)
    self:drawText(data.action, col4X + 4, textY, 0.7, 0.7, 0.7, a, self.font)
    self:clearStencilRect()

    self.itemsHeight = y + self.itemheight
    return self.itemsHeight
end

function UI:close()
    ISCollapsableWindowJoypad.close(self)
    UI.instances[self.playerIndex] = nil
end
