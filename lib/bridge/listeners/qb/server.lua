local bridge <const> = require 'lib.bridge.bridge';

bridge:AddEventHandler('qb', 'QBCore:Server:UpdateObject', function(obj)
    bridge.framework = obj;
    console.debug('QBCore framework updated');
end);

---@param player noxen.lib.bridge.qb.player
bridge:AddEventHandler('qb', 'QBCore:Server:PlayerLoaded', function(player)
    bridge.playersIdentifier[player.PlayerData.license] = player.PlayerData.source;
    nox.events.emit.resource(eLibEvents.playerLoaded, player.PlayerData.source);
end);

bridge:AddEventHandler('qb', 'QBCore:Player:SetPlayerData', function(data)
    local player <const> = bridge:GetPlayer(data.source);

    if (not player) then
        return console.warn(("QBCore:Player:SetPlayerData - Player with source ^3%s^7 not found."):format(data.source));
    end

    local data <const> = {
        identifier = player:GetIdentifier(),
        job = player:GetJob(),
        job2 = player:GetJob2(),
        money = player:GetAccountMoney('money'),
        black_money = player:GetAccountMoney('black_money'),
        bank = player:GetAccountMoney('bank'),
        inventory = player:GetInventory()
    };

    player:TriggerResourceEvent(eLibEvents.playerLoaded, data);
end);

bridge:AddEventHandler('qb', 'QBCore:Server:OnPlayerUnload', function(source)
    local player <const> = bridge:GetPlayer(source);

    if (not player) then
        return console.warn(("QBCore:Server:OnPlayerUnload - Player with source ^3%s^7 not found."):format(tostring(source)));
    end

    bridge.playersIdentifier[player.handle.PlayerData.license] = nil;
end);
