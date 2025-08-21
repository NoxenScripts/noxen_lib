local FREEZE_ENTITY_POSITION <const> = FreezeEntityPosition;

---@param entity number
---@param state boolean
return function(entity, state)
    if (not nox.entity.does_exist(entity)) then return; end
    FREEZE_ENTITY_POSITION(entity, state);
end
