---@class NoxenBridge
---@field frameworks table<NoxenFrameworkName, NoxenFrameworkAdapter|NoxenClientFrameworkAdapter>
---@field inventories table<NoxenInventoryName, NoxenInventoryAdapter>
---@field targets table<NoxenTargetName, NoxenTargetAdapter>
Bridge = {
    frameworks = {},
    inventories = {},
    targets = {},
}

local INACTIVE_STATES <const> = {
    missing = true,
    unknown = true,
    stopped = true,
    stopping = true,
}

local FRAMEWORK_RESOURCES <const> = {
    { name = 'qbx', resource = 'qbx_core' },
    { name = 'esx', resource = 'es_extended' },
    { name = 'qb', resource = 'qb-core' },
}

local esxObject, qbObject

---@param resource string
---@return boolean
function Bridge.isResourceActive(resource)
    return not INACTIVE_STATES[GetResourceState(resource)]
end

---@return NoxenFrameworkName?
function Bridge.detectFramework()
    if Config.Framework ~= 'auto' then
        return Config.Framework
    end

    for _, candidate in ipairs(FRAMEWORK_RESOURCES) do
        if Bridge.isResourceActive(candidate.resource) then
            return candidate.name
        end
    end
end

---@return table
function Bridge.esx()
    esxObject = esxObject or exports.es_extended:getSharedObject()
    return esxObject
end

---@return table
function Bridge.qb()
    qbObject = qbObject or exports['qb-core']:GetCoreObject({ 'Functions' })
    return qbObject
end
