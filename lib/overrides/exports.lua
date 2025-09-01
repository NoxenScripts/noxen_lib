local metatable <const> = getmetatable(exports);
local __index <const> = metatable.__index;

---@param var any
---@return boolean
local function is_function(var)
    return type(var) == 'function'
        or type(var) == 'table' and rawget(var, '__cfx_functionReference');
end

---@param state boolean
---@vararg any
---@return ...: any
local function process_result(state, ...)
    if (not state) then
        local err <const> = ...;
        console.error(('Error while calling export: %s'):format(tostring(err)));
    end
    return ...;
end

--- Silent Exports Proxy
--- Silent Exports is a proxy table to access exports of other resources without throwing errors if the resource or export does not exist.
--- This is useful for optional dependencies where you want to call an export if it exists, but don't want to throw an error if it doesn't.
--- Usage:
--- ```lua
--- SilentExports['resource_name']:MethodName(args...);
--- ```
---@class SilentExports
---@overload table<string, table<string, function(...)>> A proxy table to access exports of other resources without throwing errors if the resource or export does not exist.
SilentExports = setmetatable({}, {
    __index = function(self, key)
        local value <const> = __index(exports, key);
        return setmetatable({}, {
            __index = function(_, k)
                local metatable <const> = getmetatable(value);

                if (not metatable) then
                    return nil; -- Will not throw an error if trying to access invalid resource
                end

                local success <const>, export <const> = pcall(metatable.__index, value, k);

                if (not success or not is_function(export)) then
                    return function()
                        console.warn(('Tried to call non-existent export "^3%s^7" on resource "^3%s^7".'):format(k, key));
                        return nil;
                    end; -- Will not throw an error if trying to access invalid resource
                end

                return function(_, ...)
                    return process_result(pcall(export, nil, ...));
                end
            end,
            __newindex = function(_, k, v)
                error(('Cannot set value on silent export proxy resource: %s'):format(tostring(k)), 2);
            end,
        });
    end,
    __newindex = function(_, k, v)
        error(('Cannot set value on silent exports proxy: %s'):format(tostring(k)), 2);
    end,
});
