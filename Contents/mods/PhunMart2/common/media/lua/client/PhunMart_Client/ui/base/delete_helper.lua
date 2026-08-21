if isServer() then
    return
end

local Core = PhunMart
local tools = require "PhunMart_Client/ui/ui_utils"
require "PhunMart/references"

local FONT_HGT_SMALL = tools.FONT_HGT_SMALL
local FONT_SCALE = tools.FONT_SCALE

---------------------------------------------------------------------------
-- Shared "delete a definition" flow for the admin list panels.
--
-- Delete means two different things depending on where the key comes from:
--   * admin-created (override file only) — genuinely removable
--   * shipped with the mod — the override layer sits on top of the defaults,
--     so removing the override restores the shipped version rather than
--     deleting it. Those can only be disabled.
-- Rather than presenting a dead button for the second case, the confirm says
-- which of the two you are about to get.
---------------------------------------------------------------------------
local DeleteHelper = {}

-- Categories that carry an `enabled` flag. Prices don't — there is nothing to
-- disable on one, so a shipped price is simply immovable.
local CAN_DISABLE = {
    pools = true,
    groups = true,
    items = true,
    specials = true,
    prices = false
}

local UPSERT_COMMAND = {
    pools = "upsertPoolDef",
    groups = "upsertGroupDef",
    items = "upsertItemDef",
    prices = "upsertPriceDef",
    specials = "upsertSpecialDef"
}

local function showModal(text, withYesNo, onYes)
    local lines = tools.wrapText(text, math.floor(340 * FONT_SCALE), UIFont.Small)
    local w = math.floor(380 * FONT_SCALE)
    local h = math.max(math.floor(130 * FONT_SCALE), #lines * FONT_HGT_SMALL + math.floor(90 * FONT_SCALE))
    local modal = ISModalDialog:new((getCore():getScreenWidth() - w) / 2, (getCore():getScreenHeight() - h) / 2, w, h,
        table.concat(lines, "\n"), withYesNo, nil, function(_, button)
            if button.internal == "YES" and onYes then
                onYes()
            end
        end)
    modal:initialise()
    modal:addToUIManager()
    return modal
end

-- Refresh once the recompile has actually landed. In singleplayer Core.defs is
-- updated in place before this returns, but in multiplayer the definitive
-- update arrives with the server's broadcast, so the caller's own refresh would
-- otherwise redraw the row it just deleted.
local function refreshWhenDefsLand(onDone)
    if not onDone then
        return
    end
    local handler
    handler = function()
        Events[Core.events.OnDefsUpdated].Remove(handler)
        onDone()
    end
    Events[Core.events.OnDefsUpdated].Add(handler)
    onDone()
end

local function doDelete(kind, key, onDone)
    sendClientCommand(Core.name, Core.commands.deleteDefinition, {
        kind = kind,
        key = key
    })
    refreshWhenDefsLand(onDone)
end

local function doDisable(kind, key, onDone)
    local def = (Core.defs and Core.defs[kind] or {})[key]
    if not def then
        return
    end
    local copy = Core.utils.deepCopy(def)
    copy.enabled = false
    sendClientCommand(Core.name, Core.commands[UPSERT_COMMAND[kind]], {
        key = key,
        def = copy
    })
    if not Core.isLocal and Core.defs and Core.defs[kind] then
        Core.defs[kind][key] = copy
    end
    refreshWhenDefsLand(onDone)
end

--- Ask about removing `key` from `kind`, then carry it out.
-- @param kind    "pools" | "groups" | "items" | "prices" | "specials"
-- @param key     definition key
-- @param onDone  called after the change is dispatched, to refresh the list
function DeleteHelper.confirm(kind, key, onDone)
    if not key then
        return
    end

    local found = Core.references.find(kind, key)
    local usedBy = ""
    if #found > 0 then
        usedBy = " " .. getText("IGUI_PhunMart_Confirm_UsedBy", Core.references.summarise(found))
    end

    if Core.isShippedKey(kind, key) then
        if CAN_DISABLE[kind] then
            showModal(getText("IGUI_PhunMart_Confirm_ShippedDisable", key) .. usedBy, true, function()
                doDisable(kind, key, onDone)
            end)
        else
            showModal(getText("IGUI_PhunMart_Confirm_ShippedOnly", key), false)
        end
        return
    end

    showModal(getText("IGUI_PhunMart_Confirm_Delete", key) .. usedBy, true, function()
        doDelete(kind, key, onDone)
    end)
end

return DeleteHelper
