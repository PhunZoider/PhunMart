if isClient() then
    return
end
require "Map/SGlobalObjectSystem"
local Core = PhunMart

local Commands = require "PhunMart_Server/commands"
Core.ServerSystem = SGlobalObjectSystem:derive("SPhunMartSystem")
local ServerSystem = Core.ServerSystem

function ServerSystem:new()
    local o = SGlobalObjectSystem.new(self, "phunmart")
    return o
end

function ServerSystem:removeLuaObject(luaObject)
    Core:removeInstance(luaObject)
    SGlobalObjectSystem.removeLuaObject(self, luaObject)
end

function ServerSystem:removeInvalidInstanceData()

    -- Machines only. Everything collected here that does not match a loaded
    -- object is deleted below, so anything else living in this ModData table
    -- would be wiped on every boot for the crime of not being a shop.
    local checked = {}
    local instanceCount = 0
    for k, v in pairs(Core.instances) do
        if Core.isShopInstance(v) then
            checked[k] = true
            instanceCount = instanceCount + 1
        end
    end
    local objectCount = 0
    for i = 1, self:getLuaObjectCount() do
        local obj = self:getLuaObjectByIndex(i)
        checked[obj.x .. "_" .. obj.y .. "_" .. obj.z] = nil
        objectCount = objectCount + 1
    end
    local removed = 0
    for k, v in pairs(checked) do
        Core.instances[k] = nil
        removed = removed + 1
    end
    -- Both counts, and out loud when it actually took something. They were
    -- already being gathered and neither was ever printed, which made the one
    -- number that did print impossible to read: "removed 40" means one thing
    -- against 40 objects and something much worse against none, and the second
    -- reading is what a boot that runs before the global objects have loaded
    -- would look like.
    local msg = "removeInvalidInstanceData: " .. tostring(instanceCount) .. " instance records, " ..
                    tostring(objectCount) .. " global objects, removed " .. tostring(removed)
    if removed > 0 then
        print("[" .. Core.name .. "] " .. msg)
    else
        Core.debugLn(msg)
    end

end

-- Ghost machines: a shop this save still has records for, standing on a square
-- that no longer holds it.
--
-- Uninstalling the mod produces these. The IsoObject goes, because the engine
-- drops an object whose sprite it cannot resolve, but nothing else does: the
-- global objects belong to the map save and Core.instances is ModData, and
-- neither notices the mod is missing. Reinstall and the records are back with
-- nothing underneath them.
--
-- removeInvalidInstanceData cannot catch this. It tests instances against the
-- global object list, and after an uninstall both sides of that comparison
-- still agree with each other; it is the world they have both lost touch with.
-- Only a loaded square can settle it, which is why this runs from
-- loadGridsquare rather than at boot.
--
-- The mirror of checkObjectAdded, which recovers a sprite that outlived its
-- global object. This deals with a global object that outlived its sprite,
-- which turns out to be two different situations wanting opposite answers.
--
-- If the object is gone, the records are the only thing left and they go too.
-- If the object is still standing and only its sprite is unresolvable, then
-- nothing has been lost at all: the type is right there on the global object,
-- so the sprite can simply be put back and the machine reappears. Deleting
-- that one would throw away a working shop over a rendering problem, which is
-- what the first cut of this would have done had its guard not spared it for
-- an unrelated reason.
--
-- Returns "removed", "repaired", or nil for a square that needed neither.
local ghostsRemoved = 0
local spritesRepaired = 0

