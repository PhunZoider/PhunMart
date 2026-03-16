if isServer() then
    return
end

local PickerPanel = require "PhunMart_Client/ui/base/picker_panel"

local CategoryPicker = PickerPanel:derive("PhunMartCategoryPicker")

function CategoryPicker:populateItems()
    local catSet = {}
    local items = getScriptManager():getAllItems()
    for i = 0, items:size() - 1 do
        local item = items:get(i)
        local cat = item:getDisplayCategory()
        if cat and cat ~= "" and not catSet[cat] then
            catSet[cat] = true
        end
    end

    local sorted = {}
    for cat in pairs(catSet) do
        table.insert(sorted, cat)
    end
    table.sort(sorted)

    for _, cat in ipairs(sorted) do
        self:addPickerItem(cat, cat)
    end
end

--- Open a category picker modal.
-- @param player        Player object
-- @param selectedKeys  Array of currently selected category strings (or nil)
-- @param callback      function(keys) called with array of selected categories on OK
function CategoryPicker.open(player, selectedKeys, callback)
    local core = getCore()
    local sw = core:getScreenWidth()
    local sh = core:getScreenHeight()
    local w = math.min(400, sw - 40)
    local h = math.min(500, sh - 40)
    local x = math.floor((sw - w) / 2)
    local y = math.floor((sh - h) / 2)

    local picker = CategoryPicker:new(x, y, w, h, player, selectedKeys, callback)
    picker:setTitle(getText("IGUI_PhunMart_Admin_PickCategories"))
    picker:initialise()
    picker:addToUIManager()
    picker:bringToTop()
    return picker
end

return CategoryPicker
