if isServer() then
    return
end

require "ISUI/ISPanel"
local Core = PhunMart
local tools = require "PhunMart_Client/ui/ui_utils"
require "PhunMart/references"

local FONT_HGT_SMALL = tools.FONT_HGT_SMALL
local FONT_HGT_MEDIUM = tools.FONT_HGT_MEDIUM
local FONT_SCALE = tools.FONT_SCALE
local PAD = math.max(10, math.floor(10 * FONT_SCALE))
local ROW_H = FONT_HGT_SMALL + math.floor(6 * FONT_SCALE)
local BUTTON_HGT = tools.BUTTON_HGT
local HEADER_HGT = tools.HEADER_HGT
local SCROLLBAR_W = 13

-- A content panel rather than a window. Every definition list used to be its
-- own collapsable window, which is how an admin ended up with seven of them
-- stacked on top of each other while following a single shop down to a price.
-- They are now views inside one tabbed shell (see ui/admin/admin_shell.lua),
-- so this owns the list and its controls and nothing about window chrome.
local ListPanel = ISPanel:derive("PhunMartListPanel")

-- Filter tab states. Shared because prerender assigns them every frame.
local TAB_ON = {r = 0.3, g = 0.7, b = 0.35, a = 0.4}
local TAB_OFF = {r = 0, g = 0, b = 0, a = 0.25}
local TAB_HOVER = {r = 0.3, g = 0.7, b = 0.35, a = 0.2}

-- Open panels, weakly held so closed ones fall out on their own.
local liveInstances = setmetatable({}, {
    __mode = "k"
})

-- Re-read whenever the definitions recompile, so a change made anywhere (a
-- different panel, the in-shop menu, another admin in multiplayer) shows up
-- without reopening the window. Subclasses opt in by setting UI.refresh.
Events[Core.events.OnDefsUpdated].Add(function()
    for inst in pairs(liveInstances) do
        if inst.refresh and inst:isLive() then
            inst:refresh()
        end
    end
end)

-- Export constants for subclasses
ListPanel.PAD = PAD
ListPanel.ROW_H = ROW_H
ListPanel.FONT_SCALE = FONT_SCALE
ListPanel.FONT_HGT_SMALL = FONT_HGT_SMALL
ListPanel.FONT_HGT_MEDIUM = FONT_HGT_MEDIUM
ListPanel.HEADER_HGT = HEADER_HGT
ListPanel.SCROLLBAR_W = SCROLLBAR_W

---------------------------------------------------------------------------
-- Construction
---------------------------------------------------------------------------

function ListPanel:new(x, y, width, height, player)
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.player = player
    o.playerIndex = player:getPlayerNum()
    o.backgroundColor = {r = 0, g = 0, b = 0, a = 0}
    o.borderColor = {r = 0, g = 0, b = 0, a = 0}
    o.moveWithMouse = false
    liveInstances[o] = true
    return o
end

--- The shell that owns this view sets itself here, so the Close button and the
--- Escape key can act on the window rather than on a panel that has none.
function ListPanel:setShell(shell)
    self.shell = shell
end

--- On screen right now? A hidden window does not clear its children's visible
--- flags, so a view inside a closed shell still reports itself as visible and
--- would keep doing refresh work nobody can see.
function ListPanel:isLive()
    if self.shell and not self.shell:isVisible() then
        return false
    end
    return self:isVisible()
end

function ListPanel:requestClose()
    if self.shell then
        self.shell:close()
    end
end

---------------------------------------------------------------------------
-- Skeleton: description area, scrolling list, and bottom button bar.
---------------------------------------------------------------------------

