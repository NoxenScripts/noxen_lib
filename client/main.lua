local SYNC_EVENT <const> = 'noxen_lib:client:playerData'
local SYNC_REQUEST_EVENT <const> = 'noxen_lib:server:requestPlayerData'
local DEFAULT_NOTIFY_DURATION <const> = 5000
local NOTIFY_KINDS <const> = { info = true, success = true, error = true, warning = true }

local frameworkName = Bridge.detectFramework()
assert(frameworkName, 'noxen_lib: no supported framework is started, ensure it before noxen_lib')

---@return NoxenTargetName
local function detectTarget()
    if Config.Target ~= 'auto' then
        return Config.Target
    end

    return Bridge.isResourceActive('ox_target') and 'ox' or 'qb'
end

local framework = Bridge.frameworks[frameworkName] --[[@as NoxenClientFrameworkAdapter]]
local target = Bridge.targets[detectTarget()]

---@class NoxenTargetRegistration
---@field owner string
---@field remove fun()

---@type table<integer, NoxenTargetRegistration>
local registrations = {}
local nextRegistrationId = 0
---@type NoxenJob?
local cachedJob
---@type NoxenPlayer?
local cachedPlayer

---@return NoxenFrameworkName
local function getFramework()
    return frameworkName
end

---@return boolean
local function isLoaded()
    return framework.isLoaded()
end

---@return NoxenPlayer?
local function getPlayerData()
    return cachedPlayer or framework.getPlayerData()
end

---@return boolean
local function isPvpEnabled()
    return framework.isPvpEnabled() == true
end

---@return NoxenJob?
local function getJob()
    if not cachedJob and framework.isLoaded() then
        local player = framework.getPlayerData()
        cachedJob = player and player.job or nil
    end

    return cachedJob
end

---@param jobs string|string[]
---@param minGrade? integer
---@return boolean
local function hasJob(jobs, minGrade)
    return Mappers.matchesJob(getJob(), jobs, minGrade)
end

---@param message string
---@param kind? NoxenNotifyType
---@param duration? integer
local function notify(message, kind, duration)
    kind = NOTIFY_KINDS[kind] and kind or 'info'
    duration = duration or DEFAULT_NOTIFY_DURATION

    if Config.Notify == 'ox_lib' then
        exports.ox_lib:notify({ description = message, type = kind == 'info' and 'inform' or kind, duration = duration })
        return
    end

    framework.notify(message, kind, duration)
end

---@param option NoxenTargetOption
---@return fun(entity: integer, distance: number): boolean
local function buildGuard(option)
    return function(entity, distance)
        if option.job and not hasJob(option.job, option.minGrade) then
            return false
        end

        if option.canInteract then
            return option.canInteract(entity, distance) == true
        end

        return true
    end
end

---@param id integer
---@param options NoxenTargetOption[]
---@return NoxenResolvedOption[]
local function resolveOptions(id, options)
    local resolved = {}

    for index, option in ipairs(options) do
        resolved[index] = {
            name = ('noxen_%d_%d'):format(id, index),
            label = option.label,
            icon = option.icon,
            distance = option.distance or Config.TargetDistance,
            canInteract = buildGuard(option),
            onSelect = option.onSelect,
        }
    end

    return resolved
end

---@param owner string
---@param build fun(id: integer): fun()
---@return integer
local function register(owner, build)
    nextRegistrationId = nextRegistrationId + 1

    local id = nextRegistrationId
    registrations[id] = { owner = owner, remove = build(id) }

    return id
end

---@param zone NoxenBoxZone
---@param options NoxenTargetOption[]
---@return integer
local function addBoxZone(zone, options)
    return register(GetInvokingResource() or nox.name, function(id)
        local handle = target.addBoxZone(('noxen_zone_%d'):format(id), zone, resolveOptions(id, options))

        return function()
            target.removeZone(handle)
        end
    end)
end

---@param zone NoxenSphereZone
---@param options NoxenTargetOption[]
---@return integer
local function addSphereZone(zone, options)
    return register(GetInvokingResource() or nox.name, function(id)
        local handle = target.addSphereZone(('noxen_zone_%d'):format(id), zone, resolveOptions(id, options))

        return function()
            target.removeZone(handle)
        end
    end)
end

---@param entities integer|integer[]
---@param options NoxenTargetOption[]
---@return integer
local function addEntity(entities, options)
    return register(GetInvokingResource() or nox.name, function(id)
        local resolved = resolveOptions(id, options)
        target.addEntity(entities, resolved)

        return function()
            target.removeEntity(entities, resolved)
        end
    end)
end

---@param models string|string[]|integer|integer[]
---@param options NoxenTargetOption[]
---@return integer
local function addModel(models, options)
    return register(GetInvokingResource() or nox.name, function(id)
        local resolved = resolveOptions(id, options)
        target.addModel(models, resolved)

        return function()
            target.removeModel(models, resolved)
        end
    end)
end

---@param options NoxenTargetOption[]
---@return integer
local function addGlobalVehicle(options)
    return register(GetInvokingResource() or nox.name, function(id)
        local resolved = resolveOptions(id, options)
        target.addGlobalVehicle(resolved)

        return function()
            target.removeGlobalVehicle(resolved)
        end
    end)
end

---@param options NoxenTargetOption[]
---@return integer
local function addGlobalPed(options)
    return register(GetInvokingResource() or nox.name, function(id)
        local resolved = resolveOptions(id, options)
        target.addGlobalPed(resolved)

        return function()
            target.removeGlobalPed(resolved)
        end
    end)
end

---@param id integer
local function removeTarget(id)
    local registration = registrations[id]

    if registration then
        registrations[id] = nil
        registration.remove()
    end
end

AddEventHandler('onResourceStop', function(resource)
    if resource == nox.name then
        return
    end

    for id, registration in pairs(registrations) do
        if registration.owner == resource then
            removeTarget(id)
        end
    end
end)

framework.registerEvents(function(event, ...)
    if event == 'jobChanged' then
        cachedJob = ...
    elseif event == 'playerUnloaded' then
        cachedJob = nil
        cachedPlayer = nil
    end

    TriggerEvent(('noxen:client:%s'):format(event), ...)
end)

RegisterNetEvent(SYNC_EVENT, function(player)
    cachedPlayer = player
    cachedJob = player.job
    TriggerEvent('noxen:client:playerSynced', player)
end)

RegisterNetEvent('ox_inventory:updateSlots', function()
    TriggerServerEvent(SYNC_REQUEST_EVENT)
end)

exports('GetFramework', getFramework)
exports('IsLoaded', isLoaded)
exports('GetPlayerData', getPlayerData)
exports('GetJob', getJob)
exports('HasJob', hasJob)
exports('Notify', notify)
exports('IsPvpEnabled', isPvpEnabled)
exports('AddBoxZone', addBoxZone)
exports('AddSphereZone', addSphereZone)
exports('AddEntity', addEntity)
exports('AddModel', addModel)
exports('AddGlobalVehicle', addGlobalVehicle)
exports('AddGlobalPed', addGlobalPed)
exports('RemoveTarget', removeTarget)
