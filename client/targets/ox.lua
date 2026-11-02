---@param options NoxenResolvedOption[]
---@return table[]
local function toOxOptions(options)
    local converted = {}

    for index, option in ipairs(options) do
        converted[index] = {
            name = option.name,
            label = option.label,
            icon = option.icon,
            distance = option.distance,
            canInteract = function(entity, distance)
                return option.canInteract(entity, distance)
            end,
            onSelect = function(data)
                option.onSelect(data.entity)
            end,
        }
    end

    return converted
end

---@param options NoxenResolvedOption[]
---@return string[]
local function toOptionNames(options)
    local names = {}

    for index, option in ipairs(options) do
        names[index] = option.name
    end

    return names
end

---@type NoxenTargetAdapter
Bridge.targets.ox = {
    addBoxZone = function(_, zone, options)
        return exports.ox_target:addBoxZone({
            coords = zone.coords,
            size = zone.size,
            rotation = zone.rotation or 0.0,
            debug = zone.debug,
            options = toOxOptions(options),
        })
    end,

    addSphereZone = function(_, zone, options)
        return exports.ox_target:addSphereZone({
            coords = zone.coords,
            radius = zone.radius,
            debug = zone.debug,
            options = toOxOptions(options),
        })
    end,

    removeZone = function(handle)
        exports.ox_target:removeZone(handle)
    end,

    addEntity = function(entities, options)
        exports.ox_target:addLocalEntity(entities, toOxOptions(options))
    end,

    removeEntity = function(entities, options)
        exports.ox_target:removeLocalEntity(entities, toOptionNames(options))
    end,

    addModel = function(models, options)
        exports.ox_target:addModel(models, toOxOptions(options))
    end,

    removeModel = function(models, options)
        exports.ox_target:removeModel(models, toOptionNames(options))
    end,

    addGlobalVehicle = function(options)
        exports.ox_target:addGlobalVehicle(toOxOptions(options))
    end,

    removeGlobalVehicle = function(options)
        exports.ox_target:removeGlobalVehicle(toOptionNames(options))
    end,

    addGlobalPed = function(options)
        exports.ox_target:addGlobalPed(toOxOptions(options))
    end,

    removeGlobalPed = function(options)
        exports.ox_target:removeGlobalPed(toOptionNames(options))
    end,
}
