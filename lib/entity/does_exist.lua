local DOES_ENTITY_EXIST <const> = DoesEntityExist;

---@param entity number
---@return boolean
return function(entity)
    return DOES_ENTITY_EXIST(entity);
end
