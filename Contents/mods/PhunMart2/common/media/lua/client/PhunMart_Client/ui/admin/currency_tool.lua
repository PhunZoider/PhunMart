if isServer() then
    return
end

-- Switch what money is.
--
-- PhunMart prices things in its own abstract "change" by default. Pricing in a
-- lootable item instead is one edit, to currency_base, and everything that
-- inherits from it follows. That is 25 of the 47 shipped prices, so it is the
-- single highest-leverage edit in the mod and also the one most likely to be
-- got wrong.
--
-- The awkward part is `factor`. The child amounts were written as cents: 25,
-- 50, 250, 500. Left alone they would mean 500 of an item. A factor scales the
-- whole tree down, and until now the only way to know what you were about to
-- do was to read the guide and work it out on paper. So the table below is the
-- point of this dialog: pick an item, type a number, watch what everything
-- actually becomes.

local Core = PhunMart
local ListPanel = require "PhunMart_Client/ui/base/list_panel"
local FormPanel = require "PhunMart_Client/ui/base/form_panel"
local ItemPicker = require "PhunMart_Client/ui/base/item_picker"
local PendingRestock = require "PhunMart_Client/ui/admin/pending_restock"
local tools = require "PhunMart_Client/ui/ui_utils"

local FONT_SCALE = ListPanel.FONT_SCALE
local BASE_KEY = "currency_base"

local CurrencyTool = {}

---------------------------------------------------------------------------
-- The affected tree
---------------------------------------------------------------------------

local function pricesTable()
    return Core.defs and Core.defs.prices or require "PhunMart/defaults/prices"
end

--- Does `key` end up at currency_base if you keep following inherit?
local function inheritsBase(prices, key)
    local seen = 0
    while key and seen < 20 do
        if key == BASE_KEY then
            return true
        end
        local def = prices[key]
        key = def and def.inherit
        seen = seen + 1
    end
    return false
end

--- Every price the edit will reach, with the amount each one would be scaled
--- from. Sorted by that amount so the table reads as a ladder rather than
--- alphabetically, which is how you check a factor at a glance.
local function affected()
    local prices = pricesTable()
    local rows = {}
    for key, def in pairs(prices) do
        if key ~= BASE_KEY and inheritsBase(prices, key) then
            local amount = tools.resolvePriceField(def, "amount")
            -- A ranged amount scales from its low end; showing one number for
            -- a range would be a lie, so the label carries both.
            local from, to
            if type(amount) == "table" then
                from, to = tonumber(amount.min), tonumber(amount.max)
            else
                from = tonumber(amount)
            end
            if from then
                table.insert(rows, {
                    key = key,
                    from = from,
                    to = to
                })
            end
        end
    end
    table.sort(rows, function(a, b)
        if a.from ~= b.from then
            return a.from < b.from
        end
        return a.key < b.key
    end)
    return rows
end

--- What the compiler will make of an amount: ceil(amount * factor), never less
--- than one. Mirrors the rule in compiler.lua rather than approximating it,
--- because a preview that disagrees with the result is worse than none.
local function scaled(amount, factor)
    return math.max(1, math.ceil(amount * (factor or 1)))
end

---------------------------------------------------------------------------
-- The dialog
---------------------------------------------------------------------------

