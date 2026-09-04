if isServer() then
    return
end

-- The glow on a machine's face.
--
-- A machine burns whenever it is working. Most shops need no mains, so most
-- machines are lit through a blackout; a shop that declares powered = true is
-- lit only while its square has power, decided by the same test that chooses
-- between its two faces, so the light and the sprite never disagree about
-- whether the thing is running.
--
-- The light is a lamppost on the cell rather than a property on the sprite. The
-- engine will build a light out of LightRadius and lightR/G/B, which is how a
-- vanilla vending machine glows, but it decides that when the world loads the
-- object and it gates the result on mains power. These are built with
-- IsoObject.new long after the world has loaded, and a machine that ignores the
-- grid wants a light that ignores it too. The tiledefs carried those properties
-- for years and lit nothing, which is the proof; they have been taken off, and
-- this file owns the whole of it.
--
-- Finding the machines is the registry's job rather than the world's.
-- ClientSystem is a CGlobalObjectSystem, so the engine already keeps a list of
-- every machine there is and hands it over whether or not the chunk it stands
-- in is loaded. Walking that list is the only approach that does not depend on
-- catching a square at the moment it arrives, and catching squares is a bad
-- bet: a chunk raises one of two different events depending on whether the
-- engine made the square or took it back off its own pile, a machine's sprite
-- is not always resolvable at that moment, and a machine that was already in
-- the world when the shop definitions reached this client gets no event at all.
--
-- Every client does this for itself. A lamppost is a fact about rendering, it
-- is never sent anywhere, and there is nothing here to keep in step between
-- players.

local Core = PhunMart

--- What a machine burns with when its shop says nothing: a warm white, against
--- a night the game paints blue, at the two tiles vanilla gives a vending
--- machine.
local DEFAULT_LIGHT = {r = 255, g = 214, b = 170, radius = 2}

--- Which way a tile faces, in squares.
---
--- A lamppost is a point and the engine has no cone to aim, so the closest
--- thing to a directional machine is to hang its light on the square in front
--- of it rather than on the machine. The glow then lands on the ground the
--- glass is facing, and the machine, being solid, shades its own back.
local AHEAD = {
    N = {x = 0, y = -1},
    S = {x = 0, y = 1},
    E = {x = 1, y = 0},
    W = {x = -1, y = 0}
}

-- How far in front to hang it. Zero puts the light back on the machine.
local AHEAD_TILES = 1

--- The lamppost burning for a machine, keyed by the machine's own square.
local lit = {}

local function keyFor(x, y, z)
    return x .. "," .. y .. "," .. z
end

---------------------------------------------------------------------------
-- Recognising a machine
---------------------------------------------------------------------------

local function propsOf(isoObject)
    local sprite = isoObject and isoObject:getSprite()
    return sprite and sprite:getProperties() or nil
end

--- The shop an object is a machine for, if it is one.
---
--- Asked of the sprite rather than of the object's name, the same way
--- ClientSystem:checkObjectAdded asks it. A machine is named
--- PhunMartVendingMachine only once that handler has been past, and that can be
--- after this one has, while CustomName is on the sprite from the moment it is
--- drawn -- on the unpowered faces as well, so it answers the same for a
--- machine in either state.
local function shopOf(isoObject)
    local props = propsOf(isoObject)
    local name = props and props:get("CustomName")
    if not name or not Core.shops then
        return nil
    end
    return Core.shops[name]
end

--- The machine standing on a square, and the shop it belongs to.
local function machineOn(square)
    local objects = square and square:getObjects()
    if not objects then
        return nil
    end
    for i = 0, objects:size() - 1 do
        local object = objects:get(i)
        local def = shopOf(object)
        if def then
            return object, def
        end
    end
    return nil
end

--- The square a machine's light should hang over.
---
--- The direction comes off the sprite rather than off the object, because the
--- sprite is what is actually being looked at, and a machine that swaps to its
--- unpowered face keeps the same Facing. A sprite without one, which would mean
--- a shop pointed at art that does not declare which way it stands, leaves the
--- light on the machine.
local function lightSquare(isoObject, square)
    local x, y, z = square:getX(), square:getY(), square:getZ()
    local props = propsOf(isoObject)
    local ahead = props and AHEAD[props:get("Facing")]
    if not ahead then
        return x, y, z
    end
    return x + ahead.x * AHEAD_TILES, y + ahead.y * AHEAD_TILES, z
end

---------------------------------------------------------------------------
-- Deciding, lighting, putting out
---------------------------------------------------------------------------

--- What a shop's machines burn with, or nil for a shop that wants no light.
---
--- A definition says it in 0..255, which is how somebody picking a colour
--- thinks about it and how the sprite properties used to say it. Divided down
--- here, because a light source wants 0..1.
local function lightFor(def)
    if def.light == false then
        return nil
    end
    local wanted = def.light or DEFAULT_LIGHT
    return {
        r = (wanted.r or DEFAULT_LIGHT.r) / 255,
        g = (wanted.g or DEFAULT_LIGHT.g) / 255,
        b = (wanted.b or DEFAULT_LIGHT.b) / 255,
        radius = wanted.radius or DEFAULT_LIGHT.radius
    }
