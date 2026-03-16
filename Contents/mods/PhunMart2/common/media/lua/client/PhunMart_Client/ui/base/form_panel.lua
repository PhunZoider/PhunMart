if isServer() then
    return
end

require "ISUI/ISCollapsableWindowJoypad"

local tools = require "PhunMart_Client/ui/ui_utils"

local FONT_HGT_SMALL = tools.FONT_HGT_SMALL
local FONT_HGT_MEDIUM = tools.FONT_HGT_MEDIUM
local FONT_SCALE = tools.FONT_SCALE
local PAD = math.max(10, math.floor(10 * FONT_SCALE))
local ROW_H = FONT_HGT_SMALL + math.floor(6 * FONT_SCALE)
local BUTTON_HGT = tools.BUTTON_HGT

local FormPanel = ISCollapsableWindowJoypad:derive("PhunMartFormPanel")

-- Truncate text to fit within maxW pixels, appending "..." if needed.
local function truncateText(text, maxW, font)
    font = font or UIFont.Small
    if getTextManager():MeasureStringX(font, text) <= maxW then
        return text
    end
    local ellipsis = "..."
    local ellW = getTextManager():MeasureStringX(font, ellipsis)
    for i = #text, 1, -1 do
        local sub = text:sub(1, i)
        if getTextManager():MeasureStringX(font, sub) + ellW <= maxW then
            return sub .. ellipsis
        end
    end
    return ellipsis
end

-- Export constants for subclasses
FormPanel.PAD = PAD
FormPanel.ROW_H = ROW_H
FormPanel.FONT_SCALE = FONT_SCALE
FormPanel.FONT_HGT_SMALL = FONT_HGT_SMALL
FormPanel.FONT_HGT_MEDIUM = FONT_HGT_MEDIUM
FormPanel.BUTTON_HGT = BUTTON_HGT

---------------------------------------------------------------------------
-- Construction
---------------------------------------------------------------------------

function FormPanel:new(opts)
    local w = opts.width or math.floor(420 * FONT_SCALE)
    local core = getCore()
    -- Height is provisional; recalculated after fields are laid out
    local h = opts.height or 400
    local sx = (core:getScreenWidth() - w) / 2
    local sy = (core:getScreenHeight() - h) / 2

    local o = ISCollapsableWindowJoypad:new(sx, sy, w, h)
    setmetatable(o, self)
    self.__index = self
    o.backgroundColor = {
        r = 0.1,
        g = 0.1,
        b = 0.1,
        a = 0.95
    }
    o.resizable = false
    o._fields = {} -- ordered list of field descriptors
    o._fieldsByKey = {} -- key -> field descriptor
    o._groups = {} -- groupName -> {field descriptors}
    o._onApply = opts.onApply -- function(values)
    o._onCancel = opts.onCancel -- function() (optional)
    o._labelW = opts.labelWidth -- nil = auto-measure from longest label
    o._formWidth = w
    if opts.title then
        o:setTitle(opts.title)
    end
    return o
end

---------------------------------------------------------------------------
-- Field definition API (call before :initialise())
--
-- Each method returns self for chaining.
-- Every field has: key, label, hint (optional), group (optional), visible
---------------------------------------------------------------------------

