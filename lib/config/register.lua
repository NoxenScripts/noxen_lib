---@class NoxConfig
---@field public set fun(key: string, value: any, valueType: string, secondaryType: string): NoxConfig

local config <const> = {};

---[[
--- TODO: Make this able to use all primitives types, not just tables.
---]]

---@param name string
---@return NoxConfig
local function setup(name)
    return setmetatable({}, {
        __data = {};
        __index = function(self, key)
            if (key == 'set') then
                return function(key2, value, type, secondaryType)
                    return config.register_sub(name, key2, value, type, secondaryType);
                end;
            end

            local metatable <const> = getmetatable(self);

            if (not metatable or metatable.__data[key] == nil) then
                if (not nox.config.default[name]) then
                    console.err(("^3Config key ^1%s^3 is not registered!"):format(name));
                    return nil;
                end

                return nox.config.default[name].value[key];
            end

            return metatable.__data[key];
        end;
        __newindex = function(self, key, value)
            local metatable <const> = getmetatable(self);

            if (not nox.config.default[name].value[key]) then
                console.warn(("^3Config key ^1%s^3 does not exist in config ^1%s^3!"):format(key, name));
                return;
            end

            self.__data[key] = value;
        end;
    });
end

---@param name string
function config.register(name)
    if (type(nox.config.default[name]) ~= 'Config') then
        nox.config.default[name] = nox.config.class.config({}, 'table');
        return setup(name);
    end
    console.warn(("^3Config key ^1%s^3 already registered!"):format(name));
end

---@param parent string
---@param key string
---@param value any
---@param valueType string
---@param secondaryType string
---@return NoxConfig
function config.register_sub(parent, name, value, valueType, secondaryType)
    if (typeof(nox.config.default[parent]) ~= 'Config') then
        console.err(("^3Config key ^1%s^3 is not registered!"):format(parent));
        return;
    end

    if (nox.config.default[parent].type ~= 'table') then
        console.err(("^3Config key ^1%s^3 is not a valid parent!"):format(parent));
        return;
    end

    nox.config.default[parent].value = nox.config.default[parent].value or {};
    nox.config.default[parent].value[name] = nox.config.class.config(value, valueType, secondaryType, parent);

    return setup(name);
end

return config.register;
