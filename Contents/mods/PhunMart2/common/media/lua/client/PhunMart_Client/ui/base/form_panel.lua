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

-- Section tab states. Shared tables because reflow assigns them every pass, and
-- deliberately the same colours the list panel's filter tabs use: a row of tabs
-- should mean the same thing wherever it appears.
local SECTION_ON = {r = 0.3, g = 0.7, b = 0.35, a = 0.4}
local SECTION_OFF = {r = 0, g = 0, b = 0, a = 0.25}
local SECTION_HOVER = {r = 0.3, g = 0.7, b = 0.35, a = 0.2}

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
    o._onDelete = opts.onDelete -- function(form), optional; omit on an Add form
    o._deleteLabel = opts.deleteLabel -- when "Delete" is the wrong word for it
    -- {text, onClick = function(form)}: one extra button on the left, for a form
    -- that can show you something about what you are editing.
    o._extraButton = opts.extraButton
    o._validateForm = opts.validate -- function(form) -> errorText (cross-field rules)
    o._showErrors = false -- set on the first Apply; errors then track live edits
    o:setWantKeyEvents(true)
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
--
-- Validation opts accepted by every field type:
--   required   Field must not be blank
--   numeric    Must parse as a number when non-blank
--   integer    Must be a whole number when non-blank
--   min / max  Numeric bounds when non-blank
--   validate   function(value, form) -> errorText or nil
-- A field carrying any of these gets a message row even without a hint, so
-- showing an error never resizes the window under the user's cursor.
---------------------------------------------------------------------------

--- Copy validation options onto the freshly-added descriptor and index it.
function FormPanel:_registerField(opts)
    local f = self._fields[#self._fields]
    opts = opts or {}
    f.required = opts.required
    f.numeric = opts.numeric
    f.integer = opts.integer
    f.min = opts.min
    f.max = opts.max
    f.requireBoth = opts.requireBoth
    f.validate = opts.validate
    -- A conditional field belongs to a step but is not shown just because that
    -- step is. Something else decides, usually a combo above it choosing
    -- "Other", and stepping must not override that decision.
    f.conditional = opts.conditional
    -- Which tab this field lives on, independent of `group`. See setSections.
    f.section = opts.section
    f.hasMessageRow = (f.hint ~= nil) or f.required == true or f.numeric == true or f.integer == true or f.min ~=
                          nil or f.max ~= nil or f.validate ~= nil
    self._fieldsByKey[f.key] = f
    return self
end

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
        onChange = opts.onChange,
        visible = true
    })
    return self:_registerField(opts)
end

--- Combo box field.
-- opts: { options, selected, hint, group, onChange, button }
-- options: array of strings; selected: 1-based index or string value
-- button: { text, onClick = function(form, fieldDesc) }, a small action sitting
--         to the right of the combo. For a field that names another thing, so
--         you can go and look at it without leaving to find it.
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
        button = opts.button,
        visible = true
    })
    return self:_registerField(opts)
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
    return self:_registerField(opts)
end

--- Checkbox field.
-- opts: { checked, text, hint, group, onChange }
-- text: checkbox label (defaults to label param)
--
-- A tickbox is the field type most likely to need a hint and was the only one
-- that dropped it: a box reading "Bound balances too" says what it is called,
-- not what ticking it does. The label alone carries the whole meaning here,
-- which is exactly when a second line earns its space.
function FormPanel:addCheckField(key, label, opts)
    opts = opts or {}
    table.insert(self._fields, {
        type = "check",
        key = key,
        label = label,
        checked = opts.checked or false,
        text = opts.text or label,
        hint = opts.hint,
        group = opts.group,
        onChange = opts.onChange,
        visible = true
    })
    return self:_registerField(opts)
end

