require "PhunMart2/core"
local Core = PhunMart

Core.wallet = {
    name = "PhunMart_Wallet",
    log = "wallet.log",
    currencies = {
        ["PhunMart.QuarterCoin"] = {
            bound = false
        },
        ["PhunMart.SilverDollar"] = {
            bound = false
        },
        ["PhunMart.TraiterToken"] = {
            bound = true
        }
    }
}

function Core.wallet:isCurrency(item)
    return Core.wallet.currencies[item] ~= nil
end

function Core.wallet:isBound(item)
    return (Core.wallet.currencies[item] or {}).bound == true
end

function Core.wallet:get(player)
    local key = nil
    if self.data == nil then
        self.data = ModData.getOrCreate(self.name)
    end
    if Core.isLocal then
        key = 0
    elseif type(player) == "string" then
        key = player
    else
        key = player:getUsername()
    end
    if key then
        if not self.data[key] then
            self.data[key] = {
                current = {},
                bound = {},
                purchases = {}
            }
        end
        return self.data[key]
    end
end

function Core.wallet:setPlayerData(player, data)
    local w = self:get(player) -- ensure it has at least default
    self.data[player] = data
end

function Core.wallet:reset(player)

    local name = type(player) == "string" and player or player:getUsername()

    if isClient() then
        -- tell the server to do the same thing
        sendClientCommand(Core.name, Core.commands.resetWallet, {
            username = name
        })
    end

    local w = self:get(name)

    for k, v in pairs(self.currencies) do

        if (w.current[k] or 0) > 0 then
            -- deduct current amount
            Core.tools.logTo(self.log, name, k, 0 - w.current[k])
            w.current[k] = 0
        end

        if v.bound then
            -- overwrite any bound amount
            if (w.bound[k] or 0) > 0 then
                w.current[k] = w.bound[k]
                Core.tools.logTo(self.log, name, k, w.current[k])
            end
        end
    end
end

function Core.wallet:adjustByType(player, walletType, item, amount)
    local name = type(player) == "string" and player or player:getUsername()
    local w = self:get(name)
    if w then
        w[walletType][item] = (w[walletType][item] or 0) + amount
        Core.tools.logTo(self.log, name, item, amount)
    end
end

function Core.wallet:adjust(player, item, amount)

    local name = type(player) == "string" and player or player:getUsername()
    -- print("Adjusting wallet for ", tostring(name), tostring(item), tostring(amount))
    local w = self:get(name)
    if w then
        w.current[item] = (w.current[item] or 0) + (amount or 1)
        -- TODO: If bound, adjust bound wallet
        if self.currencies[item].bound then
            w.bound[item] = (w.bound[item] or 0) + (amount or 1)
        end
        if isClient() then
            -- add to queue to send to server
            if not self.queue then
                self.queue = require "PhunMart2/itemqueue"
                self.queue.module = Core.name
                self.queue.sendCommand = Core.commands.addToWallet
            end
            self.queue:add(player, item, amount or 1)
        end

        Core.tools.logTo(self.log, name, item, amount or 1)

    end
end
