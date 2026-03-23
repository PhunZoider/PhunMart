if isServer() then
    return
end
local Core = PhunMart
Core.contexts = {}

Core.contexts.open = function(player, context, worldobjects, test)
    local obj
    local playerObj = getSpecificPlayer(player)
    local isShop = false
    local wsq = nil

    for _, wObj in ipairs(worldobjects) do -- find object to interact with; code support for controllers
        obj = Core.ClientSystem.instance:getLuaObjectOnSquare(wObj:getSquare())

        -- If the machine was moved (pickup + place), the global object's stored
        -- coordinates are stale.  Detect the mismatch and fix both sides.
        if obj then
            local sq = wObj:getSquare()
            local sqX, sqY, sqZ = sq:getX(), sq:getY(), sq:getZ()
            if obj.x ~= sqX or obj.y ~= sqY or obj.z ~= sqZ then
                local oldX, oldY, oldZ = obj.x, obj.y, obj.z
                obj.x = sqX
                obj.y = sqY
                obj.z = sqZ
                -- Patch the IsoObject's modData so subsequent reads are correct.
                local iso = obj:getIsoObject()
                if iso then
                    local md = iso:getModData()
                    md.x = sqX
                    md.y = sqY
                    md.z = sqZ
                end
                -- Tell the server to migrate its global object + instance data.
                Core.ClientSystem.instance:sendCommand(playerObj, Core.commands.relocateShop, {
                    oldX = oldX,
                    oldY = oldY,
                    oldZ = oldZ,
                    newX = sqX,
                    newY = sqY,
                    newZ = sqZ
                })
                Core.debugLn("context: relocated shop from " .. oldX .. "," .. oldY .. "," .. oldZ .. " to " .. sqX ..
                                 "," .. sqY .. "," .. sqZ)
            end
        end

        -- Fallback: if no global object but the IsoObject has a PhunMart sprite,
        -- try to register it on the spot (recovers orphaned machines).
        if not obj then
            local sq = wObj:getSquare()
            local objects = sq:getObjects()
            for i = 0, objects:size() - 1 do
                local iso = objects:get(i)
                local sprite = iso:getSprite()
                if sprite then
                    local cn = sprite:getProperties():get("CustomName")
                    if cn and Core.shops[cn] then
                        Core.ClientSystem.instance:checkObjectAdded(iso)
                        obj = Core.ClientSystem.instance:getLuaObjectOnSquare(sq)
                        break
                    end
                end
            end
        end
        if obj then
            isShop = true
            wsq = wObj:getSquare()
            local text = getText("IGUI_PhunMart_Open_X", getText("IGUI_PhunMart_Shop_" .. obj.type))
            local desc = getText("IGUI_PhunMart_Shop_" .. obj.type .. "_tooltip")
            local disabled = false
            if obj.powered then
                if not obj:getSquare():haveElectricity() and SandboxVars.ElecShutModifier > -1 and
                    GameTime:getInstance():getNightsSurvived() > SandboxVars.ElecShutModifier then
                    desc = getText("IGUI_PhunMart_Open_X_nopower_tooltip", getText("IGUI_PhunMart_Shop_" .. obj.type))
                    disabled = true
                end
            end
            local option = context:addOptionOnTop(text, getSpecificPlayer(player), function()

                local o = Core.ClientSystem.instance:getLuaObjectOnSquare(wObj:getSquare())

                local square = o:getFrontSquare()
                if not square then
                    return
                end

                ISTimedActionQueue.add(ISWalkToTimedAction:new(playerObj, square))
                ISTimedActionQueue.add(Core.actions.openShop:new(playerObj, o))

            end)

            local toolTip = ISToolTip:new();
            toolTip:setVisible(false);
            toolTip:setName(getText("IGUI_PhunMart_Shop_" .. obj.type));
            toolTip.description = desc;
            option.notAvailable = disabled
            option.toolTip = toolTip;
        end
        break
    end
end