function ListPanel:createChildren()
    ISPanel.createChildren(self)

    local w = self.width
    local h = self.height

    -- Main content panel
    local mainPanel = ISPanel:new(0, 0, w, h)
    mainPanel:initialise()
    mainPanel:instantiate()
    self:addChild(mainPanel)
    self._mainPanel = mainPanel

    -- Button bar at bottom
    local btnBarH = BUTTON_HGT + PAD * 2
    local btnBar = ISPanel:new(0, h - btnBarH, w, btnBarH)
    btnBar:initialise()
    btnBar:instantiate()
    self._mainPanel:addChild(btnBar)
    self._buttonBar = btnBar
    self._bottomButtons = {}

    -- Scrolling list (fills the space between description and button bar)
    local list = ISScrollingListBox:new(PAD, HEADER_HGT, w - PAD * 2, 100)
    list:initialise()
    list:instantiate()
    list.itemheight = FONT_HGT_SMALL + 6 * 2
    list.selected = 0
    list.joypadParent = self
    list.font = UIFont.NewSmall
    list.drawBorder = true
    -- Back-reference: doDrawItem runs with the list box as self, so a row
    -- renderer has no other route to the panel that owns it.
    list.panel = self
    self._mainPanel:addChild(list)
    self.list = list
    self._columnDefs = {}
    self._allItems = {}

    -- Filter entry (in button bar, left side). A subclass sets _noFilter when
    -- its list is a fixed handful of rows: a search box over six of them is one
    -- more control to read past for no gain.
    if not self._noFilter then
        local filterLblW = getTextManager():MeasureStringX(UIFont.Small, getText("IGUI_PhunMart_Lbl_Filter")) + 8
        local filterLbl = ISLabel:new(PAD, PAD, BUTTON_HGT, getText("IGUI_PhunMart_Lbl_Filter"), 0.8, 0.8, 0.8, 1, UIFont.Small, true)
        filterLbl:initialise()
        self._buttonBar:addChild(filterLbl)
        self._filterLabel = filterLbl

        local filterEntry = ISTextEntryBox:new("", PAD + filterLblW, PAD, 100, BUTTON_HGT)
        filterEntry:initialise()
        filterEntry:instantiate()
        filterEntry:setClearButton(true)
        self._buttonBar:addChild(filterEntry)
        self._filterEntry = filterEntry
    end
    self._lastFilterText = ""

    -- Only shown on panels that declare a definition kind, since the other
    -- lists (token rewards, the global blacklist) are not override-backed and
    -- have nothing to compare against.
    if self._defKind then
        local tick = ISTickBox:new(0, PAD, BUTTON_HGT, BUTTON_HGT, "")
        tick:initialise()
        tick:instantiate()
        tick:addOption(getText("IGUI_PhunMart_Lbl_OnlyChanged"), nil)
        tick:setSelected(1, false)
        -- The stripe colours mean nothing on their own, and this is the only
        -- control that sits next to them.
        tick.tooltip = getText("IGUI_PhunMart_Tip_OnlyChanged")
        tick.changeOptionMethod = function()
            self:applyFilter()
        end
        tick.changeOptionTarget = self
        self._buttonBar:addChild(tick)
        self._onlyChangedTick = tick
        self._onlyChangedW = getTextManager():MeasureStringX(UIFont.Small, getText("IGUI_PhunMart_Lbl_OnlyChanged")) +
                                 BUTTON_HGT + PAD
    end

    -- A second tickbox for lists whose rows are mostly generated variants of
    -- one another. Declared by the subclass overriding isVariation, and ticked
    -- by default: a list where nine rows in ten differ only by a skill name
    -- opens more usefully with them folded away.
    if self.isVariation ~= ListPanel.isVariation then
        local vtick = ISTickBox:new(0, PAD, BUTTON_HGT, BUTTON_HGT, "")
        vtick:initialise()
        vtick:instantiate()
        vtick:addOption(getText("IGUI_PhunMart_Lbl_HideVariations"), nil)
        vtick:setSelected(1, true)
        vtick.tooltip = getText("IGUI_PhunMart_Tip_HideVariations")
        vtick.changeOptionMethod = function()
            self:applyFilter()
        end
        vtick.changeOptionTarget = self
        self._buttonBar:addChild(vtick)
        self._hideVariationsTick = vtick
        self._hideVariationsW = getTextManager():MeasureStringX(UIFont.Small,
            getText("IGUI_PhunMart_Lbl_HideVariations")) + BUTTON_HGT + PAD
    end

    -- The "used by" line, as a button rather than drawn text so it can be
    -- clicked through to whatever it names. It keeps real button chrome: as
    -- flat text it read as a status line and nobody would think to click it,
    -- and a hover tint is no help when you have to hover to find it. Toned down
    -- against the action buttons, because it reports as much as it does.
    if self:showsReferences() then
        local refsBtn = ISButton:new(PAD, 0, 10, BUTTON_HGT, "", self, self.onReferenceClick)
        refsBtn:initialise()
        refsBtn:instantiate()
        refsBtn.font = UIFont.Small
        refsBtn.backgroundColor = {r = 0, g = 0, b = 0, a = 0.25}
        refsBtn.backgroundColorMouseOver = {r = 0.3, g = 0.7, b = 0.35, a = 0.35}
        refsBtn.borderColor = {r = 0.55, g = 0.55, b = 0.55, a = 0.7}
        refsBtn.textColor = {r = 0.8, g = 0.8, b = 0.8, a = 1}
        -- Held rather than assigned, because prerender takes it off again when
        -- the line has nothing to click through to.
        refsBtn._tip = getText("IGUI_PhunMart_Tip_UsedBy")
        refsBtn:setVisible(false)
        self._mainPanel:addChild(refsBtn)
        self._refsBtn = refsBtn
    end

    -- Close button (right-aligned in button bar)
    local closeBtnW = math.max(math.floor(70 * FONT_SCALE),
        getTextManager():MeasureStringX(UIFont.Small, getText("IGUI_PhunMart_Btn_Close")) + PAD * 2)
    local closeBtn = ISButton:new(0, PAD, closeBtnW, BUTTON_HGT, getText("IGUI_PhunMart_Btn_Close"), self,
        self.requestClose)
    closeBtn:initialise()
    closeBtn:instantiate()
    if closeBtn.enableCancelColor then
        closeBtn:enableCancelColor()
    end
    self._buttonBar:addChild(closeBtn)
    self._closeBtn = closeBtn