function ServerSystem:reconcileMachineAt(square, objects)
    -- Before ini the shop definitions have not compiled and the world is still
    -- coming up, so an empty-looking square proves nothing yet.
    if not Core.inied or not square or not objects then
        return nil
    end

    local x, y, z = square:getX(), square:getY(), square:getZ()
    local key = x .. "_" .. y .. "_" .. (z or 0)

    -- Both halves are asked about, because either can outlive the other and
    -- the first cut of this asked only about the ModData record. That is the
    -- half that does not drive what a player sees: the context menu appears
    -- when the CLIENT finds a global object on the square, and the client only
    -- has one because the server sent it. So a record that has already gone,
    -- which removeInvalidInstanceData will do at boot the moment the global
    -- object list is not loaded yet, left the visible ghost untouched.
    --
    -- isShopInstance guards the ModData side for the reason it does in
    -- removeInvalidInstanceData: other things live in that table.
    local luaObj = self:getLuaObjectAt(x, y, z)
    local instance = Core.instances and Core.instances[key]
    local hasRecord = Core.isShopInstance(instance)

    if not luaObj and not hasRecord then
        return nil
    end

    -- Both marks a machine can carry, so this decides for itself rather than
    -- trusting what the caller worked out. loadGridsquare arrives here having
    -- already ruled out one of them, openShop having ruled out neither, and a
    -- function that deletes a player's shop on being called wrongly should not
    -- depend on which.
    --
    -- Two marks because either can go missing on its own. A shop whose type an
    -- admin has since deleted no longer matches Core.shops, and a machine whose
    -- sprite failed to resolve has no properties to read at all; the name
    -- outlives both, and the client sets it on arrival for exactly this kind of
    -- lookup. Any one of them means a machine is standing here.
    --
    -- Only reached on a square that has one half of a machine on it, so the
    -- per-object cost lands nowhere near the whole map.
    for i = 0, objects:size() - 1 do
        local obj = objects:get(i)
        local isMachine = self:isValidIsoObject(obj)
        if not isMachine then
            local sprite = obj:getSprite()
            if sprite and sprite.getProperties then
                local customName = sprite:getProperties():get("CustomName")
                isMachine = customName ~= nil and Core.shops[customName] ~= nil
            end
        end
        if isMachine then
            -- Standing, so not a ghost. The caller only gets here having failed
            -- to find a sprite it recognises, so this object is a machine
            -- wearing a sprite the game cannot resolve: invisible, but real,
            -- and still answering when a player right-clicks the bare square it
            -- appears to be. The type is on the global object, so put the
            -- sprite back rather than taking the shop away.
            if luaObj and luaObj.applyTypeSprite and luaObj:applyTypeSprite() then
                spritesRepaired = spritesRepaired + 1
                if spritesRepaired == 1 then
                    print("[" .. Core.name ..
                              "] a machine was standing here with a sprite this build could not resolve, so it was invisible.")
                    print("[" .. Core.name ..
                              "] its shop type was intact, so the sprite has been put back and the machine is visible again.")
                    print("[" .. Core.name .. "] this is expected after the mod has been reinstalled.")
                end
                Core.debugLn("reconcileMachineAt: restored sprite for " .. tostring(luaObj.type) .. " at " .. x .. "," ..
                                 y .. "," .. tostring(z))
                return "repaired"
            end
            Core.debugLn("reconcileMachineAt: machine standing at " .. x .. "," .. y .. "," .. tostring(z) ..
                             " but its sprite could not be restored")
            return nil
        end
    end

    if luaObj then
        -- Takes the global object and the instance record together.
        self:removeLuaObject(luaObj)
    end
    if hasRecord then
        -- Unconditional rather than an else. removeLuaObject goes through
        -- Core:removeInstance, but only for the position the global object
        -- holds, and the whole reason this function looks at both halves is
        -- that the two can disagree.
        Core:removeInstance({
            x = x,
            y = y,
            z = z
        })
    end

    ghostsRemoved = ghostsRemoved + 1
    if ghostsRemoved == 1 then
        -- Once per session, whether or not debug is on. Records disappearing is
        -- worth a line in anybody's log, and the count is not knowable up front
        -- because they surface a chunk at a time.
        print("[" .. Core.name .. "] found shop data for a machine that is no longer in the world, and removed it.")
        print("[" .. Core.name .. "] this is expected after the mod has been uninstalled and reinstalled.")
        print("[" .. Core.name .. "] turn on the Debug sandbox option to log each one.")
    end
    Core.debugLn("reconcileMachineAt: dropped ghost shop data at " .. x .. "," .. y .. "," .. tostring(z))
    return "removed"
end

function ServerSystem.addToWorld(square, shop, direction)
    local index = 4
    if direction == IsoDirections.E then
        index = 1
    elseif direction == IsoDirections.S then
        index = 2
    elseif direction == IsoDirections.W then
        index = 3
    end
    -- Checked rather than assumed, because every caller reaches here having
    -- already taken the old machine off the square. Indexing a missing
    -- definition throws, and a throw at this point has destroyed a shop and put
    -- nothing back: the machine is simply gone, which is what an admin sees.
    -- Saying so and returning false lets the caller decide, and none of them
    -- can decide anything useful after the fact, which is why they now ask
    -- before they demolish.
    local shopDef = shop and Core.shops[shop]
    if not shopDef or not shopDef.sprites then
        print("[" .. Core.name .. "] addToWorld: no shop definition for '" .. tostring(shop) .. "', nothing placed at " ..
                  square:getX() .. "," .. square:getY() .. "," .. square:getZ())
        return false
    end

    local sprite = shopDef.sprites[index]
    -- Plain IsoObject (not IsoThumpable): zombies ignore it and it can't be
    -- destroyed. Admin pickup/relocate goes through transmitRemoveItemFromSquare.
    local isoObject = IsoObject.new(square:getCell(), square, sprite)
    ServerSystem.initializeShopObject(isoObject)
    square:AddSpecialObject(isoObject, -1)
    triggerEvent("OnObjectAdded", isoObject)
    isoObject:transmitCompleteItemToClients()
    -- Sent again, by name, because the complete-item packet does not reliably
    -- carry a modded sprite. The machine arrives on the client named and real
    -- but wearing nothing: it draws nothing, it hands RecalcProperties no solid
    -- flag to fold in, and it carries no CustomName for the client's
    -- checkObjectAdded to recognise -- so a player walks through a machine they
    -- cannot right-click. transmitUpdatedSpriteToClients is the path that
    -- survives, and it is already what applyTypeSprite uses to put the face
    -- back on a machine whose sprite a client could not resolve.
    isoObject:transmitUpdatedSpriteToClients()
    -- An IsoThumpable carried its own collision; a plain IsoObject does not. The
    -- machine blocks movement only once the square has folded the sprite's
    -- solid/solidtrans flag into its own properties, and nothing on the way here
    -- does that: the transmitRemoveItemFromSquare that precedes most calls drops
    -- the old machine's flags, and AddSpecialObject does not put the new one's
    -- back. Without these two the machine draws, lights, opens and sells, and
    -- the player walks straight through it. Every vanilla placement path in
    -- ISMoveableSpriteProps ends on the same pair.
    square:RecalcProperties()
    square:RecalcAllWithNeighbours(true)
    return true

