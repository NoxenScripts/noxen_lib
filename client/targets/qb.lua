---@param options NoxenResolvedOption[]
---@return { options: table[], distance: number }
local function toQbParameters(options)
    local converted = {}
    local distance = 0.0

    for index, option in ipairs(options) do
        distance = math.max(distance, option.distance)
        converted[index] = {
            label = option.label,
            icon = option.icon,
            distance = option.distance,
            canInteract = function(entity, currentDistance)
                return option.canInteract(entity, currentDistance)
            end,
            action = function(entity)
                option.onSelect(entity)
            end,
        }
    end

    return { options = converted, distance = distance }
end

---@param options NoxenResolvedOption[]
---@return string[]
local function toLabels(options)
    local labels = {}

    for index, option in ipairs(options) do
        labels[index] = option.label
    end

    return labels
end

---@type NoxenTargetAdapter
Bridge.targets.qb = {
    addBoxZone = function(id, zone, options)
        exports['qb-target']:AddBoxZone(id, zone.coords, zone.size.y, zone.size.x, {
            name = id,
            heading = zone.rotation or 0.0,
            debugPoly = zone.debug,
            minZ = zone.coords.z - zone.size.z / 2,
            maxZ = zone.coords.z + zone.size.z / 2,
        }, toQbParameters(options))

        return id
    end,

    addSphereZone = function(id, zone, options)
        exports['qb-target']:AddCircleZone(id, zone.coords, zone.radius, {
            name = id,
            useZ = true,
            debugPoly = zone.debug,
        }, toQbParameters(options))

        return id
    end,

    removeZone = function(handle)
        exports['qb-target']:RemoveZone(handle)
    end,

    addEntity = function(entities, options)
        exports['qb-target']:AddTargetEntity(entities, toQbParameters(options))
    end,

    removeEntity = function(entities, options)
        exports['qb-target']:RemoveTargetEntity(entities, toLabels(options))
    end,

    addModel = function(models, options)
        exports['qb-target']:AddTargetModel(models, toQbParameters(options))
    end,

    removeModel = function(models, options)
        exports['qb-target']:RemoveTargetModel(models, toLabels(options))
    end,

    addGlobalVehicle = function(options)
        exports['qb-target']:AddGlobalVehicle(toQbParameters(options))
    end,

    removeGlobalVehicle = function(options)
        exports['qb-target']:RemoveGlobalVehicle(toLabels(options))
    end,

    addGlobalPed = function(options)
        exports['qb-target']:AddGlobalPed(toQbParameters(options))
    end,

    removeGlobalPed = function(options)
        exports['qb-target']:RemoveGlobalPed(toLabels(options))
    end,
}
