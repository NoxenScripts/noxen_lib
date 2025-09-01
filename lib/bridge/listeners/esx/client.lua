local bridge <const> = require 'lib.bridge.bridge';

-- bridge:RegisterNetEvent('esx', 'esx:playerLoaded', function(playerData)
--     console.log(("ESX player loaded: %s"):format(json.encode(playerData, {indent=true})));
-- end);

bridge:AddEventHandler('esx', 'esx:setPlayerData', function(key, value)
    local invoking <const> = GetInvokingResource();

    if (invoking ~= 'es_extended') then
        return console.warn(("esx:setPlayerData - Invalid invoking resource ^3%s^7."):format(tostring(invoking)));
    end

    if (key ~= 'inventory') then
        return;
    end

    bridge.player.data[key] = {};

    for i = 1, #value do
        bridge.player.data[key][#bridge.player.data[key] + 1] = value[i] and {
            name = value[i].name,
            label = value[i].label,
            weight = value[i].weight,
            amount = type(value[i].count) == 'number' and value[i].count or value[i].amount,
            usable = type(value[i].usable) == 'boolean' and value[i].usable == true
        } or nil;
    end
    console.debug(('Updated player data ^3%s^7 to ^2%s^7'):format(key, json.encode(bridge.player.data[key], {indent=true})));
end);

nox.events.on.secure('ox_inventory:updateSlots', function(_, data)
    local inventory <const> = table.clone(bridge.player.data['inventory']);
    bridge.player.data['inventory'] = {};

    console.debug(('(^3ox_inventory^7) Received inventory update with ^3%s^7 items. Old inventory had ^3%s^7 items.'):format(#data, #inventory));

    for i = 1, #data do
        if (data[i].inventory ~= nox.bridge.player.source) then
            goto continue;
        end

        local exists <const> = table.filter(inventory, function(_, item)
            return item.name == data[i].item.name;
        end, true);

        if (exists ~= nil) then
            exists.amount = data[i].item and type(data[i].item.count) == 'number' and data[i].item.count or items[i].amount;
        end

        bridge.player.data['inventory'][#bridge.player.data['inventory'] + 1] = data[i].item and data[i].item.name and {
            name = data[i].item.name,
            label = data[i].item.label,
            weight = data[i].item.weight,
            amount = type(data[i].item.count) == 'number' and data[i].item.count or data[i].amount,
            usable = type(data[i].item.usable) == 'boolean' and data[i].item.usable == true
        } or nil;
        ::continue::
    end
    console.debug(('(^3ox_inventory^7) Updated player data ^3%s^7 to ^2%s^7'):format('inventory', json.encode(bridge.player.data['inventory'], {indent=true})));
end);
