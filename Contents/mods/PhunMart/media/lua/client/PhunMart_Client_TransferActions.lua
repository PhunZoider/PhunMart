if isServer() then
    return
end
require "TimedActions/ISInventoryTransferAction"
-- Hook the original New Inventory Transfer Method
local originalNewInventoryTransaferAction = ISInventoryTransferAction.new
function ISInventoryTransferAction:new(player, item, srcContainer, destContainer, time)

    local itemType = item:getFullType()

    if itemType == "PhunMart.VehicleKeySpawner" or itemType == "PhunMart.SafehousePaint" then
        -- prevent transfering this anywhere. Its only meant for this person!
        return {
            ignoreAction = true
        }
    end

    -- otherwise, just do the transfer by passing parms back to original method
    return originalNewInventoryTransaferAction(self, player, item, srcContainer, destContainer, time)
end
