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

--- Every machine this client has seen, keyed by its own square. The light is
--- remembered separately as {x, y, z}, because it does not hang on that square.
local known = {}

--- The lamppost burning for a machine, for those that have one.
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

local function ignite(key, where, colour)
    if lit[key] then
        return
    end
    local cell = getCell()
    if not cell then
        return
    end
    local light = IsoLightSource.new(where.x, where.y, where.z, colour.r, colour.g, colour.b, colour.radius)
    cell:addLamppost(light)
    lit[key] = light
    Core.debugLn("light on at " .. keyFor(where.x, where.y, where.z) .. " for the machine at " .. key)
end

--- Put one machine's light where it should be, lit or out.
local function settle(key, at, square, def)
    local colour = lightFor(def)
    if colour and shouldBurn(def, square) then
        ignite(key, at.light, colour)
    else
        extinguish(key)
    end
end

--- Take note of a machine, and light it if it has earned it.
local function remember(isoObject, def)
    local square = isoObject:getSquare()
    if not square then
        return
    end
    local x, y, z = square:getX(), square:getY(), square:getZ()
    local key = keyFor(x, y, z)
    local at = known[key]
    if not at then
        local lx, ly, lz = lightSquare(isoObject, square)
        at = {x = x, y = y, z = z, light = {x = lx, y = ly, z = lz}}
        known[key] = at
    end
    settle(key, at, square, def)
end

local function forget(key)
    known[key] = nil
    extinguish(key)
end

---------------------------------------------------------------------------
-- When to look
---------------------------------------------------------------------------

--- Read a square that has just come in.
---
--- OnObjectAdded covers a machine that appears while somebody is watching it.
--- Squares are read as they arrive as well, because the ordinary way to meet a
--- machine is to walk to one that comes in with its chunk, and reading the same
--- machine twice costs nothing.
local function readSquare(square)
    local machine, def = machineOn(square)
    if machine then
        remember(machine, def)
    end
end

--- Walk everything known.
---
--- Two jobs on the minute. Nothing announces the grid going down, so every
--- light is decided again. And the cell holds a lamppost until it is told
--- otherwise, so a machine whose chunk has unloaded, or that somebody has
--- carried off, would leave one burning over nothing.
local function sweep()
    local cell = getCell()
    if not cell then
        return
    end
    for key, at in pairs(known) do
        local square = cell:getGridSquare(at.x, at.y, at.z)
        local machine, def = machineOn(square)
        if not machine then
            forget(key)
        else
            settle(key, at, square, def)
        end
    end
end

--- Look again at every square already loaded around a player.
---
--- A machine is only recognisable once Core.shops has arrived, and on a client
--- that is a round trip after the world has begun filling in around the player.
--- Neither square event fires a second time for a square that never left, so
--- without this the machines that were already in the chunk map when the
--- definitions landed stay dark until their chunks have been away and come
--- back. The bounds are the chunk map's own, so this is exactly what is loaded
--- and no more; a machine on another floor waits for its chunk.
local function rescan()
    local cell = getCell()
    if not cell then
        return
    end
    for i = 0, getNumActivePlayers() - 1 do
        local player = getSpecificPlayer(i)
        local chunkMap = player and cell:getChunkMap(player:getPlayerNum())
        if chunkMap then
            local z = math.floor(player:getZ())
            for x = chunkMap:getWorldXMinTiles(), chunkMap:getWorldXMaxTiles() do
                for y = chunkMap:getWorldYMinTiles(), chunkMap:getWorldYMaxTiles() do
                    readSquare(cell:getGridSquare(x, y, z))
                end
            end
        end
    end
end

--- Both halves of a chunk arriving. The engine raises LoadGridsquare for a
--- square it has just made and ReuseGridsquare for one it has taken back off
--- its own pile, and once a player has moved about for a while it is almost
--- always the second. Listening only to the first lit the machines somebody
--- built while watching, and left every machine that was already standing
--- there dark.
Events.LoadGridsquare.Add(readSquare)
Events.ReuseGridsquare.Add(readSquare)

Events.OnObjectAdded.Add(function(isoObject)
    local def = shopOf(isoObject)
    if def then
        remember(isoObject, def)
    end
end)

Events.OnObjectAboutToBeRemoved.Add(function(isoObject)
    if not shopOf(isoObject) then
        return
    end
    local square = isoObject:getSquare()
    if square then
        forget(keyFor(square:getX(), square:getY(), square:getZ()))
    end
end)

Events.EveryOneMinute.Add(sweep)

--- Colour, reach and the power requirement all come off the definitions, and
--- this is the moment they land or change. Everything burning is put out first,
--- because ignite will not touch a light that is already lit and so would keep
--- an old colour alive; the sweep then decides them all again.
Events[Core.events.OnDefsUpdated].Add(function()
    for key in pairs(known) do
        extinguish(key)
    end
    sweep()
    rescan()
end)
