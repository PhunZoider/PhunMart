-- Makes plain Lua 5.1 (LuaJIT) resemble the Project Zomboid B42.20.4 runtime
-- closely enough to be worth testing against.
--
-- Two jobs: take away what PZ does not give us, and stand in for the engine
-- globals the mod calls. The first half is the point. Testing against a richer
-- Lua than the game has is how a change passes here and fails there.

local harness = {}

---------------------------------------------------------------------------
-- Taken away
---------------------------------------------------------------------------

-- B42.20.4 removed these, which is the whole reason the config format moved to
-- JSON. Anything that reaches for them again should fail here, loudly, rather
-- than work on this machine and be nil in the game.
local REMOVED = {"loadstring", "load", "loadfile", "dofile",
                 -- Not available to mod code either. pairs and ipairs are
                 -- built on next below the C boundary, so they keep working;
                 -- a direct call to next does not.
                 "next"}

function harness.strip()
    for _, name in ipairs(REMOVED) do
        _G[name] = function()
            error("'" .. name .. "' is not available in PZ B42.20.4", 2)
        end
    end
end

---------------------------------------------------------------------------
-- Stood in for
---------------------------------------------------------------------------

-- An in-memory stand-in for the Zomboid/Lua folder, so a test can write a file
-- and read it back the way the mod does, without touching a real disk.
harness.files = {}

local function makeWriter(name, append)
    if not append then
        harness.files[name] = ""
    elseif harness.files[name] == nil then
        harness.files[name] = ""
    end
    local w = {}
    function w:write(text)
        harness.files[name] = harness.files[name] .. tostring(text)
    end
    function w:close()
    end
    return w
end

local function makeReader(name)
    local contents = harness.files[name]
    if contents == nil then
        return nil
    end
    -- PZ hands back one line at a time with the newline stripped, which is why
    -- readAll joins with "\n" rather than expecting the separators to survive.
    local lines, pos = {}, 1
    if contents ~= "" then
        for line in (contents .. "\n"):gmatch("([^\n]*)\n") do
            lines[#lines + 1] = line
        end
        -- A trailing newline produces one empty entry; drop it.
        if #lines > 0 and lines[#lines] == "" and contents:sub(-1) ~= "\n" then
            lines[#lines] = nil
        end
    end
    local r = {}
    function r:readLine()
        local line = lines[pos]
        pos = pos + 1
        return line
    end
    function r:close()
    end
    return r
end

function harness.installGlobals()
    _G.getFileWriter = function(name, createIfNotExist, append)
        return makeWriter(name, append == true)
    end

    _G.getFileReader = function(name, createIfNotExist)
        if harness.files[name] == nil then
            if createIfNotExist then
                harness.files[name] = ""
            else
                return nil
            end
        end
        return makeReader(name)
    end

    _G.isClient = function() return false end
    _G.isServer = function() return false end
    _G.isCoopHost = function() return false end

    _G.Events = setmetatable({}, {
        __index = function(t, k)
            local slot = {Add = function() end, Remove = function() end}
            rawset(t, k, slot)
            return slot
        end
    })

    _G.getTextOrNull = function() return nil end
    _G.getText = function(k) return k end
end

function harness.reset()
    harness.files = {}
end

---------------------------------------------------------------------------
-- Comparing
---------------------------------------------------------------------------

--- Deep equality, reporting the path to the first difference.
function harness.deepEqual(a, b, path)
    path = path or "root"
    if type(a) ~= type(b) then
        return false, path .. ": type " .. type(a) .. " vs " .. type(b)
    end
    if type(a) ~= "table" then
        if a ~= b then
            return false, path .. ": " .. tostring(a) .. " vs " .. tostring(b)
        end
        return true
    end
    for k, v in pairs(a) do
        local ok, why = harness.deepEqual(v, b[k], path .. "." .. tostring(k))
        if not ok then
            return false, why
        end
    end
    for k in pairs(b) do
        if a[k] == nil then
            return false, path .. "." .. tostring(k) .. ": missing on the left"
        end
    end
    return true
end

return harness
