---@param item string
---@return table?
local function getSharedItem(item)
    return exports['qb-core']:GetShared('Items', item:lower())
end

---@param source integer
---@param item string
---@param action 'add'|'remove'
---@param count integer
local function showItemBox(source, item, action, count)
    TriggerClientEvent('qb-inventory:client:ItemBox', source, getSharedItem(item), action, count)
end

---@type NoxenInventoryAdapter
Bridge.inventories.qb = {
    getCount = function(source, item)
        return exports['qb-inventory']:GetItemCount(source, item) or 0
    end,

    getItems = function(source)
        local player = Bridge.qb().Functions.GetPlayer(source)
        return player and player.PlayerData.items or {}
    end,

    add = function(source, item, count, metadata, reason)
        local added = exports['qb-inventory']:AddItem(source, item, count, false, metadata or false, reason) == true

        if added then
            showItemBox(source, item, 'add', count)
        end

        return added
    end,

    remove = function(source, item, count, _, reason)
        local removed = exports['qb-inventory']:RemoveItem(source, item, count, false, reason) == true

        if removed then
            showItemBox(source, item, 'remove', count)
        end

        return removed
    end,

    canCarry = function(source, item, count)
        return exports['qb-inventory']:CanAddItem(source, item, count) == true
    end,

    getItem = function(item)
        local data = getSharedItem(item)
        return data and { name = data.name, label = data.label, weight = data.weight } or nil
    end,

    registerStash = function() end,

    openStash = function(source, id, label, slots, weight)
        exports['qb-inventory']:OpenInventory(source, id, { label = label, maxweight = weight, slots = slots })
        return true
    end,
}
