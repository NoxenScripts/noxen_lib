---@alias NoxenQbNotifyType 'primary'|'success'|'error'|'warning'

---@type table<NoxenNotifyType, NoxenQbNotifyType>
local NOTIFY_TYPES <const> = {
    info = 'primary',
    success = 'success',
    error = 'error',
    warning = 'warning',
}

---@param source integer
---@return table?
local function getPlayerObject(source)
    return Bridge.qb().Functions.GetPlayer(source)
end

---@param player table
---@return NoxenPlayer
local function toPlayer(player)
    return Mappers.qbPlayer('qb', player.PlayerData)
end

---@type NoxenFrameworkAdapter
Bridge.frameworks.qb = {
    isLoaded = function(source)
        return getPlayerObject(source) ~= nil
    end,

    getPlayer = function(source)
        local player = getPlayerObject(source)
        return player and toPlayer(player) or nil
    end,

    getPlayerByIdentifier = function(identifier)
        local player = Bridge.qb().Functions.GetPlayerByCitizenId(identifier)
        return player and toPlayer(player) or nil
    end,

    getPlayers = function()
        local players = {}

        for _, player in pairs(Bridge.qb().Functions.GetQBPlayers()) do
            players[#players + 1] = toPlayer(player)
        end

        return players
    end,

    hasPermission = function(source, permission)
        return IsPlayerAceAllowed(source, permission)
    end,

    isPvpEnabled = function()
        return exports['qb-core']:GetCoreObject({ 'Config' }).Config.Server.PVP == true
    end,

    getBalance = function(source, account)
        local player = getPlayerObject(source)
        return player and player.PlayerData.money[account] or nil
    end,

    addMoney = function(source, account, amount, reason)
        local player = getPlayerObject(source)
        return player ~= nil and player.Functions.AddMoney(account, amount, reason) == true
    end,

    removeMoney = function(source, account, amount, reason)
        local player = getPlayerObject(source)
        return player ~= nil and player.Functions.RemoveMoney(account, amount, reason) == true
    end,

    setMoney = function(source, account, amount, reason)
        local player = getPlayerObject(source)
        return player ~= nil and player.Functions.SetMoney(account, amount, reason) == true
    end,

    setJob = function(source, name, grade)
        local player = getPlayerObject(source)
        local job = exports['qb-core']:GetShared('Jobs', name)

        if not player or not job or not job.grades[tostring(grade)] then
            return false
        end

        return player.Functions.SetJob(name, grade) == true
    end,

    setJob2 = function(source, name, grade)
        local player = getPlayerObject(source)
        local gang = exports['qb-core']:GetShared('Gangs', name)

        if not player or not gang or not gang.grades[tostring(grade)] then
            return false
        end

        return player.Functions.SetGang(name, grade) == true
    end,

    setDuty = function(source, onDuty)
        local player = getPlayerObject(source)

        if not player then
            return false
        end

        player.Functions.SetJobDuty(onDuty)
        return true
    end,

    notify = function(source, message, kind, duration)
        TriggerClientEvent('QBCore:Notify', source, message, NOTIFY_TYPES[kind], duration)
    end,

    isItemUsable = function(item)
        return Bridge.qb().Functions.CanUseItem(item) ~= nil
    end,

    registerUsableItem = function(item, handler)
        Bridge.qb().Functions.CreateUseableItem(item, handler)
    end,

    registerEvents = function(emit)
        AddEventHandler('QBCore:Server:PlayerLoaded', function(player)
            emit('playerLoaded', player.PlayerData.source)
        end)

        AddEventHandler('QBCore:Server:OnPlayerUnload', function(source)
            emit('playerUnloaded', source)
        end)

        AddEventHandler('QBCore:Server:OnJobUpdate', function(source, job)
            emit('jobChanged', source, Mappers.qbJob(job))
        end)

        AddEventHandler('QBCore:Server:OnPlayerUpdated', function(source)
            emit('dataChanged', source)
        end)
    end,
}
