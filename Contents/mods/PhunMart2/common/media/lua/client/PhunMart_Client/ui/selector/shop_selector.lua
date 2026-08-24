if isServer() then
    return
end

local Core = PhunMart
local ListPanel = require "PhunMart_Client/ui/base/list_panel"
local ShopWizard = require "PhunMart_Client/ui/admin/shop_wizard"

Core.ui.shop_selector = ListPanel:derive("PhunMartUIShopListing")
Core.ui.shop_selector.instances = {}
local UI = Core.ui.shop_selector
-- Shop definitions are override-backed like the rest, so the list marks the
-- ones an admin has customised and can filter down to them.
UI._defKind = "shops"

---------------------------------------------------------------------------
-- Data
---------------------------------------------------------------------------

local function shopLabel(shopType)
    return Core.shopLabel(shopType)
end

function UI:refreshAll()
    self:clearList()
    self.list.instanceCounts = self.list.instanceCounts or {}

    -- Sort by display name so the list holds a stable order between sessions.
    -- pairs() order is undefined, and this is the first list an admin sees.
    -- Definitions, not the compiled runtime. The compiler drops anything with
    -- enabled=false, so a shop disabled here vanished from the only list that
    -- could reach its editor: there was no way back to the tickbox that
    -- disabled it short of hand-editing PhunMart_Shops.txt.
    --
    -- Disabled rows draw grey, which the column colour below has always been
    -- written to do and never had the chance to.
    local rows = {}
    for shopType, shopDef in pairs(Core.defs and Core.defs.shops or {}) do
        table.insert(rows, {
            type = shopType,
            label = shopLabel(shopType),
            enabled = shopDef.enabled ~= false
        })
    end
    table.sort(rows, function(a, b)
        return a.label:lower() < b.label:lower()
    end)

    for _, row in ipairs(rows) do
        self:addListItem(row.label, row)
    end

    -- Instance counts. Singleplayer can read them straight off Core.instances;
    -- multiplayer asks the server and fills them in when the reply lands.
    if Core.isLocal then
        local counts = {}
        for _, v in pairs(Core.instances or {}) do
            -- Machines only. A stray key in this ModData table would otherwise
            -- reach counts[nil], which is an error rather than a wrong number.
            if Core.isShopInstance(v) then
                counts[v.type] = (counts[v.type] or 0) + 1
            end
        end
        self.list.instanceCounts = counts
    else
        sendClientCommand(Core.name, Core.commands.getInstanceList, {})
    end
end

-- Re-read when the definitions recompile, via ListPanel's shared hook.
UI.refresh = UI.refreshAll

function UI:setInstanceCounts(list)
    local counts = {}
    for _, v in ipairs(list) do
        counts[v.type] = (counts[v.type] or 0) + 1
    end
    self.list.instanceCounts = counts
end

--- Push counts into every open selector. Called from the server reply handler.
function UI.updateInstanceCounts(list)
    for _, inst in pairs(UI.instances) do
        if inst.setInstanceCounts then
            inst:setInstanceCounts(list)
        end
    end
end

---------------------------------------------------------------------------
-- Tab
---------------------------------------------------------------------------

--- Build this panel as a view for the tabbed shell. The shell owns the size
--- and position, so both are placeholders until its first layout pass.
function UI.createTab(player)
    local playerIndex = player:getPlayerNum()
    local instance = UI.instances[playerIndex]
    if not instance then
        instance = UI:new(0, 0, 100, 100, player)
        instance.description = getText("IGUI_PhunMart_Desc_Shops")
        instance:initialise()
        UI.instances[playerIndex] = instance
    end
    return instance
end

function UI:createChildren()
    ListPanel.createChildren(self)

    self.list.doDrawItem = ListPanel.defaultDrawRow
    self.list:setOnMouseDoubleClick(self, self.onEdit)
    self.list.onRightMouseUp = function(target, x, y)
        local row = target:rowAt(x, y)
        if row == -1 then
            return
        end
        target.selected = row
        target:ensureVisible(row)
        self:onRowContextMenu(target.items[row].item, getMouseX(), getMouseY())
    end

    self:addListColumn(getText("IGUI_PhunMart_Col_Shop"), 0, {
        field = "label",
        color = function(d)
            if not d.enabled then
                return 0.5, 0.5, 0.5
            end
        end
    })
    self:addListColumn(getText("IGUI_PhunMart_Col_InWorld"), 0.5, {
        -- Read live rather than baked into the row: in multiplayer the counts
        -- arrive after the list has already been built.
        text = function(d)
            return tostring((self.list.instanceCounts or {})[d.type] or 0)
        end
    })

    -- New sits where New sits on every other tab. It was missing entirely:
    -- nothing in the UI could create a shop, only edit one that already existed.
    self._newBtn = self:addBottomButton(getText("IGUI_PhunMart_Btn_New"), self.onNewShop)
    self._editBtn = self:addBottomButton(getText("IGUI_PhunMart_Btn_Edit"), self.onEdit, true)
    -- An "Admin Tools" button used to sit here, opening a context menu holding
    -- the wallet editor, recompile and restock-all. They live on the Tools tab
    -- now, where each one is a labelled row rather than a bare verb in a menu
    -- that had to be opened before it would say what was in it.

    self:refreshAll()
end

-- Shop rows are keyed by type, not by a `key` field.
function UI:getRowKey(itemData)
    return itemData and itemData.type
end

function UI:getFilterText(itemData)
    return (itemData.label or "") .. " " .. (itemData.type or "")
end

function UI:prerender()
    -- Set visibility before the base lays the button bar out, so hidden
    -- buttons don't reserve space.
    local canEdit = Core.canEditConfig(self.player)
    if self._newBtn then
        self._newBtn:setVisible(canEdit)
    end
    if self._editBtn then
        self._editBtn:setVisible(canEdit)
    end
    ListPanel.prerender(self)
end

--- Create a shop, then hand straight over to its group. The same entry point
--- as the Tools tab offers, so the two cannot drift apart.
function UI:onNewShop()
    if not Core.canEditConfig(self.player) then
        return
    end
    ShopWizard.openThenEdit(self.player, self.shell)
end

---------------------------------------------------------------------------
-- Actions
---------------------------------------------------------------------------

function UI:onEdit(item)
    -- Double-click opened the shop editor unchecked, which was the easiest of
    -- the bypasses to hit by accident.
    if not Core.canEditConfig(self.player) then
        return
    end
    local sel = self.list.selected
    local row = sel and sel > 0 and self.list.items[sel]
    if row and row.item and row.item.type then
        Core.ui.admin_shops.OnOpenPanel(self.player, row.item.type)
    end
end

function UI:onRowContextMenu(item, screenX, screenY)
    local context = ISContextMenu.get(self.playerIndex, screenX, screenY)
    context:addOption(getText("IGUI_PhunMart_Btn_Locations"), self, function()
        Core.ui.shop_instances.open(self.player, item.type)
    end)
    if Core.canEditConfig(self.player) then
        context:addOption(getText("IGUI_PhunMart_Btn_Config"), self, function()
            Core.ui.admin_shops.OnOpenPanel(self.player, item.type)
        end)
    end
end