end

--- Whether a machine on this square should be burning.
---
--- The powered branch is worded to match ServerObject:hasElectricity, which is
--- what picks the sprite. A machine wearing its unpowered face and glowing
--- anyway would be worse than no light at all.
local function shouldBurn(def, square)
    if def.powered ~= true then
        return true
    end
    if square:haveElectricity() then
        return true
    end
    local grace = SandboxVars.ElecShutModifier
    return grace ~= nil and grace > -1 and GameTime:getInstance():getNightsSurvived() < grace
end

local function extinguish(key)
    local light = lit[key]
    if not light then
        return
    end
    local cell = getCell()
    if cell then
        cell:removeLamppost(light)
    end
    lit[key] = nil
    Core.debugLn("light out for the machine at " .. key)
end

local function ignite(key, x, y, z, colour)
    if lit[key] then
        return
    end
    local cell = getCell()
    if not cell then
        return
    end
    local light = IsoLightSource.new(x, y, z, colour.r, colour.g, colour.b, colour.radius)
    cell:addLamppost(light)
    lit[key] = light
    Core.debugLn("light on at " .. keyFor(x, y, z) .. " for the machine at " .. key)
end

--- Put the light for the machine on one square where it should be.
---
--- `shopKey` is what the registry says is standing here, and is only consulted
--- when the sprite could not say for itself. That happens to a machine wearing
--- a sprite this build cannot resolve, which has no properties to read at all
--- -- the same state the server repairs on load, and common enough there that
--- it prints an explanation when it does.
local function settleAt(x, y, z, shopKey)
    local key = keyFor(x, y, z)
    local cell = getCell()
    local square = cell and cell:getGridSquare(x, y, z)
    local object, def = machineOn(square)
    if not object and shopKey then
        local system = Core.ClientSystem and Core.ClientSystem.instance
        -- Asks by the name the client puts on a machine when it arrives, which
        -- outlives a sprite going missing.
        local standing = system and system:getIsoObjectOnSquare(square)
        local shop = Core.shops and Core.shops[shopKey]
        if standing and shop then
            object, def = standing, shop
        end
    end
    if not object then
        -- Either the square is not loaded or what stood on it has gone, and a
        -- lamppost burning over nothing is the same mistake either way.
        extinguish(key)
        return
    end
    local colour = lightFor(def)
    if not colour or not shouldBurn(def, square) then
        extinguish(key)
        return
    end
    local lx, ly, lz = lightSquare(object, square)
    ignite(key, lx, ly, lz, colour)
end

---------------------------------------------------------------------------
-- When to look
---------------------------------------------------------------------------

--- Walk every machine the engine knows about.
---
--- This is what actually gets a machine lit. It also re-decides the ones that
--- are: nothing announces the grid going down, and the cell holds a lamppost
--- until it is told otherwise, so one whose chunk has unloaded has to be put
--- out from here.
local function sweep()
    local system = Core.ClientSystem and Core.ClientSystem.instance
    -- Answers false, not zero, until the system is up.
    local count = system and system:getLuaObjectCount()
    if not count then
        return
    end

    local seen = {}
    for i = 1, count do
        local machine = system:getLuaObjectByIndex(i)
        if machine and machine.x and machine.y and machine.z then
            seen[keyFor(machine.x, machine.y, machine.z)] = true
            settleAt(machine.x, machine.y, machine.z, machine.type)
        end
    end

    -- A machine carried off while its square was unloaded leaves the registry
    -- without ever passing through the loop above, and its lamppost with it.
    for key in pairs(lit) do
        if not seen[key] then
            extinguish(key)
        end
    end
end

--- A square that has just arrived, read in case it is carrying a machine.
---
--- Not the mechanism, only a head start: the sweep is what guarantees a machine
--- is lit, and this spares it the wait when a chunk turns up with one on it.
--- Both events are wanted, because the engine raises LoadGridsquare for a
--- square it has just made and ReuseGridsquare for one it has taken back off
--- its own pile.
local function readSquare(square)
    if machineOn(square) then
        settleAt(square:getX(), square:getY(), square:getZ())
    end
end

Events.LoadGridsquare.Add(readSquare)
Events.ReuseGridsquare.Add(readSquare)

Events.OnObjectAdded.Add(function(isoObject)
    local square = shopOf(isoObject) and isoObject:getSquare()
    if square then
        settleAt(square:getX(), square:getY(), square:getZ())
    end
end)

Events.OnObjectAboutToBeRemoved.Add(function(isoObject)
    local square = shopOf(isoObject) and isoObject:getSquare()
    if square then
        extinguish(keyFor(square:getX(), square:getY(), square:getZ()))
    end
end)

Events.EveryOneMinute.Add(sweep)

--- Colour, reach and the power requirement all come off the definitions, and
--- this is the moment they land or change. Everything burning is put out first,
--- because ignite will not touch a light that is already lit and so would keep
--- an old colour alive; the sweep then decides them all again.
Events[Core.events.OnDefsUpdated].Add(function()
    for key in pairs(lit) do
        extinguish(key)
    end
    sweep()
end)
