if isServer() then
    return
end

local Core = PhunMart
local ListPanel = require "PhunMart_Client/ui/base/list_panel"
local FormPanel = require "PhunMart_Client/ui/base/form_panel"
local DeleteHelper = require "PhunMart_Client/ui/base/delete_helper"
local KeyPicker = require "PhunMart_Client/ui/base/key_picker"
local VehiclePicker = require "PhunMart_Client/ui/base/vehicle_picker"
local Traits = require "PhunMart/traits"
local PendingRestock = require "PhunMart_Client/ui/admin/pending_restock"
local tools = require "PhunMart_Client/ui/ui_utils"

local PAD = ListPanel.PAD
local ROW_H = ListPanel.ROW_H
local FONT_SCALE = ListPanel.FONT_SCALE
local FONT_HGT_SMALL = ListPanel.FONT_HGT_SMALL
local FONT_HGT_MEDIUM = ListPanel.FONT_HGT_MEDIUM
local SCROLLBAR_W = ListPanel.SCROLLBAR_W

local windowName = "PhunSpecialsAdminUI"

Core.ui.admin_specials = ListPanel:derive(windowName)
Core.ui.admin_specials.instances = {}
local UI = Core.ui.admin_specials
UI._defKind = "specials"
-- Six templates stand behind 209 children. Folded away by default so the tab
-- opens on the entries a shop can actually roll.
UI._hasTemplates = true

--- What to print under the price dropdown: what the chosen key costs.
local function priceHintFor(key)
    local text = tools.priceHint(key)
    if text == "" then
        return getText("IGUI_PhunMart_Hint_PriceOverride")
    end
    return text
end

-- Format the kind/inherit column for display.
local function formatType(def)
    if def.template then
        return getText("IGUI_PhunMart_Template")
    end
    if def.inherit then
        return def.inherit
    end
    return def.kind or "?"
end

-- Format display text column.
local function formatDisplay(def)
    if def.display then
        return def.display.text or def.display.texture or ""
    end
    return ""
end

-- Summarise the first action for the list.
local function formatAction(def)
    if not def.actions or not def.actions[1] then
        return ""
    end
    local act = def.actions[1]
    if act.type == "addTrait" then
        return "+" .. Traits.getLabel(act.trait or "")
    elseif act.type == "removeTrait" then
        return "-" .. Traits.getLabel(act.trait or "")
    elseif act.type == "spawnVehicle" then
        return "vehicle:" .. (act.script or (act.scripts and act.scripts[1]) or "")
    elseif act.type == "spawnAnimal" then
        return "animal:" .. tostring(act.animal or "?") .. "/" .. tostring(act.breed or "?")
    elseif act.type == "giveXP" then
        return (act.skill or "?") .. " +" .. tostring(act.amount or 0) .. " XP"
    elseif act.type == "applyBoost" then
        return (act.skill or "?") .. " x" .. tostring(act.multiplier or 1) .. " for " .. tostring(act.hours or 0) .. "h"
    elseif act.type == "grantBoundTokens" then
        return tostring(act.amount or 0) .. " tokens"
    elseif act.type == "adjustBalance" then
        return tostring(act.amount or 0) .. " " .. (act.pool or "change")
    elseif act.type == "giveItem" then
        return tostring(act.amount or 1) .. "x " .. (act.item or "?")
    end
    return act.type or ""
end

---------------------------------------------------------------------------
-- Edit / Add Modal (FormPanel-based)
---------------------------------------------------------------------------

-- giveXP and applyBoost were missing here, which was quietly destructive: they
-- are 210 of the 316 shipped specials, the combo cannot show an option it does
-- not have so it fell back to the first one, and saving then replaced a real
-- giveXP action with an empty addTrait.
local ACTION_TYPES = {"addTrait", "removeTrait", "giveXP", "applyBoost", "spawnVehicle", "spawnAnimal",
                      "grantBoundTokens", "adjustBalance", "giveItem"}
local KIND_OPTIONS = {"trait", "skill", "boost", "vehicle", "animal", "collector", "pawn"}

local function trim(s)
    return (s or ""):match("^%s*(.-)%s*$")
end

