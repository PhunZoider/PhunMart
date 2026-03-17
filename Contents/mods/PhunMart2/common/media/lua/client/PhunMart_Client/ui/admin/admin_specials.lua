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
    elseif act.type == "adjustBalance" then
        return tostring(act.amount or 0) .. " " .. (act.pool or "change")
    end
    return act.type or ""
end

---------------------------------------------------------------------------
-- Edit / Add Modal (FormPanel-based)
---------------------------------------------------------------------------

local ACTION_TYPES = {"addTrait", "removeTrait", "spawnVehicle", "grantBoundTokens", "adjustBalance"}
local KIND_OPTIONS = {"trait", "skill", "boost", "vehicle", "collector", "pawn"}

local function getActionArgHint(actionType)
    if actionType == "addTrait" or actionType == "removeTrait" then
        return getText("IGUI_PhunMart_Hint_TraitKey")
    elseif actionType == "spawnVehicle" then
        return getText("IGUI_PhunMart_Hint_ScriptNames")
    elseif actionType == "grantBoundTokens" then
        return getText("IGUI_PhunMart_Hint_TokenAmount")
    elseif actionType == "adjustBalance" then
        return getText("IGUI_PhunMart_Hint_ChangeAmount")
    end
    return ""
end

local function createEditModal(specialKey, specialDef, isNew, cb)
    local def = specialDef or {}
    local isTpl = def.template or false

    -- Pre-compute action arg default
    local curAction = def.actions and def.actions[1]
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

    -- Build inherit options from template keys
    local specials = Core.defs and Core.defs.specials or require "PhunMart/defaults/specials"
    local inheritOptions = {getText("IGUI_PhunMart_Lbl_None")}
    local templateKeys = {}
    for k, v in pairs(specials) do
        if v.template then
            table.insert(templateKeys, k)
        end
    end
    table.sort(templateKeys)
    for _, tk in ipairs(templateKeys) do
        table.insert(inheritOptions, tk)
    end

    local inheritSelected = inheritOptions[1]
    if def.inherit then
        for _, tk in ipairs(inheritOptions) do
            if tk == def.inherit then
                inheritSelected = tk
                break
            end
        end
    end

    local titleText = isNew and getText("IGUI_PhunMart_Title_AddSpecial") or
                          getText("IGUI_PhunMart_Title_EditX", specialKey or "")

    local form = FormPanel:new({
        width = math.floor(420 * FONT_SCALE),
        title = titleText,
        onApply = function(f)
            local key = f:getFieldValue("key")
            if not key or key == "" then return end

            local result = {}
            local tpl = f:getFieldValue("template")

            if tpl then
                result.template = true
                result.kind = f:getFieldValue("kind")
                local cat = f:getFieldValue("category")
                if cat ~= "" then
                    result.category = cat
                end
                local tex = f:getFieldValue("texture")
                local ovl = f:getFieldValue("overlay")
                if tex ~= "" or ovl ~= "" then
                    result.display = {}
                    if tex ~= "" then result.display.texture = tex end
                    if ovl ~= "" then result.display.overlay = ovl end
                end
            else
                local inheritIdx = f._fieldsByKey["inherit"]._combo.selected
                if inheritIdx > 1 then
                    result.inherit = f:getFieldValue("inherit")
                end
                local dispText = f:getFieldValue("displayText")
                if dispText ~= "" then
                    result.display = { text = dispText }
                end

                local actionType = f:getFieldValue("action")
                local argText = f:getFieldValue("actionArg")
                if actionType and argText ~= "" then
                    local action = { type = actionType }
                    if actionType == "addTrait" or actionType == "removeTrait" then
                        action.trait = argText
                    elseif actionType == "spawnVehicle" then
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
                        if not amt then return end
                        action.amount = math.floor(amt)
                    end
                    result.actions = {action}
                end
            end

            if cb then cb(key, result) end
            f:close()
        end,
    })

    -- Key
    form:addTextField("key", getText("IGUI_PhunMart_Lbl_Key"), {
        default = specialKey or "", editable = isNew,
    })

    -- Template checkbox
    form:addCheckField("template", getText("IGUI_PhunMart_Lbl_IsTemplate"), {
        checked = isTpl,
        text = getText("IGUI_PhunMart_Lbl_IsTemplate"),
        onChange = function(f, field)
            local tpl = f:getFieldValue("template")
            f:setGroupVisible("template", tpl)
            f:setGroupVisible("instance", not tpl)
        end,
    })

    -- Template-only fields
    form:addComboField("kind", getText("IGUI_PhunMart_Lbl_Kind"), {
        options = KIND_OPTIONS,
        selected = def.kind or KIND_OPTIONS[1],
        group = "template",
    })
    form:addTextField("category", getText("IGUI_PhunMart_Lbl_Category"), {
        default = def.category or "",
        group = "template",
    })
    form:addTextField("texture", getText("IGUI_PhunMart_Lbl_Texture"), {
        default = (def.display and def.display.texture) or "",
        group = "template",
    })
    form:addTextField("overlay", getText("IGUI_PhunMart_Lbl_Overlay"), {
        default = (def.display and def.display.overlay) or "",
        group = "template",
    })

    -- Instance-only fields
    form:addComboField("inherit", getText("IGUI_PhunMart_Lbl_Inherit"), {
        options = inheritOptions,
        selected = inheritSelected,
        group = "instance",
    })
    form:addTextField("displayText", getText("IGUI_PhunMart_Lbl_Display"), {
        default = (def.display and def.display.text) or "",
        group = "instance",
    })
    form:addComboField("action", getText("IGUI_PhunMart_Lbl_Action"), {
        options = ACTION_TYPES,
        selected = curAction and curAction.type or ACTION_TYPES[1],
        group = "instance",
        onChange = function(f, field)
            local actionType = f:getFieldValue("action")
            f:setHintText("actionArg", getActionArgHint(actionType))
        end,
    })
    form:addTextField("actionArg", getText("IGUI_PhunMart_Lbl_ActionArg"), {
        default = argDefault,
        hint = getActionArgHint(curAction and curAction.type or ACTION_TYPES[1]),
        group = "instance",
    })

    form:initialise()

    -- Apply initial group visibility
    form:setGroupVisible("template", isTpl)
    form:setGroupVisible("instance", not isTpl)

    form:addToUIManager()
    form:bringToTop()
    return form
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
    createEditModal(nil, nil, true, function(key, def)
        saveSpecialDef(self, key, def)
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
        saveSpecialDef(self, key, def)
    end)
end

function UI:onDoubleClick(item)
    createEditModal(item.key, item.def, false, function(key, def)
        saveSpecialDef(self, key, def)
    end)
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
