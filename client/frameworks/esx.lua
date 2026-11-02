---@type NoxenClientFrameworkAdapter
Bridge.frameworks.esx = {
    isLoaded = function()
        return Bridge.esx().IsPlayerLoaded() == true
    end,

    getPlayerData = function()
        local data = Bridge.esx().GetPlayerData()

        if not data or not data.job then
            return nil
        end

        return {
            source = GetPlayerServerId(PlayerId()),
            identifier = data.identifier,
            name = ('%s %s'):format(data.firstName or '', data.lastName or ''),
            firstName = data.firstName or '',
            lastName = data.lastName or '',
            job = Mappers.esxJob(data.job),
            job2 = data.job2 and Mappers.esxJob(data.job2) or nil,
            money = Mappers.esxMoney(data.accounts or {}),
        }
    end,

    isPvpEnabled = function()
        return Bridge.esx().GetConfig().EnablePVP == true
    end,

    notify = function(message, kind, duration)
        Bridge.esx().ShowNotification(message, kind, duration)
    end,

    registerEvents = function(emit)
        RegisterNetEvent('esx:playerLoaded', function()
            emit('playerLoaded')
        end)

        RegisterNetEvent('esx:onPlayerLogout', function()
            emit('playerUnloaded')
        end)

        RegisterNetEvent('esx:setJob', function(job)
            emit('jobChanged', Mappers.esxJob(job))
        end)
    end,
}
