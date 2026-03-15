local utils = {}

utils.isLocal = not isClient() and not isServer() and not isCoopHost()

function utils.printTable(t, indent)
    indent = indent or ""
    for key, value in pairs(t or {}) do
        if type(value) == "table" then
            print(indent .. key .. ":")
            utils.printTable(value, indent .. "  ")
        elseif type(value) ~= "function" then
            print(indent .. key .. ": " .. tostring(value))
        end
    end
end

function utils.getPlayerByUsername(name, caseSensitive)
    local online = utils.onlinePlayers()
    local text = caseSensitive and name or name:lower()
    for i = 0, online:size() - 1 do
        local player = online:get(i)
        if (caseSensitive and player:getUsername() == name) or
            (not caseSensitive and player:getUsername():lower() == text) then
            return player
        end
    end
    return nil
end

function utils.onlinePlayers(all)
    local onlinePlayers
    if utils.isLocal then
        onlinePlayers = ArrayList.new()
        local p = getPlayer()
        onlinePlayers:add(p)
    elseif all ~= false and isClient() then
        onlinePlayers = ArrayList.new()
        for i = 0, getOnlinePlayers():size() - 1 do
            local player = getOnlinePlayers():get(i)
            if player:isLocalPlayer() then
                onlinePlayers:add(player)
            end
        end
    else
        onlinePlayers = getOnlinePlayers()
    end
    return onlinePlayers
end

function utils.isAdmin(player, ignoreLocal)
    if isAdmin() or getDebug() or (utils.isLocal and not ignoreLocal) then
        return true
    end
    local level = player and player.getAccessLevel and player:getAccessLevel()
    if level == "admin" or level == "moderator" then
        return true
    end
    return (getAccessLevel and (getAccessLevel() == "moderator" or getAccessLevel() == "admin")) or false
end


--- Compute a minimal diff of `edited` against `original`.
--- Returns a table containing only keys whose values differ.
--- Nested maps are diffed recursively; sequences are compared as wholes.
--- Returns nil if there are no differences.
function utils.diffTable(original, edited)
    if original == nil then
        return utils.shallowClone(edited)
    end
    if edited == nil then
        return nil
    end
    if type(original) ~= "table" or type(edited) ~= "table" then
        if original == edited then
            return nil
        end
        return edited
    end
    -- Sequences: compare as a whole
    if utils.isSequence(original) or utils.isSequence(edited) then
        -- Quick length check
        if #original ~= #edited then
            return utils.shallowClone(edited)
        end
        for i = 1, #original do
            if original[i] ~= edited[i] then
                return utils.shallowClone(edited)
            end
        end
        return nil
    end
    local diff = {}
    local hasDiff = false
    for k, v in pairs(edited) do
        local sub = utils.diffTable(original[k], v)
        if sub ~= nil then
            diff[k] = sub
            hasDiff = true
        end
    end
    return hasDiff and diff or nil
end

function utils.formatWholeNumber(n)
    n = tonumber(n) or 0
    local rounded = math.floor(n + 0.5)
    local s = tostring(rounded)
    local sign = ""
    if s:sub(1, 1) == "-" then
        sign = "-"
        s = s:sub(2)
    end
    local rev = s:reverse()
    rev = rev:gsub("(%d%d%d)", "%1,")
    s = rev:reverse():gsub("^,", "")
    return sign .. s
end

function utils.formatNumber(number, decimals)
    number = number or 0
    local roundedNumber = math.floor(number + (decimals and 0.005 or 0.5))
    local formattedNumber = tostring(roundedNumber):reverse():gsub("(%d%d%d)", "%1,")
    formattedNumber = formattedNumber:reverse():gsub("^,", "")
    return formattedNumber
end

function utils.shallowCopy(original, excludeKeys)
    local exclude = {}
    for _, k in ipairs(excludeKeys or {}) do
        exclude[k] = true
    end
    local copy = {}
    for key, value in pairs(original or {}) do
        if not exclude[key] then
            copy[key] = value
        end
    end
    return copy
end

-- Shallow copy a table (one level deep). Non-tables pass through unchanged.
function utils.shallowClone(t)
    if type(t) ~= "table" then
        return t
    end
    local out = {}
    for k, v in pairs(t) do
        out[k] = v
    end
    return out
end

-- Returns true if t is a non-empty table with only consecutive integer keys.
function utils.isSequence(t)
    if type(t) ~= "table" then
        return false
    end
    local n = #t
    if n == 0 then
        return false
    end
    for k in pairs(t) do
        if type(k) ~= "number" or k < 1 or k > n or k % 1 ~= 0 then
            return false
        end
    end
    return true
end

-- Deep merge: scalars → child wins; sequences → child replaces; maps → recurse.
-- This is the canonical merge used by both the compiler and core.compileWith.
function utils.deepMerge(parent, child)
    if child == nil then
        return utils.shallowClone(parent)
    end
    if parent == nil then
        return utils.shallowClone(child)
    end
    if type(parent) ~= "table" or type(child) ~= "table" then
        return utils.shallowClone(child)
    end
    if utils.isSequence(parent) or utils.isSequence(child) then
        return utils.shallowClone(child)
    end
    local out = utils.shallowClone(parent)
    for k, vChild in pairs(child) do
        local vParent = out[k]
        if type(vChild) == "table" and type(vParent) == "table" and not utils.isSequence(vChild) and
            not utils.isSequence(vParent) then
            out[k] = utils.deepMerge(vParent, vChild)
        else
            out[k] = utils.shallowClone(vChild)
        end
    end
    return out
