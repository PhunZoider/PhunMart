local json = {}

local function escapeString(value)
    local escapes = {
        ['\\'] = '\\\\',
        ['"'] = '\\"',
        ['\b'] = '\\b',
        ['\f'] = '\\f',
        ['\n'] = '\\n',
        ['\r'] = '\\r',
        ['\t'] = '\\t'
    }
    return '"' .. value:gsub('[%z\1-\31\\"]', function(char)
        return escapes[char] or string.format('\\u%04x', string.byte(char))
    end) .. '"'
end

local function isArray(value)
    local count = 0
    for key in pairs(value) do
        if type(key) ~= 'number' or key < 1 or key ~= math.floor(key) then
            return false, 0
        end
        count = count + 1
    end
    for index = 1, count do
        if value[index] == nil then
            return false, 0
        end
    end
    return true, count
end

local function encodeValue(value, stack)
    local valueType = type(value)
    if value == nil then
        return 'null'
    elseif valueType == 'boolean' then
        return value and 'true' or 'false'
    elseif valueType == 'number' then
        if value ~= value or value == math.huge or value == -math.huge then
            error('cannot encode NaN or infinity')
        end
        return tostring(value)
    elseif valueType == 'string' then
        return escapeString(value)
    elseif valueType ~= 'table' then
        error('cannot encode ' .. valueType)
    end

    if stack[value] then
        error('cannot encode a circular table')
    end
    stack[value] = true

    local array, count = isArray(value)
    local result = {}
    if array then
        for index = 1, count do
            result[index] = encodeValue(value[index], stack)
        end
        stack[value] = nil
        return '[' .. table.concat(result, ',') .. ']'
    end

    for key, item in pairs(value) do
        if type(key) ~= 'string' then
            error('object keys must be strings')
        end
        result[#result + 1] = escapeString(key) .. ':' .. encodeValue(item, stack)
    end
    stack[value] = nil
    return '{' .. table.concat(result, ',') .. '}'
end

function json.encode(value)
    local ok, result = pcall(encodeValue, value, {})
    if not ok then
        return nil, result
    end
    return result, nil
end

local function decodeError(message, position)
    error(message .. ' at character ' .. tostring(position))
end

local function decoder(source)
    local position = 1
    local length = #source

    local function skipWhitespace()
        while position <= length and source:sub(position, position):match('%s') do
            position = position + 1
        end
    end

    local parseValue

    local function parseString()
        position = position + 1
        local result = {}
        while position <= length do
            local char = source:sub(position, position)
            position = position + 1
            if char == '"' then
                return table.concat(result)
            elseif char == '\\' then
                local escaped = source:sub(position, position)
                position = position + 1
                local replacements = { ['"'] = '"', ['\\'] = '\\', ['/'] = '/', b = '\b', f = '\f', n = '\n', r = '\r', t = '\t' }
                if replacements[escaped] then
                    result[#result + 1] = replacements[escaped]
                elseif escaped == 'u' then
                    local hex = source:sub(position, position + 3)
                    if not hex:match('^%x%x%x%x$') then
                        decodeError('invalid unicode escape', position)
                    end
                    local code = tonumber(hex, 16)
                    position = position + 4
                    if code < 128 then
                        result[#result + 1] = string.char(code)
                    elseif code < 2048 then
                        result[#result + 1] = string.char(192 + math.floor(code / 64), 128 + code % 64)
                    else
                        result[#result + 1] = string.char(224 + math.floor(code / 4096), 128 + math.floor(code / 64) % 64, 128 + code % 64)
                    end
                else
                    decodeError('invalid string escape', position - 1)
                end
            else
                if string.byte(char) < 32 then
                    decodeError('control character in string', position - 1)
                end
                result[#result + 1] = char
            end
        end
        decodeError('unterminated string', position)
    end

    local function parseNumber()
        local start = position
        -- Scan to the end of the number, then let tonumber judge it.
        --
        -- This was a PCRE pattern: '^-?(?:0|[1-9]%d*)(?:%.%d+)?(?:[eE][+-]?%d+)?'.
        -- Lua patterns have no alternation and no non-capturing groups, so Lua
        -- read "(?" as a capture whose first item is a literal question mark.
        -- The pattern therefore demanded a "?" where the digits were and could
        -- never match a number at all, which meant every JSON file carrying one
        -- failed to decode. The failure was invisible: json.decode pcalls the
        -- decoder and returns nil plus a message, loadTable prints it and
        -- returns nil, so a saved config was silently thrown away on load.
        local finish = source:find('[^%-%+%d%.eE]', position) or (length + 1)
        local token = source:sub(position, finish - 1)
        local value = tonumber(token)
        if not value then
            decodeError('invalid number', start)
        end
        position = finish
        return value
    end

    local function parseArray()
        position = position + 1
        local result = {}
        skipWhitespace()
        if source:sub(position, position) == ']' then
            position = position + 1
            return result
        end
        while true do
            result[#result + 1] = parseValue()
            skipWhitespace()
            local char = source:sub(position, position)
            position = position + 1
            if char == ']' then
                return result
            elseif char ~= ',' then
                decodeError("expected ',' or ']'", position - 1)
            end
            skipWhitespace()
        end
    end

    local function parseObject()
        position = position + 1
        local result = {}
        skipWhitespace()
        if source:sub(position, position) == '}' then
            position = position + 1
            return result
        end
        while true do
            if source:sub(position, position) ~= '"' then
                decodeError('object key must be a string', position)
            end
            local key = parseString()
            skipWhitespace()
            if source:sub(position, position) ~= ':' then
                decodeError("expected ':'", position)
            end
            position = position + 1
            result[key] = parseValue()
            skipWhitespace()
            local char = source:sub(position, position)
            position = position + 1
            if char == '}' then
                return result
            elseif char ~= ',' then
                decodeError("expected ',' or '}'", position - 1)
            end
            skipWhitespace()
        end
    end

    parseValue = function()
        skipWhitespace()
        local char = source:sub(position, position)
        if char == '"' then return parseString() end
        if char == '{' then return parseObject() end
        if char == '[' then return parseArray() end
        if source:sub(position, position + 3) == 'true' then position = position + 4; return true end
        if source:sub(position, position + 4) == 'false' then position = position + 5; return false end
        if source:sub(position, position + 3) == 'null' then position = position + 4; return nil end
        if char == '-' or char:match('%d') then return parseNumber() end
        decodeError('unexpected token', position)
    end

    local result = parseValue()
    skipWhitespace()
    if position <= length then
        decodeError('trailing content', position)
    end
    return result
end

function json.decode(source)
    if type(source) ~= 'string' then
        return nil, 'JSON input must be a string'
    end
    local ok, result = pcall(decoder, source)
    if not ok then
        return nil, result
    end
    return result, nil
end

return json
