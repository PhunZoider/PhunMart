if isServer() then
    return
end

local PickerPanel = require "PhunMart_Client/ui/base/picker_panel"

--- Generic picker for arbitrary string keys.
-- Usage:
--   KeyPicker.open(player, options, selectedKeys, callback, opts)
-- options: array of strings OR array of {key, display} tables
-- selectedKeys: array of currently selected key strings (or nil)
-- callback(keys): receives array of selected keys on OK, or single key if singleSelect
-- opts: { title, singleSelect }
local KeyPicker = PickerPanel:derive("PhunMartKeyPicker")

function KeyPicker:populateItems()
    for _, entry in ipairs(self._options or {}) do
        if type(entry) == "string" then
            self:addPickerItem(entry, entry)
        elseif type(entry) == "table" then
            self:addPickerItem(entry.key, entry.display or entry.key, entry.extra)
        end
    end
end

function KeyPicker.open(player, options, selectedKeys, callback, opts)
    opts = opts or {}
    local core = getCore()
    local sw = core:getScreenWidth()
    local sh = core:getScreenHeight()
    local w = math.min(450, sw - 40)
    local h = math.min(500, sh - 40)
    local x = math.floor((sw - w) / 2)
    local y = math.floor((sh - h) / 2)

    local picker = KeyPicker:new(x, y, w, h, player, selectedKeys, callback)
    picker._options = options or {}
    if opts.singleSelect then
        picker.singleSelect = true
    end
    picker:setTitle(opts.title or "Pick")
    picker:initialise()
    picker:addToUIManager()
    picker:bringToTop()
    return picker
end

return KeyPicker