end

function utils.deepCopy(original, excludeKeys)
    local exclude = {}
    for _, k in ipairs(excludeKeys or {}) do
        exclude[k] = true
    end
    local function _copy(obj)
        if type(obj) ~= "table" then
            return obj
        end
        local result = {}
        for k, v in pairs(obj) do
            if not exclude[k] then
                result[_copy(k)] = _copy(v)
            end
        end
        setmetatable(result, getmetatable(obj))
        return result
    end
    return _copy(original)
end

function utils.merge(tableA, tableB, excludeKeys)
    local mergedTable = {}
    local exclude = {}
    if type(excludeKeys) == "table" then
        -- Support both plain arrays and ArrayList-like objects
        if excludeKeys.contains then
            -- Legacy ArrayList — convert to set
            for i = 0, (excludeKeys.size and excludeKeys:size() - 1 or -1) do
                exclude[excludeKeys:get(i)] = true
            end
        else
            for _, k in ipairs(excludeKeys) do
                exclude[k] = true
            end
        end
    end
    for k, v in pairs(tableA or {}) do
        if not exclude[k] then
            if type(v) == "table" then
                mergedTable[k] = utils.merge(v, {})
            else
                mergedTable[k] = v
            end
        end
    end
    for k, v in pairs(tableB or {}) do
        if not exclude[k] then
            if type(v) == "table" then
                mergedTable[k] = utils.merge(v, mergedTable[k] or {})
            else
                mergedTable[k] = v
            end
        end
    end
    return mergedTable
end

local tid = nil
function utils.getCategory(item)
    if tid == nil then
        if TweakItemData then
            tid = TweakItemData
        else
            tid = false
        end
    end
    if tid then
        local check = TweakItemData[item:getFullName()] or {}
        local test = check["DisplayCategory"] or check["displaycategory"]
        if test then
            return test
        end
    end

    local category = item.getCategory and item:getCategory() or item.getTypeString and item:getTypeString() or nil
    local dcategory = item:getDisplayCategory()
    category = tostring(dcategory or category)

    if item.fluidContainer then
        local fluid = item.fluidContainer:getFluidContainer():getPrimaryFluid()
        if fluid and item:getFluidContainer():getAmount() > 0 then
            if fluid:isCategory(FluidCategory.Alcoholic) then
                category = "FoodA"
            elseif fluid:isCategory(FluidCategory.Beverage) then
                category = "FoodB"
            elseif fluid:isCategory(FluidCategory.Fuel) then
                category = "Fuel"
            end
        else
            category = "Container"
        end
    elseif item.getCanStoreWater and item:getCanStoreWater() then
        if item:getTypeString() ~= "Drainable" then
            category = "Container"
        else
            category = "FoodB"
        end
    elseif item:getDisplayCategory() == "Water" then
        category = "FoodB"
    elseif item.getTypeString and item:getTypeString() == "Food" then
        if item:getDaysTotallyRotten() > 0 and item:getDaysTotallyRotten() < 1000000000 then
            category = "FoodP"
        else
            category = "FoodN"
        end
    elseif item.getTypeString and item:getTypeString() == "Literature" then
        if string.len(item:getSkillTrained()) > 0 then
            category = "LitS"
        elseif item:getTeachedRecipes() and not item:getTeachedRecipes():isEmpty() then
            category = "LitR"
        elseif item:getStressChange() ~= 0 or item:getBoredomChange() ~= 0 or item:getUnhappyChange() ~= 0 then
            category = "LitE"
        else
            category = "LitW"
        end
    elseif item.getTypeString and item:getTypeString() == "Weapon" then
        if item:getDisplayCategory() == "Explosives" or item:getDisplayCategory() == "Devices" then
            category = "WepBomb"
        end
    elseif string.find(item:getFullName(), "Tsarcraft.Cassette") or string.find(item:getFullName(), "Tsarcraft.Vinyl") then
        category = "MediaA"
    elseif item.getTypeString and item:getTypeString() == "Normal" and item:getModuleName() == "TAD" then
        category = "Misc"
    end

    return category or "Unknown"
end

function utils.getAllItemCategories()
    if utils.itemCategories == nil then
        utils.getAllItems()
    end
    return utils.itemCategories
end

function utils.getAllItems(refresh)
    if utils.itemsAll ~= nil and not refresh then
        return utils.itemsAll
    end
    utils.itemsAll = {}
    utils.itemCategories = {}
    local catMap = {}
    local itemList = getScriptManager():getAllItems()
    for i = 0, itemList:size() - 1 do
        local item = itemList:get(i)
        if not item:getObsolete() and not item:isHidden() then
            local cat = utils.getCategory(item) or "Unknown"
            if cat ~= "" and catMap[cat] == nil then
                catMap[cat] = true
                table.insert(utils.itemCategories, {
                    label = cat,
                    type = cat
                })
            end
            table.insert(utils.itemsAll, {
                type = item:getFullName(),
                label = item:getDisplayName(),
                texture = item:getNormalTexture(),
                category = cat
            })
        end
    end
    table.sort(utils.itemsAll, function(a, b)
        return a.label:lower() < b.label:lower()
    end)
    table.sort(utils.itemCategories, function(a, b)
        return a.label:lower() < b.label:lower()
    end)
    return utils.itemsAll
end

return utils
