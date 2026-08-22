if isServer() then
    return
end

local Core = PhunMart
local ListPanel = require "PhunMart_Client/ui/base/list_panel"
local ItemPicker = require "PhunMart_Client/ui/base/item_picker"
local PendingRestock = require "PhunMart_Client/ui/admin/pending_restock"

local FONT_SCALE = ListPanel.FONT_SCALE
local FONT_HGT_SMALL = ListPanel.FONT_HGT_SMALL
local SCROLLBAR_W = ListPanel.SCROLLBAR_W

Core.ui.admin_blacklist = ListPanel:derive("PhunBlacklistAdminUI")
Core.ui.admin_blacklist.instances = {}
local UI = Core.ui.admin_blacklist

-- Resolve a script item's display name, falling back to the raw key for
-- specials and anything the script manager doesn't know about.
local function resolveName(key)
    local si = getScriptManager():getItem(key)
    return si and si:getDisplayName() or key
end

---------------------------------------------------------------------------
-- Panel
---------------------------------------------------------------------------

--- Build this panel as a view for the tabbed shell. The shell owns the size
--- and position, so both are placeholders until its first layout pass.
function UI.createTab(player)
    local playerIndex = player:getPlayerNum()
    local instance = UI.instances[playerIndex]
    if not instance then
        instance = UI:new(0, 0, 100, 100, player)
        instance.description = getText("IGUI_PhunMart_Desc_GlobalBlacklist")
        instance:initialise()
        UI.instances[playerIndex] = instance
    end
    return instance
end

function UI:requestData()
    sendClientCommand(Core.name, Core.commands.getGlobalBlacklist, {})
end

function UI:setData(keys)
    self.keys = keys or {}
    self:refreshList()
end

function UI:createChildren()
    ListPanel.createChildren(self)

    self.list.doDrawItem = ListPanel.defaultDrawRow
    self.list:setOnMouseDoubleClick(self, self.onRemoveClick)

    self:addListColumn(getText("IGUI_PhunMart_Col_Name"), 0, {field = "name"})
    self:addListColumn(getText("IGUI_PhunMart_Col_Key"), 0.45, {field = "key", color = {0.7, 0.7, 0.7}})

    -- "Add" here rather than "New": this puts an existing item onto a list, it
    -- doesn't author a new definition the way the other panels' buttons do.
    self:addBottomButton(getText("IGUI_PhunMart_Btn_Add"), self.onAddClick)
    self:addBottomButton(getText("IGUI_PhunMart_Btn_Unblacklist"), self.onRemoveClick, true)
end

function UI:getFilterText(itemData)
    return itemData.key .. " " .. itemData.name
end

function UI:refreshList()
    self:clearList()
    for _, key in ipairs(self.keys or {}) do
        self:addListItem(key, {
            key = key,
            name = resolveName(key)
        })
    end
end

function UI:onAddClick()
    ItemPicker.open(self.player, {}, function(picked)
        if not picked or #picked == 0 then
            return
        end
        for _, key in ipairs(picked) do
            sendClientCommand(Core.name, Core.commands.setGlobalBlacklistEntry, {
                itemKey = key,
                excluded = true
            })
        end
        -- The global list is consulted by every shop when it rolls stock.
        PendingRestock.noteAllShops()
        self:requestData()
    end)
end

function UI:onRemoveClick()
    if not self.list.selected or self.list.selected == 0 then
        return
    end
    local selectedItem = self.list.items[self.list.selected]
    if not selectedItem then
        return
    end
    sendClientCommand(Core.name, Core.commands.setGlobalBlacklistEntry, {
        itemKey = selectedItem.item.key,
        excluded = false
    })
    -- The global list is consulted by every shop when it rolls stock.
    PendingRestock.noteAllShops()
    self:requestData()
end

-- The global blacklist lives on the server rather than in the override files,
-- so the shell's tab switch has to go and fetch it rather than re-read
-- Core.defs.
UI.refresh = UI.requestData

---------------------------------------------------------------------------
-- Command handlers
--
-- Mirrors admin_rewards: in singleplayer the server files share this Lua
-- state, so the panel reads Core.getBlacklist() directly off the intercepted
-- client command; in multiplayer it waits for the server's reply.
---------------------------------------------------------------------------
local Commands = {}

if Core.isLocal then

    local function refreshLocal()
        local excluded = (Core.getBlacklist().items or {}).exclude or {}
        local keys = {}
        for k, v in pairs(excluded) do
            if v then
                table.insert(keys, k)
            end
        end
        table.sort(keys)
        for _, instance in pairs(UI.instances or {}) do
            instance:setData(keys)
        end
    end

    Commands[Core.commands.getGlobalBlacklist] = function(player, args)
        refreshLocal()
    end

    -- The server handler also runs in singleplayer, so this repeats its write.
    -- Setting a boolean is idempotent, and doing it here means the refresh below
    -- can't observe a stale list whichever handler the event loop calls first.
    Commands[Core.commands.setGlobalBlacklistEntry] = function(player, args)
        local itemKey = args and args.itemKey
        if not itemKey then
            return
        end
        local list = Core.getBlacklist() or {}
        list.items = list.items or {}
        list.items.exclude = list.items.exclude or {}
        list.items.exclude[itemKey] = args.excluded == true
        Core.setBlacklist(list)
        refreshLocal()
    end

    Events.OnClientCommand.Add(function(module, command, playerObj, arguments)
        if module == Core.name and Commands[command] then
            Commands[command](playerObj, arguments)
        end
    end)

else

    Commands[Core.commands.getGlobalBlacklist] = function(args)
        for _, instance in pairs(UI.instances or {}) do
            instance:setData(args.items)
        end
    end

    Events.OnServerCommand.Add(function(module, command, arguments)
        if module == Core.name and Commands[command] then
            Commands[command](arguments)
        end
    end)

end
