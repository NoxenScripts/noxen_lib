local bridge <const> = require 'lib.bridge.bridge';

bridge:AddEventHandler('qb', 'QBCore:Server:UpdateObject', function(obj)
    bridge.framework = obj;
    console.debug('QBCore framework updated');
end);

---@param player noxen.lib.bridge.qb.player
bridge:AddEventHandler('qb', 'QBCore:Server:PlayerLoaded', function(player)
    bridge.playersIdentifier[player.PlayerData.license] = player.PlayerData.source;
end);

bridge:AddEventHandler('qb', 'QBCore:Server:OnPlayerUnload', function(source)
    local player <const> = bridge:GetPlayer(source);

    if (not player) then
        return console.warn(("QBCore:Server:OnPlayerUnload - Player with source ^3%s^7 not found."):format(tostring(source)));
    end

    bridge.playersIdentifier[player.handle.PlayerData.license] = nil;
end);