end

function ServerSystem.initializeShopObject(obj)
    obj:setName("PhunMartVendingMachine")

    local sprite = obj:getSprite()
    local props = sprite:getProperties()
    local customName = props:get("CustomName")

    local data = {
        type = customName,
        facing = tostring(obj:getFacing()),
        created = GameTime:getInstance():getWorldAgeHours(),
        x = obj:getX(),
        y = obj:getY(),
        z = obj:getZ()
    }
    obj:setModData(data)
    Core:addInstance(data)
end

function ServerSystem:initSystem()
    SGlobalObjectSystem.initSystem(self)
    -- Specify GlobalObjectSystem fields that should be saved.
    self.system:setModDataKeys({})

    -- Specify GlobalObject fields that should be saved.
    -- ids = array of all shop ids that have been generated
    -- chunks = array of all chunk coordinates that have shops?
    self.system:setObjectModDataKeys({'type', 'facing', 'created', 'x', 'y', 'z', 'lastRestock', 'offers'})
end

function ServerSystem:isValidIsoObject(isoObject)
    return isoObject:getName() == "PhunMartVendingMachine"
end

function ServerSystem:newLuaObjectAt(x, y, z)
    local globalObject = self.system:newObject(x, y, z)
    return self:newLuaObject(globalObject)
end
function ServerSystem:newLuaObject(globalObject)
    return Core.ServerObject:new(self, globalObject)
end

-- Map a facing string/enum (or targetSprites entry) to IsoDirections.
-- Sprite orientation is the source of truth; getFacing() is often wrong on
-- vanilla vending machines (e.g. east-facing sprites reporting north).
local function facingToIsoDirection(f)
    if f == nil then
        return IsoDirections.N
    end
    if f == IsoDirections.E or f == IsoDirections.S or f == IsoDirections.W or f == IsoDirections.N then
        return f
    end
    local s = string.lower(tostring(f))
    if s == "e" or s == "east" then
        return IsoDirections.E
    end
    if s == "s" or s == "south" then
        return IsoDirections.S
    end
    if s == "w" or s == "west" then
        return IsoDirections.W
    end
    return IsoDirections.N
end

-- Resolve a shop object's facing string/enum to an IsoDirections constant.
local function resolveFacing(shopObj)
    return facingToIsoDirection(shopObj.facing)
end

function ServerSystem:generateRandomShopOnSquare(square, direction)
    direction = facingToIsoDirection(direction or "south")
    local shop = Core:generateShop(square)
    if shop ~= nil then
        square:transmitRemoveItemFromSquare(true)
        self.addToWorld(square, shop, direction)
    end
end

-- Build a shop payload table suitable for sending to clients or triggering events.
function ServerSystem.buildShopPayload(shopObj)
    local shopDef = Core.runtime and Core.runtime.shops and Core.runtime.shops[shopObj.type]
    local shopCfg = Core.shops and Core.shops[shopObj.type]
    local payload = {
        key = shopObj:getKey(),
        shopType = shopObj.type,
        location = {
            x = shopObj.x,
            y = shopObj.y,
            z = shopObj.z
        },
        offers = shopObj.offers or {},
        conditionsDefs = Core.runtime and Core.runtime.conditionsDefs,
        background = shopDef and shopDef.background,
        defaultView = shopDef and shopDef.defaultView,
        poolSets = shopDef and shopDef.poolSets,
        -- Travels so the window knows there is nothing of the shop's own to
        -- show. Placement already reads it; the window needs it for the same
        -- reason, one step later.
        stocksNothing = shopDef and shopDef.stocksNothing,
        lastRestock = shopObj.lastRestock,
        restockFrequency = (shopCfg and shopCfg.restock) or 24
    }

    -- The flags another mod kept through compilation travel on to the window
    -- as well. A shop window mode is chosen from these, and the client has no
    -- other route to a definition: it draws entirely from this payload.
    for _, field in ipairs(Core.shopDefPassthrough or {}) do
        if payload[field] == nil then
            payload[field] = shopDef and shopDef[field]
        end
    end

    return payload
end

