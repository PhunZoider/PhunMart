if not isServer() then
    return
end
require "PhunMart_Core"
local PhunMart = PhunMart
local PhunTools = PhunTools

--- @class PhunMartItemDisplay
--- @field label string used to determine the name of the item for translation. eg Base.Seldgehammer
--- @field labelExt? string optional extra label info. Used for PERK and BOOSTS to differntiate levels
--- @field type string used to determine the type of item for translation. eg ITEM or VEHICLE or PERK
--- @field texture? string used to determine the name of texture to use for the item. eg Base.Seldgehammer or perk-1
--- @field textureType? string defaults to type. Used to determine the type of item to use for looking up the texture. eg. ITEM or VEHICLE or PERK
--- @field overlay? string optional name of the png in texures folder to overlay on the item. eg token-overlay or plus-1

--- @class PhunMartItemReceive
--- @field type string used to determine the type of item for translation. eg ITEM or VEHICLE or PERK
--- @field label string used to determine the name of the item for translation. eg Base.Seldgehammer
--- @field quantity number used to determine the quantity of the item to receive
--- @field tag? string optional text to store with receipt
--- @field value? string optional value to use when processing receipt

--- @class PhunMartItemCondition
--- @field skills? table<string, number | table<min:number, max:number>> used to determine the skills required to purchase the item
--- @field boosts? table<string, boolean> string=true, player requires the boost. string=false, player must not have the trait
--- @field traits? table<string, boolean> string=true, player requires the trait. string=false, player must not have the trait
--- @field professions? table<string, boolean> string=true, player requires the profession. string=false, player must not have the profession
--- @field maxLimit? number of times the player could purchase the item before being denied
--- @field maxCharLimit? number of times the players character could purchase the item before being denied
--- @field minTime? number of hours the player must have played before being allowed to purchase the item
--- @field minCharTime? number of hours the players character must have played before being allowed to purchase the item
--- @field price? table<string, number|table<min:number, max:number>> used to determine the price of the item

--- @class PhunMartItem
--- @field key string unique refernce for this item. Defaults to type + display.label
--- @field inherits string? optional key of another item to inherit from
--- @field probability number? whole number (1-100) chance of this item appearing in the mart
--- @field display PhunMartItemDisplay properties used to display the item in the mart
--- @field tab string? optional tab to display the item in
--- @field mod string? optional mod to check if active before enabling
--- @field quantity number? optional quantity of the item to display
--- @field inventory string? optional inventory to display the item in
--- @field receive PhunMartItemReceive[] properties used to determine what the player receives when they buy the item
--- @field conditions PhunMartItemCondition[][] properties used to determine if the item is available to the player
--- @field file string? optional file the item was loaded from
--- @field level number? optional level of the item (eg Boost 3)
--- @field abstract boolean? optional flag to indicate if the item is abstract
--- @field enabled boolean? optional flag to indicate if the item is enabled
--- @field tags string? optional tags to filter items by

