---@class noxen.lib.events.emit
---@field public net fun(eventName: string, ...: any) | fun(eventName: string, src: number | boolean, ...: any)
---@field public broadcast fun(eventName: string, ...: any): void
---@field public callback noxen.lib.events.emit.callback
---@overload fun(eventName: string, src: number | boolean, ...: any): void
---@overload fun(eventName: string, ...: any): void
local emit <const> = table.overload(TriggerEvent, {
    ---@param eventName string
    ---@param src number | boolean
    ---@vararg any
    ---@overload fun(eventName: string, ...: any): void
    net = function(eventName, ...)
        if (nox.is_server) then
            TriggerClientEvent(eventName, ...);
        else
            TriggerServerEvent(eventName, ...);
        end
    end,
    ---@param eventName string
    ---@vararg any
    broadcast = function(eventName, ...)
        TriggerClientEvent(eventName, -1, ...);
    end,
    ---@class noxen.lib.events.emit.callback
    ---@field public await fun(eventName: string, ...: any): any
    ---@overload fun(eventName: string, src: number, callback: fun(...: any), ...: any): void
    ---@overload fun(eventName: string, callback: fun(...: any), ...: any): void
    callback = table.overload(function(eventName, src, callback, ...)
        if (nox.is_server) then
            exports['noxen_lib']:emit_callback(eventName, callback, src, ...);
        else
            exports['noxen_lib']:emit_callback(eventName, src, callback, ...);
        end
    end, {
        ---@param eventName string
        ---@vararg any
        ---@return any
        await = function(eventName, src, ...)
            local promise <const> = promise.new();

            exports['noxen_lib']:emit_callback(eventName, function(...)
                promise:resolve({...});
            end, src, ...);

            return table.unpack(Citizen.Await(promise));
        end
    });
});

return emit;
