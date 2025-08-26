local bridge <const> = require 'lib.bridge.bridge';

nox.events.on.secure(('noxen_lib_%s:bridge:player:setPlayerData'):format(nox.current_resource), function(_, data)
    assert(type(data) == 'table', 'Invalid player data sent from the server');

    for k, v in pairs(data) do
        bridge.player.data[k] = v;
        console.debug(('Updated player data ^3%s^7 to ^2%s^7'):format(k, tostring(v)));
    end
end);