function PhunMart:validateItemDef(item)

    local issues = {}
    if item.abstract or not item.enabled then
        -- do not validate abstract or disabled items
        return issues
    end
    if not item.key then
        table.insert(issues, "Missing key")
    end
    if not item.display then
        table.insert(issues, "Missing display properties")
    else
        local displayIssues = {}
        if not item.display.label then
            table.insert(displayIssues, "Missing display.label")
        end
        if not item.display.type then
            table.insert(displayIssues, "Missing display.type")
        end
        if not item.display.texture then
            table.insert(displayIssues, "Missing display.texture")
        end
        if not item.display.textureType then
            table.insert(displayIssues, "Missing display.textureType")
        end
        if item.display.label and item.display.type then
            if item.display.type == "ITEM" then
                local instance = getScriptManager():getItem(item.display.label)
                if not instance then
                    table.insert(issues, "Invalid ITEM display.label: " .. item.display.label)
                end
            elseif item.display.type == "VEHICLE" then
                local instance = getScriptManager():getVehicle(item.display.label)
                if not instance then
                    table.insert(issues, "Invalid VEHICLE display.label: " .. item.display.label)
                end
            elseif item.display.type == "PERK" or item.display.type == "BOOST" then
                local instance = PerkFactory.getPerkFromName(item.display.label)
                if not instance then
                    table.insert(issues, "Invalid " .. item.display.type .. " display.label: " .. item.display.label)
                end
            elseif item.display.type == "TRAIT" then
                local instance = TraitFactory.getTrait(item.display.label)
                if not instance then
                    table.insert(issues, "Invalid TRAIT display.label: " .. item.display.label)
                end
            end
        end
    end
    if not item.conditions then
        -- TODO: Is this a valid condition? Maybe it should be optional
        table.insert(issues, "Missing conditions")
    end

    if not item.receive then
        -- TODO: Is this a valid condition? Maybe it should be optional
        table.insert(issues, "Missing receive property")
    else
        for _, v in ipairs(item.receive) do
            if not v.type then
                table.insert(issues, "Missing receive.type")
            end
            if not v.label then
                table.insert(issues, "Missing receive.label")
            end
            if not v.quantity then
                table.insert(issues, "Missing receive.quantity")
            end
            if v.type and v.label then
                -- check validity of entry
                if v.type == "ITEM" then
                    local instance = getScriptManager():getItem(v.label)
                    if not instance then
                        table.insert(issues, "Invalid receive.label: " .. v.label)
                    end
                end
            end
        end
    end

    return issues
end

function PhunMart:isItemValid(item)
    local issues = self:validateItemDef(item)
    return #issues == 0
end

function PhunMart:validateItems()

    local results = {
        total = 0,
        valid = 0,
        invalid = 0,
        abstract = 0,
        disabled = 0,
        issues = {}
    }
    for k, v in pairs(self.defs.items) do
        results.total = results.total + 1
        if v.abstract then
            v.enabled = false
            results.abstract = results.abstract + 1
        elseif not v.enabled then
            results.disabled = results.disabled + 1
        else
            local issues = self:validateItemDef(v)
            if #issues > 0 then
                v.enabled = false
                results.issues[v.key] = issues
                results.invalid = results.invalid + 1
            else
                results.valid = results.valid + 1
            end
        end
    end
    return results
end

