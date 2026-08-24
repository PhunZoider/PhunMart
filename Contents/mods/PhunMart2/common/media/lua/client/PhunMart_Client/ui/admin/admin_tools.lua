if isServer() then
    return
end

-- Everything an admin can do that is not editing a definition.
--
-- These used to live behind an "Admin Tools" button on the Shops tab, which
-- opened a context menu, which held a submenu. Three of the six were two clicks
-- deep in a menu that gave no clue what any of them did, and the currency tool
-- was not in there at all: it hung off a button on the Prices tab and nowhere
-- else. Nothing about a menu of bare verbs says which one rerolls every machine
-- on the server.
--
-- So: a tab, one row per tool, each carrying a sentence about what it does and
-- when you would want it. The row is the explanation; the button just runs it.

local Core = PhunMart
local ListPanel = require "PhunMart_Client/ui/base/list_panel"
local ShopWizard = require "PhunMart_Client/ui/admin/shop_wizard"
local CurrencyTool = require "PhunMart_Client/ui/admin/currency_tool"
local PendingRestock = require "PhunMart_Client/ui/admin/pending_restock"
local PlayerDataTool = require "PhunMart_Client/ui/admin/player_data_tool"
local tools = require "PhunMart_Client/ui/ui_utils"

local FONT_HGT_SMALL = ListPanel.FONT_HGT_SMALL
local FONT_SCALE = ListPanel.FONT_SCALE
local SCROLLBAR_W = ListPanel.SCROLLBAR_W

Core.ui.admin_tools = ListPanel:derive("PhunMartAdminTools")
Core.ui.admin_tools.instances = {}
local UI = Core.ui.admin_tools

-- No definition kind: nothing here is override-backed, so there is no "only my
-- changes" to filter to and nothing that can be referenced by anything else.
-- No filter box either; six fixed rows do not need searching.
UI._noFilter = true

---------------------------------------------------------------------------
-- Confirmation
---------------------------------------------------------------------------

--- A yes/no modal that calls back on yes. ISModalDialog reports the button
--- through `internal`, which every caller of it was unpacking for itself.
local function confirm(panel, text, onYes)
    local w = math.floor(360 * FONT_SCALE)
    local h = math.floor(180 * FONT_SCALE)
    local modal = ISModalDialog:new((getCore():getScreenWidth() - w) / 2, (getCore():getScreenHeight() - h) / 2, w, h,
        text, true, panel, function(_, button)
            if button.internal == "YES" then
                onYes()
            end
        end)
    modal:initialise()
    modal:addToUIManager()
end

---------------------------------------------------------------------------
-- The tools
--
-- Ordered by when you would reach for them: building a shop, then the settings
-- that apply across all of them, then the player-facing data, then the two
-- maintenance actions that act on the world rather than on the definitions.
--
--   label     row heading
--   desc      the sentence under it, saying what it does and when to use it.
--             A function when what it should say depends on the state of
--             something, in which case the row is rebuilt when that changes
--             rather than the text being resolved every frame.
--   action    verb for the run button, defaults to Open
--   warn      draws the heading amber, for anything that changes the world for
--             every player at once. A function for a row that is only sometimes
--             worth shouting about.
--   suffix    function(panel) -> string appended to the heading, read live
--   available function(panel) -> boolean; false greys the row and its button
--   run       function(panel)
---------------------------------------------------------------------------

