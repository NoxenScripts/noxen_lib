local api <const> = exports[nox.name];

---@class noxen.lib.target
local target <const> = {};

---@param zone NoxenBoxZone
---@param options NoxenTargetOption[]
---@return integer
function target.add_box_zone(zone, options)
    return api:AddBoxZone(zone, options);
end

---@param zone NoxenSphereZone
---@param options NoxenTargetOption[]
---@return integer
function target.add_sphere_zone(zone, options)
    return api:AddSphereZone(zone, options);
end

---@param entities integer|integer[]
---@param options NoxenTargetOption[]
---@return integer
function target.add_entity(entities, options)
    return api:AddEntity(entities, options);
end

---@param models string|string[]|integer|integer[]
---@param options NoxenTargetOption[]
---@return integer
function target.add_model(models, options)
    return api:AddModel(models, options);
end

---@param options NoxenTargetOption[]
---@return integer
function target.add_global_vehicle(options)
    return api:AddGlobalVehicle(options);
end

---@param options NoxenTargetOption[]
---@return integer
function target.add_global_ped(options)
    return api:AddGlobalPed(options);
end

---@param id integer
function target.remove(id)
    api:RemoveTarget(id);
end

return target;
