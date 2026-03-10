require("PhunMart2/core")
local Core = PhunMart

Core.purchases = {}

local function getCharname(player)
    return tostring(player:getDescriptor():getForename() .. " " .. player:getDescriptor():getSurname())
end

function Core.purchases:get(player)

    if not player then
        return nil
    end
    local username = player:getUsername()
    if not self.histories then
        self.histories = {}
    end
    if not self.histories[username] then
        self.histories[username] = {}
    end
    return self.histories[username]

end

function Core.purchases:add(player, key, value)
    local purchases = self:get(player)
    local charname = getCharname(player)
    if not purchases[charname] then
        purchases[charname] = {}
    end
    if not purchases[charname][key] then
        purchases[charname][key] = {}
    end
    table.insert(purchases[charname][key], {
        value = value or 1,
        timestamp = getTimestamp(),
        age = GameTime:getInstance():getWorldAgeHours()
    })
end

function Core.purchases:getEntries(player, key, windowSeconds)

    local purchases = self:get(player)
    local charname = getCharname(player)

    local now = getTimestamp()

    local total = 0
    local charTotal = 0

    local totals = {}
    local charTotals = {}

    for c, histories in pairs(purchases) do
        local entry = histories[key]
        if entry then
            if windowSeconds then
                if now - entry.timestamp <= windowSeconds then
                    table.insert(totals, entry.value or 1)
                    total = total + 1
                    if c == charname then
                        table.insert(charTotals, entry.value or 1)
                        charTotal = charTotal + 1
                    end
                end
            else
                table.insert(totals, entry.value or 1)
                total = total + 1
                if c == charname then
                    table.insert(charTotals, entry.value or 1)
                    charTotal = charTotal + 1
                end
            end
        end
    end

    return {
        total = total,
        charTotal = charTotal,
        all = totals,
        current = charTotals
    }
end

function Core.purchases:getCount(player, isCharacter, key, windowSeconds)
    local entries = self:getEntries(player, key, windowSeconds)
    if isCharacter then
        return entries.charTotal
    else
        return entries.total
    end
end

function Core.purchases:load()
    self.histories = Core.tools.loadTable("PhunMart2_Purchases.lua")
end

function Core.purchases:save()
    Core.tools.saveTable("PhunMart2_Purchases.lua", self.histories or {})
end