--- Tell clients this machine's stock changed, so a shop window standing open in
--- front of it redraws rather than showing the cycle before.
---
--- restock() saves and transmits modData, which is enough for the world and not
--- enough for an open window: the window draws from the payload it was handed
--- when it opened. Without this, a forced restock left the window showing offer
--- IDs the shop no longer has, and buying one came back "Offer not found".
---
--- Broadcast rather than aimed at one player, because anyone can be standing at
--- the machine, not only the admin who pressed the button. The client drops any
--- key that is not the shop it has open, so a machine nobody is looking at costs
--- one ignored message.
function ServerSystem.notifyShopChanged(shopObj)
    if not shopObj then
        return
    end
    local payload = ServerSystem.buildShopPayload(shopObj)
    if Core.isLocal then
        triggerEvent(Core.events.OnShopChange, payload.key, payload, false)
    else
        sendServerCommand(Core.name, Core.commands.onShopChange, {
            key = payload.key,
            data = payload
        })
    end
end

--- Turn the machine at `location` into a different shop, picked the way one is
--- picked when a machine is first placed.
---
--- Everything is resolved before anything is destroyed. It used to remove the
--- old machine and then work out what to put back, so a pick that came to
--- nothing left bare ground and threw on the way out, and the shop an admin
--- was standing in front of was gone for good.
---
--- The machine leaves itself out of the spacing measurement. It stands exactly
--- where the answer would go, so counted in it rules out its own type at
--- distance zero and everything sharing its category along with it, which on a
--- server with one machine of each kind rules out the entire list. This is the
--- same omission system_object's timed reroll already makes; this path never
--- did, which is why the cog could empty a square that a timer never would.
---
--- ignoreDistance was accepted and then never read, so the tickbox offering to
--- relax the spacing rule did nothing at all.
function ServerSystem:reroll(location, ignoreDistance)
    local shopObj = self:getLuaObjectAt(location.x, location.y, location.z)
    local iso = shopObj and shopObj.getIsoObject and shopObj:getIsoObject()
    local square = iso and iso:getSquare()
    if not square then
        Core.debugLn("reroll: no machine at " .. tostring(location.x) .. "," .. tostring(location.y) .. "," ..
                         tostring(location.z))
        return false
    end

    local facing = resolveFacing(shopObj)
    local shopname = self:getRandomShop(square:getX(), square:getY(), shopObj, ignoreDistance)
    if not shopname then
        -- Left standing on purpose. Nothing qualifies here, and an admin who
        -- asked for a different shop is better served by the one they have than
        -- by an empty square.
        print("[" .. Core.name .. "] reroll: nothing eligible at " .. square:getX() .. "," .. square:getY() ..
                  "; the machine has been left as it is")
        return false
    end

    square:transmitRemoveItemFromSquare(iso)
    return self.addToWorld(square, shopname, facing)
end

--- Turn the machine at `location` into `shopName` specifically. Same ordering
--- rule as reroll: the definition is checked while the machine is still
--- standing, because there is no putting it back afterwards.
function ServerSystem:changeTo(shopName, location)
    local shopObj = self:getLuaObjectAt(location.x, location.y, location.z)
    local iso = shopObj and shopObj.getIsoObject and shopObj:getIsoObject()
    local square = iso and iso:getSquare()
    if not square then
        Core.debugLn("changeTo: no machine at " .. tostring(location.x) .. "," .. tostring(location.y) .. "," ..
                         tostring(location.z))
        return false
    end

    if not shopName or not Core.shops[shopName] then
        print("[" .. Core.name .. "] changeTo: no shop definition for '" .. tostring(shopName) ..
                  "'; the machine has been left as it is")
        return false
    end

    local facing = resolveFacing(shopObj)
    square:transmitRemoveItemFromSquare(iso)
    return self.addToWorld(square, shopName, facing)
end

function ServerSystem:rerollAll()
    for i = 1, self:getLuaObjectCount() do
        local obj = self:getLuaObjectByIndex(i)
        if obj then
            self:reroll(obj.location)
        end
    end
end

function ServerSystem:restockAll()
    -- Round to the same precision lastRestock persists at (numberToTens), so a
    -- shop that services this stamp can't come back with a rounded-down
    -- lastRestock that still looks older than the stamp.
    local now = tonumber(string.format("%.1f", GameTime:getInstance():getWorldAgeHours()))
    -- Stamp global ModData so unloaded-chunk shops restock when their chunk loads
    Core.restockStamps().forceRestockAt = now

    -- Immediately restock every loaded shop object
    local count = 0
    for i = 1, self:getLuaObjectCount() do
        local obj = self:getLuaObjectByIndex(i)
        if obj then
            obj:restock()
            ServerSystem.notifyShopChanged(obj)
            count = count + 1
        end
    end
    Core.debugLn("restockAll: restocked " .. tostring(count) .. " loaded shops at " .. tostring(now))
end

