if isServer() then
    return
end

require "ISUI/ISToolTipInv"

-- "Shop: <name>" on a machine item's tooltip.
--
-- A machine item carries its shop as modData.type (shared/PhunMart/machine_item.lua), but its
-- name comes from its tile, and on the generic tiles that is only "Vending Machine". The line
-- is worked out each time the tooltip draws, so it is in this player's language and follows a
-- shop being renamed. Vanilla prints an item's getTooltip() as the last line; that value lives
-- in the item's modData, so it is set just for the draw and put back straight after, leaving
-- the saved item as it was.

local Core = PhunMart

local function machineShop(item)
    if not item or not item.hasModData or not item:hasModData() then
        return nil
    end
    local key = item:getModData().type
    return key and Core.shops and Core.shops[key] and key or nil
end

local oldRender = ISToolTipInv.render
function ISToolTipInv:render()
    local item = self.item
    local key = machineShop(item)
    if not key then
        return oldRender(self)
    end
    local previous = item:getModData().Tooltip
    item:setTooltip(getText("IGUI_PhunMart_Tooltip_MachineShop", Core.shopLabel(key)))
    local ok, err = pcall(oldRender, self)
    item:getModData().Tooltip = previous
    if not ok then
        error(err)
    end
end
