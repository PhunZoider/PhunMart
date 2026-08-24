if isServer() then
    return
end

-- Clearing player data on request: wallets, purchase history, reward tracking.
--
-- This started life as a wipe tool, because those four used to be kept in files
-- that outlived the world they belonged to and a new map inherited the old
-- one's balances. They live in ModData now, which ends that problem at the
-- source, so what is left is the plain admin action: clear this, for everybody,
-- now. See server/PhunMart_Server/player_data.lua.
--
-- Each tracker is a tickbox with a sentence saying what it holds and what
-- clearing it costs, because "reset player data" as a single button is a
-- request to guess.

local Core = PhunMart
local FormPanel = require "PhunMart_Client/ui/base/form_panel"

local PlayerDataTool = {}

-- Last counts the server sent. Read by the Tools tab to label its row, so it
-- lives here rather than on any one panel.
PlayerDataTool.counts = {}

PlayerDataTool.listeners = {}

function PlayerDataTool.onStatus(fn)
    table.insert(PlayerDataTool.listeners, fn)
end

local function publish(status)
    PlayerDataTool.counts = (status and status.counts) or {}
    for _, fn in ipairs(PlayerDataTool.listeners) do
        fn(PlayerDataTool)
    end
end

function PlayerDataTool.request()
    sendClientCommand(Core.name, Core.commands.getPlayerDataStatus, {})
end

--- How many records are held, across everything.
function PlayerDataTool.total()
    local n = 0
    for _, v in pairs(PlayerDataTool.counts) do
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
    label = "IGUI_PhunMart_Reset_Wallets",
    hint = "IGUI_PhunMart_Reset_WalletsHint",
    count = "wallets"
}, {
    key = "bound",
    label = "IGUI_PhunMart_Reset_Bound",
    hint = "IGUI_PhunMart_Reset_BoundHint"
}, {
    key = "purchases",
    label = "IGUI_PhunMart_Reset_Purchases",
    hint = "IGUI_PhunMart_Reset_PurchasesHint",
    count = "purchases"
}, {
    key = "playtime",
    label = "IGUI_PhunMart_Reset_Playtime",
    hint = "IGUI_PhunMart_Reset_PlaytimeHint",
    count = "playtime"
}, {
    key = "kills",
    label = "IGUI_PhunMart_Reset_Kills",
    hint = "IGUI_PhunMart_Reset_KillsHint",
    count = "kills"
}}

local function labelFor(spec)
    local text = getText(spec.label)
    if spec.count then
        text = text .. " (" .. tostring(PlayerDataTool.counts[spec.count] or 0) .. ")"
    end
    return text
end

function PlayerDataTool.open(player, onDone)
    local form
    form = FormPanel:new({
        width = math.floor(460 * FormPanel.FONT_SCALE),
        title = getText("IGUI_PhunMart_Reset_Title"),
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

            if #names == 0 then
                f:close()
                return
            end

            local w = math.floor(420 * FormPanel.FONT_SCALE)
            local h = math.floor(220 * FormPanel.FONT_SCALE)
            local modal = ISModalDialog:new((getCore():getScreenWidth() - w) / 2,
                (getCore():getScreenHeight() - h) / 2, w, h,
                getText("IGUI_PhunMart_Confirm_ResetData", table.concat(names, ", ")), true, nil, function(_, button)
                    if button.internal == "YES" then
                        sendClientCommand(Core.name, Core.commands.resetPlayerData, opts)
                        f:close()
                        if onDone then
                            onDone()
                        end
                    end
                end)
            modal:initialise()
            modal:addToUIManager()
        end
    })

    for _, spec in ipairs(FIELDS) do
        form:addCheckField(spec.key, labelFor(spec), {
            -- Every box starts empty. This clears data for every player at
            -- once, so ticking anything is a deliberate act rather than
            -- something an accidental Apply can do.
            checked = false,
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
    form:setFieldVisible("bound", false)
    return form
end

---------------------------------------------------------------------------
-- Commands
---------------------------------------------------------------------------

local Commands = {}

if Core.isLocal then

    -- Singleplayer shares the Lua state with the server files, so
    -- Core.playerData is right here. The server handlers bail out under
    -- Core.isLocal for the same reason the wallet ones do.
    local function status()
        return {
            counts = Core.playerData and Core.playerData.counts() or {}
        }
    end

    Commands[Core.commands.getPlayerDataStatus] = function(player, args)
        publish(status())
    end

    Commands[Core.commands.resetPlayerData] = function(player, args)
        if not Core.playerData then
            return
        end
        Core.playerData.clear(args or {})
        publish(status())
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

    Commands[Core.commands.getPlayerDataStatus] = function(args)
        publish(args)
    end

    Events.OnServerCommand.Add(function(module, command, arguments)
        if module == Core.name and Commands[command] then
            Commands[command](arguments)
        end
    end)

end

Core.ui.player_data_tool = PlayerDataTool
return PlayerDataTool