-- Restock only machines of the given shop types. Used after a definition edit,
-- where restocking everything would reroll shops the change never touched and
-- pull stock out from under any player mid-purchase.
function ServerSystem:restockTypes(types)
    -- Tracked with a flag rather than testing the table with next(), which
    -- PZ's Lua sandbox does not expose.
    local wanted = {}
    local any = false
    for _, t in ipairs(types or {}) do
        wanted[t] = true
        any = true
    end
    if not any then
        return 0
    end

    -- Same rounding as restockAll, for the same reason.
    local now = tonumber(string.format("%.1f", GameTime:getInstance():getWorldAgeHours()))
    -- Per-type stamp so machines in unloaded chunks catch up when their chunk
    -- loads, without dragging in every other shop type the way forceRestockAt
    -- would.
    local stamps = Core.restockStamps()
    stamps.forceRestockTypeAt = stamps.forceRestockTypeAt or {}
    for t in pairs(wanted) do
        stamps.forceRestockTypeAt[t] = now
    end

    local count = 0
    for i = 1, self:getLuaObjectCount() do
        local obj = self:getLuaObjectByIndex(i)
        if obj and wanted[obj.type] then
            obj:restock()
            ServerSystem.notifyShopChanged(obj)
            count = count + 1
        end
    end
    Core.debugLn("restockTypes: restocked " .. tostring(count) .. " loaded shops at " .. tostring(now))
    return count
end

function ServerSystem:openShop(player, args, forceRestock)
    local shop = self:getLuaObjectAt(args.x, args.y, args.z)

    if not shop then
        Core.debugLn("openShop: no shop at " .. args.x .. "," .. args.y .. "," .. args.z)
        return
    end

    -- A ghost answers this command exactly as a machine would, which is how one
    -- gets noticed: right-click bare ground and a working shop opens. Caught
    -- here as well as on chunk load because this is the moment a player is
    -- standing on the square, so it is certainly loaded, and because a shop
    -- that is not there should not sell anything in the meantime.
    local cell = getWorld() and getWorld():getCell()
    local square = cell and cell:getGridSquare(args.x, args.y, args.z)
    -- Only "removed" stops the open. A machine whose sprite was put back is a
    -- real shop that is now visible as well, and the player asked to open it.
    if square and self:reconcileMachineAt(square, square:getObjects()) == "removed" then
        local key = shop.getKey and shop:getKey() or nil
        if Core.isLocal then
            Core.pendingShopData = Core.pendingShopData or {}
            if key then
                Core.pendingShopData[key] = {
                    error = "machineGone"
                }
            end
        else
            sendServerCommand(player, Core.name, Core.commands.openError, {
                key = key,
                message = "machineGone"
            })
        end
        return
    end

    if shop:requiresPower() then
        local key = shop:getKey()
        if Core.isLocal then
            Core.pendingShopData = Core.pendingShopData or {}
            Core.pendingShopData[key] = {
                error = "requiresPower"
            }
        else
            sendServerCommand(player, Core.name, Core.commands.openError, {
                key = key,
                message = "requiresPower"
            })
        end
        Core.debugLn("openShop: shop requires power")
        return
    end

    if shop:requiresRestock() or forceRestock then
        -- restock builds offers, saves, and transmits modData to all clients
        shop:restock()
    end

    local inventoryData = ServerSystem.buildShopPayload(shop)

    if Core.isLocal then
        Core.pendingShopData = Core.pendingShopData or {}
        Core.pendingShopData[inventoryData.key] = inventoryData
    else
        sendServerCommand(player, Core.name, Core.commands.requestShop, {
            playerIndex = player:getPlayerNum(),
            key = inventoryData.key,
            data = inventoryData
        })
    end

end

function ServerSystem:getLoadedObjects()
    local result = {}
    for i = 1, self:getLuaObjectCount() do
        local obj = self:getLuaObjectByIndex(i)
        if obj and obj.key then
            table.insert(result, obj)
        end
    end
    return result
end

function ServerSystem:closestShopKeysTo(x, y)

    local shops = {}
    for k, v in pairs(Core.shops) do
        if Core.settings["ShopProbability" .. k] > 0 then
            -- set default distance to max per group
            shops[k] = 9999999
        end
    end

    for i = 1, self.system:getObjectCount() do
        local obj = self.system:getObjectByIndex(i)
        if obj then
            local data = obj:getModData()
            local dx = x - obj.x
            local dy = y - obj.y
            local distance = math.sqrt(dx * dx + dy * dy)
            if distance < shops[data.type] then
                shops[data.type] = distance
            end
        end
    end
    return shops

end

