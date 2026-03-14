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