end

---------------------------------------------------------------------------
-- Column / button helpers (called by subclass in createChildren)
---------------------------------------------------------------------------

--- Add a column to the list.
-- @param name  Column header text
-- @param size  If 0, starts at left edge. If < 1, treated as a fraction of
--              list width (recalculated on resize). If >= 1, absolute pixels.
-- @param opts  How defaultDrawRow should render this column:
--   field  key into the row's data table
--   text   function(data) -> string, when the cell isn't a plain field
--   color  {r,g,b} or function(data) -> r,g,b; defaults to white for the first
--          column and grey for the rest
--   sub    function(data) -> string, drawn dim after the main text in the same
--          cell. Used for the key trailing a name.
--   align  "right" to right-align against the list edge
function ListPanel:addListColumn(name, size, opts)
    opts = opts or {}
    table.insert(self._columnDefs, {
        name = name,
        size = size,
        field = opts.field,
        text = opts.text,
        sub = opts.sub,
        color = opts.color,
        align = opts.align
    })
    -- Set initial position; fractional values are recalculated in prerender
    local pos = size
    if size > 0 and size < 1 then
        pos = math.floor(self.list.width * size)
    end
    self.list:addColumn(name, pos)
end

---------------------------------------------------------------------------
-- Names
--
-- Keys are precise and unreadable. pool_shedsandcommoners_t1 tells you nothing
-- at a glance, and the information that would fix it exists only as a Lua
-- comment above the block that no admin ever sees. A definition can carry a
-- `title` now, shown in place of the key with the key trailing in grey, so
-- nothing is lost for the people who think in keys.
---------------------------------------------------------------------------

--- The name an admin gave this definition, or nil when it only has a key.
--- Accepts a translation key so shipped content stays translatable while an
--- admin can just type something.
---
--- Groups had a `label` long before any of this, and it already reads well on
--- the 21 that have one, so it stands in when there is no title. The two are
--- not the same field: label is the category heading players see in the shop,
--- so a group can reasonably want both.
function ListPanel:titleFor(def)
    if not def then
        return nil
    end
    local t = def.title
    if (not t or t == "") and self._defKind == "groups" then
        t = def.label
    end
    if not t or t == "" then
        return nil
    end
    return getTextOrNull(t) or t
end

--- Compose the first cell of a row: the name if there is one, else the key,
--- with any status markers appended. Returns the composed text and the title,
--- since a row needs to know whether it has one to decide what the key does.
-- @param markers array of suffixes such as "[S]" or "[off]", may be nil
function ListPanel:rowName(key, def, markers)
    local title = self:titleFor(def)
    local name = title or key
    for _, m in ipairs(markers or {}) do
        name = name .. " " .. m
    end
    return name, title
end

--- Sort keys by the name each row will show rather than by the key itself.
--- Once a definition has a name, the key is no longer what you are reading, so
--- ordering by it makes an otherwise sorted list look shuffled. Ties fall back
--- to the key so the order stays stable between sessions.
function ListPanel:sortKeysByName(keys, defs)
    table.sort(keys, function(a, b)
        local an = (self:titleFor(defs[a]) or a):lower()
        local bn = (self:titleFor(defs[b]) or b):lower()
        if an == bn then
            return a < b
        end
        return an < bn
    end)
end

--- The first column of a definition list. Every one of them wants the same
--- thing, so the only per-list part is the colour rule for its status markers.
function ListPanel:addNameColumn(color)
    self:addListColumn(getText("IGUI_PhunMart_Col_Name"), 0, {
        text = function(d)
            return d.name or d.key
        end,
        -- Only once there is a name to distinguish it from, otherwise the key
        -- would be printed twice on the same row.
        sub = function(d)
            return d.title and d.key or ""
        end,
        color = color
    })
