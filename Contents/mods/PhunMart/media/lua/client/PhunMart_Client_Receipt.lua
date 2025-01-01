if isServer() then
    return
end
local PhunMart = PhunMart
local PhunWallet = PhunWallet

PhunMart.applyReceipt = {}

PhunMart.applyReceipt["ITEM"] = function(playerObj, item)

    if PhunWallet and PhunWallet.currencies[item.label] then
        PhunWallet.queue:add(playerObj, item.label, item.quantity)
    else
        for i = 1, (item.quantity or 1) do
            playerObj:getInventory():AddItem(item.name, 1)
        end
    end

end

PhunMart.applyReceipt["PERK"] = function(playerObj, item)

    local perk = PerkFactory.getPerkFromName(item.name or item.label)
    local qty = item.quantity or 1
    playerObj:getXp():AddXP(perk, qty, true, false, false)

end

PhunMart.applyReceipt["BOOST"] = function(playerObj, item)

    local perk = PerkFactory.getPerkFromName(item.name or item.label)
    local existing = playerObj:getXp():getPerkBoost(perk) or 0
    playerObj:getXp():setPerkBoost(perk, item.quantity + existing);

end

PhunMart.applyReceipt["TRAIT"] = function(playerObj, item)

    local trait = TraitFactory.getTrait(item.name or item.label)
    if item.tag == "REMOVE" then
        playerObj:getTraits():remove(trait:getType())
    else
        playerObj:getTraits():add(trait:getType())
    end

end

PhunMart.applyReceipt["VEHICLE"] = function(playerObj, item)
    -- TODO: shit or get off the pot with item.name or item.label calls everywhere. PICK A LANE
    local key = InventoryItemFactory.CreateItem("PhunMart.VehicleKeySpawner")
    local VehicleScript = getScriptManager():getVehicle(item.name or item.label)
    local named = getText("IGUI_VehicleName" .. VehicleScript:getName())
    key:setName(getText("IGUI_PhunMart.CallForX", named))
    key:getModData().PhunMart = {
        text = named,
        name = item.name or item.label,
        playername = playerObj:getUsername()
    }
    playerObj:getInventory():AddItem(key)

end
