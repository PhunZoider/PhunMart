if isServer() then
    return
end

-- The 3D face of a machine.
--
-- Every machine is drawn with the one shared vending machine model, wearing its shop's wrap
-- texture (media/textures/phunmart/*.png; the layout is Tools/blender/vending_layout.py). The
-- tile underneath stays as it is: it still says which way the machine faces, still makes the
-- square solid, and is what shows if the model is switched off or cannot be built.
--
-- A machine is in one of three states, and each has its own shader:
--   powered  needs power and has it    the texture's glow mask at full brightness
--   soft     needs no power            the same areas, softer, so the two can be told apart
--   off      needs power, has none     no glow; the lit areas dimmed and greyed
--
-- IsoObject:setSpriteModelName points one object at a named sprite model, overriding whatever
-- its tile would show. Those are built here, one per shop, state and facing, the first time a
-- machine needs one, and handed to the ScriptManager the way the engine registers the
-- spriteModels.txt entries itself. A shop def only has to name a texture.
--
-- B42 draws most objects once into a low-resolution chunk texture and only a few live every
-- frame, which is why a machine looked sharp only while selected. setAnimating(true) puts it in
-- the live layer; nothing but the renderer reads the flag. It costs one model draw per machine
-- on screen per frame, so players can turn it off.
--
-- When to look is lights.lua's business: it already meets every machine as its square loads,
-- asks the powered ones again every minute and starts over when the definitions change. It
-- calls Looks.settle with the state it decided, so the face and the light never disagree.
--
-- All of this is client side. The server never draws anything, and every client works out the
-- same face from the same definitions.

local Core = PhunMart

local Looks = {}
Core.looks = Looks

local LOG = "[PhunMart] "

local MODELS = {
    powered = "PhunMart.VendingPowered",
    soft = "PhunMart.VendingSoft",
    off = "PhunMart.VendingOff"
}

--- Tile Facing -> the model's turn about its vertical axis. At 0 the model faces north.
local ROTATE = {
    E = -90,
    S = 180,
    W = 90,
    N = 0
}

---------------------------------------------------------------------------
-- Player options
---------------------------------------------------------------------------

-- Under Options > Mods, saved per player on their own machine.
local options = PZAPI.ModOptions:create("PhunMart", getText("IGUI_PhunMart_Opt_Title"))
options:addTickBox("models3D", getText("IGUI_PhunMart_Opt_Models"), true, getText("IGUI_PhunMart_Opt_Models_tooltip"))
options:addTickBox("liveRender", getText("IGUI_PhunMart_Opt_Live"), true, getText("IGUI_PhunMart_Opt_Live_tooltip"))
-- The game reads saved values only when it builds the options screen, which can be before
-- this file has run. Reading them here too only fills in options that already exist.
PZAPI.ModOptions:load()

local function option(id)
    local o = options:getOption(id)
    return o == nil or o:getValue() ~= false
end

---------------------------------------------------------------------------
-- Textures and sprite models
---------------------------------------------------------------------------

--- Every model built this session, by name. Names carry a generation that moves on when the
--- definitions change, because a registered model cannot be changed and a shop's texture can.
local built = {}
local generation = 1

--- A shop's wrap texture as a path under media/, or false when it has none.
local textureCache = {}

--- Machine textures live in media/textures/phunmart/, and a shop def names one
--- relative to it, extension optional: "good-phoods". A mod adds its own by
--- shipping media/textures/phunmart/<name>.png. A name with a folder in it is
--- read from media/textures/ instead, and one starting media/ as it stands, so
--- a texture kept elsewhere can still be named.
local FOLDER = "media/textures/phunmart/"

local function texturePath(name)
    if name:sub(1, 6) == "media/" then
        -- as it stands
    elseif name:find("/", 1, true) then
        name = "media/textures/" .. name
    else
        name = FOLDER .. name
    end
    if not name:lower():match("%.png$") then
        name = name .. ".png"
    end
    return name
end

--- The name a shop def would use for a texture path: the reverse of texturePath.
function Looks.shortName(path)
    if path:sub(1, #FOLDER) == FOLDER then
        return path:sub(#FOLDER + 1):gsub("%.png$", "")
    end
    return (path:gsub("^media/textures/", ""))
end

--- The full path for a texture named the way a shop def names one, if the file
--- exists. For the admin editor, so a typo is caught where it is typed.
function Looks.findTexture(name)
    local path = name and name ~= "" and texturePath(name)
    return path and getTexture(path) and path or nil
end

--- The texture a shop's machines wear: its own `texture`, or else the wrap texture made from
--- its UI background (machine-good-phoods.png -> good-phoods). Missing files mean
--- no model, and the machine keeps its tile.
local function textureFor(def)
    local cached = textureCache[def.key]
    if cached ~= nil then
        return cached or nil
    end
    local wanted = def.texture
    if not wanted and def.background then
        wanted = def.background:gsub("^machine%-", ""):gsub("%.png$", "")
    end
    local path = wanted and texturePath(wanted)
    if path and not getTexture(path) then
        print(LOG .. "shop " .. tostring(def.key) .. " names texture " .. path .. " but there is no such file")
        path = nil
    end
    textureCache[def.key] = path or false
    return path
end

--- The shop's wrap texture as a path, or nil. Also what the shop window draws its background
--- from (ui/shop/shop_main.lua), so a machine needs only the one picture.
Looks.textureFor = textureFor

--- Every machine texture worth offering in a dropdown, by short name, sorted: the
--- ones the shops wear plus the registered ones (Core.machineTextures). Only
--- names whose file is really there.
function Looks.textureOptions()
    local seen, out = {}, {}
    local function offer(name)
        if name and not seen[name] and Looks.findTexture(name) then
            seen[name] = true
            table.insert(out, name)
        end
    end
    for _, def in pairs(Core.shops or {}) do
        local path = textureFor(def)
        offer(path and Looks.shortName(path))
    end
    for _, name in ipairs(Core.machineTextures or {}) do
        offer(name)
    end
    table.sort(out)
    return out
end

--- The front of the machine in a wrap texture, in pixels: the shop window's background. Must
--- match FRONT in Tools/blender/vending_layout.py.
Looks.FRONT = {
    x = 0,
    y = 0,
    w = 512,
    h = 1024
}

local function modelName(def, state, facing)
    local key = tostring(def.key):gsub("[^%w]", "_")
    return "Look_" .. key .. "_" .. state .. "_" .. facing .. "_" .. generation
end

--- Builds the named sprite model unless it already exists. Answers its full name, or nil.
local function ensure(def, state, facing)
    local name = modelName(def, state, facing)
    local full = "PhunMart." .. name
    if built[name] then
        return full
    end
    local texture = textureFor(def)
    if not texture then
        return nil
    end
    local body = string.format("spriteModel %s\n{\n    modelScript = %s,\n    texture = %s,\n" ..
                                   "    translate = 0.0 0.0 0.0,\n    rotate = 0.0 %d.0 0.0,\n    scale = 1.0,\n}\n",
        name, MODELS[state], texture, ROTATE[facing])
    local ok, err = pcall(function()
        local manager = getScriptManager()
        local sm = SpriteModel.new()
        sm:Load(name, body)
        sm:setModule(manager:getModule("PhunMart"))
        sm:InitLoadPP(name)
        manager:addSpriteModel(sm)
    end)
    if not ok then
        print(LOG .. "could not build sprite model " .. name .. ": " .. tostring(err))
        return nil
    end
    built[name] = true
    return full
end

---------------------------------------------------------------------------
-- Dressing a machine
---------------------------------------------------------------------------

--- What each machine was last dressed in, by square, so a sweep that changes nothing does not
--- throw its chunk out of the cache every minute.
local dressed = {}

local function redraw(isoObject)
    pcall(function()
        isoObject:invalidateRenderChunkLevel(FBORenderChunk.DIRTY_REDRAW)
    end)
end

local function dress(key, isoObject, name, live)
    local was = dressed[key]
    if was and was.name == name and was.live == live and was.object == isoObject then
        return
    end
    isoObject:setSpriteModelName(name)
    isoObject:setAnimating(live)
    redraw(isoObject)
    dressed[key] = {
        name = name,
        live = live,
        object = isoObject
    }
end

--- Puts the right face on one machine. `key` is the machine's square, as lights.lua keys it;
--- `state` is "powered", "soft" or "off".
function Looks.settle(key, isoObject, def, state)
    local props = isoObject:getSprite() and isoObject:getSprite():getProperties()
    local facing = props and props:get("Facing")
    local name = option("models3D") and ROTATE[facing] ~= nil and ensure(def, state, facing) or nil
    dress(key, isoObject, name, name ~= nil and option("liveRender"))
end

--- The machine on `key` has gone; nothing to undo on an object that no longer exists.
function Looks.forget(key)
    dressed[key] = nil
end

--- Definitions changed: textures may have, so models are rebuilt under new names as machines
--- are settled again.
function Looks.reset()
    generation = generation + 1
    textureCache = {}
    dressed = {}
end

---------------------------------------------------------------------------
-- Previews
---------------------------------------------------------------------------

--- A sprite model wearing texture `name`, for a preview, or nil when there is no
--- such file. Built and cached like a shop's, under a key of its own.
function Looks.previewSpriteModel(name, state)
    if not name or name == "" or not Looks.findTexture(name) then
        return nil
    end
    local def = {
        key = "Preview_" .. tostring(name),
        texture = name
    }
    local full = ensure(def, state or "powered", "N")
    return full and getScriptManager():getSpriteModel(full) or nil
end

--- Show the machine wearing texture `name` in an ISUI3DScene (nil shows nothing).
--- Sets the scene up the first time: no grid, a three-quarter view, the machine
--- stood at the centre. Drag turns it and the wheel zooms, since a preview is
--- for looking at it from the side you are unsure about.
---
--- Drawn in the scene's sprite-model-editor mode, as vanilla's editor draws tile
--- models: without it the scene mirrors the model left to right, which also
--- turns its faces inside out, so it shows the inside of the back. The mode also
--- scales by 1.5, which the framing below allows for.
---
--- Framing: the view is orthographic and shows panelHeight * 1366 / panelWidth
--- / zoomMult scene units top to bottom, zoomMult = e^(0.2 * zoom) * 87.9. For a
--- panel about 110 x 80 at zoom 9 that is ~3.8 units, which the 1.5x machine
--- (2.82 tall) fills about three quarters of.
local PREVIEW_ZOOM = 9
local PREVIEW_SCALE = 1.5
function Looks.showInScene(scene, name)
    local js = scene and scene.javaObject
    if not js then
        return
    end
    if not scene.phunMartReady then
        scene.phunMartReady = true
        scene.rotX, scene.rotY, scene.zoom = 15, 210, PREVIEW_ZOOM
        js:fromLua1("setDrawGrid", false)
        js:fromLua1("setView", "UserDefined")
        js:fromLua3("setViewRotation", scene.rotX, scene.rotY, 0)
        js:fromLua1("setMaxZoom", 14)
        js:fromLua1("setZoom", scene.zoom)
        js:fromLua2("createModel", "machine", MODELS.powered)
        js:fromLua2("setModelSpriteModelEditor", "machine", true)
        -- The model stands on its origin; lower it by half its scaled height so
        -- the view centres on it.
        js:fromLua4("setObjectPosition", "machine", 0, -1.88 * PREVIEW_SCALE / 2, 0)
        scene.onMouseDown = function(p, mx, my)
            p.dragX, p.dragY, p.rotX0, p.rotY0 = mx, my, p.rotX, p.rotY
        end
        scene.onMouseUp = function(p)
            p.dragX = nil
        end
        scene.onMouseMoveOutside = function(p)
            p.dragX = nil
        end
        scene.onMouseMove = function(p)
            if p.dragX then
                p.rotY = p.rotY0 + (p:getMouseX() - p.dragX) * 0.5
                p.rotX = p.rotX0 - (p:getMouseY() - p.dragY) * 0.5
                p.javaObject:fromLua3("setViewRotation", p.rotX, p.rotY, 0)
            end
        end
        scene.onMouseWheel = function(p, del)
            p.zoom = math.max(1, math.min(14, p.zoom - del))
            p.javaObject:fromLua1("setZoom", p.zoom)
            return true
        end
    end
    local sm = Looks.previewSpriteModel(name)
    js:fromLua2("setModelSpriteModel", "machine", sm)
    js:fromLua2("setObjectVisible", "machine", sm ~= nil)
end

function options:apply()
    -- Every machine is dressed again on the next sweep, under the new choices.
    dressed = {}
    if Core.lights and Core.lights.resettle then
        Core.lights.resettle()
    end
end

return Looks