end

---------------------------------------------------------------------------
-- Filter tabs
--
-- A row of buttons above the list for narrowing to one category of row. Built
-- to read as tabs rather than as a dropdown, because the categories are half
-- the value: someone asking "why is that vehicle not showing up" needs to see
-- that there is a Vehicles grouping at all, and a dropdown hides exactly that
-- until it is opened. They sit inside the list rather than in the shell's tab
-- strip, which is already carrying eight and would start scrolling.
---------------------------------------------------------------------------

--- @param tabs array of {key = "xp", label = "XP"}. The first is selected.
function ListPanel:addFilterTabs(tabs)
    self._filterTabs = {}
    for _, t in ipairs(tabs) do
        local w = getTextManager():MeasureStringX(UIFont.Small, t.label) + PAD * 2
        local btn = ISButton:new(0, 0, w, BUTTON_HGT, t.label, self, self.onFilterTabClick)
        btn:initialise()
        btn:instantiate()
        btn._tabKey = t.key
        btn.borderColor = {r = 0.5, g = 0.5, b = 0.5, a = 0.6}
        self._mainPanel:addChild(btn)
        table.insert(self._filterTabs, btn)
    end
    self._activeFilterTab = tabs[1] and tabs[1].key or nil
end

function ListPanel:onFilterTabClick(btn)
    self._activeFilterTab = btn._tabKey
    -- The selection almost certainly is not in the new set, and keeping it
    -- would leave the "used by" line describing a row nobody can see.
    self.list.selected = 0
    self:applyFilter()
end

--- Does this row belong in the given tab? Override in a subclass that adds
--- filter tabs. Called for every row on every filter pass, so keep it cheap.
function ListPanel:rowInFilterTab(itemData, tabKey)
    return true
end

--- Is this row one of many near-identical generated entries? A subclass that
--- overrides this gets a "hide variations" tickbox; the base answer of false
--- means no such box appears, which is right for a list of distinct things.
function ListPanel:isVariation(itemData)
    return false
end

--- Add a button to the bottom bar (left-aligned).
-- @param text            Button label
-- @param callback        Click handler
-- @param requiresSelection  If true, button is disabled when no list row is selected
function ListPanel:addBottomButton(text, callback, requiresSelection)
    local btnW = math.max(math.floor(70 * FONT_SCALE),
        getTextManager():MeasureStringX(UIFont.Small, text) + PAD * 2)
    local btn = ISButton:new(0, PAD, btnW, BUTTON_HGT, text, self, callback)
    btn:initialise()
    btn:instantiate()
    btn._requiresSelection = requiresSelection
    self._buttonBar:addChild(btn)
    table.insert(self._bottomButtons, btn)
    return btn
end

---------------------------------------------------------------------------
-- Customisation state
---------------------------------------------------------------------------

-- A subclass declares which definition category it edits by setting _defKind
-- on the class table, e.g. `UI._defKind = "pools"`. That enables the row
-- markers and the "only my changes" filter. It is a field rather than a setter
-- because createChildren reads it, so a setter would have to be called before
-- initialise and could be forgotten. Panels backed by something other than the
-- override files simply leave it unset.

---------------------------------------------------------------------------
-- "Used by" line
--
-- The definition tables only ever store the forward direction, so until now
-- nothing could answer "what breaks if I change this?". The edit form already
-- shows what a definition points at, via its own pickers; this is the opposite
-- direction, which was not available anywhere.
--
-- Recomputed only when the selection changes or the definitions recompile:
-- references.find scans every table, which is fine on a click and wasteful at
-- sixty frames a second.
---------------------------------------------------------------------------

--- True when this panel's category is one something else can point at.
function ListPanel:showsReferences()
    return self._defKind ~= nil and Core.references.canBeReferenced(self._defKind)
end

function ListPanel:updateReferenceLine()
    if not self:showsReferences() then
        return
    end

    local key
    local sel = self.list.selected
    if sel and sel > 0 and self.list.items[sel] then
        key = self:getRowKey(self.list.items[sel].item)
    end

    if key == self._refsKey and not self._refsDirty then
        return
    end
    self._refsKey = key
    self._refsDirty = false

    if not key then
        self._refsText = ""
        self._refsOrphan = false
        return
    end

    local found = Core.references.find(self._defKind, key)
    self._refsOrphan = #found == 0
    if self._refsOrphan then
        -- Worth saying out loud: an unreferenced definition is dead weight, and
        -- there was previously no way to notice.
        self._refsText = getText("IGUI_PhunMart_Lbl_UsedByNothing")
    else
        self._refsText = getText("IGUI_PhunMart_Lbl_UsedBy", Core.references.summarise(found))
    end
