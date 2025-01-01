if isServer() then
    return
end
local sandbox = SandboxVars.PhunMart

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)
local FONT_HGT_LARGE = getTextManager():getFontHeight(UIFont.Large)
local FONT_SCALE = FONT_HGT_SMALL / 14
local HEADER_HGT = FONT_HGT_MEDIUM + 2 * 2

local PM = PhunMart
PhunMartUIShopSprites = ISPanelJoypad:derive("PhunMartUIShopSprites");
local UI = PhunMartUIShopSprites

function UI:new(x, y, width, height, options)
    local opts = options or {}
    local o = ISPanelJoypad:new(x, y, width, height);
    setmetatable(o, self);
    o.player = opts.player or getPlayer()
    o.playerIndex = o.player:getPlayerNum()

    -- o.backgroundColor = {
    --     r = 1,
    --     g = 0,
    --     b = 0,
    --     a = 0.8
    -- };

    self.instance = o;
    return o;
end

function UI:createChildren()
    ISPanelJoypad.createChildren(self)

    local padding = 10
    local x = padding
    local y = HEADER_HGT - 1

    self.selection = ISComboBox:new(x, y, self:getWidth() - (padding * 2), FONT_HGT_MEDIUM, self, function()
        self:setSelection(self.selection.selected)
    end);
    self.selection:initialise()
    self:addChild(self.selection)

    y = y + self.selection:getHeight() + padding

    self.sprite = ISPanel:new(0, y, self.width, self.height - y - padding - 100)
    self.sprite.background = false
    self.sprite:initialise()
    self.sprite.render = function(self)
        if self.parent.texture then
            self:drawTextureScaledAspect(self.parent.texture, 0, 0, self:getWidth(), self:getHeight(), 1)
        end
    end
    self:addChild(self.sprite)

end

function UI:setSelection(selection)
    self.selection.selected = selection
    local opts = self.selection.options[self.selection.selected]
    local data = opts.data
    if data then
        local texture = getTexture(data.k)
        self.texture = texture
    else
        self.texture = nil
    end
end

function UI:setData(data)

    self.selection:clear()
    self.selection:addOption("")
    self.selection.selected = 1
    if not data then
        return
    end

    local i = 0
    for k, v in pairs(data.spriteMap) do
        i = i + 1
        local title = k
        if i < 5 then
            title = k .. " - " .. v
        else
            title = k .. " - " .. v .. " (disabled)"
        end
        self.selection:addOptionWithData(title, {
            k = k,
            v = v
        })
    end

    if i > 0 then
        self:setSelection(2)
    end

end