-- Vehicle script names as their in-game labels, so the field reads as cars
-- rather than as script identifiers.
local function formatVehicleList(keys)
    if not keys or #keys == 0 then
        return getText("IGUI_PhunMart_Lbl_None")
    end
    local names = {}
    local limit = math.min(#keys, 3)
    for i = 1, limit do
        names[i] = VehiclePicker.labelFor(keys[i])
    end
    local text = table.concat(names, ", ")
    if #keys > limit then
        text = text .. " +" .. tostring(#keys - limit) .. " more"
    end
    return text
end

-- Which field group each action type needs. Everything not listed here shows
-- no extra fields at all.
local ACTION_GROUPS = {
    addTrait = "act_trait",
    removeTrait = "act_trait",
    giveXP = "act_xp",
    applyBoost = "act_boost",
    spawnVehicle = "act_vehicle",
    spawnAnimal = "act_animal",
    grantBoundTokens = "act_tokens",
    adjustBalance = "act_balance",
    giveItem = "act_item"
}

local ALL_ACTION_GROUPS = {"act_trait", "act_xp", "act_boost", "act_vehicle", "act_animal", "act_tokens",
                           "act_balance", "act_item"}

-- Which filter tab an action type belongs to. "Special" means nothing to
-- someone looking for a vehicle, so the list is grouped by what the thing
-- actually does. Anything not named here falls into "other", which keeps the
-- row reachable rather than hiding it because it is unusual.
local ACTION_DOMAINS = {
    giveXP = "xp",
    applyBoost = "boost",
    addTrait = "trait",
    removeTrait = "trait",
    spawnVehicle = "vehicle",
    spawnAnimal = "animal"
}

local DOMAIN_TABS = {{
    key = "all",
    label = "IGUI_PhunMart_Tab_All"
}, {
    key = "xp",
    label = "IGUI_PhunMart_Tab_XP"
}, {
    key = "boost",
    label = "IGUI_PhunMart_Tab_Boosts"
}, {
    key = "trait",
    label = "IGUI_PhunMart_Tab_Traits"
}, {
    key = "vehicle",
    label = "IGUI_PhunMart_Tab_Vehicles"
}, {
    key = "animal",
    label = "IGUI_PhunMart_Tab_Animals"
}, {
    key = "other",
    label = "IGUI_PhunMart_Tab_Other"
}}

-- Same domains, reached from `kind` instead. Templates declare no actions at
-- all, so an action alone put every one of them in Other, which is where the
-- XP and Boosts tabs went empty the moment their children were folded away:
-- the only rows left were the templates that represent them.
local KIND_DOMAINS = {
    skill = "xp",
    boost = "boost",
    trait = "trait",
    vehicle = "vehicle",
    animal = "animal"
}

--- Which tab a special belongs in. Its own first action when it has one, since
--- every generated child declares one; otherwise its kind, which is what a
--- template carries instead.
local function domainOf(def)
    local act = def.actions and def.actions[1]
    local byAction = act and ACTION_DOMAINS[act.type]
    if byAction then
        return byAction
    end
    local kind = def.kind
    if not kind and def.inherit then
        local specials = Core.defs and Core.defs.specials or {}
        local parent = specials[def.inherit]
        kind = parent and parent.kind
    end
    return KIND_DOMAINS[kind] or "other"
end

-- Show only the group belonging to `actionType`, hiding the rest.
local function applyActionGroups(form, actionType, isTemplate)
    local wanted = (not isTemplate) and ACTION_GROUPS[actionType] or nil
    for _, g in ipairs(ALL_ACTION_GROUPS) do
        form:setGroupVisible(g, g == wanted)
    end
end

-- Traits as {key, display} sorted by label, for the picker.
local function getTraitOptions()
    local opts = {}
    for key, entry in pairs(Traits.cache() or {}) do
        table.insert(opts, {
            key = key,
            display = entry.label or key
        })
    end
    table.sort(opts, function(a, b)
        return a.display:lower() < b.display:lower()
    end)
    return opts
end

-- Collect sorted price keys for combo.
local function getPriceKeys()
    local prices = Core.defs and Core.defs.prices or require "PhunMart/defaults/prices"
    local keys = {""}
    local sorted = {}
    for k, v in pairs(prices) do
        if not v.template then
            table.insert(sorted, k)
        end
    end
    table.sort(sorted)
    for _, k in ipairs(sorted) do
        table.insert(keys, k)
    end
    return keys
end

-- sameValue, isEmptyTable and pruneInherited moved to ui_utils when the price
-- editor turned out to need the same rule.
local pruneInherited = tools.pruneInherited

---------------------------------------------------------------------------
-- Provenance
--
-- Where each field on the form reads from, so the form can say whether the
-- value on screen belongs to this entry or came down from its template. Only
-- four fields used to carry that marker, and `action` was not one of them,
-- which is the field whose inherited value looked like a real choice of
-- addTrait and got saved as one.
---------------------------------------------------------------------------

--- A test for "the first action carries this field".
local function fromAction(name)
    return function(d)
        local a = d.actions and d.actions[1]
        return a ~= nil and a[name] ~= nil
    end
end

local FIELD_SOURCE = {
    displayText = function(d)
        return d.display ~= nil and d.display.text ~= nil
    end,
    price = function(d)
        return d.price ~= nil
    end,
    weight = function(d)
        return d.offer ~= nil and d.offer.weight ~= nil
    end,
    -- One key, matching the one range field that replaced the two boxes.
    stock = function(d)
        return d.offer ~= nil and d.offer.stock ~= nil and
                   (d.offer.stock.min ~= nil or d.offer.stock.max ~= nil)
    end,
    enabled = function(d)
        return d.enabled ~= nil
    end,
    action = fromAction("type"),
    trait = fromAction("trait"),
    xpSkill = fromAction("skill"),
    xpAmount = fromAction("amount"),
    boostSkill = fromAction("skill"),
    boostMultiplier = fromAction("multiplier"),
    animalType = fromAction("animal"),
    animalBreed = fromAction("breed"),
    tokenAmount = fromAction("amount"),
    balanceAmount = fromAction("amount"),
    pool = fromAction("pool"),
    giveItemItem = fromAction("item"),
    giveItemAmount = fromAction("amount")
}

--- Mark every field whose value the resolved definition has but the raw entry
--- does not. Tested against the resolved copy rather than the parent so a field
--- that is simply blank on both stays unmarked: "inherited" has to mean an
--- actual value arrived from somewhere, not that nobody set one.
local function markInheritedFields(form, raw, def)
    local from = raw.inherit
    if not from or from == "" then
        return
    end
    for key, hasValue in pairs(FIELD_SOURCE) do
        if not hasValue(raw) and hasValue(def) then
            form:setFieldInherited(key, from)
        end
    end
end

local function createEditModal(specialKey, specialDef, isNew, cb)
    local raw = specialDef or {}
    local isTpl = raw.template or false

    -- Two views of the same row. `raw` is what this entry stores; `def` is what
    -- it resolves to once its template has been folded in. The form reads the
    -- resolved one, because a child of a template stores a skill name and
    -- almost nothing else, and a form fed the raw table shows blanks where
    -- there are real values. A combo cannot show a blank at all: it falls to
    -- its first option, so editing a boost offered addTrait and saving wrote
    -- that over the inherited action.
    local allSpecials = Core.defs and Core.defs.specials or require "PhunMart/defaults/specials"
    local def = (specialKey and tools.resolveInherited(allSpecials, specialKey)) or raw
    -- What this entry would be if it declared nothing: the yardstick for
    -- deciding, on save, whether a value is its own or borrowed.
    local parentDef = tools.resolveParent(allSpecials, raw)

    -- Provenance used to be four hand-marked hints appended at build time, which
    -- covered four of twenty-eight fields and never updated once you typed. It
    -- is markInheritedFields plus FormPanel now, for every field and live.

    -- Each action type reads its own fields off the stored action, rather than
    -- everything being flattened into one string.
    local curAction = def.actions and def.actions[1]
    local selectedTrait = curAction and curAction.trait or nil
    local selectedVehicles = {}
    if curAction then
        if curAction.scripts then
            for _, s in ipairs(curAction.scripts) do
                table.insert(selectedVehicles, s)
            end
        elseif curAction.script then
            table.insert(selectedVehicles, curAction.script)
        end
    end
    local animalTypeDefault = (curAction and curAction.animal) or ""
    local animalBreedDefault = (curAction and curAction.breed) or ""
    local amountDefault = (curAction and curAction.amount) and tostring(curAction.amount) or ""

    -- Build inherit options from template keys
    local specials = Core.defs and Core.defs.specials or require "PhunMart/defaults/specials"
    local inheritOptions = {getText("IGUI_PhunMart_Lbl_None")}
    local templateKeys = {}
    for k, v in pairs(specials) do
        if v.template then
            table.insert(templateKeys, k)
        end
    end
    table.sort(templateKeys)
    for _, tk in ipairs(templateKeys) do
        table.insert(inheritOptions, tk)
    end

    local inheritSelected = inheritOptions[1]
    if def.inherit then
        for _, tk in ipairs(inheritOptions) do
            if tk == def.inherit then
                inheritSelected = tk
                break
            end
        end
    end

    local titleText = isNew and getText("IGUI_PhunMart_Title_AddSpecial") or
                          getText("IGUI_PhunMart_Title_EditX", specialKey or "")

    local form = FormPanel:new({
        width = math.floor(420 * FONT_SCALE),
        title = titleText,
        onDelete = (not isNew) and function(f)
            DeleteHelper.confirm("specials", specialKey, function()
                if not f._removed then
                    f._removed = true
                    f:close()
                end
            end)
        end or nil,
        onApply = function(f)
            local key = f:getFieldValue("key")

            -- Start from what this entry stores, not from what it resolves to.
            -- Copying the resolved view would bake every inherited value into
            -- the child on the first save.
            local result = Core.utils.deepCopy(raw)
            local tpl = f:getFieldValue("template")

            if tpl then
                result.template = true
                result.kind = f:getFieldValue("kind")

                local cat = f:getFieldValue("category")
                result.category = (cat ~= "") and cat or nil

                local tex = f:getFieldValue("texture")
                local ovl = f:getFieldValue("overlay")
                if tex ~= "" or ovl ~= "" then
                    result.display = {}
                    if tex ~= "" then
                        result.display.texture = tex
                    end
                    if ovl ~= "" then
                        result.display.overlay = ovl
                    end
                else
                    result.display = nil
                end

                -- Instance-only shape doesn't belong on a template.
                result.inherit = nil
                result.actions = nil
                result.price = nil
                result.offer = nil
                result.enabled = nil
            else
                result.template = nil

                local inheritIdx = f._fieldsByKey["inherit"]._combo.selected
                result.inherit = inheritIdx > 1 and f:getFieldValue("inherit") or nil

                local dispText = f:getFieldValue("displayText")
                result.display = (dispText ~= "") and {
                    text = dispText
                } or nil

                -- Each branch reads only its own fields. Validation has already
                -- run, so anything required here is present and well formed.
                local actionType = f:getFieldValue("action")
                local action

                if actionType == "giveItem" then
                    local amt = tonumber(f:getFieldValue("giveItemAmount"))
                    action = {
                        type = "giveItem",
                        item = f:getFieldValue("giveItemItem"),
                        -- Blank means one per purchase.
                        amount = (amt and math.floor(amt) >= 1) and math.floor(amt) or 1
                    }
                elseif ACTION_GROUPS[actionType] then
                    action = {
                        type = actionType
                    }
                    if actionType == "addTrait" or actionType == "removeTrait" then
                        action.trait = f:getFieldValue("trait")
                    elseif actionType == "giveXP" then
                        action.skill = trim(f:getFieldValue("xpSkill"))
                        action.amount = f:getFieldNumber("xpAmount")
                    elseif actionType == "applyBoost" then
                        action.skill = trim(f:getFieldValue("boostSkill"))
                        action.multiplier = f:getFieldNumber("boostMultiplier")
                    elseif actionType == "spawnVehicle" then
                        local scripts = f:getFieldValue("vehicleScripts") or {}
                        if #scripts > 1 then
                            action.scripts = scripts
                        else
                            action.script = scripts[1]
                        end
                    elseif actionType == "spawnAnimal" then
                        action.animal = trim(f:getFieldValue("animalType"))
                        action.breed = trim(f:getFieldValue("animalBreed"))
                        action.size = (curAction and curAction.size) or "medium"
                    elseif actionType == "grantBoundTokens" then
                        action.amount = math.floor(f:getFieldNumber("tokenAmount"))
                    elseif actionType == "adjustBalance" then
                        action.amount = math.floor(f:getFieldNumber("balanceAmount"))
                        local poolVal = f:getFieldValue("pool")
                        action.pool = (poolVal and poolVal ~= "") and poolVal or "change"
                    end
                end

                -- Only written when the form actually modelled the type. An
                -- action this form knows nothing about keeps whatever it had:
                -- rebuilding it from fields that were never shown is how a
                -- giveXP action became an empty addTrait, and the same would
                -- happen to any type added later or by another mod.
                if action then
                    -- This form only edits the first action. Keep any others the
                    -- definition already had rather than truncating the list.
                    result.actions = result.actions or {}
                    result.actions[1] = action
                end

                local priceVal = f:getFieldValue("price")
                result.price = (priceVal and priceVal ~= "") and priceVal or nil

                -- Offer: weight and stock
                local weightVal = f:getFieldNumber("weight")
                -- One range field now, so both bounds come back together.
                local stockMin, stockMax = f:getFieldRange("stock")
                if weightVal or stockMin or stockMax then
                    result.offer = {}
                    if weightVal then
                        result.offer.weight = weightVal
                    end
                    if stockMin or stockMax then
                        result.offer.stock = {}
                        if stockMin then
                            result.offer.stock.min = math.floor(stockMin)
                        end
                        if stockMax then
                            result.offer.stock.max = math.floor(stockMax)
                        end
                    end
                else
                    result.offer = nil
                end

                -- Only written when disabled; absent already means enabled.
                -- Clearing the key tombstones it, so re-enabling still carries.
                -- Spelled out rather than `x and nil or false`: that idiom
                -- cannot yield nil, so it returned false for both answers and
                -- every save disabled whatever it was saving.
                if f:getFieldValue("enabled") then
                    result.enabled = nil
                else
                    result.enabled = false
                end

                -- Template-only shape doesn't belong on an instance.
                result.kind = nil
                result.category = nil
            end

            local title = f:getFieldValue("title")
            result.title = (title ~= "") and title or nil

            -- Give back everything the parent already provides. Actions go
            -- first and element by element, because the sequence as a whole
            -- rarely matches and the child would otherwise keep a copy of the
            -- type and amount it only borrowed.
            if parentDef then
                if type(result.actions) == "table" and type(parentDef.actions) == "table" then
                    local anyLeft = false
                    for i, act in ipairs(result.actions) do
                        local pact = parentDef.actions[i]
                        if type(act) == "table" and type(pact) == "table" then
                            pruneInherited(act, pact)
                        end
                        if type(act) ~= "table" or not isEmptyTable(act) then
                            anyLeft = true
                        end
                    end
                    if not anyLeft then
                        result.actions = nil
                    end
                end
                pruneInherited(result, parentDef)
            end

            if cb then
                cb(key, result)
            end
            f:close()
        end
    })

    -- Identity above the tabs, key first, matching the other editors: the
    -- required field before the optional one that overrides how it is shown.
    form:addTextField("key", getText("IGUI_PhunMart_Lbl_Key"), {
        default = specialKey or "",
        editable = isNew,
        required = true,
        hint = getText(isNew and "IGUI_PhunMart_Hint_Key" or "IGUI_PhunMart_Hint_KeyFixed"),
        validate = isNew and function(value)
            if specials[value] then
                return getText("IGUI_PhunMart_Err_KeyInUse")
            end
        end or nil
    })
    form:addTextField("title", getText("IGUI_PhunMart_Lbl_Title"), {
        default = def.title or "",
        hint = getText("IGUI_PhunMart_Hint_Title"),
    })

    -- Template checkbox
    form:addCheckField("template", getText("IGUI_PhunMart_Lbl_IsTemplate"), {
        checked = isTpl,
        text = getText("IGUI_PhunMart_Lbl_IsTemplate"),
        onChange = function(f, field)
            local tpl = f:getFieldValue("template")
            f:setGroupVisible("template", tpl)
            f:setGroupVisible("instance", not tpl)
        end
    })

    -- Template-only fields
    form:addComboField("kind", getText("IGUI_PhunMart_Lbl_Kind"), {
        options = KIND_OPTIONS,
        selected = def.kind or KIND_OPTIONS[1],
        group = "template"
    })
    form:addTextField("category", getText("IGUI_PhunMart_Lbl_Category"), {
        default = def.category or "",
        group = "template"
    })
    form:addTextField("texture", getText("IGUI_PhunMart_Lbl_Texture"), {
        default = (def.display and def.display.texture) or "",
        group = "template"
    })
    form:addTextField("overlay", getText("IGUI_PhunMart_Lbl_Overlay"), {
        default = (def.display and def.display.overlay) or "",
        group = "template"
    })

    -- Instance-only fields
    form:addComboField("inherit", getText("IGUI_PhunMart_Lbl_Inherit"), {
        options = inheritOptions,
        selected = inheritSelected,
        hint = getText("IGUI_PhunMart_Hint_Inherit"),
        group = "instance",
        -- Half the fields below can be showing this entry's values, and the
        -- only way to see them was to cancel out, find it in the list and open
        -- it. Reads the combo at click time rather than the value it loaded
        -- with, so it follows a parent you have just picked.
        button = {
            text = getText("IGUI_PhunMart_Btn_OpenParent"),
            onClick = function(f)
                local parentKey = f:getFieldValue("inherit")
                local parentRaw = parentKey and parentKey ~= "" and allSpecials[parentKey]
                if parentRaw then
                    createEditModal(parentKey, parentRaw, false, cb)
                end
            end
        }
    })
    form:addTextField("displayText", getText("IGUI_PhunMart_Lbl_Label"), {
        default = (def.display and def.display.text) or "",
        hint = getText("IGUI_PhunMart_Hint_DisplayText"),
        group = "instance"
    })
    local curActionType = curAction and curAction.type or ACTION_TYPES[1]

    -- A combo cannot show an option it does not have, and it does not complain:
    -- it just sits on the first one, so an unrecognised action would read as
    -- addTrait. Add it instead, and the save path leaves it alone because it has
    -- no field group.
    local actionOptions = {}
    local knownType = false
    for _, t in ipairs(ACTION_TYPES) do
        table.insert(actionOptions, t)
        if t == curActionType then
            knownType = true
        end
    end
    if not knownType and curActionType and curActionType ~= "" then
        table.insert(actionOptions, curActionType)
    end
    local extraActions = (def.actions and #def.actions > 1) and (#def.actions - 1) or 0
    form:addComboField("action", getText("IGUI_PhunMart_Lbl_Action"), {
        options = actionOptions,
        selected = curActionType,
        group = "instance",
        -- Only the first action is editable here. Say so when there are more,
        -- rather than letting them look absent (they are preserved on save).
        hint = extraActions > 0 and getText("IGUI_PhunMart_Hint_MoreActions", tostring(extraActions)) or
            getText("IGUI_PhunMart_Hint_ActionType"),
        onChange = function(f, field)
            applyActionGroups(f, f:getFieldValue("action"))
        end
    })

    -- One field per action type rather than a single box whose meaning changed
    -- with the combo above it. Each lives in its own group, so only the fields
    -- the chosen action actually uses are on screen.
    form:addPickerField("trait", getText("IGUI_PhunMart_Lbl_Trait"), {
        value = selectedTrait,
        display = selectedTrait and Traits.getLabel(selectedTrait) or getText("IGUI_PhunMart_Lbl_None"),
        hint = getText("IGUI_PhunMart_Hint_TraitPick"),
        group = "act_trait",
        required = true,
        onPick = function(f, field)
            KeyPicker.open(getSpecificPlayer(0), getTraitOptions(), selectedTrait and {selectedTrait} or {},
                function(picked)
                    selectedTrait = picked
                    f:setPickerValue("trait", selectedTrait,
                        selectedTrait and Traits.getLabel(selectedTrait) or getText("IGUI_PhunMart_Lbl_None"))
                end, {
                    title = getText("IGUI_PhunMart_Admin_PickTrait"),
                    singleSelect = true
                })
        end
    })
    form:addTextField("xpSkill", getText("IGUI_PhunMart_Lbl_Skill"), {
        default = (curAction and curAction.skill) or "",
        hint = getText("IGUI_PhunMart_Hint_Skill"),
        group = "act_xp",
        required = true
    })
    form:addTextField("xpAmount", getText("IGUI_PhunMart_Lbl_XPAmount"), {
        default = (curAction and curAction.amount) and tostring(curAction.amount) or "",
        hint = getText("IGUI_PhunMart_Hint_XPAmount"),
        group = "act_xp",
        required = true,
        numeric = true,
        min = 0
    })
    form:addTextField("boostSkill", getText("IGUI_PhunMart_Lbl_Skill"), {
        default = (curAction and curAction.skill) or "",
        hint = getText("IGUI_PhunMart_Hint_Skill"),
        group = "act_boost",
        required = true
    })
    form:addTextField("boostMultiplier", getText("IGUI_PhunMart_Lbl_BoostMultiplier"), {
        default = (curAction and curAction.multiplier) and tostring(curAction.multiplier) or "",
        hint = getText("IGUI_PhunMart_Hint_BoostMultiplier"),
        group = "act_boost",
        required = true,
        numeric = true,
        min = 0
    })
    -- Not required, because nothing reads it. grantReward's applyBoost branch
    -- calls setPerkBoost(perk, level) and never looks at hours, so a boost
    -- lasts as long as the game decides. Kept as a field because the shipped
    -- data carries it and dropping it would discard the intent, but demanding
    -- a number for something inert was the wrong thing to ask.
    -- A picker rather than free text. Script names are not guessable, a typo
    -- here silently disables the offer at compile time, and there was no list
    -- of valid ones anywhere in the UI.
    form:addPickerField("vehicleScripts", getText("IGUI_PhunMart_Lbl_VehicleScripts"), {
        value = selectedVehicles,
        display = formatVehicleList(selectedVehicles),
        hint = getText("IGUI_PhunMart_Hint_VehiclePick"),
        group = "act_vehicle",
        required = true,
        onPick = function(f, field)
            VehiclePicker.open(getSpecificPlayer(0), selectedVehicles, function(keys)
                selectedVehicles = keys or {}
                f:setPickerValue("vehicleScripts", selectedVehicles, formatVehicleList(selectedVehicles))
            end)
        end
    })
    form:addTextField("animalType", getText("IGUI_PhunMart_Lbl_AnimalType"), {
        default = animalTypeDefault,
        hint = getText("IGUI_PhunMart_Hint_AnimalType"),
        group = "act_animal",
        required = true
    })
    form:addTextField("animalBreed", getText("IGUI_PhunMart_Lbl_AnimalBreed"), {
        default = animalBreedDefault,
        hint = getText("IGUI_PhunMart_Hint_AnimalBreed"),
        group = "act_animal",
        required = true
    })
    form:addTextField("tokenAmount", getText("IGUI_PhunMart_Lbl_TokenAmount"), {
        default = amountDefault,
        hint = getText("IGUI_PhunMart_Hint_TokenAmount"),
        group = "act_tokens",
        required = true,
        integer = true
    })
    form:addTextField("balanceAmount", getText("IGUI_PhunMart_Lbl_BalanceAmount"), {
        default = amountDefault,
        hint = getText("IGUI_PhunMart_Hint_ChangeAmount"),
        group = "act_balance",
        required = true,
        integer = true
    })
    -- The currency pools, read off the wallet rather than typed. There are two
    -- and they are defined in code, so no Open button: there is no editor to
    -- open, unlike the price and inherit fields this sits near.
    local poolOptions = {}
    for poolKey in pairs(Core.wallet and Core.wallet.pools or {}) do
        table.insert(poolOptions, poolKey)
    end
    table.sort(poolOptions)
    form:addComboField("pool", getText("IGUI_PhunMart_Lbl_Pool"), {
        options = poolOptions,
        selected = (curAction and curAction.pool) or "change",
        hint = getText("IGUI_PhunMart_Hint_CurrencyPool"),
        group = "act_balance"
    })
    form:addTextField("giveItemItem", getText("IGUI_PhunMart_Lbl_Item"), {
        default = (curAction and curAction.item) or "",
        hint = getText("IGUI_PhunMart_Hint_ItemKey"),
        group = "act_item",
        required = true
    })
    form:addTextField("giveItemAmount", getText("IGUI_PhunMart_Lbl_ItemAmount"), {
        default = (curAction and curAction.amount) and tostring(curAction.amount) or "",
        hint = getText("IGUI_PhunMart_Hint_ItemAmount"),
        group = "act_item",
        integer = true,
        min = 1
    })
    form:addComboField("price", getText("IGUI_PhunMart_Lbl_Price"), {
        options = getPriceKeys(),
        selected = def.price or "",
        -- What it costs, not what the field is for. Same treatment as the
        -- group price dropdown, which is where most prices are actually set.
        hint = priceHintFor(def.price),
        onChange = function(f)
            f:setHintText("price", priceHintFor(f:getFieldValue("price")))
        end,
        group = "instance",
        -- Same treatment as Inherits: a field naming another definition can go
        -- and show you it. Reads the combo at click time so it follows a price
        -- you have just picked.
        button = {
            text = getText("IGUI_PhunMart_Btn_OpenParent"),
            onClick = function(f)
                local key = f:getFieldValue("price")
                if key and key ~= "" then
                    Core.ui.admin_prices.OnEditPrice(getSpecificPlayer(0), key)
                end
            end
        }
    })
    form:addTextField("weight", getText("IGUI_PhunMart_Lbl_Weight"), {
        default = (def.offer and def.offer.weight) and tostring(def.offer.weight) or "",
        hint = getText("IGUI_PhunMart_Hint_WeightOverride"),
        group = "instance",
        numeric = true,
        min = 0
    })
    -- One range rather than two boxes: a minimum and a maximum of the same thing
    -- read as a pair, and side by side they cannot be filled in half.
    form:addRangeField("stock", getText("IGUI_PhunMart_Lbl_Stock"), {
        minDefault = (def.offer and def.offer.stock and def.offer.stock.min) and tostring(def.offer.stock.min) or "",
        maxDefault = (def.offer and def.offer.stock and def.offer.stock.max) and tostring(def.offer.stock.max) or "",
        hint = getText("IGUI_PhunMart_Hint_UnlimitedStock"),
        group = "instance",
        integer = true,
        min = 0
    })
    form:addCheckField("enabled", getText("IGUI_PhunMart_Lbl_Enabled_Checkbox"), {
        checked = def.enabled ~= false,
        group = "instance"
    })

    -- Sections are independent of the groups above: `group` says whether a field
    -- applies to the chosen action type at all, `section` says which tab it sits
    -- on. Named by exception, since everything not listed belongs on Basics.
    --
    -- What a special is, does, and costs stays on Basics. Price was on Advanced
    -- with the rest, which was wrong: it is not an occasional setting but half
    -- of what an offer is, and the first thing anyone checks after the action.
    -- How often it shows up, how many exist, and the whole template apparatus
    -- stay on Advanced.
    form:assignSections({
        template = "sp_more",
        kind = "sp_more",
        category = "sp_more",
        texture = "sp_more",
        overlay = "sp_more",
        weight = "sp_more",
        stock = "sp_more"
    }, "sp_basics")

    form:setSections({{
        section = "sp_basics",
        label = getText("IGUI_PhunMart_Sec_Basics")
    }, {
        section = "sp_more",
        label = getText("IGUI_PhunMart_Sec_Advanced")
    }})

    -- Apply initial group visibility BEFORE initialise so the window height is
    -- computed from only the visible fields. Done after initialise, the hidden
    -- template/pool fields still count toward the height and the form opens too
    -- tall until the first user-triggered reflow.
    form:setGroupVisible("template", isTpl)
    form:setGroupVisible("instance", not isTpl)
    applyActionGroups(form, curActionType, isTpl)

    markInheritedFields(form, raw, def)

    form:initialise()

    form:addToUIManager()
    form:bringToTop()
    return form
end

---------------------------------------------------------------------------
-- Main Specials Panel
---------------------------------------------------------------------------

--- Build this panel as a view for the tabbed shell. The shell owns the size
--- and position, so both are placeholders until its first layout pass.
function UI.createTab(player)
    local playerIndex = player:getPlayerNum()
    local instance = UI.instances[playerIndex]
    if not instance then
        instance = UI:new(0, 0, 100, 100, player)
        instance.description = getText("IGUI_PhunMart_Desc_SpecialDefs")
        instance:initialise()
        UI.instances[playerIndex] = instance
    end
    return instance
end

function UI:createChildren()
    ListPanel.createChildren(self)

    -- Columns: Name, Type, Display, Action
    self:addNameColumn(function(d)
        if not d.enabled then
            return 0.5, 0.5, 0.5
        elseif d.template then
            return 0.9, 0.85, 0.3
        end
    end)
    self:addListColumn(getText("IGUI_PhunMart_Col_Type"), 0.32, {field = "typeCol"})
    self:addListColumn(getText("IGUI_PhunMart_Col_Display"), 0.55, {field = "display"})
    self:addListColumn(getText("IGUI_PhunMart_Col_Action"), 0.78, {field = "action", color = {0.7, 0.7, 0.7}})

    local tabs = {}
    for _, t in ipairs(DOMAIN_TABS) do
        table.insert(tabs, {
            key = t.key,
            label = getText(t.label)
        })
    end
    self:addFilterTabs(tabs)

    self.list.doDrawItem = ListPanel.defaultDrawRow

    -- Double-click to edit
    self.list:setOnMouseDoubleClick(self, self.onDoubleClick)

    -- Bottom buttons
    self:addBottomButton(getText("IGUI_PhunMart_Btn_New"), UI.onAddClick, false)
    self:addBottomButton(getText("IGUI_PhunMart_Btn_Edit"), UI.onEditClick, true)
    self:addBottomButton(getText("IGUI_PhunMart_Btn_Duplicate"), UI.onDuplicateClick, true)
    self:addBottomButton(getText("IGUI_PhunMart_Btn_Delete"), UI.onDeleteClick, true)
end

function UI:onDeleteClick()
    if not self.list.selected or self.list.selected == 0 then
        return
    end
    local selectedItem = self.list.items[self.list.selected]
    if not selectedItem then
        return
    end
    DeleteHelper.confirm("specials", selectedItem.item.key, function()
        self:refreshSpecials()
    end)
end

function UI:rowInFilterTab(itemData, tabKey)
    return tabKey == "all" or itemData.domain == tabKey
end

function UI:getFilterText(itemData)
    return (itemData.key or "") .. " " .. (itemData.title or "") .. " " .. (itemData.typeCol or "") .. " " ..
               (itemData.action or "")
end

function UI:refreshSpecials()
    self:clearList()

    local specials = Core.defs and Core.defs.specials or require "PhunMart/defaults/specials"

    local keys = {}
    for k in pairs(specials) do
        table.insert(keys, k)
    end
    self:sortKeysByName(keys, specials)

    -- Templates used to be filtered out here, which hid the only entries worth
    -- editing: the six XP and boost bases stand behind 209 children that differ
    -- from each other by a skill name. Editing a base changes all of them at
    -- once, so it has to be reachable. Marked [T] the way item overrides mark
    -- theirs, and the children fold away behind the variations tickbox.
    for _, key in ipairs(keys) do
        local def = specials[key]
        local markers = {}
        if def.template then
            table.insert(markers, "[T]")
        end
        if def.enabled == false then
            table.insert(markers, "[off]")
        end
        local name, title = self:rowName(key, def, markers)
        self:addListItem(name, {
            key = key,
            name = name,
            title = title,
            domain = domainOf(def),
            template = def.template == true,
            -- What it copies from, so the variations filter can tell a
            -- generated child from something an admin wrote.
            inherit = def.inherit,
            enabled = def.enabled ~= false,
            typeCol = formatType(def),
            display = formatDisplay(def),
            action = formatAction(def),
            def = def
        })
    end
end

local function saveSpecialDef(self, key, def)
    sendClientCommand(Core.name, Core.commands.upsertSpecialDef, {
        key = key,
        def = def
    })
    PendingRestock.note("specials", key)
    if not Core.isLocal and Core.defs and Core.defs.specials then
        Core.defs.specials[key] = def
    end
    self:refreshSpecials()
end

function UI:onAddClick()
    createEditModal(nil, nil, true, function(key, def)
        saveSpecialDef(self, key, def)
    end)
end

--- Open a copy of the selected special as a new entry.
---
--- This is the tab the request came from. A template here stands behind
--- hundreds of children, so wanting one slightly different version of it is
--- common and editing the base to get there is the worst possible way: it
--- changes every child at once. Copying a template yields a template, and
--- copying a child keeps whatever it inherits, so both readings work.
function UI:onDuplicateClick()
    local data = self:selectedRow()
    if not data then
        return
    end
    local specials = Core.defs and Core.defs.specials or require "PhunMart/defaults/specials"
    local copy = Core.utils.deepCopy(data.def)
    if copy.title and copy.title ~= "" then
        copy.title = getText("IGUI_PhunMart_CopyOfX", copy.title)
    end
    createEditModal(self:copyKeyFor(data.key, specials), copy, true, function(key, def)
        saveSpecialDef(self, key, def)
    end)
end

function UI:onEditClick()
    if not self.list.selected or self.list.selected == 0 then
        return
    end
    local selectedItem = self.list.items[self.list.selected]
    if not selectedItem then
        return
    end
    local data = selectedItem.item
    createEditModal(data.key, data.def, false, function(key, def)
        saveSpecialDef(self, key, def)
    end)
end

function UI:onDoubleClick(item)
    createEditModal(item.key, item.def, false, function(key, def)
        saveSpecialDef(self, key, def)
    end)
end

--- Open the editor for one special, from outside this tab. The Open button
--- beside the Grants dropdown on the item overrides form needs a way in, and
--- createEditModal is file-local.
function UI.OnEditSpecial(player, specialKey)
    local specials = Core.defs and Core.defs.specials or require "PhunMart/defaults/specials"
    local def = specials[specialKey]
    if not def then
        return
    end
    createEditModal(specialKey, def, false, function(key, editedDef)
        local inst = UI.instances[player and player:getPlayerNum() or 0]
        if inst then
            saveSpecialDef(inst, key, editedDef)
        end
    end)
end

UI.refresh = UI.refreshSpecials
