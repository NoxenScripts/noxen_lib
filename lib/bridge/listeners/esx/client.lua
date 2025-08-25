local bridge <const> = require 'lib.bridge.bridge';

bridge:RegisterNetEvent('esx', 'esx:playerLoaded', function(playerData)
    console.log(("ESX player loaded: %s"):format(json.encode(playerData, {indent=true})));
end);
