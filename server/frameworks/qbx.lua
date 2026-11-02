local NOTIFY_TYPES <const> = {
    info = 'inform',
    success = 'success',
    error = 'error',
    warning = 'warning',
}

---@param source integer
---@return table?
local function getPlayerObject(source)
    return exports.qbx_core:GetPlayer(source)
end

---@param player table
---@return NoxenPlayer
local function toPlayer(player)
    return Mappers.qbPlayer('qbx', player.PlayerData)
end

---@type NoxenFrameworkAdapter
Bridge.frameworks.qbx = {
    isLoaded = function(source)
        return getPlayerObject(source) ~= nil
    end,

    getPlayer = function(source)
        local player = getPlayerObject(source)
        return player and toPlayer(player) or nil
    end,

    getPlayerByIdentifier = function(identifier)
        local player = exports.qbx_core:GetPlayerByCitizenId(identifier)
        return player and toPlayer(player) or nil
    end,

    getPlayers = function()
        local players = {}

        for _, player in pairs(exports.qbx_core:GetQBPlayers()) do
            players[#players + 1] = toPlayer(player)
        end

        return players
    end,

    hasPermission = function(source, permission)
        return IsPlayerAceAllowed(source, permission)
    end,

    isPvpEnabled = function()
        return GlobalState.PVPEnabled == true
    end,

    getBalance = function(source, account)
        local balance = exports.qbx_core:GetMoney(source, account)
        return type(balance) == 'number' and balance or nil
    end,

    addMoney = function(source, account, amount, reason)
        return exports.qbx_core:AddMoney(source, account, amount, reason) == true
    end,

    removeMoney = function(source, account, amount, reason)
        return exports.qbx_core:RemoveMoney(source, account, amount, reason) == true
    end,

    setMoney = function(source, account, amount, reason)
        return exports.qbx_core:SetMoney(source, account, amount, reason) == true
    end,

    setJob = function(source, name, grade)
        return exports.qbx_core:SetJob(source, name, grade) == true
    end,

    setJob2 = function(source, name, grade)
        return exports.qbx_core:SetGang(source, name, grade) == true
    end,

    setDuty = function(source, onDuty)
        if not getPlayerObject(source) then
            return false
        end

        exports.qbx_core:SetJobDuty(source, onDuty)
        return true
    end,

    notify = function(source, message, kind, duration)
        exports.qbx_core:Notify(source, message, NOTIFY_TYPES[kind], duration)
    end,

    isItemUsable = function(item)
        return exports.qbx_core:CanUseItem(item) ~= nil
    end,

    registerUsableItem = function(item, handler)
        exports.qbx_core:CreateUseableItem(item, handler)
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

        AddEventHandler('QBCore:Server:SetDuty', function(source)
            local player = getPlayerObject(source)

            if player then
                emit('jobChanged', source, Mappers.qbJob(player.PlayerData.job))
            end
        end)

        AddEventHandler('QBCore:Server:OnMoneyChange', function(source)
            emit('dataChanged', source)
        end)
    end,
}
