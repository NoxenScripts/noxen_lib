local ENTITY = Entity;

---@class noxen.lib.entity: EventEmitter
---@overload fun(handle?: number): noxen.lib.entity
local Entity = nox.class.extends('noxen.lib.entity', 'EventEmitter');

---@param handle number
function Entity:Constructor(handle)

    self:super();

    local metatable = self:GetMetatable();

    self.handle = handle;
    self.model = nil;
    self.type = metatable.__name;

end

---@param entity? Entity
---@return boolean
function Entity.IsValid(entity)
    return typeof(entity) == entity.type and nox.entity.does_exist(entity:GetHandle());
end

---@return number
function Entity:GetHandle()
    return self.handle;
end

---@return Entity
function Entity:GetState()
    return ENTITY(self:GetHandle()).state;
end

---@return vector4
function Entity:GetCoords()
    return nox.entity.get_coords(self:GetHandle());
end

---@param coords vector3 | vector4
---@param no_offset boolean
function Entity:SetCoords(coords, no_offset)
    nox.entity.set_coords(self:GetHandle(), coords, no_offset);
    self:emit(eEntityEvents.UpdatedCoords, coords);
end

---@param toggle boolean
function Entity:FreezePosition(toggle)
    nox.entity.freeze_position(self:GetHandle(), toggle);
end

return Entity;