--- Transforms raw data into a PhunMartItem
--- @returns PhunMartItem
function PhunMart:formatItem(data)

    if not data.display then
        data.display = {}
    end
    local base = {
        display = {}
    }

    if data.inherits then
        local b = self.defs.items[data.inherits]
        if b then
            base = PhunTools:deepCopyTable(b)
        end
    end

    PhunTools:printTable(data)

    local doDebug = (data.display and data.display.type == "PERK") or (base.display and base.display.type == "PERK")

    local type = data.display.type or base.display.type or data.type or base.type or "ITEM"
    local name = data.name or base.name or data.display.label or base.display.label or nil
    local key = data.key or (type .. ":" .. name)
    if data.display.labelExt or base.display.labelExt then
        key = key .. "-" .. (data.display.labelExt or base.display.labelExt)
    end

    local baseDisplay = base.display or {}
    local dataDisplay = data.display or {}
    -- these values are used client side to translate names, draw textures, etc...
    local display = {
        label = dataDisplay.label or baseDisplay.label or name or nil, -- the name of item used to translate on client side eg: Base.Seldgehammer. Defaults to data.name
        labelExt = data.display.labelExt or baseDisplay.labelExt or nil, -- extra label info. Used for PERK and BOOSTS to differntiate levels
        type = string.upper(dataDisplay.type or baseDisplay.type or type), -- the type of item for translation eg: ITEM or VEHICLE or PERK. Defaults to data.type
        texture = dataDisplay.texture or baseDisplay.texture or name or nil, -- the name of texture to use for the item eg: Base.Seldgehammer. Defaults to data.name
        textureType = string.upper(dataDisplay.textureType or baseDisplay.textureType or baseDisplay.type or type), -- the type of item to use for looking up the texture. eg. ITEM or VEHICLE or PERK. Defaults to data.type
        overlay = dataDisplay.overlay or baseDisplay.overlay or nil -- the name of the png in texures folder to overlay on the item eg: token-overlay or plus-1
    }

    local receives = {}

    -- do not inherit the base receive values
    local receive = data.receive or nil

    if receive and #receive > 0 then
        -- provided own receive values
        for _, v in ipairs(receive) do
            table.insert(receives, {
                type = string.upper(v.type or type),
                label = v.label or v.name or name,
                quantity = v.quantity or 1,
                tag = v.tag or nil,
                name = v.name or name,
                value = v.value or nil
            })
        end
    else
        -- no receive values provided so use defaults
        table.insert(receives, {
            type = type,
            label = name or display.label,
            name = name or display.label,
            quantity = data.quantity or base.quantity or 1
        })
    end

    -- base conditions will already be processed here so "inherit" those accordingly
    local conditions = base.conditions or {}
    local conditionsValue = data.conditions or nil
    if conditionsValue then
        -- provided own array of conditions
        -- merge those with any that may exist from inherited base
        for i, v in ipairs(conditionsValue) do
            if not conditionsValue[i] then
                conditionsValue[i] = {}
            end
            for k, v in pairs(v) do
                conditionsValue[i][k] = v
            end
        end
    elseif data.condition or base.condition then
        -- provided a single condition, merge with any that may exist from inherited base
        for k, v in pairs(data.condition) do
            conditions[1][k] = v
        end
    else
        -- the usual: no conditions provided, assume any are embedded at top level
        if #conditions == 0 then
            conditions[1] = {}
        end
        local condition = conditions[1]
        -- derive one 
        condition = conditions[1] or {}
        condition.skills = data.skills or condition.skills or nil
        condition.traits = data.traits or condition.traits or nil
        condition.professions = data.professions or condition.professions or nil
        condition.maxLimit = data.maxLimit or condition.maxLimit or nil
        condition.maxCharLimit = data.maxCharLimit or condition.maxCharLimit or nil
        condition.minTime = data.minTime or condition.minTime or nil
        condition.minCharTime = data.minCharTime or condition.minCharTime or nil
        condition.price = data.price or condition.price or nil
        condition.boosts = data.boosts or condition.boots or nil
    end

    --- @type PhunMartItem
    local formatted = {
        key = key, -- unique refernce for this item
        probability = data.probability or base.probability or nil,
        tab = data.tab or base.tab or nil,
        mod = data.mod or base.mod or nil,
        quantity = data.quantity or base.quantity or 1,
        inventory = nil,
        display = display,
        receive = receives,
        conditions = conditions,
        file = data.file or nil,
        level = data.level or base.level or nil,
        abstract = data.abstract or nil,
        enabled = data.enabled ~= false
    }

    if data.inventory ~= nil then
        formatted.inventory = data.inventory
    elseif base.inventory ~= nil then
        formatted.inventory = base.inventory
    end

    if string.len(data.tags or base.tags or "") > 0 then
        formatted.tags = data.tags or base.tags or ""
        if not PhunTools:startsWith(formatted.tags, ",") then
            formatted.tags = "," .. formatted.tags
        end
        if not PhunTools:endsWith(formatted.tags, ",") then
            formatted.tags = formatted.tags .. ","
        end
    end

    return formatted
end

--[[

    LOADING QUEUE

]] --

-- add all files we want to load at startup that contain item definitions
function PhunMart:loadFilesForItemQueue()
    -- get list of filename from PhunMart_ItemDefs.ini
    local files = PhunTools:loadLinesIntoTable("PhunMart_ItemDefs.ini")
    if not files then
        -- none were specified so default to PhunMart_Items
        files = {"PhunMart_Items"}
    end
    for _, v in ipairs(files or {}) do
        -- add to the queue
        self:queueFileForItemProcessing(v)
    end
    triggerEvent(self.events.OnItemQueueFilesReadyToProcess)
