if isServer() then return end

require "PhunMart/core"
local Core = PhunMart
local tools = require "PhunMart_Client/ui/ui_utils"

-- ---------------------------------------------------------------------------
-- Toast notification system
-- Displays a slide-in panel from the right side of the screen.
-- Usage: Core.ui.toast.show({ text="...", icon="media/textures/...", duration=4, color={r=1,g=1,b=1} })
-- Multiple toasts are queued and displayed one at a time.
-- ---------------------------------------------------------------------------

local Toast = {}
Toast.queue   = {}
Toast.current = nil  -- the active ISPanel, or nil

-- Toast panel dimensions and positioning constants
local W           = 300
local H           = 64
local MARGIN      = 20   -- gap from screen edges
local HUD_OFFSET  = 80   -- pixels above bottom of screen (clears the HUD)
local PAD         = 14   -- inner padding, and where text starts without an icon
local MAX_LINES   = 2    -- the panel is 64 tall; a third line would not fit

-- Animation timing (real-world seconds)
local SLIDE_DURATION = 0.3
local FADE_DURATION  = 0.4

-- Show a toast. Options:
--   text     (string, required)  Message to display.
--   icon     (string, optional)  Texture path, e.g. "media/textures/Item_Token.png".
--   duration (number, optional)  Seconds to hold before fading out. Default: 4.
--   color    (table, optional)   Accent colour, {r=,g=,b=} or {r,g,b}. Default: gold.
function Toast.show(opts)
    if not opts or not opts.text then return end
    table.insert(Toast.queue, opts)
    Toast:_next()
end

-- Advance to the next queued toast. No-op if one is already showing.
function Toast:_next()
    if self.current ~= nil then return end
    if #self.queue == 0 then return end
    local opts = table.remove(self.queue, 1)
    self:_create(opts)
end

-- Create and register the ISPanel for a single toast notification.
function Toast:_create(opts)
    local sw = getCore():getScreenWidth()
    local sh = getCore():getScreenHeight()
    local targetX = sw - W - MARGIN
    local targetY = sh - H - HUD_OFFSET

    -- Start the panel off-screen to the right; slide animation moves it in.
    local panel = ISPanel:new(sw, targetY, W, H)
    panel:initialise()
    panel:addToUIManager()
    panel.moveWithMouse = false
    panel.alwaysOnTop   = true

    -- Accepts { r=, g=, b= } and { r, g, b } alike, and falls back to gold for
    -- anything else.
    --
    -- Everything below reads color.r, so a positional triple used to hand three
    -- nils to drawRect and drawText -- which fails as a NullPointerException
    -- from inside the render loop, once per frame, naming a Java method and no
    -- part of the call that caused it. Since other mods call this now, being
    -- forgiving here is worth more than being strict.
    local color = { r = 0.95, g = 0.78, b = 0.2 }
    if type(opts.color) == "table" then
        local given = opts.color
        local r = given.r or given[1]
        local g = given.g or given[2]
        local b = given.b or given[3]
        if type(r) == "number" and type(g) == "number" and type(b) == "number" then
            color = { r = r, g = g, b = b }
        end
    end
    local startTime = getTimestamp()
    local duration  = opts.duration or 4
    local text      = opts.text or ""
    local iconTex   = opts.icon and getTexture(opts.icon) or nil
    local owner     = self   -- capture reference for closure

    -- All drawing and animation handled in prerender (runs every frame).
    panel.prerender = function(self)
        local now     = getTimestamp()
        local elapsed = now - startTime
        local alpha   = 1.0

        if elapsed < SLIDE_DURATION then
            -- Slide in from the right (ease-out quad).
            local t     = elapsed / SLIDE_DURATION
            local eased = 1 - (1 - t) * (1 - t)
            local newX  = sw + (targetX - sw) * eased
            self:setX(newX)

        elseif elapsed < SLIDE_DURATION + duration then
            -- Hold phase: ensure panel is at the correct position.
            self:setX(targetX)

        else
            -- Fade-out phase.
            local fadeElapsed = elapsed - SLIDE_DURATION - duration
            alpha = math.max(0, 1 - fadeElapsed / FADE_DURATION)
            self:setX(targetX)
            if alpha <= 0 then
                self:setVisible(false)
                self:removeFromUIManager()
                owner.current = nil
                owner:_next()
                return
            end
        end

        -- Background
        self:drawRect(0, 0, W, H, alpha * 0.88, 0.06, 0.06, 0.06)
        -- Coloured left accent bar
        self:drawRect(0, 0, 4, H, alpha, color.r, color.g, color.b)
        -- Subtle top border
        self:drawRect(4, 0, W - 4, 1, alpha * 0.5, color.r, color.g, color.b)

        -- Optional icon
        local textX = PAD
        if iconTex then
            local iconSize = H - 16
            local iconY    = (H - iconSize) / 2
            self:drawTextureScaled(iconTex, PAD, iconY, iconSize, iconSize, alpha)
            textX = PAD + iconSize + 8
        end

        -- Message text, wrapped to the panel and centred as a block.
        --
        -- The panel is a fixed 300 wide and the text used to be drawn as one
        -- line from textX, so anything longer than the room left simply ran off
        -- the edge and over whatever was behind it. Callers cannot be expected
        -- to count pixels, and an item name is as long as the item is called.
        --
        -- Wrapped rather than shrunk: two lines of the same size read better at
        -- a glance than one line of smaller text, and a glance is all a toast
        -- gets. A third line will not fit in 64, so the second is truncated.
        local fontH = getTextManager():getFontHeight(UIFont.Small)
        local avail = W - textX - PAD
        local lines = tools.wrapText(text, avail, UIFont.Small)
        if #lines > MAX_LINES then
            lines[MAX_LINES] = lines[MAX_LINES] .. " " .. lines[MAX_LINES + 1]
            for i = #lines, MAX_LINES + 1, -1 do
                lines[i] = nil
            end
        end
        -- Every line, not only the one that absorbed the overflow: wrapText
        -- breaks on spaces and never inside a word, so a single long word --
        -- which is what a modded item with no spaces in its name is -- comes
        -- back as one line wider than the panel however many lines there are.
        for i, line in ipairs(lines) do
            lines[i] = tools.truncate(line, avail, UIFont.Small)
        end

        local blockH = #lines * fontH
        local textY = math.floor((H - blockH) / 2)
        for i, line in ipairs(lines) do
            self:drawText(line, textX, textY + (i - 1) * fontH, color.r, color.g, color.b, alpha, UIFont.Small)
        end
    end

    -- No additional drawing in render; prerender handles everything.
    panel.render = function(self) end

    self.current = panel
end

Core.ui.toast = Toast
return Toast
