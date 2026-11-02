local api <const> = exports[nox.name];
local frameworkName <const> = api:GetFramework();

local FRAMEWORK_RESOURCES <const> = { esx = 'es_extended', qb = 'qb-core', qbx = 'qbx_core' };
local NEUTRAL_ACCOUNTS <const> = {
    money = 'cash',
    bank = 'bank',
    black_money = frameworkName == 'esx' and 'black' or 'crypto',
};

---@return table<string, { name: string, label: string, type: string }>
local function buildAccounts()
    local isEsx <const> = frameworkName == 'esx';

    return {
        bank = { name = 'bank', label = 'Bank', type = 'account' },
        black_money = {
            name = isEsx and 'black_money' or 'crypto',
            label = isEsx and 'Black Money' or 'Crypto',
            type = 'item'
        },
        money = { name = isEsx and 'money' or 'cash', label = 'Cash', type = 'item' },
    };
end

---@param job? NoxenJob|NoxenGang
---@return { name: string, label: string, grade: { name: string, level: integer, isboss: boolean } }?
local function toLegacyJob(job)
    return job and {
        name = job.name,
        label = job.label,
        grade = { name = job.gradeName, level = job.grade, isboss = job.isBoss }
    } or nil;
end

---@param data NoxenPlayer
---@return table<string, any>
local function toLegacyData(data)
    return {
        identifier = data.license,
        job = toLegacyJob(data.job),
        job2 = toLegacyJob(data.job2 or data.gang),
        money = data.money.cash,
        bank = data.money.bank,
        black_money = data.money[NEUTRAL_ACCOUNTS.black_money],
        inventory = data.inventory or {},
    };
end

---@class noxen.lib.bridge
---@field public name NoxenFrameworkName
---@field public resource_name string
---@field public version string?
---@field public wrapper { accounts: table<string, table> }
---@field public loaded boolean
---@field public events EventEmitter
---@field public player noxen.lib.bridge.player.local?
---@field public framework table
local bridge <const> = {
    name = frameworkName,
    resource_name = FRAMEWORK_RESOURCES[frameworkName],
    version = GetResourceMetadata(FRAMEWORK_RESOURCES[frameworkName], 'version', 0),
    wrapper = { accounts = buildAccounts() },
    loaded = true,
    events = EventEmitter(),
};

setmetatable(bridge, {
    __index = function(self, key)
        if (key ~= 'framework') then
            return nil;
        end

        local object <const> = frameworkName == 'esx'
            and exports.es_extended:getSharedObject()
            or exports['qb-core']:GetCoreObject();

        rawset(self, key, object);
        return object;
    end
});

---@return boolean
function bridge:IsLoaded()
    return true;
end

function bridge:Await() end

---@return boolean
function bridge:IsPVPEnabled()
    return api:IsPvpEnabled();
end

---@param framework NoxenFrameworkName
---@param name string
---@param handler fun(...)
function bridge:AddEventHandler(framework, name, handler)
    if (self.name == framework) then
        return nox.events.on(name, function(_, ...)
            handler(...);
        end);
    end
end

---@param framework NoxenFrameworkName
---@param name string
---@param handler fun(...)
function bridge:RegisterNetEvent(framework, name, handler)
    if (self.name == framework) then
        return nox.events.on.net(name, function(_, ...)
            handler(...);
        end);
    end
end

