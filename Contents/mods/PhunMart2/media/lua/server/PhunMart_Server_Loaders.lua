if not isServer() then
    return
end
local PhunMart = PhunMart

function PhunMart:loadAllItems()

    print("---------------------")
    print("-")
    print("- PhunMart: LOADING ITEMDEFS")
    print("-")
    print("---------------------")
    self.defs.items = {}
    self:loadFilesForItemQueue()
    self:processFilesToItemQueue()
    local results = self:processItemTransformQueue()
    local total = 0

    for k, v in pairs(results.all) do
        total = total + v
    end

    print("Added " .. results.all.success .. " items from:")

    for k, v in pairs(results.files) do
        print(" - Lua/" .. tostring(k) .. " loaded " .. tostring(v.success) .. " items")
    end

    results = self:validateItems()

    print("Validated " .. results.total .. " items")
    print(" - Skipped " .. (results.abstract + results.disabled) .. " as they were marked as abstract or disabled")
    print(" - " .. results.valid .. " items passed, " .. results.invalid .. " item failed")
    local header = false
    for k, v in pairs(results.issues) do
        if not header then
            print(" - The following issues were found (and the item was disabled):")
            header = true
        end
        print("\t" .. k)
        for _, issue in pairs(v) do
            print("\t- " .. issue)
        end
    end
end

function PhunMart:loadAllShops()
    print("---------------------")
    print("-")
    print("- PhunMart: LOADING Shops")
    print("-")
    print("---------------------")
    self.defs.shops = {}
    self:loadFilesForShopQueue()
    self:processFilesToShopQueue()
    local results = PhunMart:processShopTransformQueue()
    local total = 0
    for k, v in pairs(results.all) do
        total = total + v
    end

    print("Added " .. results.all.success .. " shops from:")

    for k, v in pairs(results.files) do
        print(" - Lua/" .. k .. " loaded " .. (v and v.success or 0) .. " items")
    end

    results = self:validateShops()

    print("Validated " .. results.total .. " shops")
    print(" - Skipped " .. (results.abstract + results.disabled) .. " as they were marked as abstract or disabled")
    print(" - " .. results.valid .. " shops passed, " .. results.invalid .. " shops failed")
    local header = false
    for k, v in pairs(results.issues) do
        if not header then
            print(" - The following issues were found (and the shop was disabled):")
            header = true
        end
        print("\t" .. k)
        for _, issue in pairs(v) do
            print("\t- " .. issue)
        end
    end

    for k, v in pairs(self.defs.shops) do
        if v.enabled then
            print(" - " .. k .. " is enabled")
        else
            print(" - " .. k .. " is disabled")
        end
    end

end

function PhunMart:loadAll()
    local startTime = getTimestampMs()
    self:loadAllItems()
    self:loadAllShops()
    print("====================================")
    print(" PhunMart Data Loaded in " .. PhunTools:differenceInSeconds(startTime, getTimestampMs()) .. " seconds")
    print("====================================")
end
