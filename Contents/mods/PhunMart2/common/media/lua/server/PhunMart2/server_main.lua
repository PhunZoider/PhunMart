if isClient() then
    return
end
local Core = PhunMart
Core.instances = {}

function Core.compile()

    local ctx = {
        prices = Core.tools.loadTable("PhunMart2_Prices.lua"),
        rewards = Core.tools.loadTable("PhunMart2_Rewards.lua"),
        conditionsDefs = Core.tools.loadTable("PhunMart2_Conditions.lua"),
        items = Core.tools.loadTable("PhunMart2_Items.lua"),
        groups = Core.tools.loadTable("PhunMart2_Groups.lua"),
        pools = Core.tools.loadTable("PhunMart2_Pools.lua"),
        shops = Core.tools.loadTable("PhunMart2_Shops.lua")
    }

    local runtime, log = Core.compiler.compileAll(ctx)
    Core.runtime = runtime
    Core.tools.debug("Warn", log.warnings, "Errors", log.errors)
    return runtime, log

end

function Core:addInstance(instance)
    self.instances[instance.key] = instance
end
function Core:removeInstance(instance)
    self.instances[instance.key] = nil
end

function Core:getInstanceDistancesFrom(x, y)
    local results = {}
    for k, v in pairs(self.shops) do
        if v.enabled ~= false then
            results[k] = 9999999
        end
    end

    for k, v in pairs(self.instances) do
        if results[v.key] then

            local dx = x - v.x
            local dy = y - v.y
            local distance = math.sqrt(dx * dx + dy * dy)
            if distance < results[v.key] then
                results[v.key] = distance
            end
        else
            print("PhunMart Error: No shop with key " .. k)
        end
    end

    return results
end

function Core:getPoolItems(pool)
    local items = {}
    local filters = pool.filters or {}

    if filters.items then
        local allItems = Core.getAllItems()
        for _, v in ipairs(allItems) do
            if not filters.items.exclude[v.type] then
                if filters.items.include[v.type] or filters.items.categories[v.category] then
                    table.insert(items, {
                        type = v.type,
                        label = v.label,
                        category = v.category,
                        texture = v.texture,
                        source = "items"
                    })
                end
            end
        end
    end

    if filters.vehicles then
        local allCars = Core.getAllVehicles()
        for _, v in ipairs(allCars) do
            if not filters.vehicles.exclude[v.type] then
                if filters.vehicles.include[v.type] or filters.vehicles.categories[v.category] then
                    table.insert(items, {
                        type = v.type,
                        label = v.label,
                        category = v.category,
                        source = "vehicles"
                    })
                end
            end
        end
    end

    if filters.traits then
        local allTraits = Core.getAllTraits()
        for _, v in ipairs(allTraits) do
            if not filters.traits.exclude[v.type] then
                if filters.traits.include[v.type] or filters.traits.categories[v.category] then
                    table.insert(items, {
                        type = v.type,
                        label = v.label,
                        category = v.category,
                        texture = v.texture,
                        source = "traits"
                    })
                end
            end
        end
    end

    if filters.xp then
        local allXp = Core.getAllXp()
        for _, v in ipairs(allXp) do
            if not filters.xp.exclude[v.type] then
                if filters.xp.include[v.type] or filters.xp.categories[v.category] then
                    table.insert(items, {
                        type = v.type,
                        label = v.label,
                        category = v.category,
                        texture = v.texture,
                        source = "xp"
                    })
                end
            end
        end
    end

    if filters.boosts then
        local allBoosts = Core.getAllBoosts()
        for _, v in ipairs(allBoosts) do
            if not filters.boosts.exclude[v.type] then
                if filters.boosts.include[v.type] or filters.boosts.categories[v.category] then
                    table.insert(items, {
                        type = v.type,
                        label = v.label,
                        category = v.category,
                        texture = v.texture,
                        source = "boosts"
                    })
                end
            end
        end
    end

    table.sort(items, function(a, b)
        return a.label:lower() < b.label:lower()
    end)

    return items
end

function Core:ini()
    self.inied = true
    self.instances = ModData.getOrCreate(self.name)
    self.lastStart = getTimestamp()
    Core.ServerSystem.instance:removeInvalidInstanceData()
    Core.compile()
    Core.debug("Server System initialized", self:getShops())
    triggerEvent(self.events.OnReady, self)
end