-- Returns true if at least one pool in the shop's poolSets passes the zone filter at (x, y).
--
-- Zones only, deliberately: a pool's months gate is not consulted here. A shop
-- is placed once and then stands there through every month that follows, so
-- refusing to place one in November because its seasonal pool is out of season
-- would only make the shop rarer without making it any less empty in January.
-- Seasonal pools are filtered where it can actually change with the calendar,
-- which is buildOffers on each restock.
--
-- `stocksNothing` shops are exempt. A machine whose stock comes from somewhere
-- other than a pool -- players listing their own goods, say -- has no poolSets
-- to offer, and the test below answers "no eligible pool" for an empty list.
-- That is the right answer to the question being asked and the wrong answer to
-- the question that matters: such a shop is never empty for want of a pool, so
-- refusing to place it would keep it out of the world entirely, with no way for
-- an admin to force one in either, since this test survives ignoreDistance.
local function shopHasEligiblePool(shopDef, x, y)
    if shopDef.stocksNothing == true then
        return true
    end
    local fn = Core.poolPassesZoneFilter
    for _, poolSet in ipairs(shopDef.poolSets or {}) do
        for _, poolRef in ipairs(poolSet.keys or {}) do
            local poolKey = type(poolRef) == "table" and poolRef.key or poolRef
            local pool = Core.runtime.pools and Core.runtime.pools[poolKey]
            if pool and (not fn or fn(pool, x, y)) then
                return true
            end
        end
    end
    return false
end

-- returns a random shop key based on x,y location based on its probability
-- it will omit shops that are disabled, whose group/type would be too close to one another,
-- or whose pools are all zone-filtered out at this location
--
-- `ignore` is an instance table to leave out of the spacing measurement, used
-- by a machine asking what it could turn into: it is standing on the spot being
-- filled and should not be spacing itself out of the running.
--- Pick a shop that could stand at x,y.
---
--- `ignore` is one instance to leave out of the spacing measurement, for a
--- machine asking what it could become. `ignoreDistance` drops the spacing test
--- altogether, for an admin who has said they want this shop here regardless;
--- the enabled, probability and eligible-pool tests still apply, since those
--- are about whether the shop can work at all rather than where it sits.
function ServerSystem:getRandomShop(x, y, ignore, ignoreDistance)

    local options, byCategory = Core:getInstanceDistancesFrom(x, y, ignore)
    local candidates = {}

    local shops = Core.shops
    local defaultDistance = Core.settings.DefaultDistance or 200
    local totalProbability = 0
    -- remove options that are too close or have no eligible pools at this location
    for k, v in pairs(options) do
        local shopDef = shops[k]
        local probability = shopDef and (shopDef.probability or 1) or 0
        if shopDef and shopDef.enabled ~= false and probability > 0 then
            local minDist = shopDef.minDistance or defaultDistance
            -- Against the nearest of its own type, and against the nearest of
            -- anything sharing its category. The category test is the stricter
            -- of the two whenever a shop has one, since a machine of the same
            -- type is also of the same category; a shop without a category
            -- falls back to the type test alone, which is what every shop used
            -- to get.
            local catDist = shopDef.category and byCategory[shopDef.category] or 9999999
            local farEnough = ignoreDistance == true or (minDist <= v and minDist <= catDist)
            if farEnough and shopHasEligiblePool(shopDef, x, y) then
                table.insert(candidates, {
                    shop = k,
                    p = probability
                })
                totalProbability = totalProbability + probability
            end
        end
    end

    if #candidates == 0 then
        return nil
    end

    local r = ZombRand(totalProbability) + 1
    local sum = 0
    for _, v in ipairs(candidates) do
        sum = sum + v.p
        if sum >= r then
            return v.shop
        end
    end

end

function ServerSystem:getShopList()
    local shops = {}
    for k, v in pairs(Core.shops) do
        table.insert(shops, {
            type = k,
            label = Core.shopLabel(k),
            group = v.group or "NONE",
            enabled = v.enabled == false and "false" or "true"
        })
    end
    return shops
end

function ServerSystem:upsertShopDefinition(data)
    self:upsertDefinition(Core.primaryOverride("shops"), "shops", data.type, data)
end

--- Generic upsert: diff against defaults, merge into override file, save, recompile.
--- `defsKey` is the Core.defs key (e.g. "prices", "groups") used to look up the
--- raw default for diffing. Only changed fields are persisted.
function ServerSystem:upsertDefinition(filename, defsKey, key, def)
    local defaults = Core.defs and Core.defs[defsKey] or {}
    local diff = Core.utils.diffTable(defaults[key] or {}, def)
    if not diff then
        return -- nothing changed
    end
    local override = Core.fileUtils.loadTable(filename) or {}
    -- Merge into any existing override entry so two admins editing different
    -- fields of the same definition don't clobber each other.
    override[key] = Core.utils.deepMerge(override[key] or {}, diff)
    Core.fileUtils.saveTable(filename, override)
    self:recompileShops()
end

--- Drop a definition's override entry entirely.
-- Only meaningful for a key that exists solely in the override file: the
-- override layer sits on top of the shipped defaults, so removing the entry for
-- a default-supplied key just restores the shipped version rather than deleting
-- it. Callers are expected to have checked Core.isShippedKey first.
function ServerSystem:deleteDefinition(filename, key)
    local override = Core.fileUtils.loadTable(filename) or {}
    if override[key] == nil then
        return false
    end
    override[key] = nil
    Core.fileUtils.saveTable(filename, override)
    self:recompileShops()
    return true
end

