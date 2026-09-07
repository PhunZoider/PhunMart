if isServer() then
    return
end

local Core = PhunMart
local Commands = require "PhunMart_Client/commands"
Core.ClientSystem = CGlobalObjectSystem:derive("CPhunMartSystem")
local ClientSystem = Core.ClientSystem

function ClientSystem:new()
    local o = CGlobalObjectSystem.new(self, "phunmart")
    o.loadedShops = {}
    return o
end

function ClientSystem:isValidIsoObject(isoObject)
    return isoObject:getName() == "PhunMartVendingMachine"
end

function ClientSystem:newLuaObject(globalObject)
    local o = Core.ClientObject:new(self, globalObject)
    return o
end

function ClientSystem:openShop(player, obj)
    obj:updateFromIsoObject()
    self:sendCommand(player or getSpecificPlayer(0), Core.commands.openShop, {
        key = obj:getKey(),
        type = obj.type,
        x = obj.x,
        y = obj.y,
        z = obj.z
    })
end

function ClientSystem:requestPurchase(obj, itemId, playerObj)

    local item = obj.items[itemId]
    if not item then
        return
    end

    -- recheck that player can buy
    local canBuy = Core:canBuy(playerObj, item)

    if canBuy.passed == true then
        -- assert condition 1 is the one Condition that passeed
        -- iterate through each condition and adjust any prices
        for _, v in ipairs(canBuy.conditions[1]) do

            if v.type == "price" then
                local allocations = v.allocation or {}
                for _, a in ipairs(allocations) do
                    if a.type == "trait" then
                        playerObj:getTraits():remove(a.currency)
                    elseif a.type == "item" and a.value > 0 then
                        local item = getScriptManager():getItem(a.currency)
                        if item then
                            local remaining = a.value
                            -- asserting we have enough to consume or canBuy wouldn't have passed?
                            for i = 1, remaining do
                                local invItem = playerObj:getInventory():getItemFromTypeRecurse(a.currency)
                                if invItem then
                                    local container = invItem:getContainer()
                                    container:Remove(invItem)
                                    sendRemoveItemFromContainer(container, invItem)
                                end
                            end
                        end
                    else
                        -- assert its a hook
                        local hooks = Core.hooks.prePurchase
                        for _, v in ipairs(hooks) do
                            if v then
                                -- should mutate val if handled in hook
                                v(playerObj, a.type, a.currency, a.value)
                            end
                        end
                    end
                end
            end
        end
        self:sendCommand(playerObj, Core.commands.buy, {
            shopId = obj.id,
            itemId = itemId,
            location = obj.location
        })
    end

end

function ClientSystem:restock(shop, playerObj)
    self:sendCommand(playerObj or getSpecificPlayer(0), Core.commands.restock, {
        x = shop.x,
        y = shop.y,
        z = shop.z
    })
end

function ClientSystem:changeTo(shop, playerObj, to)
    self:sendCommand(playerObj or getSpecificPlayer(0), Core.commands.changeTo, {
        shopId = shop.id,
        type = shop.type,
        location = {
            x = shop.x,
            y = shop.y,
            z = shop.z
        },
        to = to
    })
end

function ClientSystem:reroll(shop, target, playerObj)
    self:sendCommand(playerObj or getSpecificPlayer(0), Core.commands.reroll, {
        location = {
            x = shop.x,
            y = shop.y,
            z = shop.z
        }
    })
end

function ClientSystem:close(shop, playerObj)
    self:sendCommand(playerObj or getSpecificPlayer(0), Core.commands.closeShop, {
        shopId = shop.id,
        location = shop.location
    })
end

function ClientSystem:updateShop(location)
    local obj = self:getLuaObjectAt(location.x, location.y, location.z)
    obj:updateFromIsoObject()
end

function ClientSystem:OnServerCommand(command, args)
    if Commands[command] then
        Commands[command](args)
    end
end

function ClientSystem:newLuaObjectAt(x, y, z)
    local globalObject = self.system:newObject(x, y, z)
    return self:newLuaObject(globalObject)
end

-- Machine squares whose solid flag could not be folded in yet, keyed by
-- position. See ClientSystem:pollPendingSolids.
local pendingSolids = {}
local pendingCount = 0

-- How long a square waits for its machine's sprite before it is given up on.
-- A sprite that has not arrived within ten seconds of ticks is not coming, and
-- an entry kept forever would leak one per machine the client ever sees.
local PENDING_TICKS = 600

--- Fold a machine's solid/solidtrans flag into the square it stands on.
---
--- Collision is decided on the client from the square's own flags rather than
--- the object's, and only two things ever set them: a chunk load, and the
--- engine's own recalculation when an object arrives in an AddItemToMap packet.
--- A sprite that lands after that -- transmitUpdatedSpriteToClients, which is
--- how a machine gets its face back when the complete-item packet dropped it --
--- updates the sprite and nothing else, so the machine goes visible again on a
--- square that is still walk-through.
function ClientSystem:recalcSquare(square)
    if not square then
        return
    end
    square:RecalcProperties()
    square:RecalcAllWithNeighbours(true)
end