end

-- iterate through file queued and add contents to transform queue
function PhunMart:processFilesToItemQueue()
    for _, v in ipairs(self.loaders.itemFiles) do
        v.status = "processing"
        -- load the contents of the file into queue
        print(v.file .. ".lua")
        self:loadFileContentsToItemQueue(v.file .. ".lua")
        v.status = "processed"
    end
    triggerEvent(self.events.OnItemQueueReadyToProcess)
end

-- add a file to the item processing queue
function PhunMart:loadFileContentsToItemQueue(file)
    print("Loading " .. file)
    local data = PhunTools:loadTable(file)
    for _, v in ipairs(data) do
        v.file = file
        self:queueRawItemToProcess(v, file)
    end
    triggerEvent(self.events.OnItemQueueProcessed)
end

--[[

    TRANSFORM QUEUE

]] --

-- iterate through raw data to tranform
function PhunMart:processItemTransformQueue()
    local results = {
        all = {},
        files = {}
    }
    for _, v in ipairs(self.loaders.items or {}) do
        if v.status == "pending" then
            local f = v.data.file or "unknown"
            local r = self:transformToItemDef(v.data)

            if not results.all[r.status] then
                results.all[r.status] = 0
            end
            results.all[r.status] = results.all[r.status] + 1
            if not results.files[f] then
                results.files[f] = {}
            end
            if not results.files[f][r.status] then
                results.files[f][r.status] = 0
            end
            results.files[f][r.status] = results.files[f][r.status] + 1
            v.status = r.status
        else
            print("PhunMart: Skipping item as it is not in pending state")
        end
    end
    return results
end

-- transform raw data into item def
function PhunMart:transformToItemDef(data)

    local formatted = self:formatItem(data)
    local status = "success"
    if formatted.abstract then
        formatted.enabled = false
        status = "abstract"
    elseif formatted.mod and not getActivatedMods():contains(formatted.mod) then
        -- we will still leave in defs as something may inherit from it
        formatted.enabled = false
        status = "modinactive"
    end
    -- add to defs
    self.defs.items[formatted.key] = formatted

    return {
        status = status,
        key = formatted.key,
        data = formatted
    }
end

function PhunMart:filterItemListByFile(file, itemList)
    local list = itemList or self.defs.items
    local files = {}
    if type(file) == "table" then
        files = file
    elseif type(file) == "string" and string.len(file) > 0 then
        files = PhunTools:splitString(file, ",")
    else
        return list
    end
    local items = {}
    for k, v in pairs(list) do
        local add = false
        if v.file then
            for _, f in ipairs(files) do
                if v.file == f then
                    add = true
                    break
                end
            end
        end
        if add then
            items[k] = v
        end
    end
    return items
end

function PhunMart:filterItemListByTags(tag, includeTagless, itemList)
    local list = itemList or self.defs.items
    local tags = {}
    if type(tag) == "table" then
        tags = tag
    elseif type(tag) == "string" and string.len(tag) > 0 then
        tags = PhunTools:splitString(tag, ",")
    else
        return list
    end

    local items = {}
    for k, v in pairs(list) do
        if v.enabled and not v.abstract then
            local add = false
            if v.tags then
                for _, f in ipairs(tags) do
                    if v.tags:contains("," .. f .. ",") then
                        add = true
                        break
                    end
                end
            elseif includeTagless then
                add = true
            end
            if add then
                items[k] = v
            end
        end
    end
    return items
end

function PhunMart:filterItemListByLevel(level, itemList)
    local list = itemList or self.defs.items
    local min, max = 0, 0

    if type(level) == "table" then
        min = level.min or 0
        max = level.max or 1000
    elseif string.len(tostring(level)) > 0 then
        min = tonumber(level)
        max = 1000
    else
        return list
    end
    local items = {}
    for k, v in pairs(list) do
        if v.level then
            if v.level >= min and v.level <= max then
                items[k] = v
            end
        end
    end
    return items
end