local TOOLS = {{
    key = "wizard",
    label = "IGUI_PhunMart_Tool_NewShop",
    desc = "IGUI_PhunMart_ToolDesc_NewShop",
    run = function(panel)
        ShopWizard.openThenEdit(panel.player, panel.shell)
    end
}, {
    key = "currency",
    label = "IGUI_PhunMart_Tool_Currency",
    desc = "IGUI_PhunMart_ToolDesc_Currency",
    run = function(panel)
        CurrencyTool.open(panel.player)
    end
}, {
    -- The wallet editor was a row here until it became a tab of its own. A row
    -- whose only job is to send you to a tab is worse than no row at all.
    key = "pending",
    label = "IGUI_PhunMart_Tool_Pending",
    desc = "IGUI_PhunMart_ToolDesc_Pending",
    action = "IGUI_PhunMart_Btn_Review",
    -- Shown even at zero rather than hidden. The row is the only place the
    -- rule is written down, and the moment you need to know it is before you
    -- have walked to a machine wondering why your edit did nothing.
    suffix = function()
        local n = PendingRestock.count()
        return n > 0 and (" (" .. tostring(n) .. ")") or ""
    end,
    available = function()
        return PendingRestock.count() > 0
    end,
    run = function()
        PendingRestock.show()
    end
}, {
    key = "playerdata",
    label = "IGUI_PhunMart_Tool_ResetData",
    desc = "IGUI_PhunMart_ToolDesc_ResetData",
    action = "IGUI_PhunMart_Btn_Review",
    warn = true,
    -- How much there is to lose, which is the one thing worth knowing before
    -- opening a form whose every option is destructive.
    suffix = function()
        local n = PlayerDataTool.total()
        return n > 0 and (" (" .. tostring(n) .. ")") or ""
    end,
    run = function(panel)
        PlayerDataTool.open(panel.player)
    end
}, {
    key = "restockall",
    label = "IGUI_PhunMart_Tool_RestockAll",
    desc = "IGUI_PhunMart_ToolDesc_RestockAll",
    action = "IGUI_PhunMart_Btn_Restock",
    warn = true,
    run = function(panel)
        confirm(panel, getText("IGUI_PhunMart_Confirm_RestockAll"), function()
            sendClientCommand(Core.name, Core.commands.restockAllShops, {})
        end)
    end
}, {
    key = "recompile",
    label = "IGUI_PhunMart_Tool_Recompile",
    desc = "IGUI_PhunMart_ToolDesc_Recompile",
    action = "IGUI_PhunMart_Btn_Run",
    run = function()
        sendClientCommand(Core.name, Core.commands.compile, {})
        if Core.ui.toast then
            Core.ui.toast.show({
                text = getText("IGUI_PhunMart_Msg_Recompiling")
            })
        end
    end
}}

---------------------------------------------------------------------------
-- Tab
---------------------------------------------------------------------------

function UI.createTab(player)
    local playerIndex = player:getPlayerNum()
    local instance = UI.instances[playerIndex]
    if not instance then
        instance = UI:new(0, 0, 100, 100, player)
        instance.description = getText("IGUI_PhunMart_Desc_Tools")
        instance:initialise()
        UI.instances[playerIndex] = instance
    end
    return instance
end

function UI:createChildren()
    ListPanel.createChildren(self)

    -- Two lines to a row: the tool on top, what it does underneath. A single
    -- description column would be squeezed to a few words at any window size
    -- an admin actually uses, and the description is the whole point of the
    -- tab existing.
    self.list.itemheight = FONT_HGT_SMALL * 2 + math.floor(14 * FONT_SCALE)
    self.list.doDrawItem = UI.drawRow
    self.list:setOnMouseDoubleClick(self, self.onRun)

    -- No columns, so no header bar. A "Tool" heading over a list of tools says
    -- nothing the tab title has not already said.

    -- Sized for the longest verb any row can put on it, because the title
    -- changes with the selection and a button does not resize with its text.
    local widest = getText("IGUI_PhunMart_Btn_Open")
    for _, spec in ipairs(TOOLS) do
        local t = getText(spec.action or "IGUI_PhunMart_Btn_Open")
        if getTextManager():MeasureStringX(UIFont.Small, t) > getTextManager():MeasureStringX(UIFont.Small, widest) then
            widest = t
        end
    end
    self._runBtn = self:addBottomButton(widest, self.onRun, true)

    self:refresh()
end

