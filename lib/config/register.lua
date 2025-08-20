---@param key string
---@param value any
---@param valueType string
---@param secondaryType string
return function(key, value, valueType, secondaryType)
    if (type(nox.config.default[key]) ~= 'Config') then
        nox.config.default[key] = nox.config.class.config(value, valueType, secondaryType);
    else
        console.warn(("^3Config key ^1%s^3 already registered!"):format(key));
    end
end
