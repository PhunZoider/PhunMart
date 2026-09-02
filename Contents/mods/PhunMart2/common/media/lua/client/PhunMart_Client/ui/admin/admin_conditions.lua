if isServer() then
    return
end

local Core = PhunMart
local ListPanel = require "PhunMart_Client/ui/base/list_panel"
local FormPanel = require "PhunMart_Client/ui/base/form_panel"
local ItemPicker = require "PhunMart_Client/ui/base/item_picker"
local DeleteHelper = require "PhunMart_Client/ui/base/delete_helper"
local PendingRestock = require "PhunMart_Client/ui/admin/pending_restock"
local tools = require "PhunMart_Client/ui/ui_utils"

local FONT_SCALE = ListPanel.FONT_SCALE

---------------------------------------------------------------------------
-- Which tests an admin may write
--
-- canGrantTrait and canRemoveTrait are absent on purpose: the compiler injects
-- those onto trait offers itself, so one written by hand would be a duplicate
-- of a check that is already there. An entry that names one anyway still opens
-- and still saves, because the combo takes its own test on as an option.
---------------------------------------------------------------------------
local TESTS = {"worldAgeHoursBetween", "perkLevelBetween", "perkBoostBetween", "professionIn", "hasItems",
               "purchaseCountMax", "boundTokensBelowMax"}

-- Which field groups each test needs. A test not listed here shows none, which
-- is the right answer for one this editor does not model.
local TEST_GROUPS = {
    worldAgeHoursBetween = {"c_age"},
    -- Two groups, because both tests ask which skill but mean different
    -- numbers by it: a level runs 0 to 10 and a boost 0 to 3.
    perkLevelBetween = {"c_perk", "c_level"},
    perkBoostBetween = {"c_perk", "c_boost"},
    professionIn = {"c_prof"},
    hasItems = {"c_items"},
    purchaseCountMax = {"c_purchase"},
    boundTokensBelowMax = {"c_tokens"}
}

local ALL_GROUPS = {"c_age", "c_perk", "c_level", "c_boost", "c_prof", "c_items", "c_purchase", "c_tokens"}

--- Show only the groups belonging to `test`, hiding the rest.
local function applyTestGroups(form, test)
    local wanted = {}
    for _, g in ipairs(TEST_GROUPS[test] or {}) do
        wanted[g] = true
    end
    for _, g in ipairs(ALL_GROUPS) do
        form:setGroupVisible(g, wanted[g] == true)
    end
end

---------------------------------------------------------------------------
-- Helpers
---------------------------------------------------------------------------

local function trim(s)
    return (s or ""):match("^%s*(.-)%s*$")
end

--- Comma-separated text into a trimmed array. nil when nothing survives, so an
--- empty box stores no key rather than an empty list.
local function parseCsv(text)
    local out = {}
    for s in tostring(text or ""):gmatch("[^,]+") do
        s = trim(s)
        if s ~= "" then
            table.insert(out, s)
        end
    end
    return #out > 0 and out or nil
end

--- Skill names the runtime can actually look up.
---
--- The condition test resolves a perk with `Perks[name]`, so a display name
--- that is not also an enum key would compile into a gate that silently reads
--- level 0. Every candidate is round-tripped through that same lookup before it
--- reaches the combo, and whatever the existing definitions already name is
--- folded in so an entry always shows its own value.
local function perkOptions(current)
    local seen, out = {}, {}

    local function add(name)
        if type(name) == "string" and name ~= "" and not seen[name] then
            seen[name] = true
            table.insert(out, name)
        end
    end

    if Perks and PerkFactory and Perks.getMaxIndex then
        for i = 0, Perks.getMaxIndex() - 1 do
            local ok, perk = pcall(function()
                return PerkFactory.getPerk(Perks.fromIndex(i))
            end)
            if ok and perk then
                local name = perk:getName()
                if name and name ~= "None" and Perks[name] then
                    add(name)
                end
            end
        end
    end

    for _, def in pairs(Core.defs and Core.defs.conditionsDefs or {}) do
        if type(def.args) == "table" then
            add(def.args.perk)
        end
    end
    add(current)

    table.sort(out)
    return out