function CurrencyTool.open(player, onDone)
    local prices = pricesTable()
    local base = prices[BASE_KEY] or {}
    local rows = affected()

    -- Where it currently stands, so the dialog opens describing the truth
    -- rather than a default.
    local usingItems = base.kind == "items"
    local selectedItem = base.item or (base.items and base.items[1] and base.items[1].item) or "Base.Money"

    local KIND_CHANGE = getText("IGUI_PhunMart_Cur_Change")
    local KIND_ITEM = getText("IGUI_PhunMart_Cur_Item")

    local function itemDisplay(key)
        if not key or key == "" then
            return getText("IGUI_PhunMart_Lbl_None")
        end
        local si = getScriptManager():getItem(key)
        return si and si:getDisplayName() or key
    end

    local form
    local function isItemMode()
        return form and form:getFieldValue("kind") == KIND_ITEM
    end

    --- Rebuild the table. Called on every edit to either input.
    local function refreshTable()
        if not form then
            return
        end
        local item = isItemMode() and itemDisplay(selectedItem) or nil
        local factor = tonumber(form:getFieldValue("factor")) or 1
        local out = {}
        for _, r in ipairs(rows) do
            local now
            if usingItems then
                now = tostring(scaled(r.from, base.factor)) .. "x"
            else
                now = tools.formatCents(r.from)
                if r.to then
                    now = now .. " - " .. tools.formatCents(r.to)
                end
            end
            local after
            if item then
                after = tostring(scaled(r.from, factor)) .. "x " .. item
                if r.to then
                    after = tostring(scaled(r.from, factor)) .. " - " .. tostring(scaled(r.to, factor)) .. "x " .. item
                end
            else
                after = tools.formatCents(r.from)
                if r.to then
                    after = after .. " - " .. tools.formatCents(r.to)
                end
            end
            table.insert(out, {
                key = r.key,
                now = now,
                after = after
            })
        end
        form:setListItems("preview", out)
    end

    -- Only when there is something to undo. Its presence is itself the answer
    -- to "have I changed this", and offering a reset on an untouched install
    -- would suggest there is a mess to clean up.
    local customised = Core.isOverriddenKey and Core.isOverriddenKey("prices", BASE_KEY)

    form = FormPanel:new({
        width = math.floor(560 * FONT_SCALE),
        title = getText("IGUI_PhunMart_Cur_Title"),
        deleteLabel = getText("IGUI_PhunMart_Cur_Btn_Reset"),
        -- Deleting the override rather than writing the shipped values back.
        -- currency_base is a shipped key, so removing what sits on top of it
        -- restores the original by definition, and cannot drift from it later.
        onDelete = customised and function(f)
            sendClientCommand(Core.name, Core.commands.revertDefinition, {
                kind = "prices",
                key = BASE_KEY
            })
            PendingRestock.noteAllShops()
            f:close()
            if onDone then
                onDone()
            end
        end or nil,
        onApply = function(f)
            local result = Core.utils.deepCopy(base)
            if f:getFieldValue("kind") == KIND_ITEM then
                result.kind = "items"
                result.pool = nil
                result.amount = nil
                result.item = nil
                result.items = {{
                    item = selectedItem,
                    amount = 1
                }}
                local factor = tonumber(f:getFieldValue("factor")) or 1
                result.factor = factor
            else
                -- Back to the built in wallet. The item shape has to go or it
                -- would sit alongside the currency shape and win.
                result.kind = "currency"
                result.pool = "change"
                result.amount = 1
                result.item = nil
                result.items = nil
                result.factor = 1
            end

            sendClientCommand(Core.name, Core.commands.upsertPriceDef, {
                key = BASE_KEY,
                def = result
            })
            -- Every shop that sells anything priced from this tree, which is
            -- most of them, is now quoting the old money until it restocks.
            PendingRestock.noteAllShops()
            f:close()
            if onDone then
                onDone()
            end
        end
    })

    form:addSeparator("s_what", {
        text = getText("IGUI_PhunMart_Cur_Blurb")
    })
    form:addComboField("kind", getText("IGUI_PhunMart_Cur_Lbl_Kind"), {
        options = {KIND_CHANGE, KIND_ITEM},
        selected = usingItems and KIND_ITEM or KIND_CHANGE,
        hint = getText("IGUI_PhunMart_Cur_Hint_Kind"),
        onChange = function(f)
            local item = isItemMode()
            f:setFieldVisible("item", item)
            f:setFieldVisible("factor", item)
            refreshTable()
        end
    })
    form:addPickerField("item", getText("IGUI_PhunMart_Cur_Lbl_Item"), {
        value = selectedItem,
        display = itemDisplay(selectedItem),
        hint = getText("IGUI_PhunMart_Cur_Hint_Item"),
        conditional = true,
        onPick = function(f, field)
            ItemPicker.open(getSpecificPlayer(0), {selectedItem}, function(keys)
                selectedItem = keys and keys[1] or selectedItem
                f:setPickerValue("item", selectedItem, itemDisplay(selectedItem))
                refreshTable()
            end)
        end
    })
    form:addTextField("factor", getText("IGUI_PhunMart_Cur_Lbl_Factor"), {
        default = tostring(base.factor or 0.04),
        hint = getText("IGUI_PhunMart_Cur_Hint_Factor"),
        conditional = true,
        numeric = true,
        min = 0,
        onChange = refreshTable
    })
    form:addListField("preview", getText("IGUI_PhunMart_Cur_Lbl_Preview"), {
        rows = 8,
        columns = {{
            name = getText("IGUI_PhunMart_Col_Key"),
            size = 0
        }, {
            name = getText("IGUI_PhunMart_Cur_Col_Now"),
            size = 0.45
        }, {
            name = getText("IGUI_PhunMart_Cur_Col_After"),
            size = 0.72
        }},
        formatColumns = function(d)
            return {d.key, d.now, d.after}
        end
    })

    form:setFieldVisible("item", usingItems)
    form:setFieldVisible("factor", usingItems)

    form:initialise()
    form:addToUIManager()
    -- After, not before: the list widget is built when the window instantiates,
    -- and filling it earlier is silently dropped.
    refreshTable()
    form:bringToTop()
    return form
end

Core.ui.currency_tool = CurrencyTool
return CurrencyTool
