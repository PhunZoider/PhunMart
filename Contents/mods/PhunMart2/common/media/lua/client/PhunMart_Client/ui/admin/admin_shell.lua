if isServer() then
    return
end

-- One window for the whole definition graph.
--
-- A shop draws on pools, which gather groups, which hold items and specials,
-- which carry prices. Following that chain used to mean opening five windows
-- and leaving them stacked on the screen, with no way back except closing them
-- in reverse. Each list is now a tab in here instead, so the chain is a row of
-- tabs rather than a pile of windows, and the shell is the only thing that owns
-- a title bar, a position and a close button.

require "ISUI/ISCollapsableWindowJoypad"
require "ISUI/ISTabPanel"

local Core = PhunMart
local ListPanel = require "PhunMart_Client/ui/base/list_panel"

-- Required so the panel modules have registered themselves on Core.ui before
-- the first open, whatever order the game happened to load the folder in.
require "PhunMart_Client/ui/selector/shop_selector"
require "PhunMart_Client/ui/admin/admin_pools"
require "PhunMart_Client/ui/admin/admin_groups"
require "PhunMart_Client/ui/admin/admin_items"
require "PhunMart_Client/ui/admin/admin_specials"
require "PhunMart_Client/ui/admin/admin_prices"
require "PhunMart_Client/ui/admin/admin_blacklist"
require "PhunMart_Client/ui/admin/admin_rewards"
require "PhunMart_Client/ui/admin/admin_tools"

local FONT_SCALE = ListPanel.FONT_SCALE
local profileName = "PhunMartAdminShell"

-- Ordered along the chain a shop actually resolves through rather than
-- alphabetically, so the tab strip reads as the path from a machine down to
-- what it charges. `admin` is false on the tab everyone may see.
--
-- `module` is the key on Core.ui rather than the panel table itself, because
-- this list is built at load time and the panels register themselves as their
-- own files load.
local TABS = {{
    key = "shops",
    module = "shop_selector",
    label = "IGUI_PhunMart_Title_Shops",
    admin = false
}, {
    key = "pools",
    module = "admin_pools",
    label = "IGUI_PhunMart_Btn_Pools"
}, {
    key = "groups",
    module = "admin_groups",
    label = "IGUI_PhunMart_Btn_Groups"
}, {
    -- Specials before item overrides: an override mostly exists to attach a
    -- special to an item type, so meeting the special first is the order the
    -- idea builds in.
    key = "specials",
    module = "admin_specials",
    label = "IGUI_PhunMart_Btn_Specials"
}, {
    key = "items",
    module = "admin_items",
    label = "IGUI_PhunMart_Btn_Items"
}, {
    key = "prices",
    module = "admin_prices",
    label = "IGUI_PhunMart_Btn_Prices"
}, {
    key = "blacklist",
    module = "admin_blacklist",
    label = "IGUI_PhunMart_Btn_Blacklist"
}, {
    key = "rewards",
    module = "admin_rewards",
    label = "IGUI_PhunMart_Btn_Rewards"
}, {
    -- Last, and deliberately outside the chain: nothing on this tab edits a
    -- definition, so it does not belong anywhere among the ones that do.
    key = "tools",
    module = "admin_tools",
    label = "IGUI_PhunMart_Btn_Tools"
}}

Core.ui.admin_shell = ISCollapsableWindowJoypad:derive("PhunMartAdminShell")
local Shell = Core.ui.admin_shell

local instances = {}

---------------------------------------------------------------------------
-- Construction
---------------------------------------------------------------------------

function Shell:new(x, y, width, height, player)
    local o = ISCollapsableWindowJoypad:new(x, y, width, height, player)
    setmetatable(o, self)
    self.__index = self
    o.player = player
    o.playerIndex = player:getPlayerNum()
    o.backgroundColor = {
        r = 0,
        g = 0,
        b = 0,
        a = 0.8
    }
    o.moveWithMouse = true
    o.minimumWidth = math.floor(560 * FONT_SCALE)
    o.minimumHeight = math.floor(360 * FONT_SCALE)
    o:setWantKeyEvents(true)
    -- Whether the admin tabs were built. Checked on reopen, because a role
    -- change while the window sat closed would otherwise leave the wrong set.
    o._editable = Core.canEditConfig(player)
    o._tabsByKey = {}
    return o
end

function Shell:createChildren()
    ISCollapsableWindowJoypad.createChildren(self)

    local th = self:titleBarHeight()
    local rh = self:resizeWidgetHeight()

    local tabs = ISTabPanel:new(0, th, self.width, self.height - th - rh)
    tabs:initialise()
    tabs:instantiate()
    tabs:setEqualTabWidth(false)
    tabs.onActivateView = Shell.onActivateView
    tabs.target = self
    self:addChild(tabs)
    self.tabs = tabs

    -- Size each view before it is added. A view builds its children when the
    -- tab panel instantiates it, and building them against the placeholder size
    -- a panel is created at would put the button bar off the bottom edge until
    -- the first prerender.
    local viewW = tabs.width
    local viewH = tabs.height - tabs.tabHeight

    for _, spec in ipairs(TABS) do
        if spec.admin == false or self._editable then
            local module = Core.ui[spec.module]
            if module and module.createTab then
                local view = module.createTab(self.player)
                if view then
                    view:setShell(self)
                    view:setWidth(viewW)
                    view:setHeight(viewH)
                    tabs:addView(getText(spec.label), view)
                    self._tabsByKey[spec.key] = {
                        id = #tabs.viewList,
                        view = view
                    }
                end
            end
        end
    end

    self:layoutViews()