end

--- Follow one reference: switch the shell to that category's tab and select
--- the row. The kinds references.find reports are the same strings the shell
--- keys its tabs by, so no mapping is needed between them.
function ListPanel:gotoReference(ref)
    if not ref or not self.shell then
        return
    end
    local view = self.shell:activateTab(ref.kind)
    if view and view.selectKey then
        view:selectKey(ref.key)
    end
end

--- Clicking the "used by" line. One referrer goes straight there. Several are
--- offered as a menu grouped by category, so the top level reads the same as
--- the line itself ("3 pools, 1 shop") rather than as a flat list that a price
--- used by forty items would bury the screen in.
function ListPanel:onReferenceClick()
    if self._refsOrphan or not self._refsKey then
        return
    end
    local found = Core.references.find(self._defKind, self._refsKey)
    if #found == 0 then
        return
    end
    if #found == 1 then
        self:gotoReference(found[1])
        return
    end

    local order, byKind = {}, {}
    for _, r in ipairs(found) do
        if not byKind[r.kind] then
            byKind[r.kind] = {}
            table.insert(order, r.kind)
        end
        table.insert(byKind[r.kind], r)
    end

    local btn = self._refsBtn
    local context = ISContextMenu.get(self.playerIndex, btn:getAbsoluteX(), btn:getAbsoluteY())
    for _, kind in ipairs(order) do
        local group = byKind[kind]
        local sub = ISContextMenu:getNew(context)
        -- summarise gives "3 pools" / "1 shop", the same wording as the line.
        context:addSubMenu(context:addOption(Core.references.summarise(group)), sub)
        for _, r in ipairs(group) do
            -- The field holding the reference, because "why is this here" is
            -- most of the question being asked.
            sub:addOption(r.key .. "  (" .. r.via .. ")", self, self.gotoReference, r)
        end
    end
end

--- Where the key lives in a row's data. Every definition panel stores it as
--- `key`; override if one ever doesn't.
function ListPanel:getRowKey(itemData)
    return itemData and itemData.key
end

--- "custom" for an admin-created definition, "modified" for a shipped one that
--- has been edited, "stock" for one nobody has touched. nil when the panel has
--- no definition kind to ask about.
function ListPanel:rowState(key)
    if not self._defKind or not key then
        return nil
    end
    if not Core.isShippedKey(self._defKind, key) then
        return "custom"
    end
    if Core.isOverriddenKey(self._defKind, key) then
        return "modified"
    end
    return "stock"
end

--- Draw the state marker for a row. Called from a subclass's doDrawItem, so
--- `listSelf` is the list box rather than the panel.
--- A stripe down the left edge rather than a text colour, because the row
--- renderers already use text colour for other things (sticky pools, disabled
--- entries) and the two meanings would collide.
function ListPanel.drawStateStripe(listSelf, y, key)
    local panel = listSelf.panel
    if not panel then
        return
    end
    local state = panel:rowState(key)
    if state == "custom" then
        listSelf:drawRect(0, y, 3, listSelf.itemheight, 0.9, 0.35, 0.7, 1)
    elseif state == "modified" then
        listSelf:drawRect(0, y, 3, listSelf.itemheight, 0.9, 0.9, 0.7, 0.25)
    end
end

---------------------------------------------------------------------------
-- Row rendering
---------------------------------------------------------------------------