--- Watch `square` until the machine on it has a sprite worth recalculating for.
function ClientSystem:markSolidPending(square)
    if not square then
        return
    end
    local key = square:getX() .. "_" .. square:getY() .. "_" .. square:getZ()
    if pendingSolids[key] == nil then
        pendingCount = pendingCount + 1
    end
    pendingSolids[key] = {
        x = square:getX(),
        y = square:getY(),
        z = square:getZ(),
        ticks = PENDING_TICKS
    }
end

--- Recheck watched squares, and run the arrival again once the sprite is there.
---
--- Called every tick, and does nothing at all on a tick with nothing waiting,
--- which is every tick but the handful after a machine is placed or changed.
function ClientSystem:pollPendingSolids()
    if pendingCount == 0 then
        return
    end
    for key, entry in pairs(pendingSolids) do
        local finished = false
        local square = getSquare(entry.x, entry.y, entry.z)
        if not square then
            -- The chunk went away; a reload will recalculate it in
            -- checkSquareLoaded, so there is nothing left to wait for.
            finished = true
        else
            local objects = square:getObjects()
            for i = 0, objects:size() - 1 do
                local obj = objects:get(i)
                if obj:getName() == "PhunMartVendingMachine" then
                    local sprite = obj:getSprite()
                    local customName = sprite and sprite:getProperties():get("CustomName")
                    -- The same test checkObjectAdded makes, not just "has a
                    -- sprite": a machine whose shop type an admin has since
                    -- deleted has a CustomName that matches nothing, and
                    -- calling checkObjectAdded for it would only put the
                    -- square back on this list and hold it here forever.
                    -- Left to age out instead.
                    if customName and Core.shops[customName] then
                        -- The whole arrival, not just the recalculation: with a
                        -- sprite in hand this run can also match the shop and
                        -- put a global object behind the machine, which is what
                        -- the context menu looks for.
                        self:checkObjectAdded(obj)
                        finished = true
                    end
                    break
                end
            end
        end
        entry.ticks = entry.ticks - 1
        if finished or entry.ticks <= 0 then
            pendingSolids[key] = nil
            pendingCount = pendingCount - 1
        end
    end
end

--- Re-solidify a machine's square as its chunk streams in.
---
--- For machines already standing in a save with a walk-through square: the
--- sprite they lost on the way to the client has since been put back, but the
--- square's flags were folded in while it was still missing and nothing has
--- touched them since.
function ClientSystem:checkSquareLoaded(square)
    if not square then
        return
    end
    local objects = square:getObjects()
    for i = 0, objects:size() - 1 do
        if objects:get(i):getName() == "PhunMartVendingMachine" then
            self:recalcSquare(square)
            return
        end
    end
end

function ClientSystem:checkObjectAdded(obj)
    if not obj then
        return
    end

    local sprite = obj:getSprite()
    local customName = sprite and sprite:getProperties():get("CustomName")
    local name = obj:getName()

    Core.debugLn("CLIENT checkObjectAdded: sprite=" .. tostring(sprite and sprite:getName()) .. " customName=" ..
                     tostring(customName) .. " name=" .. tostring(name))

    -- Either mark means a machine, because either can be the only one present.
    -- CustomName is what the server matches on, and all a machine loaded from a
    -- chunk is sure to have. The name is what survives a complete-item packet
    -- that dropped the sprite -- the server sets it before the object goes out
    -- -- and a machine with no sprite has no properties to read at all.
    -- Requiring CustomName alone meant such a machine was not recognised here
    -- at all: no global object behind it, and a square nothing folded a solid
    -- flag into, so a player walked through a machine they could not
    -- right-click, and a relog brought back only the half the server sends.
    local known = customName ~= nil and Core.shops[customName] ~= nil
    if not known and name ~= "PhunMartVendingMachine" then
        return
    end

    -- Ensure the object is named so the engine's isValidIsoObject can find it later.
    if name ~= "PhunMartVendingMachine" then
        obj:setName("PhunMartVendingMachine")
        Core.debugLn("CLIENT checkObjectAdded: set name to PhunMartVendingMachine")
    end

    -- A machine that arrived over the wire, or that replaced a vanilla vending
    -- machine here, leaves this square holding the flags it had before. The
    -- server does the same in addToWorld for its own copy of the square.
    local square = obj:getSquare()
    self:recalcSquare(square)
    if not known then
        -- Recalculated anyway, above, because the flags left behind by whatever
        -- stood here before are wrong either way -- but there is no solid flag
        -- to fold in until the sprite lands, so watch for it.
        self:markSolidPending(square)
    end

    local x, y, z = obj:getX(), obj:getY(), obj:getZ()
    local existing = self:getLuaObjectAt(x, y, z)
    Core.debugLn("CLIENT checkObjectAdded: pos=" .. x .. "," .. y .. "," .. z .. " existingLuaObj=" ..
                     tostring(existing ~= nil))

    if not existing then
        local luaObj = self:newLuaObjectAt(x, y, z)
        Core.debugLn("CLIENT checkObjectAdded: newLuaObjectAt result=" .. tostring(luaObj ~= nil))
        if luaObj then
            luaObj:stateFromIsoObject(obj)
        end
    end
end

--- Open the editor. `tabKey` and `selectKey` are optional and let a caller land
--- on a particular list with a particular definition already selected.
function ClientSystem:openShopList(player, tabKey, selectKey)
    Core.ui.admin_shell.open(player or getSpecificPlayer(0), tabKey, selectKey)
end

CGlobalObjectSystem.RegisterSystemClass(Core.ClientSystem)
