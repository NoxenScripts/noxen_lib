local GET_ENTITY_COORDS <const> = GetEntityCoords;
local GET_ENTITY_HEADING <const> = GetEntityHeading;

---@param entity number
---@return vector4
return function(entity)
    if (not nox.entity.does_exist(entity)) then
        return vector4(0.0, 0.0, 0.0, 0.0);
    end

    local coords <const> = GET_ENTITY_COORDS(entity);
    local heading <const> = GET_ENTITY_HEADING(entity);

    return vector4(coords.x, coords.y, coords.z, heading);
end
