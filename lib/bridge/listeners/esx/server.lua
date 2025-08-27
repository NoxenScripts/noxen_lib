local bridge <const> = require 'lib.bridge.bridge';

---@param xPlayer noxen.lib.bridge.esx.player
bridge:AddEventHandler('esx', 'esx:playerLoaded', function(source, xPlayer)
    local player <const> = bridge:GetPlayer(source);

    if (not player) then
        return console.warn(("esx:playerLoaded - Player with source %s not found."):format(tostring(source)));
    end

    bridge.playersIdentifier[xPlayer.license] = player.source;

    local data <const> = {
        identifier = player:GetIdentifier(),
        job = player:getJobInternal('job'),
        job2 = player:getJobInternal('job2'),
        money = player:GetAccountMoney('money'),
        black_money = player:GetAccountMoney('black_money'),
        bank = player:GetAccountMoney('bank'),
        inventory = player:GetInventory(),
    };

    player:TriggerResourceEvent(eLibEvents.setPlayerData, data);
    nox.events.emit.resource(eLibEvents.playerLoaded, player.source);

    console.debug("ESX player loaded");
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

    player:TriggerResourceEvent(eLibEvents.setPlayerData, {
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
            player:TriggerResourceEvent(eLibEvents.setPlayerData, {
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

        player:TriggerResourceEvent(eLibEvents.setPlayerData, {
            [type] = player:getJobInternal(type)
        });
    end
end

bridge:AddEventHandler('esx', 'esx:setJob', updateJob('job'));
bridge:AddEventHandler('esx', 'esx:setJob2', updateJob('job2'));
