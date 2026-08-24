if isServer() then
    return
end

-- Every machine standing in the world, and where it is.
--
-- This was a standalone window opened by right-clicking one shop, showing only
-- that shop's machines. Two columns headed "Shop" and "Group" held a location
-- and a distance, neither of which is either of those things, and there was no
-- way to see the whole set at once or to tell two shops' machines apart.
--
-- It is a tab now, listing every machine with the shop it belongs to. Arriving
-- from a shop row puts that shop's name in the filter box, which narrows the
-- list to the old behaviour while leaving it obvious what has been narrowed and
-- how to undo it.

local Core = PhunMart
local ListPanel = require "PhunMart_Client/ui/base/list_panel"

Core.ui.shop_instances = ListPanel:derive("PhunMartShopInstances")
Core.ui.shop_instances.instances = {}
local UI = Core.ui.shop_instances

-- PhunZones is optional; when present it names the region a machine sits in,
-- which is far more use than a coordinate pair. Resolved once, on first use,
-- because load order between mods is not ours to assume.
local pz = nil
local function zoneTitle(x, y)
    if pz == nil then
        pz = PhunZones or false
    end
    -- getLocation divides the coordinates, so a nil reaches it as an arithmetic
    -- error inside somebody else's mod. Ours to not ask.
    if not pz or not x or not y then
        return nil
    end
    -- A dot call: PhunZones 2 declares getLocation on Core rather than as a
    -- method, matching the other two call sites in this mod. pcall because an
    -- optional dependency's internals are not ours to depend on, and this runs
    -- once per machine on every refresh.
    local ok, loc = pcall(pz.getLocation, x, y)
    if ok and loc and loc.title and loc.title ~= "" then
        return loc.title
    end
    return nil
end

local function whereText(x, y)
    local title = zoneTitle(x, y)
    local coords = "(" .. tostring(x) .. ", " .. tostring(y) .. ")"
    return title and (title .. " " .. coords) or coords
end

---------------------------------------------------------------------------
-- Tab
---------------------------------------------------------------------------

function UI.createTab(player)
    local playerIndex = player:getPlayerNum()
    local instance = UI.instances[playerIndex]
    if not instance then
        instance = UI:new(0, 0, 100, 100, player)
        instance.description = getText("IGUI_PhunMart_Desc_Locations")
        instance:initialise()
        UI.instances[playerIndex] = instance
    end
    return instance
end

function UI:createChildren()
    ListPanel.createChildren(self)

    self.list.doDrawItem = ListPanel.defaultDrawRow
    self.list:setOnMouseDoubleClick(self, self.onTeleport)

    self:addListColumn(getText("IGUI_PhunMart_Col_Shop"), 0, {
        field = "shopLabel",
        sort = true
    })
    self:addListColumn(getText("IGUI_PhunMart_Col_Where"), 0.4, {
        field = "where",
        sort = true
    })
    self:addListColumn(getText("IGUI_PhunMart_Col_Distance"), 0.78, {
        -- Measured live rather than baked in at refresh. You walk while this is
        -- open, and a distance that was true a minute ago is worse than none.
        -- Only drawn rows call this, so it is a handful of square roots a frame.
        text = function(d)
            return Core.utils.formatWholeNumber(self:distanceTo(d)) .. "m"
        end,
        -- Sorted on the number, not on "612m", which would put 9m after 612m.
        sort = function(d)
            return self:distanceTo(d)
        end,
        color = {1, 1, 1},
        align = "right"
    })

    -- Nearest first to begin with, which is what this list was always ordered
    -- by and still the most useful answer before anyone asks a different one.
    self._sortColumn = 3
    self._sortDesc = false

    self._portBtn = self:addBottomButton(getText("IGUI_PhunMart_Btn_Teleport"), self.onTeleport, true)
    self._refreshBtn = self:addBottomButton(getText("IGUI_PhunMart_Btn_Refresh"), self.refresh)

    self:refresh()
end

---------------------------------------------------------------------------
-- Data
---------------------------------------------------------------------------

function UI:distanceTo(row)
    local player = self.player
    -- Coordinates checked, not just the row. This runs from a column renderer
    -- and from the sort comparator, both of which are called for every row on
    -- every pass, so one row without an x took the whole list down.
    if not player or not row or not row.x or not row.y then
        return 0
    end
    local dx = row.x - player:getX()
    local dy = row.y - player:getY()
    return math.sqrt(dx * dx + dy * dy)