--- Generic row renderer driven by the column definitions.
--- Every panel used to carry its own copy of this: identical cull check,
--- selection highlight, alternating shade, border and stencilled column loop,
--- differing only in which field each column read and what colour it drew in.
--- Those differences are declared on the column now, so a change to row
--- styling is one edit rather than six, and the lists cannot drift apart.
--- Runs with the list box as `listSelf`, which is why it reaches the owning
--- panel through the back-reference rather than through self.
function ListPanel.defaultDrawRow(listSelf, y, item, alt)
    local h = listSelf.itemheight
    if y + listSelf:getYScroll() + h < 0 or y + listSelf:getYScroll() >= listSelf.height then
        return y + h
    end

    local panel = listSelf.panel
    local data = item.item
    local a = 0.9

    if listSelf.selected == item.index then
        listSelf:drawRect(0, y, listSelf:getWidth(), h, 0.3, 0.7, 0.35, 0.15)
    end
    if alt then
        listSelf:drawRect(0, y, listSelf:getWidth(), h, 0.3, 0.6, 0.5, 0.5)
    end
    listSelf:drawRectBorder(0, y, listSelf:getWidth(), h, a, listSelf.borderColor.r, listSelf.borderColor.g,
        listSelf.borderColor.b)

    ListPanel.drawStateStripe(listSelf, y, panel and panel:getRowKey(data))

    local cols = (panel and panel._columnDefs) or {}
    local textY = y + (h - FONT_HGT_SMALL) / 2
    local rightEdge = listSelf.width - SCROLLBAR_W
    local clipY = math.max(0, y + listSelf:getYScroll())
    local clipY2 = math.min(listSelf.height, y + listSelf:getYScroll() + h)

    for i, col in ipairs(cols) do
        local x = listSelf.columns[i] and listSelf.columns[i].size or 0
        local nextX = (listSelf.columns[i + 1] and listSelf.columns[i + 1].size) or rightEdge

        local text = ""
        if col.text then
            text = col.text(data) or ""
        elseif col.field then
            text = data[col.field] or ""
        end
        if type(text) ~= "string" then
            text = tostring(text)
        end

        if text ~= "" then
            -- First column reads as the row's identity, so it gets full white.
            local r, g, b = 0.8, 0.8, 0.8
            if i == 1 then
                r, g, b = 1, 1, 1
            end
            if type(col.color) == "function" then
                local cr, cg, cb = col.color(data)
                if cr then
                    r, g, b = cr, cg, cb
                end
            elseif type(col.color) == "table" then
                r, g, b = col.color[1], col.color[2], col.color[3]
            end

            local tx
            if col.align == "right" then
                tx = rightEdge - getTextManager():MeasureStringX(listSelf.font, text) - 10
            elseif i == 1 then
                tx = 10
            else
                tx = x + 4
            end

            listSelf:setStencilRect(x, clipY, math.max(0, nextX - x), clipY2 - clipY)
            listSelf:drawText(text, tx, textY, r, g, b, a, listSelf.font)
            -- Secondary text sharing the cell, dimmer: the key trailing the name
            -- a definition was given. Drawn inside the same stencil so it clips
            -- against this column rather than running into the next one.
            if col.sub then
                local sub = col.sub(data)
                if sub and sub ~= "" then
                    local mainW = getTextManager():MeasureStringX(listSelf.font, text)
                    listSelf:drawText(sub, tx + mainW + 10, textY, 0.45, 0.45, 0.45, a, listSelf.font)
                end
            end
            listSelf:clearStencilRect()
        end
    end

    listSelf.itemsHeight = y + h
    return listSelf.itemsHeight
end

--- Override in subclass to return the searchable text for a list item.
-- Receives the item data (the second arg passed to list:addItem).
-- Default: uses the display text (first arg to addItem).
function ListPanel:getFilterText(itemData)
    return nil
end

--- Call this instead of self.list:addItem() so the base can track all items
--- for filtering. Arguments match ISScrollingListBox:addItem(text, data).
function ListPanel:addListItem(text, data)
    table.insert(self._allItems, {text = text, data = data})
    self.list:addItem(text, data)
end

--- Clear all items (call at start of refresh).
function ListPanel:clearList()
    -- Remember what was selected. Refresh runs on a save, on a recompile and
    -- on every tab switch, and without this each one dumped you back at the top
    -- of the list. Switching to a tab and back is how you retrace a
    -- click-through, so the selection has to survive the trip.
    local sel = self.list.selected
    local current = sel and sel > 0 and self.list.items[sel]
    self._pendingSelectKey = current and self:getRowKey(current.item) or nil

    self._allItems = {}
    self.list:clear()
    -- The reference counts may have moved with the data.
    self._refsDirty = true
    -- Keep whatever is typed in the box but forget that it was applied, so the
    -- next prerender reapplies it against the rebuilt list. Refresh runs on
    -- every save and on every tab switch, and clearing the box outright meant
    -- leaving a list and coming back lost the filter you were working under.
    self._lastFilterText = nil
end

--- Select the row holding `key`, scrolling it into view. Used when the shell
--- is asked to open on a particular definition rather than just a tab.
--- Returns true when the key was found.
function ListPanel:selectKey(key)
    if not key then
        return false
    end

    -- Filter first. A refresh leaves the list unfiltered until the next
    -- prerender, so selecting before that would pick a row out of a list that
    -- is about to be rebuilt, and ISScrollingListBox:clear resets the
    -- selection. Applying it here also settles _lastFilterText, so prerender
    -- leaves the selection alone.
    self:applyFilter()
    if self:findAndSelect(key) then
        return true
    end

    -- Not in view, so the current filter is hiding it. Being sent to a
    -- definition and landing on nothing is worse than losing a filter you can
    -- retype, so drop both filters and look again.
    if self._filterEntry then
        self._filterEntry:setText("")
    end
    if self._onlyChangedTick then
        self._onlyChangedTick:setSelected(1, false)
    end
    self:applyFilter()
    return self:findAndSelect(key)
