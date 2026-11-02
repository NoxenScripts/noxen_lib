---@param source integer
---@return table?
local function getPlayerObject(source)
    return Bridge.esx().GetPlayerFromId(source)
end

---@param xPlayer table
---@return NoxenPlayer
local function toPlayer(xPlayer)
    local job2 = xPlayer.getJob2 and xPlayer.getJob2()

    return {
        source = xPlayer.source,
        identifier = xPlayer.identifier,
        license = xPlayer.license,
        name = xPlayer.getName(),
        firstName = xPlayer.get('firstName') or '',
        lastName = xPlayer.get('lastName') or '',
        job = Mappers.esxJob(xPlayer.getJob()),
        job2 = job2 and Mappers.esxJob(job2) or nil,
        money = Mappers.esxMoney(xPlayer.getAccounts()),
    }
end

---@type NoxenFrameworkAdapter
Bridge.frameworks.esx = {
    isLoaded = function(source)
        return getPlayerObject(source) ~= nil
    end,

    getPlayer = function(source)
        local xPlayer = getPlayerObject(source)
        return xPlayer and toPlayer(xPlayer) or nil
    end,

    getPlayerByIdentifier = function(identifier)
        local xPlayer = Bridge.esx().GetPlayerFromIdentifier(identifier)
        return xPlayer and toPlayer(xPlayer) or nil
    end,

    getPlayers = function()
        local players = {}

        for _, xPlayer in pairs(Bridge.esx().GetExtendedPlayers()) do
            players[#players + 1] = toPlayer(xPlayer)
        end

        return players
    end,

    hasPermission = function(source, permission)
        local xPlayer = getPlayerObject(source)
        return xPlayer ~= nil and xPlayer.getGroup() == permission
    end,

    isPvpEnabled = function()
        local config = Bridge.esx().GetConfig()
        return config ~= nil and config.EnablePVP == true
    end,

    getBalance = function(source, account)
        local xPlayer = getPlayerObject(source)
        local entry = xPlayer and xPlayer.getAccount(account)
        return entry and entry.money or nil
    end,

    addMoney = function(source, account, amount, reason)
        local xPlayer = getPlayerObject(source)
        return xPlayer ~= nil and xPlayer.addAccountMoney(account, amount, reason) ~= false
    end,

    removeMoney = function(source, account, amount, reason)
        local xPlayer = getPlayerObject(source)
        return xPlayer ~= nil and xPlayer.removeAccountMoney(account, amount, reason) ~= false
    end,

    setMoney = function(source, account, amount, reason)
        local xPlayer = getPlayerObject(source)
        return xPlayer ~= nil and xPlayer.setAccountMoney(account, amount, reason) ~= false
    end,

    setJob = function(source, name, grade)
        local xPlayer = getPlayerObject(source)

        if not xPlayer or not Bridge.esx().DoesJobExist(name, grade) then
            return false
        end

        xPlayer.setJob(name, grade)
        return true
    end,

    setJob2 = function(source, name, grade)
        local xPlayer = getPlayerObject(source)

        if not xPlayer or not xPlayer.setJob2 or not Bridge.esx().DoesJobExist(name, grade) then
            return false
        end

        xPlayer.setJob2(name, grade)
        return true
    end,

    setDuty = function(source, onDuty)
        local xPlayer = getPlayerObject(source)

        if not xPlayer then
            return false
        end

        local job = xPlayer.getJob()
        xPlayer.setJob(job.name, job.grade, onDuty)
        return true
    end,

    notify = function(source, message, kind, duration)
        local xPlayer = getPlayerObject(source)

        if xPlayer then
            xPlayer.showNotification(message, kind, duration)
        end
    end,

    isItemUsable = function(item)
        return Bridge.esx().GetUsableItems()[item] == true
    end,

    registerUsableItem = function(item, handler)
        Bridge.esx().RegisterUsableItem(item, handler)
    end,

    registerEvents = function(emit)
        AddEventHandler('esx:playerLoaded', function(source)
            emit('playerLoaded', source)
        end)

        AddEventHandler('esx:playerDropped', function(source)
            emit('playerUnloaded', source)
        end)

        AddEventHandler('esx:playerLogout', function(source)
            emit('playerUnloaded', source)
        end)

        AddEventHandler('esx:setJob', function(source, job)
            emit('jobChanged', source, Mappers.esxJob(job))
        end)

        for _, event in ipairs({
            'esx:setAccountMoney',
            'esx:addAccountMoney',
            'esx:removeAccountMoney',
            'esx:onAddInventoryItem',
            'esx:onRemoveInventoryItem',
        }) do
            AddEventHandler(event, function(source)
                emit('dataChanged', source)
            end)
        end
    end,
}
