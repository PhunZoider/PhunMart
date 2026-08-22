if isServer() then
    return
end

local Core = PhunMart
local ListPanel = require "PhunMart_Client/ui/base/list_panel"

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
    return getTextOrNull("IGUI_PhunMart_Shop_" .. shopType) or shopType
end

function UI:refreshAll()
    self:clearList()
    self.list.instanceCounts = self.list.instanceCounts or {}

    -- Sort by display name so the list holds a stable order between sessions.
    -- pairs() order is undefined, and this is the first list an admin sees.
    local rows = {}
    for shopType, shopDef in pairs(Core.runtime and Core.runtime.shops or {}) do
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
            counts[v.type] = (counts[v.type] or 0) + 1
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

    self._adminBtn = self:addBottomButton(getText("IGUI_PhunMart_Btn_AdminTools"), self.onAdminToolsMenu)

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
    -- Set visibility before the base lays the button bar out, so a hidden
    -- Admin Tools button doesn't reserve space.
    if self._adminBtn then
        self._adminBtn:setVisible(Core.canEditConfig(self.player))
    end
    ListPanel.prerender(self)
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

function UI:onAdminToolsMenu(btn)
    local context = ISContextMenu.get(self.playerIndex, btn:getAbsoluteX(), btn:getAbsoluteY())

    -- Anything outstanding goes first and only when there is something to show,
    -- so the one time-sensitive entry isn't buried among the editors.
    local pr = Core.ui.pending_restock
    if pr and pr.count() > 0 then
        context:addOption(getText("IGUI_PhunMart_Btn_PendingN", tostring(pr.count())), self, function()
            pr.show()
        end)
    end

    -- The definition editors used to live here as a submenu. They are tabs now,
    -- so what is left is the handful of things that are not a definition list:
    -- one player-facing tool and two maintenance actions.
    context:addOption(getText("IGUI_PhunMart_Btn_Wallet"), self, function()
        Core.ui.admin.OnOpenPanel(self.player)
    end)

    -- Recompile and Restock All are not editing actions, and sitting alongside
    -- the editors made Recompile read as the commit step for an edit. It isn't:
    -- every save already recompiles. Its real job is picking up override files
    -- hand-edited on disk, which is a maintenance task.
    local maintMenu = ISContextMenu:getNew(context)
    context:addSubMenu(context:addOption(getText("IGUI_PhunMart_Menu_Maintenance")), maintMenu)
    maintMenu:addOption(getText("IGUI_PhunMart_Btn_Recompile"), self, function()
        sendClientCommand(Core.name, Core.commands.compile, {})
    end)
    maintMenu:addOption(getText("IGUI_PhunMart_Btn_RestockAll"), self, function()
        local w = 300
        local h = 150
        local modal = ISModalDialog:new(getCore():getScreenWidth() / 2 - w / 2, getCore():getScreenHeight() / 2 - h / 2,
            w, h, getText("IGUI_PhunMart_Confirm_RestockAll"), true, self, self.onConfirmRestockAll)
        modal:initialise()
        modal:addToUIManager()
    end)
end

function UI:onConfirmRestockAll(button)
    if button.internal == "YES" then
        sendClientCommand(Core.name, Core.commands.restockAllShops, {})
    end
end
