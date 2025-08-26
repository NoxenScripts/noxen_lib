local bridge <const> = require 'lib.bridge.bridge';

nox.events.on(eCitizenFXEvents.onResourceStart, function (_, src, resource)
    if (resource ~= nox.current_resource) then
        return;
    end

    Wait(2000); -- Wait for players to sync resource state

    local players <const> = bridge:GetPlayers();

    for i = 1, #players do
        if (not players[i]) then
            goto continue;
        end

        players[i]:TriggerEvent(('noxen_lib_%s:bridge:player:setPlayerData'):format(nox.current_resource), {
            identifier = players[i]:GetIdentifier(),
            job = players[i]:GetJob(),
            job2 = players[i]:GetJob2(),
            money = players[i]:GetAccountMoney('money'),
            black_money = players[i]:GetAccountMoney('black_money'),
            bank = players[i]:GetAccountMoney('bank'),
            inventory = players[i]:GetInventory(),
        });
        ::continue::
    end
end);