end

function ListPanel:findAndSelect(key)
    for i, entry in ipairs(self.list.items) do
        if self:getRowKey(entry.item) == key then
            self.list.selected = i
            self.list:ensureVisible(i)
            self._refsDirty = true
            return true
        end
    end
    return false
end

--- Reapply the current filter against _allItems.
function ListPanel:applyFilter()
    -- Remember the text as typed. prerender compares against the box verbatim,
    -- so storing the lowered copy had any capitalised filter reapplying itself
    -- on every frame.
    local typed = self._filterEntry and self._filterEntry:getText() or ""
    self._lastFilterText = typed
    local filterText = typed:lower()

    local onlyChanged = self._onlyChangedTick and self._onlyChangedTick:isSelected(1)
    local hideVariations = self._hideVariationsTick and self._hideVariationsTick:isSelected(1)

    self.list:clear()
    for _, entry in ipairs(self._allItems) do
        local include = true

        if onlyChanged then
            local state = self:rowState(self:getRowKey(entry.data))
            include = state == "custom" or state == "modified"
        end

        if include and self._activeFilterTab then
            include = self:rowInFilterTab(entry.data, self._activeFilterTab)
        end

        -- Typing a filter means looking for something specific, and a hidden
        -- variation is still a real entry, so a search reaches past this.
        if include and hideVariations and filterText == "" then
            include = not self:isVariation(entry.data)
        end

        if include and filterText ~= "" then
            local searchable = self:getFilterText(entry.data) or entry.text
            include = searchable:lower():find(filterText, 1, true) ~= nil
        end

        if include then
            self.list:addItem(entry.text, entry.data)
        end
    end

    -- Rows only exist once they are through the filter, so restoring the
    -- selection belongs here rather than in clearList where it was captured.
    if self._pendingSelectKey then
        local key = self._pendingSelectKey
        self._pendingSelectKey = nil
        self:findAndSelect(key)
    end
end

---------------------------------------------------------------------------
-- Layout (prerender)
---------------------------------------------------------------------------

