local bridge <const> = require 'lib.bridge.bridge';

bridge:RegisterNetEvent('qb', 'QBCore:Client:UpdateObject', function(obj)
    bridge.framework = obj;
    console.debug('QBCore framework updated');
end);

-- bridge:RegisterNetEvent('qb', 'QBCore:Player:SetPlayerData', function(playerData)
--     console.log(("QBCore player data updated: %s"):format(json.encode(playerData, {indent=true})));
-- end);