--- Inline range field (min entry - max entry on one row).
-- opts: { minDefault, maxDefault, hint, group }
-- Note: `min`/`max` are the shared numeric validation bounds (see above), so
-- the starting values of the two entries are named minDefault/maxDefault.
function FormPanel:addRangeField(key, label, opts)
    opts = opts or {}
    table.insert(self._fields, {
        type = "range",
        key = key,
        label = label,
        minDefault = opts.minDefault or "",
        maxDefault = opts.maxDefault or "",
        hint = opts.hint,
        group = opts.group,
        visible = true
    })
    return self:_registerField(opts)
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
-- hint: message row under the buttons, the same one every other field type has.
--       A list carries provenance as well as guidance now: an inherited list is
--       marked there, and it was the one field type with nowhere to say so.
function FormPanel:addListField(key, label, opts)
    opts = opts or {}
    table.insert(self._fields, {
        type = "list",
        key = key,
        label = label,
        hint = opts.hint,
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
    return self:_registerField(opts)
end

--- Visual separator (horizontal line + optional section label).
-- opts: { text, group }
--- A row of pictures, so a choice made from a dropdown of filenames can be
--- seen rather than imagined.
--- opts: { group, conditional, height, images = function() -> array of
---         { texture, label } }
--- `images` is called on every reflow, because what it should show depends on
--- the field above it.
function FormPanel:addImageField(key, label, opts)
    opts = opts or {}
    table.insert(self._fields, {
        type = "image",
        key = key,
        label = label,
        images = opts.images,
        imageHeight = opts.height or math.floor(48 * FONT_SCALE),
        group = opts.group,
        visible = true
    })
    return self:_registerField(opts)
end

function FormPanel:addSeparator(key, opts)
    opts = opts or {}
    table.insert(self._fields, {
        type = "separator",
        key = key,
        text = opts.text,
        group = opts.group,
        visible = true
    })
    return self:_registerField(opts)
end

---------------------------------------------------------------------------
-- Group visibility
---------------------------------------------------------------------------

--- A field is on screen when its section is the active one AND whatever else
--- controls it still wants it. Two independent answers, because `group` is
--- already spoken for: the specials form uses it to show the fields belonging
--- to the chosen action type, and which tab a field sits on is a different
--- question from whether that tab currently has any use for it.
---
--- Declared here rather than beside setSections, which is where it is
--- conceptually at home but is several hundred lines further down. A local is
--- only in scope after its declaration, so from up here the name resolved to a
--- nil global and every setGroupVisible call died on it.
local function applyVisibility(f)
    f.visible = (f._groupOn ~= false) and (f._sectionOn ~= false)
end

function FormPanel:setGroupVisible(groupName, visible)
    for _, f in ipairs(self._fields) do
        if f.group == groupName then
            f._groupOn = visible
            applyVisibility(f)
        end
    end
    if self._built then
        self:reflowFields()
    end
end

---------------------------------------------------------------------------
-- Steps
--
-- A wizard is this form with one group of fields visible at a time. Nothing
-- else had to change for that: validateAll already skips hidden fields, so a
-- step validates itself and nothing ahead of it, and setGroupVisible already
-- reflows. Apply becomes Next until the last step, and Back appears once there
-- is something to go back to.
--
-- The point is not the navigation, it is that a newcomer sees four fields and
-- a question rather than fourteen fields and no idea which matter.
---------------------------------------------------------------------------

--- @param steps array of {group = "basics", title = "What is this shop called?"}
---------------------------------------------------------------------------
-- Sections
--
-- A row of tabs inside the form, one group of fields at a time. Steps are the
-- same machinery pointed at a different problem: a step gates you until you
-- have filled it in, a section is just somewhere to put the things you rarely
-- touch. Apply stays available throughout.
--
-- Fields declared before the first sectioned one have no section and sit above
-- the strip, always visible. That is where identity goes: what you are editing
-- should not be on a tab you might not be looking at.
---------------------------------------------------------------------------

--- Put fields in sections by key, rather than a section= on all of them.
---
--- For a form where nearly everything belongs to one section and a handful do
--- not, which is the usual shape. `map` names the exceptions; anything else
--- carrying a `group` goes to `default`. A field with neither a group nor an
--- entry in the map has no section and stays above the tabs, which is how
--- identity fields keep out of this without having to say so.
-- @param map     {fieldKey = "section"}
-- @param default section for every other grouped field, optional
function FormPanel:assignSections(map, default)
    for _, f in ipairs(self._fields) do
        if map and map[f.key] then
            f.section = map[f.key]
        elseif default and f.group then
            f.section = default
        end
    end
    return self
end

--- @param sections array of {section = "appearance", label = "Appearance"}
function FormPanel:setSections(sections)
    if self._steps then
        -- A form is one or the other. Steps already own visibility and the
        -- button row, and the two would fight over both.
        return self
    end
    self._sections = sections
    self._section = 1
    self:_applySection()
    return self
end

--- Show one section's fields and hide the rest. Called before initialise, so
--- the window is sized from the section that will actually be on screen.
function FormPanel:_applySection()
    if not self._sections then
        return
    end
    for i, s in ipairs(self._sections) do
        for _, f in ipairs(self._fields) do
            if f.section == s.section then
                f._sectionOn = (i == self._section)
                applyVisibility(f)
            end
        end
    end
    if self._built then
        self:reflowFields()
    end
end

function FormPanel:_onSectionClick(btn)
    self._section = btn._sectionIndex or 1
    -- Back to the top: the new section's first field is what you asked to see,
    -- and keeping the old offset can leave a short section scrolled past itself.
    self._scrollY = 0
    self:_applySection()
end

function FormPanel:setSteps(steps)
    self._steps = steps
    self._step = 1
    self._baseTitle = self:getTitle() or ""
    -- Hide the later steps now rather than in createChildren. initialise sizes
    -- the window from the visible fields, so leaving them all visible until
    -- after that opened the first step at the height of the whole form.
    self:_applyStep()
end

function FormPanel:currentStep()
    return self._steps and self._steps[self._step] or nil
end

--- Show only the current step, and relabel the buttons to match where we are.
function FormPanel:_applyStep()
    if not self._steps then
        return
    end
    for i, s in ipairs(self._steps) do
        for _, f in ipairs(self._fields) do
            if f.group == s.group then
                -- A conditional field is on screen only when its step is AND
                -- whatever controls it still wants it. Hiding it on the way out
                -- and never restoring it meant stepping back to a page where
                -- "Other" was chosen showed the combo and none of the fields it
                -- had revealed.
                if f.conditional then
                    f.visible = (i == self._step) and (f._wanted == true)
                else
                    f.visible = (i == self._step)
                end
            end
        end
    end

    -- How far through, in the title bar. Without it a wizard is just a form
    -- that keeps changing, with no sense of how much is left.
    if self._baseTitle then
        self:setTitle(self._baseTitle .. "  (" .. tostring(self._step) .. "/" .. tostring(#self._steps) .. ")")
    end

    local last = self._step >= #self._steps
    if self._applyBtn then
        self._applyBtn:setTitle(last and getText("IGUI_PhunMart_Btn_Create") or getText("IGUI_PhunMart_Btn_Next"))
    end
    if self._backBtn then
        self._backBtn:setVisible(self._step > 1)
    end

    -- Errors are per step: arriving somewhere new should not open with
    -- complaints about fields nobody has reached yet.
    self._showErrors = false
    self._formError = nil
    for _, f in ipairs(self._fields) do
        f._error = nil
    end

    if self._built then
        self:reflowFields()
        self:_refreshMessages()
    end
end

function FormPanel:_onBackClick()
    if self._steps and self._step > 1 then
        self._step = self._step - 1
        self:_applyStep()
    end
end

function FormPanel:setFieldVisible(key, visible)
    local f = self._fieldsByKey[key]
    if f then
        f._groupOn = visible
        applyVisibility(f)
        -- Remembered separately for a conditional field, because stepping away
        -- and back rebuilds visibility from the step and would otherwise forget
        -- that something had asked for this one.
        if f.conditional then
            f._wanted = visible and true or false
        end
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
        if not f._entry then
            return f.default
        end
        -- getInternalText, not getText: during a keystroke getText still holds
        -- what was there before, so anything reacting to typing read one edit
        -- behind. The game's own text-change handlers use the internal one for
        -- the same reason. Outside a keystroke the two agree, so this changes
        -- nothing for validation or apply.
        if f._entry.getInternalText then
            return f._entry:getInternalText() or ""
        end
        return f._entry:getText() or f.default
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

---------------------------------------------------------------------------
-- Inherited values
--
-- A form filled from a definition that inherits shows the resolved value, so
-- what you read is what the thing actually does. That is right, and it is also
-- silent about where the value came from: a field holding its template's answer
-- looks exactly like one holding its own. With most shipped specials inheriting
-- almost everything, that is most of the form lying about itself.
--
-- A marked field says so in its message row until its value stops matching what
-- it was loaded with. Edit it and the marker goes, because it is now yours.
-- Put the old value back and the marker returns, because it is not.
---------------------------------------------------------------------------

--- Mark a field as currently showing a value that came from `sourceLabel`.
--- Call after the fields are declared and before initialise, since a marked
--- field needs a message row and that decides how tall the form is.
function FormPanel:setFieldInherited(key, sourceLabel)
    local f = self._fieldsByKey[key]
    if not f then
        return self
    end
    f.inheritedFrom = sourceLabel
    f._inheritNote = getText("IGUI_PhunMart_Hint_Inherited", tostring(sourceLabel))
    -- The value itself is captured on the first refresh: the widgets do not
    -- exist yet, so there is nothing to read here.
    f._inheritCaptured = false
    f.hasMessageRow = true
    -- Only a form that has marked something pays for the per-frame repaint.
    self._hasInherited = true
    return self
end

--- Is this field still showing the value it was loaded with?
function FormPanel:_isShowingInherited(f)
    if not f.inheritedFrom or not self._built then
        return false
    end
    if not f._inheritCaptured then
        local loaded = self:getFieldValue(f.key)
        -- A list field hands back its live items table. Keeping that reference
        -- would compare it against itself on every frame, so the marker could
        -- never clear no matter what was added or removed.
        if f.type == "list" then
            loaded = PhunMart.utils.deepCopy(loaded)
        end
        f.inheritedValue = loaded
        f._inheritCaptured = true
        return true
    end
    local current = self:getFieldValue(f.key)
    if type(current) == "table" or type(f.inheritedValue) == "table" then
        return PhunMart.utils.deepEquals(current, f.inheritedValue)
    end
    return current == f.inheritedValue
end

--- Update a field's hint text. Re-applies position after setName to work
-- around PZ ISLabel quirk where setName resets x.
function FormPanel:setHintText(key, text)
    local f = self._fieldsByKey[key]
    if f then
        -- Update the stored hint as well as the label: once the user has
        -- attempted Apply, _refreshMessages repaints this label from f.hint
        -- every frame and would otherwise undo the change.
        f.hint = text
        if f._hint then
            -- Through _refreshMessages rather than straight to the label, so a
            -- warning or an error on this field keeps the line it has earned.
            self:_refreshMessages()
        end
    end
end

--- Put an amber note under a field, or clear it with nil. Unlike an error this
--- shows immediately and does not block Apply. See _refreshMessages.
function FormPanel:setFieldWarning(key, text)
    local f = self._fieldsByKey[key]
    if f then
        f.warning = (text ~= "") and text or nil
        if f._hint then
            self:_refreshMessages()
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

    -- The section strip, which reflowFields places before the first sectioned
    -- field. Counted once whether or not any of those fields are visible, since
    -- the strip is how you reach the ones that are not.
    if self._sections then
        y = y + ROW_H + PAD
    end

    for _, f in ipairs(self._fields) do
        if f.visible then
            if f.type == "separator" then
                y = y + PAD + 2
                if f.text then
                    y = y + FONT_HGT_SMALL + 2
                end
                y = y + PAD
            elseif f.type == "image" then
                y = y + f.imageHeight + FONT_HGT_SMALL + PAD
            elseif f.type == "check" then
                y = y + ROW_H
                if f.hasMessageRow then
                    y = y + 2 + FONT_HGT_SMALL
                end
                y = y + PAD
            elseif f.type == "list" then
                y = y + FONT_HGT_SMALL + 2 -- header row (columns or label)
                y = y + (f._rows or 4) * ROW_H -- list rows
                y = y + 4
                -- Button row only when the list has buttons. Read off the
                -- handlers rather than f._editable, which the widgets have not
                -- been built to set yet at this point.
                if f.onAdd or f.onEdit or f.onRemove then
                    y = y + ROW_H
                end
                if f.hasMessageRow then
                    y = y + 2 + FONT_HGT_SMALL
                end
                y = y + PAD
            else
                y = y + ROW_H
                if f.hasMessageRow then
                    y = y + 2 + FONT_HGT_SMALL
                end
                y = y + PAD
            end
        end
    end

    -- Form-level message row (always reserved, so a cross-field error appearing
    -- doesn't shift the buttons out from under the cursor)
    y = y + FONT_HGT_SMALL + 2

    -- Apply/Cancel buttons
    y = y + PAD + ROW_H + PAD
    return y
end

--- Widen the form until the longest hint fits, capped at something that still
--- reads as a dialog. Hints are single-line ISLabels with no wrapping, so text
--- that does not fit simply runs off the edge of the window. Growing sideways
--- is what a person would do, and it costs nothing on forms whose hints are
--- already short.
function FormPanel:_computeNeededWidth()
    local labelW = self._labelW
    if not labelW then
        local maxLabelW = 0
        for _, f in ipairs(self._fields) do
            if f.label then
                local lw = getTextManager():MeasureStringX(UIFont.Small, f.label .. ": ")
                if lw > maxLabelW then
                    maxLabelW = lw
                end
            end
        end
        labelW = maxLabelW + 8
    end

    -- Measured one at a time: a table literal holding a nil would end an ipairs
    -- at the gap and silently skip whatever came after it.
    local widest = 0
    local function consider(text)
        if type(text) == "string" and text ~= "" then
            local w = getTextManager():MeasureStringX(UIFont.Small, text)
            if w > widest then
                widest = w
            end
        end
    end
    for _, f in ipairs(self._fields) do
        -- Hint and provenance share a line, so it is the pair that has to fit.
        if f.inheritedFrom then
            consider(((f.hint or "") ~= "" and (f.hint .. "  ") or "") ..
                         getText("IGUI_PhunMart_Hint_Inherited", tostring(f.inheritedFrom)))
        else
            consider(f.hint)
        end
        if f.type == "separator" then
            consider(f.text)
        end
    end

    local needed = labelW + widest + PAD * 3
    -- Raised from 680 when provenance started sharing the hint's line: hints do
    -- not wrap, so a pair that does not fit runs off the edge rather than
    -- folding. Still dialog-sized, and only reached by a form that asks for it.
    local cap = math.floor(820 * FONT_SCALE)
    return math.max(self._formWidth or 0, math.min(needed, cap))
end

function FormPanel:initialise()
    local neededW = self:_computeNeededWidth()
    if neededW > self.width then
        self.width = neededW
        self._formWidth = neededW
        local core = getCore()
        self:setX((core:getScreenWidth() - neededW) / 2)
    end

    -- Compute the real height before the parent lays out chrome, capped at the
    -- screen. reflowFields settles the scroll range once the fields are placed.
    local core = getCore()
    local neededH = math.min(self:_computeNeededHeight(), math.floor(core:getScreenHeight() * 0.9))
    self.height = neededH
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

    -- Section tabs, before the fields so they sit behind nothing.
    if self._sections then
        self._sectionBtns = {}
        for i, s in ipairs(self._sections) do
            local w = getTextManager():MeasureStringX(UIFont.Small, s.label) + PAD * 2
            local btn = ISButton:new(0, 0, w, ROW_H, s.label, self, FormPanel._onSectionClick)
            btn:initialise()
            btn:instantiate()
            btn._sectionIndex = i
            btn.borderColor = {r = 0.5, g = 0.5, b = 0.5, a = 0.6}
            self:addChild(btn)
            table.insert(self._sectionBtns, btn)
        end
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
    -- Guarded the same way as enableCancelColor throughout: these are build 42
    -- conveniences and an older or modded ISButton may not carry them.
    if self._applyBtn.enableAcceptColor then
        self._applyBtn:enableAcceptColor()
    end
    self:addChild(self._applyBtn)

    self._cancelBtn = ISButton:new(btnX + btnW + btnGap, 0, btnW, ROW_H, getText("IGUI_PhunMart_Btn_Cancel"), self,
        FormPanel._onCancelClick)
    self._cancelBtn:initialise()
    if self._cancelBtn.enableCancelColor then
        self._cancelBtn:enableCancelColor()
    end
    self:addChild(self._cancelBtn)

    -- Delete sits hard left, away from the centred Apply/Cancel pair, so it
    -- can't be hit by aiming at either of them.
    if self._onDelete then
        -- Labelled by the caller when "Delete" is the wrong word for what the
        -- button undoes. Same position and same colour either way: it is the
        -- destructive one, kept away from Apply.
        local label = self._deleteLabel or getText("IGUI_PhunMart_Btn_Delete")
        local w = math.max(btnW, getTextManager():MeasureStringX(UIFont.Small, label) + PAD * 2)
        self._deleteBtn = ISButton:new(PAD, 0, w, ROW_H, label, self, FormPanel._onDeleteClick)
        self._deleteBtn:initialise()
        if self._deleteBtn.enableCancelColor then
            self._deleteBtn:enableCancelColor()
        end
        self:addChild(self._deleteBtn)
    end

    -- One optional extra on the left, for a form that can show you something
    -- about what you are editing. Beside Delete rather than near Apply, because
    -- it neither commits nor cancels.
    if self._extraButton then
        local label = self._extraButton.text
        local w = math.max(btnW, getTextManager():MeasureStringX(UIFont.Small, label) + PAD * 2)
        self._extraBtn = ISButton:new(PAD, 0, w, ROW_H, label, self, function()
            self._extraButton.onClick(self)
        end)
        self._extraBtn:initialise()
        self._extraBtn:instantiate()
        self:addChild(self._extraBtn)
    end

    -- Back sits with the pair rather than hard left: it is part of moving
    -- through the form, not an escape from it like Cancel or Delete.
    if self._steps then
        self._backBtn = ISButton:new(PAD, 0, btnW, ROW_H, getText("IGUI_PhunMart_Btn_Back"), self,
            FormPanel._onBackClick)
        self._backBtn:initialise()
        self:addChild(self._backBtn)
        self:_applyStep()
    end

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
        -- Text fields can react to typing now, the way combos already reacted
        -- to picking. Wanted twice before this: once to derive a key from a
        -- name, and again to recost a table live as a multiplier is typed.
        if f.onChange then
            f._entry.onTextChangeFunction = function()
                f.onChange(self, f)
            end
            f._entry.target = self
        end
        self:addChild(f._entry)

        if f.hasMessageRow then
            f._hint = ISLabel:new(0, 0, FONT_HGT_SMALL, f.hint or "", 0.5, 0.5, 0.5, 1, UIFont.Small, true)
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
        if f.button then
            f._btnW = math.max(math.floor(50 * FONT_SCALE),
                getTextManager():MeasureStringX(UIFont.Small, f.button.text) + PAD)
            f._btn = ISButton:new(0, 0, f._btnW, ROW_H, f.button.text, self, function()
                f.button.onClick(self, f)
            end)
            f._btn:initialise()
            f._btn:instantiate()
            self:addChild(f._btn)
        end

        f._combo = ISComboBox:new(0, 0, w - labelW - (f._btnW and (f._btnW + 4) or 0), ROW_H, comboTarget, comboFn)
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

        if f.hasMessageRow then
            f._hint = ISLabel:new(0, 0, FONT_HGT_SMALL, f.hint or "", 0.5, 0.5, 0.5, 1, UIFont.Small, true)
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

        if f.hasMessageRow then
            f._hint = ISLabel:new(0, 0, FONT_HGT_SMALL, f.hint or "", 0.5, 0.5, 0.5, 1, UIFont.Small, true)
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

        if f.hasMessageRow then
            f._hint = ISLabel:new(0, 0, FONT_HGT_SMALL, f.hint or "", 0.5, 0.5, 0.5, 1, UIFont.Small, true)
            f._hint:initialise()
            self:addChild(f._hint)
        end

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

        if f.hasMessageRow then
            f._hint = ISLabel:new(0, 0, FONT_HGT_SMALL, f.hint or "", 0.5, 0.5, 0.5, 1, UIFont.Small, true)
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

        -- Only when the list can actually be edited. A read-only list, such as
        -- one used to show what an edit is about to do, was still growing Add,
        -- Edit and Delete buttons that did nothing when pressed.
        f._editable = (f.onAdd ~= nil) or (f.onEdit ~= nil) or (f.onRemove ~= nil)
        if f._editable then
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
        end

        if f.hasMessageRow then
            f._hint = ISLabel:new(0, 0, FONT_HGT_SMALL, f.hint or "", 0.5, 0.5, 0.5, 1, UIFont.Small, true)
            f._hint:initialise()
            self:addChild(f._hint)
        end

        -- Populate initial items. Outside the branch above: a read-only list
        -- still has rows to show.
        self:_refreshListField(f)

    elseif f.type == "separator" or f.type == "image" then
        -- No widgets; both are drawn in prerender
    end
end

---------------------------------------------------------------------------
-- Reflow: reposition all visible fields and resize the window
---------------------------------------------------------------------------

--- Height of the pinned footer: the form-level message row and the button row.
function FormPanel:footerHeight()
    return FONT_HGT_SMALL + 2 + PAD + ROW_H + PAD
end

function FormPanel:reflowFields()
    local th = self:titleBarHeight()
    local footerH = self:footerHeight()

    -- Size to the content, but never past the screen. A form taller than the
    -- display used to run its buttons off the bottom edge, which on the longer
    -- editors is reachable at 720p or a large UI font scale.
    local neededH = self:_computeNeededHeight()
    local newH = math.min(neededH, math.floor(getCore():getScreenHeight() * 0.9))
    if newH ~= self.height then
        -- setHeight rather than assigning self.height: the frame and the resize
        -- widget are drawn from the java element, so a direct assignment moved
        -- the contents and left the border at its old size.
        self:setHeight(newH)
        self:setY((getCore():getScreenHeight() - newH) / 2)
    end

    -- Whatever did not fit is what there is to scroll through.
    self._scrollRange = math.max(0, neededH - newH)
    self._scrollY = math.max(0, math.min(self._scrollY or 0, self._scrollRange))

    -- Fields live between the title bar and the footer. The footer does not
    -- scroll: Apply and Cancel have to stay reachable no matter where you are.
    local viewTop = th
    local viewBottom = newH - footerH

    local x = PAD
    local y = th + PAD - self._scrollY
    local w = self.width - PAD * 2
    local labelW = self._labelW

    -- The strip goes in immediately before the first field that belongs to a
    -- section, which puts it under the identity fields and above everything a
    -- tab owns, without the caller having to say where.
    local stripPlaced = (self._sectionBtns == nil)

    for _, f in ipairs(self._fields) do
        if not stripPlaced and f.section ~= nil then
            local tx = x
            for i, btn in ipairs(self._sectionBtns) do
                btn:setX(tx)
                btn:setY(y)
                local active = (i == self._section)
                btn.backgroundColor = active and SECTION_ON or SECTION_OFF
                btn.backgroundColorMouseOver = active and SECTION_ON or SECTION_HOVER
                btn:setVisible(y >= viewTop and y + ROW_H <= viewBottom)
                tx = tx + btn.width + 2
            end
            y = y + ROW_H + PAD
            stripPlaced = true
        end

        if not f.visible then
            -- Hide all widgets for this field
            self:_setFieldWidgetsVisible(f, false)
            f._inView = false
        else
            -- Shown for now so the branches below can position it; whether it is
            -- actually on screen is decided once its height is known.
            self:_setFieldWidgetsVisible(f, true)
            local rowTop = y

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
                local comboW = w - labelW
                if f._btn then
                    comboW = comboW - f._btnW - 4
                    f._btn:setX(f._fieldX + comboW + 4)
                    f._btn:setY(y)
                end
                f._combo:setX(f._fieldX)
                f._combo:setY(y)
                f._combo:setWidth(comboW)
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
                y = y + ROW_H
                if f._hint then
                    y = y + 2
                    -- Indented past the box itself so the hint reads as
                    -- belonging to this option rather than heading the next
                    -- one. There is no label column here to align to, so it
                    -- lines up with the tick's own text instead.
                    f._fieldX = x + ROW_H
                    f._hint:setX(f._fieldX)
                    f._hint:setY(y)
                    y = y + FONT_HGT_SMALL
                end
                y = y + PAD

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
                -- Position buttons in a row, when there are any. A read-only
                -- list also gets its row of space back.
                if f._addBtn then
                    local btnW2 = math.floor(60 * FONT_SCALE)
                    local gap = 4
                    f._addBtn:setX(x)
                    f._addBtn:setY(y)
                    f._editBtn:setX(x + btnW2 + gap)
                    f._editBtn:setY(y)
                    f._removeBtn:setX(x + (btnW2 + gap) * 2)
                    f._removeBtn:setY(y)
                    y = y + ROW_H
                end
                if f._hint then
                    y = y + 2
                    f._hint:setX(x)
                    f._hint:setY(y)
                    y = y + FONT_HGT_SMALL
                end
                y = y + PAD

            elseif f.type == "separator" then
                y = y + PAD
                -- Store y for prerender drawing
                f._drawY = y
                y = y + 2
                if f.text then
                    y = y + FONT_HGT_SMALL + 2
                end
                y = y + PAD

            elseif f.type == "image" then
                f._drawY = y
                f._fieldX = x + labelW
                y = y + f.imageHeight + FONT_HGT_SMALL + PAD
            end

            -- Now that the row's extent is known, take it back off screen if it
            -- has scrolled out. Whole rows only: nothing clips a child widget to
            -- its parent here, so a half-shown field would draw straight over
            -- the title bar or the buttons.
            f._inView = rowTop >= viewTop and y <= viewBottom
            if not f._inView then
                self:_setFieldWidgetsVisible(f, false)
            end
        end
    end

    -- Form-level message row, pinned with the buttons rather than following the
    -- last field.
    y = viewBottom
    self._formMsgY = y
    y = y + FONT_HGT_SMALL + 2

    -- Extra padding before buttons
    y = y + PAD

    -- Position the button row
    local btnW = math.floor(80 * FONT_SCALE)
    local btnGap = PAD

    -- Left group first, because where it ends decides how much room the right
    -- group has.
    local leftX = PAD
    if self._deleteBtn then
        self._deleteBtn:setX(leftX)
        self._deleteBtn:setY(y)
        leftX = leftX + self._deleteBtn.width + PAD
    end
    if self._extraBtn then
        self._extraBtn:setX(leftX)
        self._extraBtn:setY(y)
        leftX = leftX + self._extraBtn.width + PAD
    end

    -- Apply and Cancel sit at the right edge rather than centred on the window.
    -- Centred, they were computed from the full width while Delete and the
    -- extra button grew rightwards from the left edge, so a wide form put four
    -- buttons in the left two thirds and left a dead third on the right, and a
    -- narrow one marched the left group into Apply. Right-aligned, the row
    -- balances at any width and the destructive button stays as far from Apply
    -- as the form allows.
    local rightCount = (self._backBtn and self._backBtn:isVisible()) and 3 or 2
    local groupW = btnW * rightCount + btnGap * (rightCount - 1)
    -- Never left of where the left group ended: on a form too narrow for both,
    -- overlapping buttons are worse than an off-centre row.
    local groupX = math.max(leftX, self.width - PAD - groupW)

    if rightCount == 3 then
        self._backBtn:setX(groupX)
        self._backBtn:setY(y)
        groupX = groupX + btnW + btnGap
    end
    self._applyBtn:setX(groupX)
    self._applyBtn:setY(y)
    self._cancelBtn:setX(groupX + btnW + btnGap)
    self._cancelBtn:setY(y)

    -- The window was already sized at the top of this function, from the content
    -- rather than from wherever the last field happened to land.
end

--- Scroll the fields. Only when there is something to scroll, so a form that
--- fits leaves the wheel alone for whatever is underneath.
function FormPanel:onMouseWheel(del)
    if (self._scrollRange or 0) <= 0 then
        return false
    end
    self._scrollY = math.max(0, math.min((self._scrollY or 0) + del * ROW_H * 2, self._scrollRange))
    self:reflowFields()
    return true
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
    if f._btn then
        f._btn:setVisible(vis)
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

    -- Once the user has attempted Apply, keep errors in step with their edits
    -- so a corrected field clears without another click.
    if self._showErrors then
        self:validateAll()
    elseif self._hasInherited then
        -- validateAll refreshes the messages itself. Without it, the provenance
        -- markers still have to be repainted, because whether a field is showing
        -- an inherited value changes with every keystroke.
        self:_refreshMessages()
    end

    if self._formError and self._formMsgY then
        self:drawText(self._formError, PAD, self._formMsgY, 0.95, 0.45, 0.4, 1, UIFont.Small)
    end

    -- Provenance, drawn after each hint rather than in place of it. Two colours
    -- on one line needs two draws, and an ISLabel only has one, so this is a
    -- draw rather than a widget. Skipped where an error is showing: that has
    -- taken the row over and the two would overlap.
    if self._hasInherited then
        for _, f in ipairs(self._fields) do
            if f.visible and f._inView ~= false and f._hint and f._inheritNote and
                not (self._showErrors and f._error) and self:_isShowingInherited(f) then
                local x = f._fieldX or PAD
                local hintText = f.hint or ""
                if hintText ~= "" then
                    x = x + getTextManager():MeasureStringX(UIFont.Small, hintText) + PAD
                end
                self:drawText(f._inheritNote, x, f._hint:getY(), 0.45, 0.72, 0.78, 1, UIFont.Small)
            end
        end
    end

    -- Where there is more form than window, a bar on the right edge saying so.
    -- Otherwise the only clue that a field has scrolled out of reach is that it
    -- is not there.
    if (self._scrollRange or 0) > 0 then
        local th = self:titleBarHeight()
        local trackTop = th + 2
        local trackH = self.height - self:footerHeight() - trackTop - 2
        if trackH > 0 then
            local total = trackH + self._scrollRange
            local thumbH = math.max(math.floor(20 * FONT_SCALE), math.floor(trackH * trackH / total))
            local thumbY = trackTop + math.floor((trackH - thumbH) * (self._scrollY / self._scrollRange))
            self:drawRect(self.width - 6, trackTop, 4, trackH, 0.25, 1, 1, 1)
            self:drawRect(self.width - 6, thumbY, 4, thumbH, 0.5, 1, 1, 1)
        end
    end

    for _, f in ipairs(self._fields) do
        if not f.visible or f._inView == false then
            -- skip: hidden, or scrolled out of the field area
        elseif f.type == "separator" and f._drawY then
            local w = self.width - PAD * 2
            self:drawRect(PAD, f._drawY, w, 1, 0.3, 0.4, 0.4, 0.4)
            if f.text then
                self:drawText(f.text, PAD, f._drawY + 4, 0.6, 0.6, 0.6, 1, UIFont.Small)
            end

        elseif f.type == "image" and f._drawY then
            if f.label then
                self:drawText(f.label .. ":", PAD, f._drawY + (f.imageHeight - FONT_HGT_SMALL) / 2, 1, 1, 1, 1,
                    UIFont.Small)
            end
            local ix = f._fieldX or PAD
            local sz = f.imageHeight
            -- Recomputed each frame rather than cached: what to show depends on
            -- the field above, and this is a handful of draw calls.
            local ok, images = pcall(f.images or function()
                return {}
            end)
            if ok and images then
                for _, img in ipairs(images) do
                    -- Extra space before an entry that starts a second group,
                    -- so one row can hold two related sets without a caption
                    -- explaining where one ends.
                    if img.gap then
                        ix = ix + PAD * 2
                    end
                    if img.texture then
                        self:drawTextureScaledAspect(img.texture, ix, f._drawY, sz, sz, 1, 1, 1, 1)
                    else
                        -- A slot we could not resolve. Drawn as an empty frame,
                        -- because silence would read as "there is nothing here"
                        -- when it means "this name did not match anything".
                        self:drawRectBorder(ix, f._drawY, sz, sz, 0.5, 0.6, 0.4, 0.4)
                    end
                    if img.label then
                        self:drawTextCentre(img.label, ix + sz / 2, f._drawY + sz, 0.6, 0.6, 0.6, 1, UIFont.Small)
                    end
                    ix = ix + sz + PAD
                end
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
-- Validation
---------------------------------------------------------------------------

--- True when a field holds nothing the user has entered.
local function isFieldBlank(f, value)
    if f.type == "picker" then
        if value == nil or value == "" then
            return true
        end
        return type(value) == "table" and #value == 0
    elseif f.type == "range" then
        return type(value) ~= "table" or (value.min == "" and value.max == "")
    end
    return value == nil or value == ""
end

--- Run one field's rules. Returns an error string, or nil when the field is ok.
local function validateField(form, f)
    if f.type == "separator" or f.type == "image" or f.type == "list" or f.type == "check" then
        return nil
    end

    local value = form:getFieldValue(f.key)
    local blank = isFieldBlank(f, value)

    if f.required and blank then
        return getText("IGUI_PhunMart_Err_Required")
    end

    -- Built-in checks only apply to a field the user has filled in; a custom
    -- validate still runs either way, since it may be what decides whether an
    -- empty value is acceptable.
    if not blank then
        local err = FormPanel._builtinChecks(form, f, value)
        if err then
            return err
        end
    end

    if f.validate then
        return f.validate(value, form)
    end
    return nil
end

function FormPanel._builtinChecks(form, f, value)
    if f.type == "range" then
        local mn, mx = form:getFieldRange(f.key)
        if (value.min ~= "" and not mn) or (value.max ~= "" and not mx) then
            return getText("IGUI_PhunMart_Err_Numeric")
        end
        if f.requireBoth and (not mn or not mx) then
            return getText("IGUI_PhunMart_Err_RangeBoth")
        end
        if mn and mx and mx < mn then
            return getText("IGUI_PhunMart_Err_RangeOrder")
        end
        if f.min and ((mn and mn < f.min) or (mx and mx < f.min)) then
            return getText("IGUI_PhunMart_Err_Min", tostring(f.min))
        end
        -- `max` and `integer` were declared by range call sites and enforced by
        -- none of them: only `min` was ever read here. So a stock or roll field
        -- saying integer accepted 2.5 and the editor floored it without saying
        -- so, and an upper bound meant nothing at all.
        if f.max and ((mn and mn > f.max) or (mx and mx > f.max)) then
            return getText("IGUI_PhunMart_Err_Max", tostring(f.max))
        end
        if f.integer and ((mn and mn % 1 ~= 0) or (mx and mx % 1 ~= 0)) then
            return getText("IGUI_PhunMart_Err_Integer")
        end
    elseif f.numeric or f.integer or f.min ~= nil or f.max ~= nil then
        local n = tonumber(value)
        if not n then
            return getText("IGUI_PhunMart_Err_Numeric")
        end
        if f.integer and n % 1 ~= 0 then
            return getText("IGUI_PhunMart_Err_Integer")
        end
        if f.min ~= nil and n < f.min then
            return getText("IGUI_PhunMart_Err_Min", tostring(f.min))
        end
        if f.max ~= nil and n > f.max then
            return getText("IGUI_PhunMart_Err_Max", tostring(f.max))
        end
    end
    return nil
end

--- Push each field's current error, provenance, or hint into its message label.
---
--- An error replaces the hint, because a field you have got wrong has nothing
--- more useful to say. Provenance does not: it is drawn after the hint in
--- prerender, in its own colour, so a field can say both what it is for and
--- where its value came from. Replacing the hint cost the explanation on
--- exactly the fields most likely to need one.
--- Three things can occupy the line under a field, and they rank.
---
--- An error is red, appears once Apply has been attempted, and stops the save.
--- A warning is amber, appears the moment it becomes true, and stops nothing:
--- it is for a setting that is allowed and probably not what was meant, where
--- refusing the save would be wrong because the missing half can legitimately
--- arrive from somewhere this form cannot see.
--- A hint is grey and says what the field is for.
function FormPanel:_refreshMessages()
    for _, f in ipairs(self._fields) do
        if f._hint then
            local showError = self._showErrors and f._error
            if showError then
                f._hint:setName(showError)
                f._hint.r, f._hint.g, f._hint.b = 0.95, 0.45, 0.4
            elseif f.warning then
                f._hint:setName(f.warning)
                f._hint.r, f._hint.g, f._hint.b = 0.95, 0.75, 0.35
            else
                f._hint:setName(f.hint or "")
                f._hint.r, f._hint.g, f._hint.b = 0.5, 0.5, 0.5
            end
            -- Re-apply position after setName (PZ ISLabel resets x)
            if f._fieldX then
                f._hint:setX(f._fieldX)
            end
        end
    end
end

--- Validate every visible field plus any cross-field rule.
--- Returns true when the form is safe to apply.
function FormPanel:validateAll()
    local ok = true
    for _, f in ipairs(self._fields) do
        if f.visible then
            f._error = validateField(self, f)
            if f._error then
                ok = false
            end
        else
            f._error = nil
        end
    end

    self._formError = nil
    if ok and self._validateForm then
        self._formError = self._validateForm(self)
        if self._formError then
            ok = false
        end
    end

    self:_refreshMessages()
    return ok
end

---------------------------------------------------------------------------
-- Apply / Cancel
---------------------------------------------------------------------------

function FormPanel:_onApplyClick()
    -- From the first Apply onwards, errors track edits live rather than only
    -- appearing on click.
    self._showErrors = true
    if not self:validateAll() then
        return
    end
    -- Mid-wizard this button is Next, and validateAll has just checked the
    -- current step, since it only looks at what is visible.
    if self._steps and self._step < #self._steps then
        self._step = self._step + 1
        self:_applyStep()
        return
    end
    if self._onApply then
        self._onApply(self)
    end
end

function FormPanel:_onDeleteClick()
    if self._onDelete then
        self._onDelete(self)
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

---------------------------------------------------------------------------
-- Keyboard
---------------------------------------------------------------------------

function FormPanel:isKeyConsumed(key)
    return key == Keyboard.KEY_ESCAPE
end

function FormPanel:onKeyRelease(key)
    if key == Keyboard.KEY_ESCAPE then
        self:_onCancelClick()
    end
end

return FormPanel
