local bridge <const> = require 'lib.bridge.bridge';

---@param xPlayer noxen.lib.bridge.esx.player
bridge:AddEventHandler('esx', 'esx:playerLoaded', function(source, xPlayer)
    local player <const> = bridge:GetPlayer(source);

    if (not player) then
        return console.warn(("esx:playerLoaded - Player with source %s not found."):format(tostring(source)));
    end

    bridge.playersIdentifier[xPlayer.license] = player.source;

    player:TriggerEvent(('noxen_lib_%s:bridge:player:setPlayerData'):format(nox.current_resource), {
        identifier = player:GetIdentifier(),
        job = player:GetJob(),
        job2 = player:GetJob2(),
        money = player:GetAccountMoney('money'),
        black_money = player:GetAccountMoney('black_money'),
        bank = player:GetAccountMoney('bank'),
        inventory = player:GetInventory(),
    });

    console.debug("ESX player loaded", xPlayer);
end);

bridge:AddEventHandler('esx', 'esx:playerDropped', function(source)
    local player <const> = bridge:GetPlayer(source);

    if (not player) then
        return console.warn(("esx:playerDropped - Player with source ^3%s^7 not found."):format(tostring(source)));
    end

    bridge.playersIdentifier[player.handle.license] = nil;
end);

---@param source number
local function updateInventory(source)
    local player <const> = bridge:GetPlayer(source);

    if (not player) then
        return;
    end

    player:TriggerEvent(('noxen_lib_%s:bridge:player:setPlayerData'):format(nox.current_resource), {
        inventory = player:GetInventory()
    });
end

bridge:AddEventHandler('esx', 'esx:onAddInventoryItem', updateInventory);
bridge:AddEventHandler('esx', 'esx:onRemoveInventoryItem', updateInventory);

---@param source number
---@param accountName string
local function updateAccount(source, accountName)
    local player <const> = bridge:GetPlayer(source);

    if (not player) then
        return;
    end

    for name, account --[[ @type noxen.lib.bridge.wrapper.account ]] in pairs(bridge.wrapper.accounts) do
        if (account.name == accountName) then
            player:TriggerEvent(('noxen_lib_%s:bridge:player:setPlayerData'):format(nox.current_resource), {
                [account.name] = player:GetAccountMoney(account.name)
            });
            return;
        end
    end
end

bridge:AddEventHandler('esx', 'esx:setAccountMoney', updateAccount);
bridge:AddEventHandler('esx', 'esx:addAccountMoney', updateAccount);
bridge:AddEventHandler('esx', 'esx:removeAccountMoney', updateAccount);

---@param type 'job' | 'job2'
local function updateJob(type)
    ---@param source number
    return function(source)
        local player <const> = bridge:GetPlayer(source);

        if (not player) then
            return;
        end

        player:TriggerEvent(('noxen_lib_%s:bridge:player:setPlayerData'):format(nox.current_resource), {
            [type] = player:getJobInternal(type)
        });
    end
end

bridge:AddEventHandler('esx', 'esx:setJob', updateJob('job'));
bridge:AddEventHandler('esx', 'esx:setJob2', updateJob('job2'));