end

--- Ask the server for the machine list. The reply lands in setData, so the rows
--- already on screen stay put until it does.
function UI:refresh()
    sendClientCommand(Core.name, Core.commands.getInstanceList, {})
end

function UI:setRows(list)
    self:clearList()

    local rows = {}
    for _, v in ipairs(list or {}) do
        -- Skip anything without a position. The server filters non-machines out
        -- now, but this list is the thing that shows the damage when it does
        -- not, so it checks rather than trusts.
        if v.x and v.y then
            local x, y, z = v.x, v.y, v.z or 0
            table.insert(rows, {
                key = v.key,
                type = v.type,
                shopLabel = Core.shopLabel(v.type),
                where = whereText(x, y),
                x = x,
                y = y,
                z = z
            })
        end
    end

    -- Ordering is the sort's job now, applied when the list is filtered. The
    -- displayed distance still updates as you move while the order does not,
    -- so rows do not shuffle under the cursor while you reach for one.
    for _, row in ipairs(rows) do
        self:addListItem(row.shopLabel, row)
    end
end

--- Push a fresh list into every open tab. Called from the command handlers,
--- which is why it takes the player: in multiplayer the reply is addressed.
function UI.setData(player, list)
    local instance = player and UI.instances[player:getPlayerNum()]
    if instance and instance.setRows then
        instance:setRows(list)
    end
end

function UI:getFilterText(itemData)
    return (itemData.shopLabel or "") .. " " .. (itemData.where or "") .. " " .. (itemData.type or "")
end

---------------------------------------------------------------------------
-- Actions
---------------------------------------------------------------------------

--- Narrow to one shop by typing its name into the filter, rather than by
--- holding a hidden mode. The box shows what was done and clearing it undoes
--- it, which a hidden filter cannot manage.
function UI:showShop(shopType)
    if self._filterEntry and shopType then
        self._filterEntry:setText(Core.shopLabel(shopType))
        self:applyFilter()
    end
end

function UI:selectedRow()
    local sel = self.list.selected
    local entry = sel and sel > 0 and self.list.items[sel]
    return entry and entry.item or nil
end

function UI:onTeleport()
    local row = self:selectedRow()
    if row then
        self:doPort(row.x, row.y, row.z or 0)
    end
end

---------------------------------------------------------------------------
-- Teleport
---------------------------------------------------------------------------

function UI:doPort(destinationX, destinationY, destinationZ)
    local player = self.player
    if not player then
        return
    end

    local function place()
        player:setX(destinationX)
        player:setY(destinationY)
        player:setZ(destinationZ)
        if player.setLx then
            player:setLx(destinationX)
            player:setLy(destinationY)
            player:setLz(destinationZ)
        else
            player:setLastX(destinationX)
            player:setLastY(destinationY)
            player:setLastZ(destinationZ)
            getWorld():update()
        end
    end

    place()

    -- The destination square does not exist until the cell streams in, so the
    -- position is reapplied once there is somewhere to stand. Bounded, because
    -- a square that never loads would otherwise leave this running for the rest
    -- of the session.
    local retries = 100
    local settle
    settle = function()
        local square = player:getCurrentSquare()
        if square == nil then
            return
        end
        retries = retries - 1
        if retries <= 0 then
            Events.OnPlayerUpdate.Remove(settle)
            player:Say(getText("IGUI_PhunMart_Msg_PortFailed"))
            return
        end
        if AdjacentFreeTileFinder.FindClosest(square, player) then
            Events.OnPlayerUpdate.Remove(settle)
            place()
        end
    end
    Events.OnPlayerUpdate.Add(settle)
end

---------------------------------------------------------------------------
-- Entry point
---------------------------------------------------------------------------

--- Open the shell on this tab, optionally narrowed to one shop. Kept so the
--- Shops tab's right-click reads the same as it always did.
function UI.open(player, shopType)
    local shell = Core.ui.admin_shell
    if not shell then
        return
    end
    -- open already activates the tab, and activating one refreshes it, so there
    -- is no need to ask for the list a second time here.
    local instance = shell.open(player, "locations")
    local view = instance and instance:getTabView("locations")
    if view then
        view:showShop(shopType)
    end
    return view
end

return UI
