if isServer() then
    return
end
require "TimedActions/ISBaseTimedAction"
local Core = PhunMart
Core.actions.openShop = ISBaseTimedAction:derive("PhunMart_Actions_OpenShop")
local action = Core.actions.openShop

-- ─────────────────────────────────────────────────────────────────────────────
-- Open-shop timed action
--
-- Flow:
--   start()   → play animation, immediately send openShop request to server
--   update()  → poll Core.pendingShopData for the response;
--               call resetJobDelta() each tick until BOTH the animation has
--               played through AND the server data has arrived, so the action
--               never completes early
--   perform() → open the shop UI (guaranteed: called only after both ready);
--               also acts as a fallback if perform() fires before update() on
--               the same tick that delta first reached maxTime
--   stop()    → player cancelled (walked away) – clean up pending data
-- ─────────────────────────────────────────────────────────────────────────────

function action:isValidStart()
    local shopDef = Core.defs and Core.defs.shops and Core.defs.shops[self.shopObj.type]
    if shopDef and shopDef.powered then
        local hasPower = self.shopObj:getSquare():haveElectricity() or
            (SandboxVars.ElecShutModifier > -1 and
             GameTime:getInstance():getNightsSurvived() < SandboxVars.ElecShutModifier)
        if not hasPower then
            self.character:Say(getText("IGUI_PhunMart_Open_X_nopower_tooltip",
                getText("IGUI_PhunMart_Shop_" .. self.shopObj.type)))
            return false
        end
    end
    return true
end

function action:isValid()
    return true
end

function action:waitToStart()
    self.character:faceLocation(self.shopObj.x, self.shopObj.y)
    return self.character:isTurning() or self.character:shouldBeTurning()
end

-- ── start ─────────────────────────────────────────────────────────────────────

function action:start()
    self:setActionAnim("Loot")
    self.character:SetVariable("LootPosition", "Mid")

    self.animDone = false
    self.shopData = nil
    self.uiOpened = false
    self.waitTicks = 0

    -- Send the openShop request immediately so server processing overlaps
    -- with the animation.  The response will arrive in Core.pendingShopData.
    Core.ClientSystem.instance:openShop(self.character, self.shopObj)
end

-- ── update ────────────────────────────────────────────────────────────────────

function action:update()

    -- 1. Detect when the animation has played all the way through.
    --    (getJobDelta() >= 1 means delta has reached maxTime this tick.)
    if not self.animDone and self:getJobDelta() >= 1 then
        self.animDone = true
    end

    -- 2. Poll for the server response stored by client_commands.lua.
    if not self.shopData then
        local pending = Core.pendingShopData
        if pending then
            local key = self.shopObj:getKey()
            local data = pending[key]
            if data then
                pending[key] = nil
                if data.error then
                    -- Server rejected (e.g. power cut between click and response)
                    self:forceStop()
                    return
                end
                self.shopData = data
            end
        end
    end

    -- 3. Both animation done AND data received → open the UI and allow the
    --    action to complete naturally (don't reset delta).
    if self.animDone and self.shopData then
        if not self.uiOpened then
            self.uiOpened = true
            Core.ui.client.shop.open(self.character, self.shopData)
        end
        return -- do NOT call resetJobDelta(); perform() will fire next
    end

    -- 4. Animation finished but still waiting for data → freeze the progress
    --    bar just below 100% so perform() is not called prematurely.
    --    Abort if the server hasn't responded within ~10 seconds (200 ticks).
    if self.animDone then
        self.waitTicks = (self.waitTicks or 0) + 1
        if self.waitTicks > 200 then
            print("[PhunMart2] openShop timed out waiting for server response")
            self:forceStop()
            return
        end
        self:resetJobDelta()
    end
end

-- ── perform ───────────────────────────────────────────────────────────────────

function action:perform()
    -- Fallback: cover the case where perform() fires in the same tick that
    -- delta first hit maxTime, before update() had a chance to set uiOpened.
    if not self.uiOpened and self.shopData then
        self.uiOpened = true
        Core.ui.client.shop.open(self.character, self.shopData)
    end
    ISBaseTimedAction.perform(self)
end

-- ── stop (cancelled) ──────────────────────────────────────────────────────────

function action:stop()
    -- Remove any pending data so it doesn't accidentally open a future action.
    local key = self.shopObj and self.shopObj:getKey()
    if key and Core.pendingShopData then
        Core.pendingShopData[key] = nil
    end
    ISBaseTimedAction.stop(self)
end

-- ── constructor ───────────────────────────────────────────────────────────────

function action:new(character, shopObj, time)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    o.character = character
    o.shopObj = shopObj
    o.complete = false
    o.stopOnWalk = true
    o.stopOnRun = true
    o.maxTime = time or 50
    if o.character:isTimedActionInstant() then
        o.maxTime = 1
    end
    return o
end