-- Relocate a shop's global object and instance data from old coords to new coords.
--- Preserves shop type, facing, offers, restock time, etc.
function ServerSystem:relocateShop(oldX, oldY, oldZ, newX, newY, newZ)
    local oldObj = self:getLuaObjectAt(oldX, oldY, oldZ)
    if not oldObj then
        Core.debugLn("relocateShop: no object at old coords " .. oldX .. "," .. oldY .. "," .. oldZ)
        return
    end

    -- Already at the new coords (no-op).
    if oldX == newX and oldY == newY and oldZ == newZ then
        return
    end

    -- Snapshot the state we want to carry over.
    local saved = {
        type = oldObj.type,
        facing = oldObj.facing,
        created = oldObj.created,
        lastRestock = oldObj.lastRestock,
        -- Carried like the restock clock. Dropping it would hand the machine a
        -- fresh cycle on every move, so a machine an admin nudges around never
        -- reaches its next reroll.
        lastReroll = oldObj.lastReroll,
        offers = oldObj.offers
    }

    -- Remove the stale global object (also clears instance data).
    self:removeLuaObject(oldObj)

    -- If a global object already exists at the destination (e.g. OnObjectAdded
    -- already fired), just update it.  Otherwise create a fresh one.
    local newObj = self:getLuaObjectAt(newX, newY, newZ)
    if not newObj then
        newObj = self:newLuaObjectAt(newX, newY, newZ)
    end
    if not newObj then
        Core.debugLn("relocateShop: failed to create object at " .. newX .. "," .. newY .. "," .. newZ)
        return
    end

    -- Apply the saved state.
    newObj.type = saved.type
    newObj.facing = saved.facing
    newObj.created = saved.created
    newObj.lastRestock = saved.lastRestock
    newObj.lastReroll = saved.lastReroll
    newObj.offers = saved.offers
    newObj.x = newX
    newObj.y = newY
    newObj.z = newZ

    -- Register new instance data.
    Core:addInstance({
        type = saved.type,
        facing = saved.facing,
        created = saved.created,
        lastRestock = saved.lastRestock,
        lastReroll = saved.lastReroll,
        x = newX,
        y = newY,
        z = newZ
    })

    -- Sync modData on the IsoObject so clients pick up the new coords.
    local iso = newObj:getIsoObject()
    if iso then
        newObj:toModData(iso:getModData())
        iso:transmitModData()
    end

    newObj:updateSprite(true)
    Core.debugLn("relocateShop: moved from " .. oldX .. "," .. oldY .. "," .. oldZ .. " to " .. newX .. "," .. newY ..
                     "," .. newZ)
end

function ServerSystem:checkObjectAdded(obj)
    if not obj or not obj.getSprite then
        return
    end
    local sprite = obj:getSprite()
    if not sprite then
        return
    end
    local customName = sprite:getProperties():get("CustomName")
    local objType = tostring(obj:getType())
    local objName = tostring(obj:getName())
    local spriteName = sprite:getName() or "nil"

    Core.debugLn("checkObjectAdded: sprite=" .. spriteName .. " customName=" .. tostring(customName) .. " objType=" ..
                     objType .. " objName=" .. objName)

    if not customName or not Core.shops[customName] then
        return
    end

    local isValid = self:isValidIsoObject(obj)
    Core.debugLn("checkObjectAdded: isValidIsoObject=" .. tostring(isValid))

    if not isValid then
        self.initializeShopObject(obj)
        Core.debugLn("checkObjectAdded: initialized as PhunMartVendingMachine")
    end

    local x, y, z = obj:getX(), obj:getY(), obj:getZ()
    local existing = self:getLuaObjectAt(x, y, z)
    Core.debugLn("checkObjectAdded: pos=" .. x .. "," .. y .. "," .. z .. " existingLuaObj=" ..
                     tostring(existing ~= nil))

    if not existing then
        -- Check if the object is actually on its square before creating the global object.
        local sq = obj:getSquare()
        local onSquare = false
        if sq then
            local objects = sq:getObjects()
            for i = 0, objects:size() - 1 do
                if objects:get(i) == obj then
                    onSquare = true
                    break
                end
            end
        end
        Core.debugLn("checkObjectAdded: onSquare=" .. tostring(onSquare))

        local luaObj = self:newLuaObjectAt(x, y, z)
        Core.debugLn("checkObjectAdded: newLuaObjectAt result=" .. tostring(luaObj ~= nil))
        if luaObj then
            luaObj:stateFromIsoObject(obj)
            Core.debugLn("checkObjectAdded: stateFromIsoObject completed, type=" .. tostring(luaObj.type))
        end
    end
end