end

---------------------------------------------------------------------------
-- Layout
---------------------------------------------------------------------------

--- Size every view, not just the visible one. ISTabPanel only positions a view
--- vertically when it is added, and a tab switched to after a resize would
--- otherwise appear at the old size for a frame.
function Shell:layoutViews()
    if not self.tabs then
        return
    end
    local w = self.tabs.width
    local h = self.tabs.height - self.tabs.tabHeight
    for _, entry in ipairs(self.tabs.viewList) do
        local view = entry.view
        view:setX(0)
        view:setY(self.tabs.tabHeight)
        view:setWidth(w)
        view:setHeight(h)
    end
end

function Shell:prerender()
    ISCollapsableWindowJoypad.prerender(self)

    -- Nothing to lay out while the window is rolled up to its title bar, and
    -- the arithmetic below would go negative if we tried.
    if not self.tabs or self.isCollapsed then
        return
    end

    local th = self:titleBarHeight()
    local rh = self:resizeWidgetHeight()
    local w = self.width
    local h = math.max(self.tabs.tabHeight, self.height - th - rh)

    if self.tabs.width ~= w or self.tabs.height ~= h then
        self.tabs:setY(th)
        self.tabs:setWidth(w)
        self.tabs:setHeight(h)
        self:layoutViews()
    end
end

---------------------------------------------------------------------------
-- Tabs
---------------------------------------------------------------------------

--- Refresh on arrival rather than continuously. The shared OnDefsUpdated hook
--- only touches visible panels, which is what keeps a background tab off the
--- recompile path, so a tab has to catch up when it comes forward.
function Shell.onActivateView(self, tabPanel)
    local view = tabPanel:getActiveView()
    if view and view.refresh then
        view:refresh()
    end
end

--- Bring a tab forward by its key ("pools", "prices", ...). Returns the view,
--- or nil when this player has no such tab.
function Shell:activateTab(key)
    local entry = key and self._tabsByKey[key]
    if not entry then
        return nil
    end
    if self.tabs:getActiveView() ~= entry.view then
        self.tabs:activateViewById(entry.id)
    else
        -- Already forward, so no activation fires. Refresh anyway: the caller
        -- asked for this tab because something about it just changed.
        Shell.onActivateView(self, self.tabs)
    end
    return entry.view
end

function Shell:getTabView(key)
    local entry = key and self._tabsByKey[key]
    return entry and entry.view
end

---------------------------------------------------------------------------
-- Window
---------------------------------------------------------------------------

function Shell:isKeyConsumed(key)
    return key == Keyboard.KEY_ESCAPE
end

function Shell:onKeyRelease(key)
    if key == Keyboard.KEY_ESCAPE then
        self:close()
    end
end

--- Closing hides the window rather than discarding it, so reopening comes back
--- to the same size, position and tab. The views stay built with it; a view
--- asks the shell whether it is really on screen (ListPanel:isLive) rather than
--- trusting its own visible flag, which a hidden parent does not clear.
function Shell:close()
    ISCollapsableWindowJoypad.close(self)

    -- Closing the editor is the natural "done editing" moment, so bring any
    -- outstanding restocks back into view rather than letting them be forgotten.
    local pr = Core.ui.pending_restock
    if pr and pr.count() > 0 then
        pr.show()
    end
end

---------------------------------------------------------------------------
-- Public API
---------------------------------------------------------------------------

--- Open the editor.
-- @param player
-- @param tabKey    optional tab to open on, e.g. "pools"
-- @param selectKey optional definition key to select once that tab is up
function Shell.open(player, tabKey, selectKey)
    player = player or getSpecificPlayer(0)
    local playerIndex = player:getPlayerNum()
    local instance = instances[playerIndex]

    -- A role change while the window was closed changes which tabs belong in
    -- it, and the tab strip is built once. Rebuild rather than mislead.
    if instance and instance._editable ~= Core.canEditConfig(player) then
        instance:removeFromUIManager()
        instances[playerIndex] = nil
        instance = nil
        -- Drop the views too, otherwise createTab hands the rebuilt shell the
        -- panels still parented to the old one.
        for _, spec in ipairs(TABS) do
            local module = Core.ui[spec.module]
            if module and module.instances then
                module.instances[playerIndex] = nil
            end
        end
    end

    if not instance then
        local core = getCore()
        local width = math.floor(720 * FONT_SCALE)
        local height = math.floor(520 * FONT_SCALE)
        local x = (core:getScreenWidth() - width) / 2
        local y = (core:getScreenHeight() - height) / 2
        instance = Shell:new(x, y, width, height, player)
        instance:setTitle(getText("IGUI_PhunMart_Title_AdminShell"))
        instance:initialise()
        instances[playerIndex] = instance
        ISLayoutManager.RegisterWindow(profileName, Shell, instance)
    end

    instance:addToUIManager()
    instance:setVisible(true)
    instance:ensureVisible()

    local view = tabKey and instance:activateTab(tabKey)
    if not view then
        -- No tab asked for, so refresh whatever is already forward.
        Shell.onActivateView(instance, instance.tabs)
        view = instance.tabs:getActiveView()
    end
    if view and selectKey and view.selectKey then
        view:selectKey(selectKey)
    end

    return instance
end

--- The open shell for a player, or nil. Lets a caller check for one without
--- opening one.
function Shell.get(player)
    return instances[player and player:getPlayerNum() or 0]
end

return Shell
