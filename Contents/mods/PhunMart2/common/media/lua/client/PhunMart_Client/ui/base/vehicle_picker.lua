if isServer() then
    return
end

-- Vehicles are named in two places (a group's item list, and a spawnVehicle
-- action) and until now neither could be picked from. The item picker reads
-- getAllItems(), which has no vehicles in it, so a group holding 115 vehicle
-- script names showed them and offered no way to change one.
--
-- Everything except the source is the same job, so this rides on ItemPicker and
-- only replaces where the rows come from.

local Core = PhunMart
local ItemPicker = require "PhunMart_Client/ui/base/item_picker"
local PickerPanel = require "PhunMart_Client/ui/base/picker_panel"

local VehiclePicker = ItemPicker:derive("PhunMartVehiclePicker")

-- Vehicle labels are not unique. Van and VanSeats are both "Franklin
-- Valuline", so a field listing both reads as the same vehicle twice and a
-- picker offers two identical rows. Only the colliding labels get their script
-- name appended, so the common case stays clean.
local ambiguousLabels = nil

local function buildAmbiguity()
    ambiguousLabels = {}
    local counts = {}
    for _, v in ipairs(Core.getAllVehicles() or {}) do
        local l = v.label or ""
        counts[l] = (counts[l] or 0) + 1
    end
    for l, n in pairs(counts) do
        if n > 1 then
            ambiguousLabels[l] = true
        end
    end
end

--- Display name for a vehicle script, disambiguated only when it needs to be.
function VehiclePicker.labelFor(key)
    if not key or key == "" then
        return ""
    end
    if not ambiguousLabels then
        buildAmbiguity()
    end
    local label = (Core.getVehicleLabel and Core.getVehicleLabel(key)) or key
    if ambiguousLabels[label] then
        return label .. " (" .. key .. ")"
    end
    return label
end

function VehiclePicker:populateItems()
    -- No icons: vehicle scripts have no inventory texture, and a column of
    -- empty placeholders reads as broken artwork rather than as absence.
    self._noIcons = true

    local catSet = {}
    for _, v in ipairs(Core.getAllVehicles() or {}) do
        local key = v.type
        -- Group item lists and spawnVehicle actions both store bare names for
        -- base game vehicles, so match what is already in the files. A modded
        -- vehicle keeps its prefix: vehicleScriptExists assumes Base. for any
        -- bare name, so stripping one would make it unresolvable.
        local bare = key:match("^Base%.(.+)$")
        if bare then
            key = bare
        end

        self:addPickerItem(key, VehiclePicker.labelFor(key), {
            category = v.category
        })
        if v.category and v.category ~= "" then
            catSet[v.category] = true
        end
    end

    table.sort(self._allItems, function(a, b)
        return a.display:lower() < b.display:lower()
    end)

    self._categories = {}
    for cat in pairs(catSet) do
        table.insert(self._categories, cat)
    end
    table.sort(self._categories)
end

--- Open a vehicle picker modal.
-- @param player        Player object
-- @param selectedKeys  Array of currently selected script names, or nil
-- @param callback      function(keys) called with the selected script names
function VehiclePicker.open(player, selectedKeys, callback)
    local core = getCore()
    local sw = core:getScreenWidth()
    local sh = core:getScreenHeight()
    local w, h = PickerPanel.sizeFor(640, 600)
    local x = math.floor((sw - w) / 2)
    local y = math.floor((sh - h) / 2)

    local picker = VehiclePicker:new(x, y, w, h, player, selectedKeys, callback)
    picker:setTitle(getText("IGUI_PhunMart_Admin_PickVehicles"))
    picker:initialise()
    picker:addToUIManager()
    picker:bringToTop()
    return picker
end

--- True when `key` names a vehicle script rather than an inventory item. Used
--- to split a group's mixed list into the two pickers that can edit it.
function VehiclePicker.isVehicleScript(key)
    if not key or key == "" then
        return false
    end
    return Core.vehicleScriptExists(key) == true
end

return VehiclePicker