--- Text entry field.
-- opts: { default, hint, group, editable, numbersOnly }
function FormPanel:addTextField(key, label, opts)
    opts = opts or {}
    table.insert(self._fields, {
        type = "text",
        key = key,
        label = label,
        default = opts.default or "",
        hint = opts.hint,
        group = opts.group,
        editable = opts.editable,
        numbersOnly = opts.numbersOnly,
        visible = true
    })
    self._fieldsByKey[key] = self._fields[#self._fields]
    return self
end

--- Combo box field.
-- opts: { options, selected, hint, group, onChange }
-- options: array of strings; selected: 1-based index or string value
function FormPanel:addComboField(key, label, opts)
    opts = opts or {}
    table.insert(self._fields, {
        type = "combo",
        key = key,
        label = label,
        options = opts.options or {},
        selected = opts.selected or 1,
        hint = opts.hint,
        group = opts.group,
        onChange = opts.onChange,
        visible = true
    })
    self._fieldsByKey[key] = self._fields[#self._fields]
    return self
end

--- Picker field (display label + Pick button).
-- opts: { display, hint, group, onPick }
-- onPick: function(self, fieldDesc) -- should update fieldDesc._display and call self:reflowFields()
function FormPanel:addPickerField(key, label, opts)
    opts = opts or {}
    table.insert(self._fields, {
        type = "picker",
        key = key,
        label = label,
        _value = opts.value,
        _display = opts.display or getText("IGUI_PhunMart_Lbl_None"),
        onPick = opts.onPick,
        hint = opts.hint,
        group = opts.group,
        visible = true
    })
    self._fieldsByKey[key] = self._fields[#self._fields]
    return self
end

--- Checkbox field.
-- opts: { checked, text, group, onChange }
-- text: checkbox label (defaults to label param)
function FormPanel:addCheckField(key, label, opts)
    opts = opts or {}
    table.insert(self._fields, {
        type = "check",
        key = key,
        label = label,
        checked = opts.checked or false,
        text = opts.text or label,
        group = opts.group,
        onChange = opts.onChange,
        visible = true
    })
    self._fieldsByKey[key] = self._fields[#self._fields]
    return self
end

--- Inline range field (min entry - max entry on one row).
-- opts: { min, max, hint, group }
function FormPanel:addRangeField(key, label, opts)
    opts = opts or {}
    table.insert(self._fields, {
        type = "range",
        key = key,
        label = label,
        minDefault = opts.min or "",
        maxDefault = opts.max or "",
        hint = opts.hint,
        group = opts.group,
        visible = true
    })
    self._fieldsByKey[key] = self._fields[#self._fields]
    return self
end

--- Embedded list field (scrolling list + Add/Edit/Remove buttons).
-- opts: { items, rows, group, onAdd, onEdit, onRemove, formatItem, columns, formatColumns }
-- items: array of data objects to display
-- rows: visible row count (default 4)
-- formatItem(data): returns display string for a row (used when columns not set)
-- columns: array of {name, size} where size is fractional (0 = left edge, 0.5 = midpoint)
-- formatColumns(data): returns array of cell strings matching columns order
-- onAdd(form, field): callback when Add is clicked; should call form:addListItem(key, data)
-- onEdit(form, field, index, data): callback when Edit is clicked
-- onRemove(form, field, index, data): callback when Remove is clicked
function FormPanel:addListField(key, label, opts)
    opts = opts or {}
    table.insert(self._fields, {
        type = "list",
        key = key,
        label = label,
        _items = opts.items or {},
        _rows = opts.rows or 4,
        _formatItem = opts.formatItem or function(d)
            return tostring(d)
        end,
        _columns = opts.columns,
        _formatColumns = opts.formatColumns,
        onAdd = opts.onAdd,
        onEdit = opts.onEdit,
        onRemove = opts.onRemove,
        group = opts.group,
        visible = true
    })
    self._fieldsByKey[key] = self._fields[#self._fields]
    return self
end

--- Visual separator (horizontal line + optional section label).
-- opts: { text, group }
function FormPanel:addSeparator(key, opts)
    opts = opts or {}
    table.insert(self._fields, {
        type = "separator",
        key = key,
        text = opts.text,
        group = opts.group,
        visible = true
    })
    self._fieldsByKey[key] = self._fields[#self._fields]
    return self
end

---------------------------------------------------------------------------
-- Group visibility
---------------------------------------------------------------------------

function FormPanel:setGroupVisible(groupName, visible)
    for _, f in ipairs(self._fields) do
        if f.group == groupName then
            f.visible = visible
        end
    end
    if self._built then
        self:reflowFields()
    end
end

function FormPanel:setFieldVisible(key, visible)
    local f = self._fieldsByKey[key]
    if f then
        f.visible = visible
        if self._built then
            self:reflowFields()
        end
    end
end

---------------------------------------------------------------------------
-- Value access
---------------------------------------------------------------------------

--- Get the current value of a field by key.
function FormPanel:getFieldValue(key)
    local f = self._fieldsByKey[key]
    if not f then
        return nil
    end

    if f.type == "text" then
        return f._entry and f._entry:getText() or f.default
    elseif f.type == "combo" then
        return f._combo and f._combo:getSelectedText() or ""
    elseif f.type == "picker" then
        return f._value
    elseif f.type == "check" then
        return f._tick and f._tick:isSelected(1) or false
    elseif f.type == "range" then
        local minVal = f._minEntry and f._minEntry:getText() or ""
        local maxVal = f._maxEntry and f._maxEntry:getText() or ""
        return {
            min = minVal,
            max = maxVal
        }
    elseif f.type == "list" then
        return f._items
    end
    return nil
end

--- Get a number from a text field (returns nil if blank/invalid).
function FormPanel:getFieldNumber(key)
    local val = self:getFieldValue(key)
    if type(val) == "string" then
        return tonumber(val)
    end
    return nil
end

--- Get min/max as numbers from a range field.
function FormPanel:getFieldRange(key)
    local val = self:getFieldValue(key)
    if type(val) == "table" then
        return tonumber(val.min), tonumber(val.max)
    end
    return nil, nil
end

--- Collect all visible field values into a table keyed by field key.
function FormPanel:getAllValues()
    local values = {}
    for _, f in ipairs(self._fields) do
        if f.type ~= "separator" then
            values[f.key] = self:getFieldValue(f.key)
        end
    end
    return values
end

--- Update a picker field's display text and stored value.
function FormPanel:setPickerValue(key, value, displayText)
    local f = self._fieldsByKey[key]
    if f and f.type == "picker" then
        f._value = value
        f._display = displayText or getText("IGUI_PhunMart_Lbl_None")
        if f._displayLabel then
            if f._maxDisplayW then
                f._displayLabel:setName(truncateText(f._display, f._maxDisplayW))
            else
                f._displayLabel:setName(f._display)
            end
            -- Re-apply position after setName (PZ ISLabel resets x)
            if f._fieldX then
                f._displayLabel:setX(f._fieldX)
            end
        end
    end
end

--- Update a text field's value programmatically.
function FormPanel:setFieldValue(key, value)
    local f = self._fieldsByKey[key]
    if not f then
        return
    end
    if f.type == "text" and f._entry then
        f._entry:setText(tostring(value or ""))
    elseif f.type == "combo" and f._combo then
        -- Find matching option index
        if type(value) == "number" then
            f._combo.selected = value
        elseif type(value) == "string" then
            for i = 1, #f._combo.options do
                if f._combo.options[i] == value then
                    f._combo.selected = i
                    break
                end
            end
        end
    elseif f.type == "check" and f._tick then
        f._tick:setSelected(1, value and true or false)
    end
end

--- Update a field's hint text. Re-applies position after setName to work
-- around PZ ISLabel quirk where setName resets x.
function FormPanel:setHintText(key, text)
    local f = self._fieldsByKey[key]
    if f and f._hint then
        f._hint:setName(text)
        if f._fieldX then
            f._hint:setX(f._fieldX)
        end
    end
end

---------------------------------------------------------------------------
-- List field helpers
---------------------------------------------------------------------------

--- Add an item to a list field and refresh its display.
function FormPanel:addListItem(key, data)
    local f = self._fieldsByKey[key]
    if f and f.type == "list" then
        table.insert(f._items, data)
        self:_refreshListField(f)
    end
end

--- Update an item in a list field by index.
function FormPanel:updateListItem(key, index, data)
    local f = self._fieldsByKey[key]
    if f and f.type == "list" and f._items[index] then
        f._items[index] = data
        self:_refreshListField(f)
    end
end

--- Remove an item from a list field by index.
function FormPanel:removeListItem(key, index)
    local f = self._fieldsByKey[key]
    if f and f.type == "list" and f._items[index] then
        table.remove(f._items, index)
        self:_refreshListField(f)
    end
end

--- Set the entire items array for a list field.
function FormPanel:setListItems(key, items)
    local f = self._fieldsByKey[key]
    if f and f.type == "list" then
        f._items = items or {}
        self:_refreshListField(f)
    end
end

--- Refresh the ISScrollingListBox for a list field from its _items array.
function FormPanel:_refreshListField(f)
    if not f._list then
        return
    end
    f._list:clear()
    for i, data in ipairs(f._items) do
        local display = f._formatItem(data)
        f._list:addItem(display, data)
    end
    -- Update button states
    self:_updateListButtons(f)
end

function FormPanel:_updateListButtons(f)
    local hasSel = f._list and f._list.selected and f._list.selected > 0
    if f._editBtn then
        f._editBtn:setEnable(hasSel)
    end
    if f._removeBtn then
        f._removeBtn:setEnable(hasSel)
    end
end

---------------------------------------------------------------------------
-- Build UI
---------------------------------------------------------------------------

--- Pre-compute the total height needed for all visible fields + buttons.
-- Called before ISCollapsableWindowJoypad.initialise so the window is
-- created at the correct size from the start.
function FormPanel:_computeNeededHeight()
    local th = self:titleBarHeight()
    local y = th + PAD

    for _, f in ipairs(self._fields) do
        if f.visible then
            if f.type == "separator" then
                y = y + PAD + 2
                if f.text then
                    y = y + FONT_HGT_SMALL + 2
                end
                y = y + PAD
            elseif f.type == "check" then
                y = y + ROW_H + PAD
            elseif f.type == "list" then
                y = y + FONT_HGT_SMALL + 2 -- header row (columns or label)
                y = y + (f._rows or 4) * ROW_H -- list rows
                y = y + 4 + ROW_H -- button row
                y = y + PAD
            else
                y = y + ROW_H
                if f.hint then
                    y = y + 2 + FONT_HGT_SMALL
                end
                y = y + PAD
            end
        end
    end

    -- Apply/Cancel buttons
    y = y + PAD + ROW_H + PAD
    return y
end

function FormPanel:initialise()
    -- Compute the real height before the parent lays out chrome
    local neededH = self:_computeNeededHeight()
    self.height = neededH
    local core = getCore()
    self:setY((core:getScreenHeight() - neededH) / 2)
    ISCollapsableWindowJoypad.initialise(self)
end

function FormPanel:createChildren()
    ISCollapsableWindowJoypad.createChildren(self)
    self._built = true

    -- Measure label width if not specified
    if not self._labelW then
        local maxLabelW = 0
        for _, f in ipairs(self._fields) do
            if f.label then
                local lw = getTextManager():MeasureStringX(UIFont.Small, f.label .. ": ")
                if lw > maxLabelW then
                    maxLabelW = lw
                end
            end
        end
        self._labelW = maxLabelW + 8
    end

    -- Create all field widgets
    for _, f in ipairs(self._fields) do
        self:_createField(f)
    end

    -- Apply/Cancel buttons
    local btnW = math.floor(80 * FONT_SCALE)
    local btnGap = PAD
    local totalBtnW = btnW * 2 + btnGap
    local btnX = (self.width - totalBtnW) / 2

    self._applyBtn = ISButton:new(btnX, 0, btnW, ROW_H, getText("IGUI_PhunMart_Btn_Apply"), self,
        FormPanel._onApplyClick)
    self._applyBtn:initialise()
    self:addChild(self._applyBtn)

    self._cancelBtn = ISButton:new(btnX + btnW + btnGap, 0, btnW, ROW_H, getText("IGUI_PhunMart_Btn_Cancel"), self,
        FormPanel._onCancelClick)
    self._cancelBtn:initialise()
    if self._cancelBtn.enableCancelColor then
        self._cancelBtn:enableCancelColor()
    end
    self:addChild(self._cancelBtn)

    -- Initial layout
    self:reflowFields()
end

function FormPanel:_createField(f)
    local w = self.width - PAD * 2
    local labelW = self._labelW

    if f.type == "text" then
        f._label = ISLabel:new(0, 0, ROW_H, f.label .. ":", 1, 1, 1, 1, UIFont.Small, true)
        f._label:initialise()
        self:addChild(f._label)

        f._entry = ISTextEntryBox:new(f.default, 0, 0, w - labelW, ROW_H)
        f._entry:initialise()
        f._entry:instantiate()
        if f.editable == false then
            f._entry:setEditable(false)
        end
        if f.numbersOnly then
            f._entry:setOnlyNumbers(true)
        end
        self:addChild(f._entry)

        if f.hint then
            f._hint = ISLabel:new(0, 0, FONT_HGT_SMALL, f.hint, 0.5, 0.5, 0.5, 1, UIFont.Small, true)
            f._hint:initialise()
            self:addChild(f._hint)
        end

    elseif f.type == "combo" then
        f._label = ISLabel:new(0, 0, ROW_H, f.label .. ":", 1, 1, 1, 1, UIFont.Small, true)
        f._label:initialise()
        self:addChild(f._label)

        local comboTarget = f.onChange and self or nil
        local comboFn = f.onChange and function(combo)
            f.onChange(self, f)
        end or nil
        f._combo = ISComboBox:new(0, 0, w - labelW, ROW_H, comboTarget, comboFn)
        f._combo:initialise()
        for _, opt in ipairs(f.options) do
            f._combo:addOption(opt)
        end
        -- Set selected (by index or string match)
        if type(f.selected) == "number" then
            f._combo.selected = f.selected
        elseif type(f.selected) == "string" then
            for i, opt in ipairs(f.options) do
                if opt == f.selected then
                    f._combo.selected = i
                    break
                end
            end
        end
        self:addChild(f._combo)

        if f.hint then
            f._hint = ISLabel:new(0, 0, FONT_HGT_SMALL, f.hint, 0.5, 0.5, 0.5, 1, UIFont.Small, true)
            f._hint:initialise()
            self:addChild(f._hint)
        end

    elseif f.type == "picker" then
        f._label = ISLabel:new(0, 0, ROW_H, f.label .. ":", 1, 1, 1, 1, UIFont.Small, true)
        f._label:initialise()
        self:addChild(f._label)

        local pickBtnW = math.max(math.floor(60 * FONT_SCALE), getTextManager():MeasureStringX(UIFont.Small, getText(
            "IGUI_PhunMart_Btn_Pick")) + PAD * 2)
        f._pickBtn = ISButton:new(0, 0, pickBtnW, ROW_H, getText("IGUI_PhunMart_Btn_Pick"), self, function(btn)
            if f.onPick then
                f.onPick(self, f)
            end
        end)
        f._pickBtn:initialise()
        self:addChild(f._pickBtn)

        f._displayLabel = ISLabel:new(0, 0, ROW_H, f._display, 0.8, 0.8, 0.8, 1, UIFont.Small, true)
        f._displayLabel:initialise()
        self:addChild(f._displayLabel)

        if f.hint then
            f._hint = ISLabel:new(0, 0, FONT_HGT_SMALL, f.hint, 0.5, 0.5, 0.5, 1, UIFont.Small, true)
            f._hint:initialise()
            self:addChild(f._hint)
        end

    elseif f.type == "check" then
        f._tick = ISTickBox:new(0, 0, self.width - PAD * 2, ROW_H, "")
        f._tick:initialise()
        f._tick:instantiate()
        f._tick:addOption(f.text, nil)
        f._tick:setSelected(1, f.checked)
        if f.onChange then
            f._tick.changeOptionMethod = function(tick, idx, selected)
                f.onChange(self, f)
            end
            f._tick.changeOptionTarget = self
        end
        self:addChild(f._tick)

    elseif f.type == "range" then
        f._label = ISLabel:new(0, 0, ROW_H, f.label .. ":", 1, 1, 1, 1, UIFont.Small, true)
        f._label:initialise()
        self:addChild(f._label)

        f._minEntry = ISTextEntryBox:new(tostring(f.minDefault), 0, 0, 50, ROW_H)
        f._minEntry:initialise()
        f._minEntry:instantiate()
        self:addChild(f._minEntry)

        f._dash = ISLabel:new(0, 0, ROW_H, "-", 1, 1, 1, 1, UIFont.Small, true)
        f._dash:initialise()
        self:addChild(f._dash)

        f._maxEntry = ISTextEntryBox:new(tostring(f.maxDefault), 0, 0, 50, ROW_H)
        f._maxEntry:initialise()
        f._maxEntry:instantiate()
        self:addChild(f._maxEntry)

        if f.hint then
            f._hint = ISLabel:new(0, 0, FONT_HGT_SMALL, f.hint, 0.5, 0.5, 0.5, 1, UIFont.Small, true)
            f._hint:initialise()
            self:addChild(f._hint)
        end

    elseif f.type == "list" then
        local listH = (f._rows or 4) * ROW_H
        f._list = ISScrollingListBox:new(0, 0, self.width - PAD * 2, listH)
        f._list.itemheight = ROW_H
        f._list.font = UIFont.Small
        f._list.drawBorder = true
        f._list.backgroundColor = {
            r = 0.05,
            g = 0.05,
            b = 0.05,
            a = 0.8
        }
        f._list:initialise()
        f._list:instantiate()
        local formRef = self
        local cols = f._columns
        local fmtCols = f._formatColumns

        if cols and fmtCols then
            -- Column-based drawing
            f._list.doDrawItem = function(listSelf, y2, item, alt)
                if y2 + listSelf:getYScroll() + listSelf.itemheight < 0 or y2 + listSelf:getYScroll() >= listSelf.height then
                    return y2 + listSelf.itemheight
                end
                local textY = y2 + (listSelf.itemheight - FONT_HGT_SMALL) / 2
                if listSelf.selected == item.index then
                    listSelf:drawRect(0, y2, listSelf:getWidth(), listSelf.itemheight, 0.3, 0.7, 0.35, 0.15)
                end
                if alt then
                    listSelf:drawRect(0, y2, listSelf:getWidth(), listSelf.itemheight, 0.08, 0.5, 0.5, 0.5)
                end
                listSelf:drawRectBorder(0, y2, listSelf:getWidth(), listSelf.itemheight, 0.5, 0.3, 0.3, 0.3)
                local cells = fmtCols(item.item)
                local listW = listSelf:getWidth()
                for ci, col in ipairs(cols) do
                    local cx = math.floor(col.size * listW) + 6
                    local cellText = cells[ci] or ""
                    -- Clip: compute available width to next column or edge
                    local nextX = (cols[ci + 1] and math.floor(cols[ci + 1].size * listW)) or listW
                    local clipW = nextX - math.floor(col.size * listW)
                    listSelf:setStencilRect(math.floor(col.size * listW), math.max(0, y2 + listSelf:getYScroll()),
                        clipW, listSelf.itemheight)
                    listSelf:drawText(cellText, cx, textY, 0.9, 0.9, 0.9, 0.9, listSelf.font)
                    listSelf:clearStencilRect()
                end
                return y2 + listSelf.itemheight
            end
        else
            -- Simple single-text drawing
            f._list.doDrawItem = function(listSelf, y2, item, alt)
                if y2 + listSelf:getYScroll() + listSelf.itemheight < 0 or y2 + listSelf:getYScroll() >= listSelf.height then
                    return y2 + listSelf.itemheight
                end
                local textY = y2 + (listSelf.itemheight - FONT_HGT_SMALL) / 2
                if listSelf.selected == item.index then
                    listSelf:drawRect(0, y2, listSelf:getWidth(), listSelf.itemheight, 0.3, 0.7, 0.35, 0.15)
                end
                if alt then
                    listSelf:drawRect(0, y2, listSelf:getWidth(), listSelf.itemheight, 0.08, 0.5, 0.5, 0.5)
                end
                listSelf:drawRectBorder(0, y2, listSelf:getWidth(), listSelf.itemheight, 0.5, 0.3, 0.3, 0.3)
                listSelf:drawText(item.text, 8, textY, 0.9, 0.9, 0.9, 0.9, listSelf.font)
                return y2 + listSelf.itemheight
            end
        end

        f._list.onMouseUp = function(listSelf, x2, y2)
            ISScrollingListBox.onMouseUp(listSelf, x2, y2)
            formRef:_updateListButtons(f)
        end
        -- Double-click to edit
        f._list.onMouseDoubleClick = function(listSelf, item)
            local sel = f._list.selected
            if sel and sel > 0 and f._items[sel] and f.onEdit then
                f.onEdit(formRef, f, sel, f._items[sel])
            end
        end
        self:addChild(f._list)

        local btnW = math.floor(60 * FONT_SCALE)
        f._addBtn = ISButton:new(0, 0, btnW, ROW_H, getText("IGUI_PhunMart_Btn_Add"), self, function()
            if f.onAdd then
                f.onAdd(self, f)
            end
        end)
        f._addBtn:initialise()
        self:addChild(f._addBtn)

        f._editBtn = ISButton:new(0, 0, btnW, ROW_H, getText("IGUI_PhunMart_Btn_Edit"), self, function()
            local sel = f._list.selected
            if sel and sel > 0 and f._items[sel] then
                if f.onEdit then
                    f.onEdit(self, f, sel, f._items[sel])
                end
            end
        end)
        f._editBtn:initialise()
        f._editBtn:setEnable(false)
        self:addChild(f._editBtn)

        f._removeBtn = ISButton:new(0, 0, btnW, ROW_H, getText("IGUI_PhunMart_Btn_Delete"), self, function()
            local sel = f._list.selected
            if sel and sel > 0 and f._items[sel] then
                if f.onRemove then
                    f.onRemove(self, f, sel, f._items[sel])
                else
                    table.remove(f._items, sel)
                    self:_refreshListField(f)
                end
            end
        end)
        f._removeBtn:initialise()
        f._removeBtn:setEnable(false)
        if f._removeBtn.enableCancelColor then
            f._removeBtn:enableCancelColor()
        end
        self:addChild(f._removeBtn)

        -- Populate initial items
        self:_refreshListField(f)

    elseif f.type == "separator" then
        -- Separator has no widgets; drawn in prerender
    end
end

---------------------------------------------------------------------------
-- Reflow: reposition all visible fields and resize the window
---------------------------------------------------------------------------

function FormPanel:reflowFields()
    local th = self:titleBarHeight()
    local x = PAD
    local y = th + PAD
    local w = self.width - PAD * 2
    local labelW = self._labelW

    for _, f in ipairs(self._fields) do
        if not f.visible then
            -- Hide all widgets for this field
            self:_setFieldWidgetsVisible(f, false)
        else
            self:_setFieldWidgetsVisible(f, true)

            if f.type == "text" then
                f._label:setX(x)
                f._label:setY(y)
                f._fieldX = x + labelW
                f._entry:setX(f._fieldX)
                f._entry:setY(y)
                f._entry:setWidth(w - labelW)
                y = y + ROW_H
                if f._hint then
                    y = y + 2
                    f._hint:setX(f._fieldX)
                    f._hint:setY(y)
                    y = y + FONT_HGT_SMALL
                end
                y = y + PAD

            elseif f.type == "combo" then
                f._label:setX(x)
                f._label:setY(y)
                f._fieldX = x + labelW
                f._combo:setX(f._fieldX)
                f._combo:setY(y)
                f._combo:setWidth(w - labelW)
                y = y + ROW_H
                if f._hint then
                    y = y + 2
                    f._hint:setX(f._fieldX)
                    f._hint:setY(y)
                    y = y + FONT_HGT_SMALL
                end
                y = y + PAD

            elseif f.type == "picker" then
                f._label:setX(x)
                f._label:setY(y)
                f._pickBtn:setX(x + w - f._pickBtn.width)
                f._pickBtn:setY(y)
                local fieldX = x + labelW
                f._fieldX = fieldX
                f._displayLabel:setX(fieldX)
                f._displayLabel:setY(y)
                -- Truncate display text to fit between label and pick button
                local maxDisplayW = (x + w - f._pickBtn.width - PAD) - fieldX
                f._maxDisplayW = maxDisplayW
                f._displayLabel:setName(truncateText(f._display, maxDisplayW))
                f._displayLabel:setX(fieldX) -- re-apply after setName (PZ ISLabel quirk)
                y = y + ROW_H
                if f._hint then
                    y = y + 2
                    f._hint:setX(fieldX)
                    f._hint:setY(y)
                    y = y + FONT_HGT_SMALL
                end
                y = y + PAD

            elseif f.type == "check" then
                f._tick:setX(x)
                f._tick:setY(y)
                y = y + ROW_H + PAD

            elseif f.type == "range" then
                f._label:setX(x)
                f._label:setY(y)
                f._fieldX = x + labelW
                local fieldW = w - labelW
                local dashW = getTextManager():MeasureStringX(UIFont.Small, " - ") + 4
                local entryW = (fieldW - dashW) / 2
                f._minEntry:setX(f._fieldX)
                f._minEntry:setY(y)
                f._minEntry:setWidth(entryW)
                f._dash:setX(f._fieldX + entryW)
                f._dash:setY(y)
                f._maxEntry:setX(f._fieldX + entryW + dashW)
                f._maxEntry:setY(y)
                f._maxEntry:setWidth(entryW)
                y = y + ROW_H
                if f._hint then
                    y = y + 2
                    f._hint:setX(f._fieldX)
                    f._hint:setY(y)
                    y = y + FONT_HGT_SMALL
                end
                y = y + PAD

            elseif f.type == "list" then
                if f._columns then
                    -- Store header draw position for prerender
                    f._headerY = y
                    f._headerX = x
                    f._headerW = w
                else
                    -- No columns: draw label in prerender
                    f._headerY = y
                    f._headerX = x
                end
                y = y + FONT_HGT_SMALL + 2
                local listH = (f._rows or 4) * ROW_H
                f._list:setX(x)
                f._list:setY(y)
                f._list:setWidth(w)
                f._list:setHeight(listH)
                y = y + listH + 4
                -- Position buttons in a row
                local btnW2 = math.floor(60 * FONT_SCALE)
                local gap = 4
                f._addBtn:setX(x)
                f._addBtn:setY(y)
                f._editBtn:setX(x + btnW2 + gap)
                f._editBtn:setY(y)
                f._removeBtn:setX(x + (btnW2 + gap) * 2)
                f._removeBtn:setY(y)
                y = y + ROW_H + PAD

            elseif f.type == "separator" then
                y = y + PAD
                -- Store y for prerender drawing
                f._drawY = y
                y = y + 2
                if f.text then
                    y = y + FONT_HGT_SMALL + 2
                end
                y = y + PAD
            end
        end
    end

    -- Extra padding before buttons
    y = y + PAD

    -- Position Apply/Cancel
    local btnW = math.floor(80 * FONT_SCALE)
    local btnGap = PAD
    local totalBtnW = btnW * 2 + btnGap
    local btnX = (self.width - totalBtnW) / 2

    self._applyBtn:setX(btnX)
    self._applyBtn:setY(y)
    self._cancelBtn:setX(btnX + btnW + btnGap)
    self._cancelBtn:setY(y)

    y = y + ROW_H + PAD

    -- Resize window to fit
    local newH = y
    if newH ~= self.height then
        self.height = newH
        -- Re-center vertically
        local core = getCore()
        self:setY((core:getScreenHeight() - newH) / 2)
    end
end

function FormPanel:_setFieldWidgetsVisible(f, vis)
    if f._label then
        f._label:setVisible(vis)
    end
    if f._entry then
        f._entry:setVisible(vis)
    end
    if f._combo then
        f._combo:setVisible(vis)
    end
    if f._pickBtn then
        f._pickBtn:setVisible(vis)
    end
    if f._displayLabel then
        f._displayLabel:setVisible(vis)
    end
    if f._tick then
        f._tick:setVisible(vis)
    end
    if f._minEntry then
        f._minEntry:setVisible(vis)
    end
    if f._maxEntry then
        f._maxEntry:setVisible(vis)
    end
    if f._dash then
        f._dash:setVisible(vis)
    end
    if f._hint then
        f._hint:setVisible(vis)
    end
    if f._list then
        f._list:setVisible(vis)
    end
    if f._addBtn then
        f._addBtn:setVisible(vis)
    end
    if f._editBtn then
        f._editBtn:setVisible(vis)
    end
    if f._removeBtn then
        f._removeBtn:setVisible(vis)
    end
end

---------------------------------------------------------------------------
-- Rendering (draw separators)
---------------------------------------------------------------------------

function FormPanel:prerender()
    ISCollapsableWindowJoypad.prerender(self)

    for _, f in ipairs(self._fields) do
        if not f.visible then
            -- skip
        elseif f.type == "separator" and f._drawY then
            local w = self.width - PAD * 2
            self:drawRect(PAD, f._drawY, w, 1, 0.3, 0.4, 0.4, 0.4)
            if f.text then
                self:drawText(f.text, PAD, f._drawY + 4, 0.6, 0.6, 0.6, 1, UIFont.Small)
            end
        elseif f.type == "list" and f._headerY then
            if f._columns then
                -- Draw column headers
                local hx = f._headerX
                local hy = f._headerY
                local hw = f._headerW
                for _, col in ipairs(f._columns) do
                    local cx = hx + math.floor(col.size * hw) + 6
                    self:drawText(col.name, cx, hy, 0.6, 0.6, 0.6, 1, UIFont.Small)
                end
            else
                -- Draw simple label
                self:drawText(f.label or "", f._headerX, f._headerY, 1, 1, 1, 1, UIFont.Small)
            end
        end
    end
end

---------------------------------------------------------------------------
-- Apply / Cancel
---------------------------------------------------------------------------

function FormPanel:_onApplyClick()
    if self._onApply then
        self._onApply(self)
    end
end

function FormPanel:_onCancelClick()
    if self._onCancel then
        self._onCancel(self)
    end
    self:close()
end

function FormPanel:close()
    ISCollapsableWindowJoypad.close(self)
end

return FormPanel
