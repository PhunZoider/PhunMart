if isServer() then
    return
end

local Core = PhunMart
local ListPanel = require "PhunMart_Client/ui/base/list_panel"
local ShopWizard = require "PhunMart_Client/ui/admin/shop_wizard"
local Toast = require "PhunMart_Client/ui/toast"

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

---------------------------------------------------------------------------
-- The machine as an item
--
-- A shortcut, and only a shortcut. Every shipped shop already has a scripted
-- moveable named after it in PhunMart_Items.txt, and an admin could always get
-- one: open the Items List, find the PhunMart module, double-click the row,
-- then right-click it in the inventory and install it. This does the first
-- three steps from the list where the admin already is.
--
-- Deliberately the same item the Items List hands out, rather than one built
-- from the shop's sprite the way a pickup builds one. Building from the sprite
-- looks more general and is not: what a placed machine becomes is decided by
-- the sprite's CustomName (see ServerSystem.initializeShopObject), so a shop
-- the wizard created with the "looks like <other shop>" appearance would have
-- quietly installed as that other shop. The set of shops that can be placed at
-- all is the set whose sprite CustomName is their own key -- which is exactly
-- the set with a scripted item. So asking for the item is not the narrower
-- test, it is the accurate one.
---------------------------------------------------------------------------

--- Give `player` the machine item for `shopType`. Returns true, or false and a
--- message saying why not.
local function spawnShopItem(player, shopType)
    local def = Core.defs and Core.defs.shops and Core.defs.shops[shopType]

    -- The list shows disabled shops so their editor stays reachable, which puts
    -- one click away a machine the server would refuse to register: the compiler
    -- drops a disabled shop, and the sprite's CustomName is looked up in the
    -- compiled table. The admin would install it, right-click it and get nothing.
    if def and def.enabled == false then
        return false, getText("IGUI_PhunMart_Msg_ShopDisabled", shopLabel(shopType))
    end

    -- One item per shop, named for the shop key. A shop added by an admin or
    -- another mod has no such item and cannot be installed this way; saying so
    -- beats handing over something that installs as a different shop.
    local fullType = Core.name .. "." .. shopType
    if not getScriptManager():getItem(fullType) then
        return false, getText("IGUI_PhunMart_Msg_NoItemForShop", shopLabel(shopType))
    end

    local inventory = player:getInventory()
    local item = inventory:AddItem(fullType)
    if not item then
        return false, getText("IGUI_PhunMart_Msg_NoItemForShop", shopLabel(shopType))
    end
    sendAddItemToContainer(inventory, item)
    ISInventoryPage.dirtyUI()
    return true
end

function UI:refreshAll()
    self:clearList()
    self.list.instanceCounts = self.list.instanceCounts or {}

    -- Sort by display name so the list holds a stable order between sessions.
    -- pairs() order is undefined, and this is the first list an admin sees.
    -- Definitions, not the compiled runtime. The compiler drops anything with
    -- enabled=false, so a shop disabled here vanished from the only list that
    -- could reach its editor: there was no way back to the tickbox that
    -- disabled it short of hand-editing PhunMart_Shops.json.
    --
    -- Disabled rows draw grey, which the column colour below has always been
    -- written to do and never had the chance to.
    local rows = {}
    for shopType, shopDef in pairs(Core.defs and Core.defs.shops or {}) do
        table.insert(rows, {
            type = shopType,
            label = shopLabel(shopType),
            -- Not decoration: spacing is enforced against the nearest machine of
            -- the same type and the nearest of anything sharing its category, so
            -- which shops compete for space is a property of this column.
            category = shopDef.category or "",
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

    -- Grey for a disabled shop, on both columns that come from the definition.
    -- The count beside them is a live reading rather than a setting, so it is
    -- left alone.
    local function greyIfDisabled(d)
        if not d.enabled then
            return 0.5, 0.5, 0.5
        end
    end

    self:addListColumn(getText("IGUI_PhunMart_Col_Shop"), 0, {
        field = "label",
        color = greyIfDisabled
    })
    -- Which shops compete with which for space, which was previously only
    -- discoverable by opening them one at a time. The docs have described this
    -- column as being here for a while; it was not.
    self:addListColumn(getText("IGUI_PhunMart_Col_Category"), 0.5, {
        field = "category",
        color = greyIfDisabled
    })
    self:addListColumn(getText("IGUI_PhunMart_Col_InWorld"), 0.8, {
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
    -- Not gated with the other two: this places a machine rather than changing
    -- a definition, so it follows the same rule as the rest of the admin powers
    -- over the world instead of the editor role.
    self._spawnBtn = self:addBottomButton(getText("IGUI_PhunMart_Btn_SpawnItem"), self.onSpawnItem, true)
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
    -- Category included, so typing one narrows the list to the shops that are
    -- spaced against each other. That is the question the column invites.
    return (itemData.label or "") .. " " .. (itemData.type or "") .. " " .. (itemData.category or "")
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
    if self._spawnBtn then
        self._spawnBtn:setVisible(Core.utils.isAdmin(self.player))
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

--- Put a placeable copy of the selected shop in the admin's inventory.
function UI:onSpawnItem()
    if not Core.utils.isAdmin(self.player) then
        return
    end
    local sel = self.list.selected
    local row = sel and sel > 0 and self.list.items[sel]
    local shopType = row and row.item and row.item.type
    if shopType then
        self:spawnItemFor(shopType)
    end
end

--- Shared by the button and the context menu, so the two cannot report the
--- same failure differently.
function UI:spawnItemFor(shopType)
    local ok, why = spawnShopItem(self.player, shopType)
    Toast.show({
        text = ok and getText("IGUI_PhunMart_Msg_SpawnedShopItem", shopLabel(shopType)) or why
    })
end

function UI:onRowContextMenu(item, screenX, screenY)
    local context = ISContextMenu.get(self.playerIndex, screenX, screenY)
    context:addOption(getText("IGUI_PhunMart_Btn_Locations"), self, function()
        Core.ui.shop_instances.open(self.player, item.type)
    end)
    if Core.utils.isAdmin(self.player) then
        context:addOption(getText("IGUI_PhunMart_Btn_SpawnItem"), self, function()
            self:spawnItemFor(item.type)
        end)
    end
    if Core.canEditConfig(self.player) then
        context:addOption(getText("IGUI_PhunMart_Btn_Config"), self, function()
            Core.ui.admin_shops.OnOpenPanel(self.player, item.type)
        end)
    end
end