--- Rebuild the rows. Separate from refresh because the record counts arrive
--- asynchronously and have to rebuild them again without asking for them a
--- second time, which is what refresh does.
function UI:refreshRows()
    self:clearList()
    for _, spec in ipairs(TOOLS) do
        self:addListItem(getText(spec.label), {
            key = spec.key,
            spec = spec,
            -- Resolved once per rebuild. The row renderer runs every frame for
            -- every row, and getText is not free enough to call twelve times a
            -- frame for strings that only change between rebuilds.
            desc = type(spec.desc) == "function" and spec.desc(self) or getText(spec.desc)
        })
    end
end

function UI:refresh()
    -- How much player data there is to lose is the server's to know, and it is
    -- on one of the rows below. The reply rebuilds the rows again.
    PlayerDataTool.request()
    self:refreshRows()
end

PlayerDataTool.onStatus(function()
    for _, instance in pairs(UI.instances or {}) do
        if instance.list then
            instance:refreshRows()
        end
    end
end)

---------------------------------------------------------------------------
-- Rows
---------------------------------------------------------------------------

function UI.drawRow(listSelf, y, item, alt)
    local h = listSelf.itemheight
    if y + listSelf:getYScroll() + h < 0 or y + listSelf:getYScroll() >= listSelf.height then
        return y + h
    end

    local panel = listSelf.panel
    local data = item.item
    local spec = data.spec
    local a = 0.9
    local available = panel:isAvailable(spec)

    if listSelf.selected == item.index then
        listSelf:drawRect(0, y, listSelf:getWidth(), h, 0.3, 0.7, 0.35, 0.15)
    end
    if alt then
        listSelf:drawRect(0, y, listSelf:getWidth(), h, 0.3, 0.6, 0.5, 0.5)
    end
    listSelf:drawRectBorder(0, y, listSelf:getWidth(), h, a, listSelf.borderColor.r, listSelf.borderColor.g,
        listSelf.borderColor.b)

    local pad = math.floor(6 * FONT_SCALE)
    local maxW = listSelf.width - SCROLLBAR_W - 20

    -- Amber for anything that acts on every machine in the world at once, so
    -- the two rows that do are told apart before they are clicked rather than
    -- by reading the confirmation they raise.
    local r, g, b = 1, 1, 1
    local warn = spec.warn
    if type(warn) == "function" then
        warn = warn(panel)
    end
    if warn then
        r, g, b = 0.95, 0.8, 0.35
    end
    if not available then
        r, g, b = r * 0.5, g * 0.5, b * 0.5
    end

    local label = item.text .. (spec.suffix and spec.suffix(panel) or "")
    listSelf:drawText(tools.truncate(label, maxW, listSelf.font), 10, y + pad, r, g, b, a, listSelf.font)

    local dim = available and 0.62 or 0.4
    listSelf:drawText(tools.truncate(data.desc, maxW, UIFont.Small), 10, y + pad + FONT_HGT_SMALL, dim, dim, dim, a,
        UIFont.Small)

    listSelf.itemsHeight = y + h
    return listSelf.itemsHeight
end

---------------------------------------------------------------------------
-- Running
---------------------------------------------------------------------------

function UI:isAvailable(spec)
    if not spec then
        return false
    end
    if spec.available then
        return spec.available(self) and true or false
    end
    return true
end

function UI:selectedSpec()
    local sel = self.list.selected
    local row = sel and sel > 0 and self.list.items[sel]
    return row and row.item and row.item.spec or nil
end

function UI:onRun()
    if not Core.canEditConfig(self.player) then
        return
    end
    local spec = self:selectedSpec()
    if spec and self:isAvailable(spec) then
        spec.run(self)
    end
end

---------------------------------------------------------------------------
-- Layout
---------------------------------------------------------------------------

function UI:prerender()
    ListPanel.prerender(self)

    -- After the base, which sets the enabled state from "is anything selected"
    -- alone. A selected row can still be one there is nothing to do with.
    local spec = self:selectedSpec()
    self._runBtn:setTitle(getText(spec and spec.action or "IGUI_PhunMart_Btn_Open"))
    self._runBtn:setEnable(self:isAvailable(spec))
end

return UI
