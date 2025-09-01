local bridge <const> = require 'lib.bridge.bridge';

nox.events.on(eCitizenFXEvents.onResourceStart, function (_, resource)
    if (resource ~= nox.current_resource) then
        return;
    end

    Wait(2000); -- Wait for players to sync resource state

    local players <const> = bridge:GetPlayers();

    for i = 1, #players do
        if (not players[i]) then
            goto continue;
        end

        players[i]:TriggerResourceEvent(eLibEvents.playerLoaded, {
            identifier = players[i]:GetIdentifier(),
            job = players[i]:GetJob(),
            job2 = players[i]:GetJob2(),
            money = players[i]:GetAccountMoney('money'),
            black_money = players[i]:GetAccountMoney('black_money'),
            bank = players[i]:GetAccountMoney('bank'),
            inventory = players[i]:GetInventory(),
        });
        nox.events.emit.resource(eLibEvents.playerLoaded, players[i].source);
        ::continue::
    end

    nox.events.emit(eLibEvents.resourceRefreshed);
    console.debug(("Resource ^3%s^7 started, player data synced"):format(resource));
end);

bridge:AddPermissionCommand('admin', ('noxen:%s:state'):format(nox.current_resource), function(player, args, showNotification)
    local version <const> = GetResourceMetadata(nox.name, 'version', 0);
    showNotification(('Resource is running using ^3noxen_lib^7 version ^3%s^7, framework: ^3%s^7 version ^3%s^7'):format(version or 'unknown', bridge.name, bridge.version), 'info');
end, "Toggle debug state", { { name = "state", help = "on/off" } }, true);