-- One-time in-place upgrade: pre-existing shops from older saves are backed by
-- IsoThumpable (destroyable). Swap the backing iso for a plain IsoObject while
-- preserving offers/lastRestock so the shop keeps its inventory across the swap.
function ServerSystem:upgradeThumpableShop(square, obj)
    local oldData = obj:getModData() or {}
    local saved = {
        created = oldData.created,
        lastRestock = oldData.lastRestock,
        offers = oldData.offers
    }
    local customName = obj:getSprite():getProperties():get("CustomName")
    local facing = obj:getFacing()

    local x, y, z = obj:getX(), obj:getY(), obj:getZ()
    local oldLua = self:getLuaObjectAt(x, y, z)
    if oldLua then
        self:removeLuaObject(oldLua)
    end

    -- Full teardown: transmitRemoveItemFromSquare alone only networks the
    -- removal; the IsoThumpable's physics body and AI blocker stay attached,
    -- so on the next chunk reload the serialized thumpable comes back and a
    -- new physics body stacks on top ("Too many physics objects" error). The
    -- admin Remove Item tool does this 4-step dance for the same reason.
    square:transmitRemoveItemFromSquare(obj)
    square:RemoveTileObject(obj)
    if obj.removeFromWorld then
        obj:removeFromWorld()
    end
    if obj.removeFromSquare then
        obj:removeFromSquare()
    end
    if obj.setSquare then
        obj:setSquare(nil)
    end
    square:RecalcAllWithNeighbours(true)

    ServerSystem.addToWorld(square, customName, facing)

    local newLua = self:getLuaObjectAt(x, y, z)
    if newLua and saved.offers then
        if saved.created then
            newLua.created = saved.created
        end
        newLua.lastRestock = saved.lastRestock
        newLua.offers = saved.offers
        local newIso = newLua:getIsoObject()
        if newIso then
            newLua:toModData(newIso:getModData())
            newIso:transmitModData()
        end
    end

    Core.debugLn("upgradeThumpableShop: " .. tostring(customName) .. " at " .. x .. "," .. y .. "," .. z)
end

function ServerSystem:loadGridsquare(square)

    local objects = square:getObjects()
    local existing = {}
    local candidates = {}
    local convertEnabled = (Core.settings.ChanceToConvert or 0) > 0

    for i = 0, objects:size() - 1 do
        local obj = objects:get(i)
        local sprite = obj:getSprite()
        if sprite and sprite.getProperties then
            local customName = sprite:getProperties():get("CustomName")
            if customName and Core.shops[customName] then
                existing[#existing + 1] = obj
            elseif convertEnabled and Core.targetSprites[sprite:getName()] and not obj:getModData().PhunMart then
                -- Untested vanilla vending machine: eligible for one conversion roll.
                candidates[#candidates + 1] = {
                    obj = obj,
                    sprite = sprite
                }
            end
        end
    end

    -- No sprite here that this build recognises, which is either a machine that
    -- has gone or one that has lost its sprite. reconcileMachineAt tells them
    -- apart and does the opposite thing in each case.
    if #existing == 0 then
        self:reconcileMachineAt(square, objects)
    end

    for _, obj in ipairs(existing) do
        if instanceof(obj, "IsoThumpable") then
            -- Legacy destroyable shop: upgrade in place to a plain IsoObject.
            self:upgradeThumpableShop(square, obj)
        else
            -- PhunMart sprite already IsoObject: ensure backing global
            -- object data. Recovers orphans after a crash/restart.
            self:checkObjectAdded(obj)
        end
    end

    for _, value in ipairs(candidates) do
        local obj = value.obj
        local sprite = value.sprite
        -- Stamp the sentinel so future chunk loads skip this machine even if
        -- the roll below fails. Otherwise we'd re-roll every load.
        obj:getModData().PhunMart = {}
        if ZombRand(100) <= Core.settings.ChanceToConvert then
            local shopname = self:getRandomShop(square:getX(), square:getY())
            if shopname then
                -- Prefer sprite→direction map; getFacing() often disagrees with
                -- the actual tile art on vanilla/modded vending machines.
                local facing = facingToIsoDirection(Core.targetSprites[sprite:getName()] or obj:getFacing())
                square:transmitRemoveItemFromSquare(obj)
                self.addToWorld(square, shopname, facing)
            end
        end
    end

end

function ServerSystem:OnClientCommand(command, playerObj, args)
    if Commands[command] ~= nil then
        Commands[command](playerObj, args)
    end
end

function ServerSystem:recompileShops()
    Core.compile()
    Core.debugLn("Recompiled shop definitions")
    -- Broadcast updated override tables to all connected clients so they recompile.
    if Core._lastOverrides then
        sendServerCommand(Core.name, Core.commands.requestShopDefs, {
            overrides = Core._lastOverrides
        })
    end
end

function ServerSystem:checkObjectRemoved(obj)
    if not obj or not obj.getSprite then
        return
    end
    if not self:isValidIsoObject(obj) then
        return
    end
    local x, y, z = obj:getX(), obj:getY(), obj:getZ()
    local luaObj = self:getLuaObjectAt(x, y, z)
    if luaObj then
        self:removeLuaObject(luaObj)
    else
        -- No global object but may still have instance data from initializeShopObject
        Core:removeInstance({
            x = x,
            y = y,
            z = z
        })
    end
end

SGlobalObjectSystem.RegisterSystemClass(ServerSystem)
