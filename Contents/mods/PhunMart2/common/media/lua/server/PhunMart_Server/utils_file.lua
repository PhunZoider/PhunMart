-- Reading and writing the mod's mutable files.
--
-- These used to be Lua source: saveTable wrote "return { ... }" and loadTable
-- handed the text back to loadstring. B42.20.4 removed loadstring, load and
-- loadfile, so that round trip no longer completes. Nothing errors; loadstring
-- is simply nil, the pcall around it fails, and every override file on disk
-- reads back as nil. An admin's customisations do not come back after a
-- restart, and the next save writes the defaults over the top of them.
--
-- So the format is now JSON, which needs a parser rather than an interpreter.
-- The trade is that a config file can no longer contain Lua expressions. None
-- of ours ever did, but a hand-written one might, and there is no way to read
-- those on the new runtime: see the converter link below.

local json = require "PhunMart/json"

local file_utils = {}

-- Where an admin converts a pre-B42.20.4 config file. The page is format
-- generic and lives in the PhunZones repository because that is where it was
-- first needed; it handles every Phun mod's files, this one included.
local CONVERTER_URL = "https://phunzoider.github.io/PhunZones/converter/"

-- One warning per file per session. Core.compile() re-reads every override file
-- on each recompile, and a recompile happens on every restock, so an
-- unconverted file would otherwise print on a loop for the life of the server.
local warned = {}

--- The pre-JSON name for a config file: PhunMart_Pools.json -> PhunMart_Pools.txt.
--- Only used to notice that an old file is sitting there unconverted.
function file_utils.legacyNameFor(filename)
    return (filename:gsub("%.json$", ".txt"))
end

--- Whole file as one string, or nil if it is not there.
local function readAll(filename, createIfNotExists)
    local reader = getFileReader(filename, createIfNotExists == true)
    if not reader then
        return nil
    end
    local lines = {}
    local line = reader:readLine()
    while line do
        lines[#lines + 1] = line
        line = reader:readLine()
    end
    reader:close()
    return table.concat(lines, "\n")
end

--- Say so, once, if `filename` is absent but its pre-JSON counterpart is not.
---
--- Worth the noise: the alternative is a server that starts cleanly, reports
--- nothing, and quietly ignores every customisation the admin has made.
local function warnIfLegacyPresent(filename)
    if warned[filename] then
        return
    end
    -- Marked before the check rather than after, so a file that has no old
    -- counterpart is probed once rather than on every recompile. An admin who
    -- drops an old file in mid-session is not a case worth reopening for.
    warned[filename] = true

    local legacy = file_utils.legacyNameFor(filename)
    if legacy == filename then
        return
    end
    local contents = readAll(legacy, false)
    if not contents or contents == "" then
        return
    end
    print("[PhunMart] '" .. legacy .. "' is in the old Lua format, which this build cannot read.")
    print("[PhunMart] Convert it to '" .. filename .. "' here: " .. CONVERTER_URL)
    print("[PhunMart] Until then the settings in that file are not being applied.")
end

--- True when an old-format file is present and its JSON replacement is not.
--- Callers that want to report on this rather than act on it use this instead
--- of loadTable, which cannot distinguish "absent" from "unreadable".
function file_utils.needsConversion(filename)
    local legacy = file_utils.legacyNameFor(filename)
    if legacy == filename then
        return false
    end
    local current = readAll(filename, false)
    if current and current ~= "" then
        return false
    end
    local old = readAll(legacy, false)
    return old ~= nil and old ~= ""
end

--- Encode and write `data`, replacing whatever is there.
--- @return true on success, false if nothing was written
function file_utils.saveTable(filename, data)
    if not data then
        return false
    end

    local encoded, err = json.encode(data)
    if not encoded then
        -- Deliberately before getFileWriter. That call truncates on open, so
        -- opening it and then discovering we have nothing to write would
        -- replace a good file with an empty one. The most likely cause is a
        -- non-string table key, which the Lua format allowed and JSON does not.
        print("[PhunMart] refusing to save '" .. filename .. "': " .. tostring(err))
        print("[PhunMart] the file on disk has been left as it was")
        return false
    end

    local writer = getFileWriter(filename, true, false)
    writer:write(encoded)
    writer:close()
    return true
end

--- Decode `filename`, or nil if it is missing, empty or malformed.
---
--- nil for malformed is the same answer as for missing, which is not ideal, but
--- every caller already treats nil as "no overrides" and the alternative is
--- refusing to start. The message on the way out is what makes the difference
--- visible.
function file_utils.loadTable(filename, createIfNotExists)
    local src = readAll(filename, createIfNotExists)
    if not src or src == "" then
        warnIfLegacyPresent(filename)
        return nil
    end

    local result, err = json.decode(src)
    if err then
        print("[PhunMart] could not read '" .. filename .. "': " .. tostring(err))
        print("[PhunMart] its settings are not being applied; the file has not been changed")
        return nil
    end

    -- A JSON file whose top level is a string or a number parses fine and is
    -- still not a config. Callers index the result, so hand back nil rather
    -- than something that errors on first use.
    if type(result) ~= "table" then
        print("[PhunMart] '" .. filename .. "' does not contain a JSON object")
        return nil
    end

    return result
end

local logQueue = {}

function file_utils.log(...)
    file_utils.logTo("Phun.log", ...)
end

function file_utils.logTo(filename, ...)
    Events.EveryOneMinute.Remove(file_utils.doLogs)
    if not logQueue[filename] then
        logQueue[filename] = {}
    end
    local entry = os.date("%Y-%m-%d %H:%M:%S") .. "\t" .. table.concat({...}, "\t")
    table.insert(logQueue[filename], entry)
    Events.EveryOneMinute.Add(file_utils.doLogs)
end

function file_utils.doLogs()
    Events.EveryOneMinute.Remove(file_utils.doLogs)
    for filename, entries in pairs(logQueue) do
        if #entries > 0 then
            file_utils.appendToFile(filename, entries, true)
            logQueue[filename] = {}
        end
    end
end

function file_utils.appendToFile(filename, line, createIfNotExist)
    if not line then
        return
    end
    local ls = {}
    if type(line) == "table" then
        ls = line
    else
        ls[1] = line
    end
    local fileWriterObj = getFileWriter(filename, createIfNotExist ~= false, true)
    for _, l in ipairs(ls) do
        if l and l ~= "" then
            fileWriterObj:write(l .. "\r\n")
        end
    end
    fileWriterObj:close()
end

return file_utils
