if isClient() then
    return
end
require "PhunMart_SShopSystem"

local PM = PhunMart
local sandbox = SandboxVars.PhunMart
local Commands = {}

Commands[PM.commands.requestShop] = function(playerObj, args)
    SPhunMartSystem.instance:requestShop(args.id or args.shopId, playerObj)
end

Commands[PM.commands.buy] = function(playerObj, args)
    local success = SPhunMartSystem.instance:purchase(args.shopId, args.itemId, playerObj)
    print("success ", tostring(success))
end

Commands[PM.commands.restock] = function(playerObj, args)
    SPhunMartSystem.instance:restock(args.shopId, playerObj)
end

Commands[PM.commands.closeShop] = function(playerObj, args)
    SPhunMartSystem.instance:getLuaObjectAt(args.location.x, args.location.y, args.location.z):unlock()
end

SPhunMartServerCommands = Commands
