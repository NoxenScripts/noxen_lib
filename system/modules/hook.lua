---@class noxen.lib.hook
---@field public hooks table<string, table<number, fun(...)>>
local hook <const> = nox.class.new 'noxen.lib.hook';

local unpack <const> = table.unpack;

--- Registers a new hook
--- ## Example:
--- ```lua
--- local hooks <const> = Hook();
--- hooks:Add('MyEvent', function(arg1, arg2)
---   print('MyEvent triggered with args:', arg1, arg2);
--- end);
--- hooks:Run('MyEvent', 'Hello', 'World'); -- This will print: MyEvent triggered with args: Hello World
--- ```
--- ## Example (Updating return values):
--- ```lua
--- local hooks <const> = Hook();
--- hooks:Add('ModifyValues', function(a, b)
---  return a + 1, b + 1;
--- end);
--- hooks:Add('ModifyValues', function(a, b)
---  return a * 2, b * 2;
--- end);
--- local result1 <const>, result2 <const> = hooks:Run('ModifyValues', 2, 3);
--- print(result1, result2); -- This will print: 6 8
--- ```
---@param name string
---@param handler fun(...)
function hook:Add(name, handler)
    assert(type(name) == 'string', "hook.Add() - name must be a string");
    assert(type(handler) == 'function', "hook.Add() - handler must be a function");

    if (not self.hooks[name]) then
        self.hooks[name] = {};
    end

    self.hooks[name][#self.hooks[name] + 1] = handler;
end

--- Removes a previously registered hook
--- ## Example:
--- ```lua
--- local hooks <const> = Hook();
--- local function myHandler(arg1, arg2)
---   print('MyEvent triggered with args:', arg1, arg2);
--- end
--- hooks:Add('MyEvent', myHandler);
--- hooks:Remove('MyEvent', myHandler); -- This will remove the handler
--- hooks:Run('MyEvent', 'Hello', 'World'); -- This will not print anything
--- ```
---@param name string
---@param handler fun(...)
---@return boolean
function hook:Remove(name, handler)
    assert(type(name) == 'string', "hook.Remove() - name must be a string");
    assert(type(handler) == 'function', "hook.Remove() - handler must be a function");

    if (not self.hooks[name]) then
        return false;
    end

    for i = #self.hooks[name], 1, -1 do
        if (self.hooks[name][i] == handler) then
            table.remove(self.hooks[name], i);
            return true;
        end
    end

    return false;
end

--- Runs all handlers associated with the given hook name
--- and returns their results. The results of each handler are passed
--- as arguments to the next handler. The final results are returned.
--- If no handlers are registered for the given name, the original
--- arguments are returned.
--- ## Example:
--- ```lua
--- local hooks <const> = Hook();
--- hooks:Add('ModifyValues', function(a, b)
---  return a + 1, b + 1;
--- end);
--- hooks:Add('ModifyValues', function(a, b)
---  return a * 2, b * 2;
--- end);
--- local result1 <const>, result2 <const> = hooks:Run('ModifyValues', 2, 3);
--- print(result1, result2); -- This will print: 6 8
--- ```
---@param name string
---@vararg any
---@return any
function hook:Run(name, ...)
    assert(type(name) == 'string', "hook.Run() - name must be a string");

    if (not self.hooks[name]) then
        return ...;
    end

    local results <const> = {...};
    local resultsCount = #results;

    for i = 1, #self.hooks[name] do
        local ret <const> = {self.hooks[name][i](unpack(results, 1, resultsCount))};
        resultsCount = #ret;

        for j = 1, resultsCount do
            results[j] = ret[j];
        end
    end

    return unpack(results, 1, resultsCount);
end
