if isServer() then return end

require "PhunMart/core"
local Core = PhunMart

-- ---------------------------------------------------------------------------
-- Toast notification system
-- Displays a slide-in panel from the right side of the screen.
-- Usage: Core.ui.toast.show({ text="...", icon="media/textures/...", duration=4, color={r,g,b} })
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

-- Animation timing (real-world seconds)
local SLIDE_DURATION = 0.3
local FADE_DURATION  = 0.4

-- Show a toast. Options:
--   text     (string, required)  Message to display.
--   icon     (string, optional)  Texture path, e.g. "media/textures/Item_Token.png".
--   duration (number, optional)  Seconds to hold before fading out. Default: 4.
--   color    ({r,g,b}, optional) Accent colour. Default: gold.
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

    local color     = opts.color or { r = 0.95, g = 0.78, b = 0.2 }
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
        local textX = 14
        if iconTex then
            local iconSize = H - 16
            local iconY    = (H - iconSize) / 2
            self:drawTextureScaled(iconTex, 14, iconY, iconSize, iconSize, alpha)
            textX = 14 + iconSize + 8
        end

        -- Message text (single line, vertically centred)
        local fontH = getTextManager():getFontHeight(UIFont.Small)
        local textY = math.floor((H - fontH) / 2)
        self:drawText(text, textX, textY, color.r, color.g, color.b, alpha, UIFont.Small)
    end

    -- No additional drawing in render; prerender handles everything.
    panel.render = function(self) end

    self.current = panel
end

Core.ui.toast = Toast
return Toast
