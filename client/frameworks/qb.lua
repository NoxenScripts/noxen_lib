local NOTIFY_TYPES <const> = {
    info = 'primary',
    success = 'success',
    error = 'error',
    warning = 'warning',
}

---@type NoxenClientFrameworkAdapter
Bridge.frameworks.qb = {
    isLoaded = function()
        return LocalPlayer.state.isLoggedIn == true
    end,

    getPlayerData = function()
        local data = Bridge.qb().Functions.GetPlayerData()

        if not data or not data.job then
            return nil
        end

        return Mappers.qbPlayer('qb', data)
    end,

    isPvpEnabled = function()
        return exports['qb-core']:GetCoreObject({ 'Config' }).Config.Server.PVP == true
    end,

    notify = function(message, kind, duration)
        Bridge.qb().Functions.Notify(message, NOTIFY_TYPES[kind], duration)
    end,

    registerEvents = function(emit)
        RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
            emit('playerLoaded')
        end)

        RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
            emit('playerUnloaded')
        end)

        RegisterNetEvent('QBCore:Client:OnJobUpdate', function(job)
            emit('jobChanged', Mappers.qbJob(job))
        end)
    end,
}
