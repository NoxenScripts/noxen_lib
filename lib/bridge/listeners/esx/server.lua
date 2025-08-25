local bridge <const> = require 'lib.bridge.bridge';

---@param xPlayer noxen.lib.bridge.esx.player
bridge:AddEventHandler('esx', 'esx:playerLoaded', function(source, xPlayer)
    local player <const> = bridge:GetPlayer(source);

    if (not player) then
        return console.warn(("esx:playerLoaded - Player with source %s not found."):format(tostring(source)));
    end

    bridge.playersIdentifier[xPlayer.license] = player.source;

    console.debug("ESX player loaded", xPlayer);
end);

bridge:AddEventHandler('esx', 'esx:playerDropped', function(source)
    local player <const> = bridge:GetPlayer(source);

    if (not player) then
        return console.warn(("esx:playerDropped - Player with source ^3%s^7 not found."):format(tostring(source)));
    end

    bridge.playersIdentifier[player.handle.license] = nil;
end);
