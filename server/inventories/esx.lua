---@param source integer
---@return table?
local function getPlayerObject(source)
    return Bridge.esx().GetPlayerFromId(source)
end

---@type NoxenInventoryAdapter
Bridge.inventories.esx = {
    getCount = function(source, item)
        local xPlayer = getPlayerObject(source)
        local entry = xPlayer and xPlayer.getInventoryItem(item)
        return entry and entry.count or 0
    end,

    getItems = function(source)
        local xPlayer = getPlayerObject(source)
        return xPlayer and xPlayer.getInventory() or {}
    end,

    add = function(source, item, count)
        local xPlayer = getPlayerObject(source)
        return xPlayer ~= nil and xPlayer.addInventoryItem(item, count) == true
    end,

    remove = function(source, item, count)
        local xPlayer = getPlayerObject(source)
        return xPlayer ~= nil and xPlayer.removeInventoryItem(item, count) == true
    end,

    canCarry = function(source, item, count)
        local xPlayer = getPlayerObject(source)
        return xPlayer ~= nil and xPlayer.canCarryItem(item, count) == true
    end,

    getItem = function(item)
        local data = Bridge.esx().GetItems()[item]
        return data and { name = item, label = data.label, weight = data.weight } or nil
    end,
}