end

--- The rule a condition states, for the list column. Longer than the picker
--- label, which has to fit beside a key in a dropdown; this column is the one
--- place the whole rule can be read without opening the row.
local function formatRule(def)
    local t = def.test
    local a = def.args or {}

    local function between(lo, hi, unit)
        unit = unit or ""
        if lo and hi then
            return tostring(lo) .. unit .. " to " .. tostring(hi) .. unit
        elseif lo then
            return tostring(lo) .. unit .. " or more"
        elseif hi then
            return tostring(hi) .. unit .. " or less"
        end
        return "any"
    end

    if t == "worldAgeHoursBetween" then
        return "World age " .. between(a.min, a.max, "h")
    elseif t == "perkLevelBetween" then
        return (a.perk or "?") .. " level " .. between(a.min, a.max)
    elseif t == "perkBoostBetween" then
        return (a.perk or "?") .. " boost " .. between(a.min, a.max)
    elseif t == "professionIn" then
        local profs = a.professions
        return type(profs) == "table" and table.concat(profs, ", ") or tostring(profs or "?")
    elseif t == "hasItems" then
        local parts = {}
        for _, line in ipairs(a.items or {}) do
            table.insert(parts, tostring(line.amount or 1) .. "x " .. tostring(line.item or "?"))
        end
        return #parts > 0 and table.concat(parts, ", ") or "?"
    elseif t == "purchaseCountMax" then
        local text = "at most " .. tostring(a.max or "?")
        if a.scope == "character" then
            text = text .. " per character"
        end
        if a.key then
            text = text .. ", shared as " .. tostring(a.key)
        end
        return text
    elseif t == "boundTokensBelowMax" then
        return "bound tokens under " .. tostring(a.max or "?")
    end
    return ""
end

---------------------------------------------------------------------------
-- Edit modal
---------------------------------------------------------------------------

-- What the scope combo offers. `character` is the only value the test reads;
-- anything else, the shipped entries included, means the whole account, so the
-- other option carries the value it is stored as.
local SCOPE_ACCOUNT = "player_item_shop"
local SCOPE_CHARACTER = "character"

