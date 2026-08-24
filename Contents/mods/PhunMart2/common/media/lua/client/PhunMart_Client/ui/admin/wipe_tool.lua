if isServer() then
    return
end

-- Clearing the player data a new world inherited from the old one.
--
-- See server/PhunMart_Server/wipe.lua for why any of this is necessary. The
-- short version: wallets, purchase history and the reward trackers are mirrored
-- to files that live beside the mod rather than inside the save, so wiping a
-- world leaves them behind and the next one starts with everybody's old money.
--
-- Nothing here decides anything. Each tracker is a tickbox with a sentence
-- saying what it holds and what clearing it costs, because "reset trackers" as
-- a single button is a request to guess.

local Core = PhunMart
local FormPanel = require "PhunMart_Client/ui/base/form_panel"

local WipeTool = {}

-- Last thing the server told us. Read by the Tools tab to label its row, so it
-- lives here rather than on any one panel.
WipeTool.pending = false
WipeTool.counts = {}

--- Anyone who wants to know when fresh status lands. The Tools tab rebuilds its
--- row from it, and the row is the only thing that ever says a wipe happened.
WipeTool.listeners = {}

function WipeTool.onStatus(fn)
    table.insert(WipeTool.listeners, fn)
end

local function publish(status)
    WipeTool.pending = status and status.pending or false
    WipeTool.counts = (status and status.counts) or {}
    for _, fn in ipairs(WipeTool.listeners) do
        fn(WipeTool)
    end
end

function WipeTool.request()
    sendClientCommand(Core.name, Core.commands.getWipeStatus, {})
end

--- How many records are left, across everything. What the Tools row reports,
--- since "3 wallets, 2 playtime" is more detail than a single line wants.
function WipeTool.total()
    local n = 0
    for _, v in pairs(WipeTool.counts) do
        n = n + (tonumber(v) or 0)
    end
    return n
end

---------------------------------------------------------------------------
-- The form
---------------------------------------------------------------------------

-- Order matters: wallets first because it is the one anybody came here for,
-- and `bound` immediately under it because it modifies the line above rather
-- than standing on its own.
local FIELDS = {{
    key = "wallets",
    label = "IGUI_PhunMart_Wipe_Wallets",
    hint = "IGUI_PhunMart_Wipe_WalletsHint",
    count = "wallets"
}, {
    key = "bound",
    label = "IGUI_PhunMart_Wipe_Bound",
    hint = "IGUI_PhunMart_Wipe_BoundHint"
}, {
    key = "purchases",
    label = "IGUI_PhunMart_Wipe_Purchases",
    hint = "IGUI_PhunMart_Wipe_PurchasesHint",
    count = "purchases"
}, {
    key = "playtime",
    label = "IGUI_PhunMart_Wipe_Playtime",
    hint = "IGUI_PhunMart_Wipe_PlaytimeHint",
    count = "playtime"
}, {
    key = "kills",
    label = "IGUI_PhunMart_Wipe_Kills",
    hint = "IGUI_PhunMart_Wipe_KillsHint",
    count = "kills"
}}

local function labelFor(spec)
    local text = getText(spec.label)
    if spec.count then
        text = text .. " (" .. tostring(WipeTool.counts[spec.count] or 0) .. ")"
    end
    return text
end

function WipeTool.open(player, onDone)
    local pending = WipeTool.pending

    local form
    form = FormPanel:new({
        width = math.floor(460 * FormPanel.FONT_SCALE),
        title = getText("IGUI_PhunMart_Wipe_Title"),
        onApply = function(f)
            local opts = {}
            local names = {}
            for _, spec in ipairs(FIELDS) do
                if f:getFieldValue(spec.key) then
                    opts[spec.key] = true
                    -- Without the count, so the confirmation reads as a list of
                    -- things rather than a row of numbers.
                    table.insert(names, getText(spec.label))
                end
            end

            local function send()
                sendClientCommand(Core.name, Core.commands.wipeTrackers, opts)
                f:close()
                if onDone then
                    onDone()
                end
            end

            if #names == 0 then
                -- Nothing ticked is a deliberate "keep it all". It still counts
                -- as having answered, so it still goes, and the prompt stops.
                send()
                return
            end

            local w = math.floor(420 * FormPanel.FONT_SCALE)
            local h = math.floor(220 * FormPanel.FONT_SCALE)
            local modal = ISModalDialog:new((getCore():getScreenWidth() - w) / 2,
                (getCore():getScreenHeight() - h) / 2, w, h,
                getText("IGUI_PhunMart_Confirm_Wipe", table.concat(names, ", ")), true, nil, function(_, button)
                    if button.internal == "YES" then
                        send()
                    end
                end)
            modal:initialise()
            modal:addToUIManager()
        end
    })

    for _, spec in ipairs(FIELDS) do
        form:addCheckField(spec.key, labelFor(spec), {
            -- Pre-ticked only when the server actually saw a wipe. Opened by
            -- hand on a running server this is a loaded gun, so every box
            -- starts empty and clearing anything is a deliberate act.
            checked = pending and spec.key ~= "bound",
            hint = getText(spec.hint),
            onChange = spec.key == "wallets" and function(f)
                -- Zeroing bound totals is meaningless unless the wallets are
                -- being touched at all.
                f:setFieldVisible("bound", f:getFieldValue("wallets") and true or false)
            end or nil
        })
    end

    form:initialise()
    form:addToUIManager()
    form:bringToTop()
    form:setFieldVisible("bound", form:getFieldValue("wallets") and true or false)
    return form
end

---------------------------------------------------------------------------
-- Commands
---------------------------------------------------------------------------

local Commands = {}

if Core.isLocal then

    -- Singleplayer shares the Lua state with the server files, so Core.wipe is
    -- right here. The server handlers bail out under Core.isLocal for the same
    -- reason the wallet ones do.
    Commands[Core.commands.getWipeStatus] = function(player, args)
        if not Core.wipe then
            return
        end
        publish({
            pending = Core.wipe.isPending(),
            counts = Core.wipe.counts()
        })
    end

    Commands[Core.commands.wipeTrackers] = function(player, args)
        if not Core.wipe then
            return
        end
        Core.wipe.clear(args or {})
        publish({
            pending = Core.wipe.isPending(),
            counts = Core.wipe.counts()
        })
        -- Balances moved, so the wallet grid is showing yesterday's numbers.
        if Core.ui.admin_wallet then
            for _, instance in pairs(Core.ui.admin_wallet.instances or {}) do
                if instance.refresh then
                    instance:refresh()
                end
            end
        end
    end

    Events.OnClientCommand.Add(function(module, command, playerObj, arguments)
        if module == Core.name and Commands[command] then
            Commands[command](playerObj, arguments)
        end
    end)

else

    Commands[Core.commands.getWipeStatus] = function(args)
        publish(args)
    end

    Events.OnServerCommand.Add(function(module, command, arguments)
        if module == Core.name and Commands[command] then
            Commands[command](arguments)
        end
    end)

end

Core.ui.wipe_tool = WipeTool
return WipeTool
