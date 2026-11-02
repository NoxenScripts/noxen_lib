local NOTIFY_TYPES <const> = {
    info = 'inform',
    success = 'success',
    error = 'error',
    warning = 'warning',
}

---@type NoxenClientFrameworkAdapter
Bridge.frameworks.qbx = {
    isLoaded = function()
        return LocalPlayer.state.isLoggedIn == true
    end,

    getPlayerData = function()
        local data = exports.qbx_core:GetPlayerData()

        if not data or not data.job then
            return nil
        end

        return Mappers.qbPlayer('qbx', data)
    end,

    isPvpEnabled = function()
        return GlobalState.PVPEnabled == true
    end,

    notify = function(message, kind, duration)
        exports.qbx_core:Notify(message, NOTIFY_TYPES[kind], duration)
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

        RegisterNetEvent('QBCore:Client:SetDuty', function(onDuty)
            local job = Mappers.qbJob(exports.qbx_core:GetPlayerData().job)
            job.onDuty = onDuty
            emit('jobChanged', job)
        end)
    end,
}
