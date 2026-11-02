---@type NoxenInventoryAdapter
Bridge.inventories.ox = {
    getCount = function(source, item, metadata)
        return exports.ox_inventory:GetItemCount(source, item, metadata) or 0
    end,

    getItems = function(source)
        return exports.ox_inventory:GetInventoryItems(source) or {}
    end,

    add = function(source, item, count, metadata)
        local success = exports.ox_inventory:AddItem(source, item, count, metadata)
        return success == true
    end,

    remove = function(source, item, count, metadata)
        return exports.ox_inventory:RemoveItem(source, item, count, metadata) == true
    end,

    canCarry = function(source, item, count, metadata)
        return exports.ox_inventory:CanCarryItem(source, item, count, metadata) == true
    end,

    getItem = function(item)
        local data = exports.ox_inventory:Items(item)
        return data and { name = data.name, label = data.label, weight = data.weight } or nil
    end,
}