local function createEditModal(condKey, condDef, isNew, cb)
    local def = condDef or {}
    local args = def.args or {}
    local conditions = Core.defs and Core.defs.conditionsDefs or {}

    -- The entry's own test is appended when it is not one of the authorable
    -- ones, so an injected or third-party test opens on itself rather than
    -- silently reading as the first option in the list.
    local testOptions = {}
    for _, t in ipairs(TESTS) do
        table.insert(testOptions, t)
    end
    if def.test and not TEST_GROUPS[def.test] then
        table.insert(testOptions, def.test)
    end
    local currentTest = def.test or TESTS[1]

    -- hasItems carries a list of {item, amount}. The picker owns which items,
    -- and one Amount box covers them all, blank meaning each line keeps what it
    -- had. Same bargain the price editor makes with its item lines.
    local selectedItems = {}
    local amountByItem = {}
    local commonAmount, mixedAmounts = nil, false
    for _, line in ipairs(args.items or {}) do
        if line.item then
            table.insert(selectedItems, line.item)
            local amt = tonumber(line.amount) or 1
            amountByItem[line.item] = amt
            if commonAmount == nil then
                commonAmount = amt
            elseif commonAmount ~= amt then
                mixedAmounts = true
            end
        end
    end
    local amountDefault = mixedAmounts and "" or tostring(commonAmount or 1)

    local function formatItems(keys)
        if not keys or #keys == 0 then
            return getText("IGUI_PhunMart_Lbl_None")
        end
        local limit = math.min(#keys, 3)
        local names = {}
        for i = 1, limit do
            names[i] = keys[i]
        end
        local text = table.concat(names, ", ")
        if #keys > limit then
            text = text .. " +" .. tostring(#keys - limit) .. " more"
        end
        return text
    end

    local titleText = isNew and getText("IGUI_PhunMart_Title_AddCondition") or
                          getText("IGUI_PhunMart_Title_EditX", condKey or "")

    local form = FormPanel:new({
        width = math.floor(420 * FONT_SCALE),
        title = titleText,
        onDelete = (not isNew) and function(f)
            DeleteHelper.confirm("conditionsDefs", condKey, function()
                if not f._removed then
                    f._removed = true
                    f:close()
                end
            end)
        end or nil,
        onApply = function(f)
            local key = f:getFieldValue("key")
            local test = f:getFieldValue("test")

            -- Started from the existing entry so a test this editor does not
            -- model keeps its args, then `args` is rebuilt from scratch for one
            -- it does. A half-kept arg table is worse than either: switching
            -- from perkLevelBetween to hasItems would leave a stray `perk`
            -- behind, and nothing downstream would say so.
            local result = Core.utils.deepCopy(def)
            result.test = test

            if TEST_GROUPS[test] then
                local out = {}

                if test == "worldAgeHoursBetween" then
                    local lo, hi = f:getFieldRange("ageRange")
                    out.min = lo and math.floor(lo) or nil
                    out.max = hi and math.floor(hi) or nil

                elseif test == "perkLevelBetween" or test == "perkBoostBetween" then
                    out.perk = f:getFieldValue("perk")
                    local rangeKey = (test == "perkLevelBetween") and "levelRange" or "boostRange"
                    local lo, hi = f:getFieldRange(rangeKey)
                    out.min = lo and math.floor(lo) or nil
                    out.max = hi and math.floor(hi) or nil

                elseif test == "professionIn" then
                    out.professions = parseCsv(f:getFieldValue("professions"))

                elseif test == "hasItems" then
                    local amt = f:getFieldNumber("itemAmount")
                    local lines = {}
                    for _, itemKey in ipairs(f:getFieldValue("items") or {}) do
                        table.insert(lines, {
                            item = itemKey,
                            amount = amt and math.floor(amt) or amountByItem[itemKey] or 1
                        })
                    end
                    out.items = (#lines > 0) and lines or nil

                elseif test == "purchaseCountMax" then
                    out.max = f:getFieldNumber("purchaseMax")
                    -- Only written when it changes the answer: the test reads
                    -- "character" and treats everything else as the account, so
                    -- storing the account value spells out a default.
                    local scope = f:getFieldValue("scope")
                    out.scope = (scope == SCOPE_CHARACTER) and SCOPE_CHARACTER or SCOPE_ACCOUNT
                    local shared = trim(f:getFieldValue("sharedKey"))
                    out.key = (shared ~= "") and shared or nil

                elseif test == "boundTokensBelowMax" then
                    out.max = f:getFieldNumber("tokenMax")
                end

                result.args = out
            end

            local title = trim(f:getFieldValue("title"))
            result.title = (title ~= "") and title or nil

            if cb then
                cb(key, result)
            end
            f:close()
        end
    })

    form:addTextField("key", getText("IGUI_PhunMart_Lbl_Key"), {
        default = condKey or "",
        editable = isNew,
        required = true,
        hint = getText("IGUI_PhunMart_Hint_ConditionKey"),
        validate = isNew and function(value)
            if conditions[value] then
                return getText("IGUI_PhunMart_Err_KeyInUse")
            end
        end or nil
    })
    form:addTextField("title", getText("IGUI_PhunMart_Lbl_Title"), {
        default = def.title or "",
        hint = getText("IGUI_PhunMart_Hint_Title")
    })

    form:addComboField("test", getText("IGUI_PhunMart_Lbl_Test"), {
        options = testOptions,
        selected = currentTest,
        hint = getText("IGUI_PhunMart_Hint_Test"),
        onChange = function(f)
            applyTestGroups(f, f:getFieldValue("test"))
        end
    })

    form:addRangeField("ageRange", getText("IGUI_PhunMart_Lbl_WorldAge"), {
        minDefault = args.min and tostring(args.min) or "",
        maxDefault = args.max and tostring(args.max) or "",
        hint = getText("IGUI_PhunMart_Hint_WorldAge"),
        group = "c_age",
        integer = true,
        min = 0
    })

    form:addComboField("perk", getText("IGUI_PhunMart_Lbl_Skill"), {
        options = perkOptions(args.perk),
        selected = args.perk or "",
        hint = getText("IGUI_PhunMart_Hint_ConditionPerk"),
        group = "c_perk"
    })
    form:addRangeField("levelRange", getText("IGUI_PhunMart_Lbl_LevelRange"), {
        minDefault = args.min and tostring(args.min) or "",
        maxDefault = args.max and tostring(args.max) or "",
        hint = getText("IGUI_PhunMart_Hint_LevelRange"),
        group = "c_level",
        integer = true,
        min = 0,
        max = 10
    })
    form:addRangeField("boostRange", getText("IGUI_PhunMart_Lbl_BoostRange"), {
        minDefault = args.min and tostring(args.min) or "",
        maxDefault = args.max and tostring(args.max) or "",
        hint = getText("IGUI_PhunMart_Hint_BoostRange"),
        group = "c_boost",
        integer = true,
        min = 0,
        max = 3
    })

    form:addTextField("professions", getText("IGUI_PhunMart_Lbl_Professions"), {
        default = type(args.professions) == "table" and table.concat(args.professions, ", ") or "",
        hint = getText("IGUI_PhunMart_Hint_Professions"),
        group = "c_prof",
        required = true
    })

    form:addPickerField("items", getText("IGUI_PhunMart_Lbl_Items"), {
        value = selectedItems,
        display = formatItems(selectedItems),
        group = "c_items",
        required = true,
        onPick = function(f, field)
            ItemPicker.open(getSpecificPlayer(0), selectedItems, function(keys)
                selectedItems = keys or {}
                f:setPickerValue("items", selectedItems, formatItems(selectedItems))
            end)
        end
    })
    form:addTextField("itemAmount", getText("IGUI_PhunMart_Lbl_Amount"), {
        default = amountDefault,
        hint = mixedAmounts and getText("IGUI_PhunMart_Hint_AmountMixed") or
            getText("IGUI_PhunMart_Hint_ConditionAmount"),
        group = "c_items",
        integer = true,
        min = 1
    })

    form:addTextField("purchaseMax", getText("IGUI_PhunMart_Lbl_MaxPurchases"), {
        default = args.max and tostring(args.max) or "",
        hint = getText("IGUI_PhunMart_Hint_MaxPurchases"),
        group = "c_purchase",
        integer = true,
        min = 1,
        required = true
    })
    form:addComboField("scope", getText("IGUI_PhunMart_Lbl_Scope"), {
        options = {SCOPE_ACCOUNT, SCOPE_CHARACTER},
        selected = (args.scope == SCOPE_CHARACTER) and SCOPE_CHARACTER or SCOPE_ACCOUNT,
        hint = getText("IGUI_PhunMart_Hint_Scope"),
        group = "c_purchase"
    })
    form:addTextField("sharedKey", getText("IGUI_PhunMart_Lbl_SharedKey"), {
        default = args.key or "",
        hint = getText("IGUI_PhunMart_Hint_SharedKey"),
        group = "c_purchase"
    })

    form:addTextField("tokenMax", getText("IGUI_PhunMart_Lbl_MaxTokens"), {
        default = args.max and tostring(args.max) or "",
        hint = getText("IGUI_PhunMart_Hint_MaxTokens"),
        group = "c_tokens",
        integer = true,
        min = 1,
        required = true
    })

    -- Before initialise, so the window is sized from the fields the chosen test
    -- actually shows rather than from all eight groups at once.
    applyTestGroups(form, currentTest)

    form:initialise()
    form:addToUIManager()
    form:bringToTop()
    return form
end

---------------------------------------------------------------------------
-- Main Conditions Panel (ListPanel subclass)
---------------------------------------------------------------------------

Core.ui.admin_conditions = ListPanel:derive("PhunConditionsAdminUI")
Core.ui.admin_conditions.instances = {}
local UI = Core.ui.admin_conditions
UI._defKind = "conditionsDefs"

function UI.createTab(player)
    local playerIndex = player:getPlayerNum()
    local instance = UI.instances[playerIndex]
    if not instance then
        instance = UI:new(0, 0, 100, 100, player)
        instance.description = getText("IGUI_PhunMart_Desc_ConditionDefs")
        instance:initialise()
        UI.instances[playerIndex] = instance
    end
    return instance
end

function UI:createChildren()
    ListPanel.createChildren(self)

    self.list.doDrawItem = ListPanel.defaultDrawRow
    self.list:setOnMouseDoubleClick(self, self.onDoubleClick)

    self:addNameColumn()
    self:addListColumn(getText("IGUI_PhunMart_Col_Test"), 0.34, {field = "test"})
    -- The rule in words, because a key and a test name together still do not
    -- say what a gate actually lets through.
    self:addListColumn(getText("IGUI_PhunMart_Col_Rule"), 0.62, {field = "rule", color = {0.8, 0.85, 0.8}})

    self:addBottomButton(getText("IGUI_PhunMart_Btn_New"), self.onAddClick)
    self:addBottomButton(getText("IGUI_PhunMart_Btn_Edit"), self.onEditClick, true)
    self:addBottomButton(getText("IGUI_PhunMart_Btn_Duplicate"), self.onDuplicateClick, true)
    self:addBottomButton(getText("IGUI_PhunMart_Btn_Delete"), self.onDeleteClick, true)
end

function UI:getFilterText(itemData)
    return itemData.key .. " " .. (itemData.title or "") .. " " .. (itemData.test or "") .. " " ..
               (itemData.rule or "")
end

function UI:refreshConditions()
    self:clearList()

    local conditions = Core.defs and Core.defs.conditionsDefs or {}
    local keys = {}
    for k in pairs(conditions) do
        table.insert(keys, k)
    end
    self:sortKeysByName(keys, conditions)

    for _, key in ipairs(keys) do
        local def = conditions[key]
        local name, title = self:rowName(key, def)
        self:addListItem(name, {
            key = key,
            name = name,
            title = title,
            test = def.test or "",
            rule = formatRule(def),
            def = def
        })
    end
end

local function saveConditionDef(self, key, def)
    sendClientCommand(Core.name, Core.commands.upsertConditionDef, {
        key = key,
        def = def
    })
    PendingRestock.note("conditionsDefs", key)
    -- In SP, skip the optimistic update: shared Lua state means the server-side
    -- recompile updates Core.defs directly, and mutating it here would poison
    -- the diff in upsertDefinition, which compares against Core.defs.
    if not Core.isLocal and Core.defs and Core.defs.conditionsDefs then
        Core.defs.conditionsDefs[key] = def
    end
    self:refreshConditions()
end

function UI:onAddClick()
    createEditModal(nil, nil, true, function(key, def)
        saveConditionDef(self, key, def)
    end)
end

--- Open a copy of the selected condition as a new entry. The shipped perk gates
--- come in threes that differ by one number, which is the shape this saves
--- retyping.
function UI:onDuplicateClick()
    local data = self:selectedRow()
    if not data then
        return
    end
    local conditions = Core.defs and Core.defs.conditionsDefs or {}
    local copy = Core.utils.deepCopy(data.def)
    if copy.title and copy.title ~= "" then
        copy.title = getText("IGUI_PhunMart_CopyOfX", copy.title)
    end
    createEditModal(self:copyKeyFor(data.key, conditions), copy, true, function(key, def)
        saveConditionDef(self, key, def)
    end)
end

function UI:onEditClick()
    local data = self:selectedRow()
    if not data then
        return
    end
    createEditModal(data.key, data.def, false, function(key, def)
        saveConditionDef(self, key, def)
    end)
end

function UI:onDoubleClick(item)
    createEditModal(item.key, item.def, false, function(key, def)
        saveConditionDef(self, key, def)
    end)
end

function UI:onDeleteClick()
    local data = self:selectedRow()
    if not data then
        return
    end
    DeleteHelper.confirm("conditionsDefs", data.key, function()
        self:refreshConditions()
    end)
end

UI.refresh = UI.refreshConditions

return UI