if (nox.is_server) then
    ---@class noxen.lib.bridge.player
    ---@field public source integer
    ---@field public license string
    local player <const> = {};
    player.__index = player;

    ---@param data NoxenPlayer
    ---@return noxen.lib.bridge.player
    local function toPlayer(data)
        return setmetatable({ source = data.source, license = data.license }, player);
    end

    ---@return string
    function player:GetIdentifier()
        return self.license;
    end

    ---@param eventName string
    ---@param ... any
    ---@return noxen.lib.bridge.player
    function player:TriggerEvent(eventName, ...)
        nox.events.emit.net(eventName, self.source, ...);
        return self;
    end

    ---@param eventName string
    ---@param ... any
    ---@return noxen.lib.bridge.player
    function player:TriggerResourceEvent(eventName, ...)
        nox.events.emit.resource.net(eventName, self.source, ...);
        return self;
    end

    ---@return string
    function player:GetUserName()
        return GetPlayerName(self.source) or 'Unknown';
    end

    ---@param permission string
    ---@return boolean
    function player:HasPermission(permission)
        return api:HasPermission(self.source, permission);
    end

    function player:GetJob()
        return toLegacyJob(api:GetJob(self.source));
    end

    function player:GetJob2()
        local data <const> = api:GetPlayer(self.source);
        return data and toLegacyJob(data.job2 or data.gang) or nil;
    end

    ---@param job string
    ---@param grade integer
    ---@return boolean
    function player:SetJob(job, grade)
        return api:SetJob(self.source, job, tonumber(grade));
    end

    ---@param job string
    ---@param grade integer
    ---@return boolean
    function player:SetJob2(job, grade)
        return api:SetJob2(self.source, job, tonumber(grade));
    end

    ---@param accountName 'money'|'bank'|'black_money'
    ---@return number
    function player:GetAccountMoney(accountName)
        return api:GetMoney(self.source, NEUTRAL_ACCOUNTS[accountName]);
    end

    ---@param accountName 'money'|'bank'|'black_money'
    ---@param amount number
    ---@param reason? string
    ---@return boolean
    function player:SetAccountMoney(accountName, amount, reason)
        return api:SetMoney(self.source, NEUTRAL_ACCOUNTS[accountName], amount, reason);
    end

    ---@param accountName 'money'|'bank'|'black_money'
    ---@param amount number
    ---@param reason? string
    ---@return boolean
    function player:AddAccountMoney(accountName, amount, reason)
        return api:AddMoney(self.source, NEUTRAL_ACCOUNTS[accountName], amount, reason);
    end

    ---@param accountName 'money'|'bank'|'black_money'
    ---@param amount number
    ---@param reason? string
    ---@return boolean
    function player:RemoveAccountMoney(accountName, amount, reason)
        return api:RemoveMoney(self.source, NEUTRAL_ACCOUNTS[accountName], amount, reason);
    end

    ---@return NoxenInventoryItem[]
    function player:GetInventory()
        return api:GetInventoryItems(self.source);
    end

    ---@param itemName string
    ---@param amount? integer
    ---@return boolean
    function player:HasItem(itemName, amount)
        return api:HasItem(self.source, itemName, amount);
    end

    ---@param itemName string
    ---@param amount? integer
    ---@return boolean
    function player:CanCarryItem(itemName, amount)
        return api:CanCarry(self.source, itemName, amount);
    end

    ---@param itemName string
    ---@return NoxenInventoryItem?
    function player:GetItem(itemName)
        return api:GetInventoryItem(self.source, itemName);
    end

    ---@param itemName string
    ---@param amount? integer
    ---@param reason? string
    ---@return boolean
    function player:AddItem(itemName, amount, reason)
        return api:AddItem(self.source, itemName, amount, nil, reason);
    end

    ---@param itemName string
    ---@param amount? integer
    ---@param reason? string
    ---@return boolean
    function player:RemoveItem(itemName, amount, reason)
        return api:RemoveItem(self.source, itemName, amount, nil, reason);
    end

    ---@param message string
    ---@param kind? NoxenNotifyType
    ---@param length? integer
    ---@return noxen.lib.bridge.player
    function player:ShowNotification(message, kind, length)
        api:Notify(self.source, message, kind, length);
        return self;
    end

    ---@return noxen.lib.bridge.player[]
    function bridge:GetPlayers()
        local players <const> = {};

        for _, data in ipairs(api:GetPlayers()) do
            players[#players + 1] = toPlayer(data);
        end

        return players;
    end

    ---@param source integer|string
    ---@return noxen.lib.bridge.player?
    function bridge:GetPlayer(source)
        local data <const> = api:GetPlayer(tonumber(source));
        return data and toPlayer(data) or nil;
    end

    ---@param identifier string
    ---@return noxen.lib.bridge.player?
    function bridge:GetPlayerByIdentifier(identifier)
        for _, data in ipairs(api:GetPlayers()) do
            if (data.license == identifier) then
                return toPlayer(data);
            end
        end
    end

    ---@param item string|{ name: string }
    ---@return boolean
    function bridge:IsItemUsable(item)
        return api:IsItemUsable(type(item) == 'table' and item.name or item);
    end

    ---@param item string
    ---@param handler fun(source: integer, item: string, ...)
    function bridge:RegisterUsableItem(item, handler)
        api:RegisterUsableItem(item, handler);
    end

    ---@param commandName string
    ---@param permission? string
    ---@param handler fun(player: noxen.lib.bridge.player|false, args: string[], reply: fun(message: string, kind?: string))
    ---@param help? string
    ---@param arguments? { name: string, help: string }[]
    ---@param allowConsole? boolean
    local function registerCommand(commandName, permission, handler, help, arguments, allowConsole)
        nox.events.emit(eLibEvents.commandRegistered, commandName, help, arguments);

        RegisterCommand(commandName, function(source, args)
            local issuer <const> = source ~= 0 and bridge:GetPlayer(source) or nil;

            if (not issuer and not allowConsole) then
                return;
            end

            if (issuer and permission and not issuer:HasPermission(permission)) then
                issuer:ShowNotification('You do not have permission to use this command.', 'error');
                return;
            end

            handler(issuer or false, args, function(message, kind)
                if (issuer) then
                    issuer:ShowNotification(message:gsub('%^%d', ''), kind);
                else
                    console.log(message);
                end
            end);
        end, false);
    end

    ---@param commandName string
    ---@param handler fun(player: noxen.lib.bridge.player|false, args: string[], reply: fun(message: string, kind?: string))
    ---@param help? string
    ---@param arguments? { name: string, help: string }[]
    ---@param allowConsole? boolean
    function bridge:AddCommand(commandName, handler, help, arguments, allowConsole)
        registerCommand(commandName, nil, handler, help, arguments, allowConsole);
    end

    ---@param permission string
    ---@param commandName string
    ---@param handler fun(player: noxen.lib.bridge.player|false, args: string[], reply: fun(message: string, kind?: string))
    ---@param help? string
    ---@param arguments? { name: string, help: string }[]
    ---@param allowConsole? boolean
    function bridge:AddPermissionCommand(permission, commandName, handler, help, arguments, allowConsole)
        registerCommand(commandName, permission, handler, help, arguments, allowConsole);
    end

    AddEventHandler('noxen:server:playerLoaded', function(source)
        nox.events.emit.resource(eLibEvents.playerLoaded, source);
    end);

    nox.events.on(eCitizenFXEvents.onResourceStart, function(_, resource)
        if (resource ~= nox.current_resource) then
            return;
        end

        Wait(2000);

        for _, data in ipairs(api:GetPlayers()) do
            nox.events.emit.resource(eLibEvents.playerLoaded, data.source);
        end

        nox.events.emit(eLibEvents.resourceStarted);
    end);
else
    ---@class noxen.lib.bridge.player.local
    ---@field public source integer
    ---@field public localId integer
    ---@field public data table<string, any>
    local player <const> = {
        localId = PlayerId(),
        source = GetPlayerServerId(PlayerId()),
        data = {},
    };

    ---@return string
    function player:GetIdentifier()
        return self.data.identifier;
    end

    ---@return string
    function player:GetUserName()
        return GetPlayerName(self.localId) or 'Unknown';
    end

    function player:GetJob()
        return self.data.job;
    end

    function player:GetJob2()
        return self.data.job2;
    end

    ---@param accountName 'money'|'bank'|'black_money'
    ---@return number?
    function player:GetAccountMoney(accountName)
        return self.data[accountName];
    end

    ---@return NoxenInventoryItem[]
    function player:GetInventory()
        return self.data.inventory or {};
    end

    ---@param itemName string
    ---@return NoxenInventoryItem?
    function player:GetItem(itemName)
        for _, item in ipairs(self:GetInventory()) do
            if (item.name == itemName) then
                return item;
            end
        end
    end

    ---@param itemName string
    ---@param amount? integer
    ---@return boolean
    function player:HasItem(itemName, amount)
        local item <const> = self:GetItem(itemName);
        return item ~= nil and item.amount >= (amount or 1);
    end

    ---@param message string
    ---@param kind? NoxenNotifyType
    ---@param length? integer
    ---@return noxen.lib.bridge.player.local
    function player:ShowNotification(message, kind, length)
        api:Notify(message, kind, length);
        return self;
    end

    ---@param message string
    ---@param thisFrame? boolean
    ---@param beep? boolean
    ---@param duration? integer
    ---@return noxen.lib.bridge.player.local
    function player:ShowHelpNotification(message, thisFrame, beep, duration)
        local entry <const> = 'noxen..notify.help';

        AddTextEntry(entry, message);

        if (thisFrame) then
            DisplayHelpTextThisFrame(entry, false);
        else
            BeginTextCommandDisplayHelp(entry);
            EndTextCommandDisplayHelp(0, false, beep == nil or beep, duration or -1);
        end

        return self;
    end

    bridge.player = player;

    local isSynced = false;

    ---@param data NoxenPlayer
    local function applyPlayerData(data)
        player.data = toLegacyData(data);
        nox.events.emit.resource(isSynced and eLibEvents.setPlayerData or eLibEvents.playerLoaded, player.data);
        isSynced = true;
    end

    AddEventHandler('noxen:client:playerSynced', applyPlayerData);

    AddEventHandler('noxen:client:playerUnloaded', function()
        player.data = {};
        isSynced = false;
    end);

    local initialData <const> = api:IsLoaded() and api:GetPlayerData() or nil;

    if (initialData) then
        player.data = toLegacyData(initialData);
    end

    CreateThread(function()
        Wait(2000);

        local data <const> = api:GetPlayerData();

        if (data and api:IsLoaded() and not isSynced) then
            applyPlayerData(data);
        end
    end);
end

return bridge;