function ListPanel:prerender()
    ISPanel.prerender(self)

    local w = self.width
    local contentH = self.height

    -- Main panel
    self._mainPanel:setX(0)
    self._mainPanel:setY(0)
    self._mainPanel:setWidth(w)
    self._mainPanel:setHeight(contentH)

    -- Description area height
    local descH = 0
    if self.description and self.description ~= "" then
        local maxW = w - PAD * 2
        self._descLines = tools.wrapText(self.description, maxW, UIFont.Small)
        descH = #self._descLines * FONT_HGT_SMALL + PAD
    end

    -- The bar splits onto two lines when one will not hold everything. Narrowing
    -- controls above, acting ones below. It used to squeeze the filter box to a
    -- minimum and let it sit underneath whatever it collided with, which was
    -- how a second tickbox made the Filter label overlap it.
    local hasSelection = self.list.selected and self.list.selected > 0
    local hasFilter = self._filterEntry ~= nil
    local filterLblW = hasFilter and
                           (getTextManager():MeasureStringX(UIFont.Small, getText("IGUI_PhunMart_Lbl_Filter")) + 8) or 0
    local filterMinW = hasFilter and math.floor(150 * FONT_SCALE) or 0

    local actionsW = self._closeBtn.width + PAD
    for _, btn in ipairs(self._bottomButtons) do
        if btn:isVisible() then
            actionsW = actionsW + btn.width + PAD
        end
    end
    local narrowW = PAD + filterLblW + filterMinW + PAD + (self._onlyChangedW or 0) + (self._hideVariationsW or 0)
    local twoRows = (narrowW + actionsW + PAD) > w

    local topY = PAD
    local actionY = twoRows and (PAD * 2 + BUTTON_HGT) or PAD

    -- Button bar at bottom, tall enough for however many lines it needs.
    local btnBarH = twoRows and (BUTTON_HGT * 2 + PAD * 3) or (BUTTON_HGT + PAD * 2)
    self._buttonBar:setX(0)
    self._buttonBar:setY(contentH - btnBarH)
    self._buttonBar:setWidth(w)
    self._buttonBar:setHeight(btnBarH)

    local rightX = w - PAD
    self._closeBtn:setX(rightX - self._closeBtn.width)
    self._closeBtn:setY(actionY)
    rightX = rightX - self._closeBtn.width - PAD

    for i = #self._bottomButtons, 1, -1 do
        local btn = self._bottomButtons[i]
        if btn:isVisible() then
            rightX = rightX - btn.width
            btn:setX(rightX)
            btn:setY(actionY)
            if btn._requiresSelection then
                btn:setEnable(hasSelection)
            end
            rightX = rightX - PAD
        end
    end

    -- On two lines the narrowing controls own the whole upper line, so they
    -- measure from the right edge rather than from wherever the buttons ended.
    local narrowRight = twoRows and (w - PAD) or rightX
    if self._onlyChangedTick then
        local tickX = narrowRight - self._onlyChangedW
        self._onlyChangedTick:setX(tickX)
        self._onlyChangedTick:setY(topY)
        narrowRight = tickX - PAD
    end
    if self._hideVariationsTick then
        local tickX = narrowRight - self._hideVariationsW
        self._hideVariationsTick:setX(tickX)
        self._hideVariationsTick:setY(topY)
        narrowRight = tickX - PAD
    end
    if hasFilter then
        self._filterLabel:setX(PAD)
        self._filterLabel:setY(topY)
        self._filterEntry:setX(PAD + filterLblW)
        self._filterEntry:setY(topY)
        self._filterEntry:setWidth(math.max(filterMinW, narrowRight - PAD - filterLblW))
    end

    -- Reapply filter when text changes. Also covers the first pass after a
    -- refresh, which clears _lastFilterText to force one; a panel with no
    -- filter box still needs that pass to run.
    local currentFilter = hasFilter and self._filterEntry:getText() or ""
    if currentFilter ~= self._lastFilterText then
        self:applyFilter()
    end

    -- List: fills space between description and button bar, less the "used by"
    -- line when this panel has one. Reserved whether or not there is a
    -- selection, so the list doesn't resize as rows are clicked.
    local refsH = self:showsReferences() and (BUTTON_HGT + PAD) or 0

    -- Filter tabs sit between the description and the list, laid left to right.
    local tabsH = 0
    if self._filterTabs then
        tabsH = BUTTON_HGT + PAD
        local tx = PAD
        local ty = PAD + descH
        for _, btn in ipairs(self._filterTabs) do
            btn:setX(tx)
            btn:setY(ty)
            -- The active one is filled, the rest are outlines. Same shape, so
            -- the row still reads as one control rather than a stack of
            -- unrelated buttons. Shared colour tables rather than fresh ones:
            -- this runs every frame for every tab.
            local active = btn._tabKey == self._activeFilterTab
            btn.backgroundColor = active and TAB_ON or TAB_OFF
            btn.backgroundColorMouseOver = active and TAB_ON or TAB_HOVER
            tx = tx + btn.width + 2
        end
    end

    local listY = PAD + descH + tabsH + HEADER_HGT
    local listH = contentH - listY - btnBarH - refsH
    self.list:setX(PAD)
    self.list:setY(listY)
    self.list:setWidth(w - PAD * 2)
    self.list:setHeight(listH)

    -- Recalculate fractional column positions
    local listW = self.list.width
    for i, colDef in ipairs(self._columnDefs) do
        if colDef.size > 0 and colDef.size < 1 then
            self.list.columns[i].size = math.floor(listW * colDef.size)
        end
    end

    -- Draw description text (over the main panel area)
    if self._descLines then
        local dy = PAD
        for _, line in ipairs(self._descLines) do
            self:drawText(line, PAD, dy, 0.6, 0.6, 0.6, 1, UIFont.Small)
            dy = dy + FONT_HGT_SMALL
        end
        -- Subtle separator line below description
        self:drawRect(PAD, dy + 2, w - PAD * 2, 1, 0.3, 0.4, 0.4, 0.4)
    end

    -- "Used by" line, sitting between the list and the buttons.
    if refsH > 0 and self._refsBtn then
        self:updateReferenceLine()
        local btn = self._refsBtn
        if self._refsText and self._refsText ~= "" then
            local textW = getTextManager():MeasureStringX(UIFont.Small, self._refsText)
            btn:setTitle(self._refsText)
            btn:setX(PAD)
            btn:setY(listY + listH + math.floor(PAD / 2))
            btn:setWidth(textW + PAD * 2)
            btn:setHeight(BUTTON_HGT)
            btn:setVisible(true)
            -- Nothing points at it, so there is nowhere to click through to.
            -- Disabled also dims the text, which suits what it is saying.
            btn:setEnable(not self._refsOrphan)
            btn.tooltip = (not self._refsOrphan) and btn._tip or nil
        else
            btn:setVisible(false)
        end
    end
end

return ListPanel
