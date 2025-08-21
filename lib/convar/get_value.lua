---@param key string
---@return any
return function(key)
    local convar <const> = GetConvar(key);

    if (type(convar) == 'string') then
        return nox.convar.get_type(convar);
    end

    return nil;

end
