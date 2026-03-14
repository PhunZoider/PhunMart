-- loadstring was removed in Lua 5.2+; PZ B42 may only have load()
local loadstring = loadstring or load
local file_utils = {}

local function tableOfStringsToTable(lines)
    if not lines or type(lines) ~= "table" or #lines == 0 then
        return nil, "invalid input: empty or non-table"
    end

    local startsWithReturn = false
    for _, line in ipairs(lines) do
        local trimmed = line:match("^%s*(.-)%s*$")
        if trimmed ~= "" and not trimmed:match("^%-%-") then
            startsWithReturn = trimmed:match("^return") ~= nil
            break
        end
    end

    local src
    if startsWithReturn then
        src = table.concat(lines, "\n")
    else
        src = "return {\n" .. table.concat(lines, "\n") .. "\n}"
    end

    local ok, chunk = pcall(loadstring, src)
    if not ok then
        return nil, "loadstring error: " .. tostring(chunk)
    end

    local ok2, result = pcall(chunk)
    if not ok2 then
        return nil, "execution error: " .. tostring(result)
    end

    return result, nil
end

function file_utils.tableToString(tbl, indent)
    indent = indent or 0
    local prefix = string.rep("  ", indent + 1)
    local result = {}
    local doneKeys = {}

    for i = 1, #tbl do
        local value = tbl[i]
        doneKeys[i] = true
        local line
        if type(value) == "table" then
            line = prefix .. file_utils.tableToString(value, indent + 1)
        elseif type(value) == "string" then
            line = string.format("%s%q", prefix, value)
        else
            line = string.format("%s%s", prefix, tostring(value))
        end
        table.insert(result, line)
    end

    for key, value in pairs(tbl) do
        if not doneKeys[key] then
            local keyStr
            if type(key) == "string" then
                if string.match(key, "^[%a_][%w_]*$") then
                    keyStr = key .. " = "
                else
                    keyStr = string.format("[%q] = ", key)
                end
            else
                keyStr = "[" .. tostring(key) .. "] = "
            end

            local line
            if type(value) == "table" then
                line = prefix .. keyStr .. file_utils.tableToString(value, indent + 1)
            elseif type(value) == "string" then
                line = string.format("%s%s%q", prefix, keyStr, value)
            else
                line = string.format("%s%s%s", prefix, keyStr, tostring(value))
            end
            table.insert(result, line)
        end
    end

    return "{\n" .. table.concat(result, ",\n") .. "\n" .. string.rep("  ", indent) .. "}"
end

function file_utils.saveTable(filename, data)
    if not data then
        return
    end
    local fileWriterObj = getFileWriter(filename, true, false)
    fileWriterObj:write("return " .. file_utils.tableToString(data))
    fileWriterObj:close()
end

function file_utils.loadTable(filename, createIfNotExists)
    local fileReaderObj = getFileReader(filename, createIfNotExists == true)
    if not fileReaderObj then
        return nil
    end

    local lines = {}
    local line = fileReaderObj:readLine()
    while line do
        lines[#lines + 1] = line
        line = fileReaderObj:readLine()
    end
    fileReaderObj:close()

    if #lines == 0 then
        return nil
    end

    if lines[#lines]:sub(-1) == "," then
        lines[#lines] = lines[#lines]:sub(1, -2)
    end

    local result, err = tableOfStringsToTable(lines)
    if err then
        Core.debugLn("file_utils: error loading '" .. filename .. "': " .. err)
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
