local GET_INVOKING_RESOURCE <const> = GetInvokingResource;
local base_event <const> = require 'lib.events.classes.base_event';
local net_event <const> = require 'lib.events.classes.net_event';

---@class noxen.lib.events.on.resource
---@field public net fun(eventName: string, callback: fun(event: noxen.lib.events.net_event, ...: any) | fun(event: noxen.lib.events.net_event, resourceName: string, ...: any)): noxen.lib.events.net_event
---@overload fun(eventName: string, callback: fun(event: noxen.lib.events.base_event, ...: any): void | fun(event: noxen.lib.events.base_event, resourceName: string, ...: any): void): noxen.lib.events.base_event

---@class noxen.lib.events.on
---@field public net fun(eventName: string, callback: fun(event: noxen.lib.events.net_event, ...: any) | fun(event: noxen.lib.events.net_event, ...: any)): noxen.lib.events.net_event
---@field public secure fun(eventName: string, callback: fun(event: noxen.lib.events.net_event, ...: any) | fun(event: noxen.lib.events.net_event, ...: any)): noxen.lib.events.net_event
---@field public callback fun(eventName: string, callback: fun(src: number, response: fun(...: any), ...: any) | fun(response: fun(...: any), ...: any), ...: any): void
---@field public internal fun(eventName: string, callback: fun(event: noxen.lib.events.base_event, ...: any) | fun(event: noxen.lib.events.base_event, ...: any)): noxen.lib.events.base_event
---@field public game fun(eventName: string, callback: fun(event: noxen.lib.events.base_event, ...: any)): noxen.lib.events.base_event
---@field public resource noxen.lib.events.on.resource
---@overload fun(eventName: string, callback: fun(event: noxen.lib.events.base_event, ...: any): void | fun(event: noxen.lib.events.base_event, ...: any): void): noxen.lib.events.base_event
local on <const> = table.overload(function(eventName, callback)
    return base_event()
        :SetName(eventName)
        :SetCallback(function(event, ...)
            nox.events.safe_callback(eventName, callback, event, ...);
        end)
        :SetHandler();
end, {
    ---@param eventName string
    ---@param callback fun(event: noxen.lib.events.net_event, ...: any) | fun(event: noxen.lib.events.net_event, ...: any)
    ---@return noxen.lib.events.net_event
    net = function(eventName, callback)
        return net_event()
            :SetName(eventName)
            :SetCallback(function(event, ...)
                nox.events.safe_callback(eventName, callback, event, ...);
            end)
            :SetHandler();
    end,
    ---@param eventName string
    ---@param callback fun(event: noxen.lib.events.net_event, ...: any) | fun(event: noxen.lib.events.net_event, ...: any)
    ---@return noxen.lib.events.net_event
    secure = function(eventName, callback)
        return net_event()
            :SetName(eventName)
            :SetCallback(function(event, ...)
                if (nox.is_server) then
                    nox.events.safe_callback(eventName, callback, event, ...);
                else
                    local invoking <const> = GET_INVOKING_RESOURCE();

                    if (invoking ~= nil) then
                        nox.game.crash(eventName);
                        return;
                    end
                    nox.events.safe_callback(eventName, callback, event, ...);
                end
            end)
            :SetHandler();
    end,
    ---@param eventName string
    ---@param callback fun(src: number, response: fun(...: any), ...: any) | fun(response: fun(...: any), ...: any)
    ---@param ... any
    callback = function(eventName, callback, ...)
        exports['noxen_lib']:register_callback(eventName, callback, ...);
    end,
    --- Internal events are sided events that can be handled only by noxen lib.
    ---@param eventName string
    ---@param callback fun(event: noxen.lib.events.base_event, ...: any): void | fun(event: noxen.lib.events.base_event, ...: any): void
    ---@return noxen.lib.events.base_event
    internal = function(eventName, callback)
        return base_event()
            :SetName(eventName)
            :SetCallback(function(event, ...)
                if (nox.is_server) then
                    nox.events.safe_callback(eventName, callback, event, ...);
                else
                    local invoking <const> = GET_INVOKING_RESOURCE();
                    if (invoking ~= nox.name) then
                        nox.game.crash(('[Internal] > %s'):format(eventName));
                        return;
                    end
                    nox.events.safe_callback(eventName, callback, event, ...);
                end
            end)
            :SetHandler();
    end,
    ---@param eventName string
    ---@param callback fun(event: noxen.lib.events.base_event, ...: any): void
    ---@return noxen.lib.events.base_event
    game = function(eventName, callback)
        return base_event()
            :SetName("gameEventTriggered")
            :SetCallback(function(event, _, event_name, ...)
                if (eventName == event_name) then
                    nox.events.safe_callback(("Game Event (%s)"):format(eventName), callback, event, ...);
                end
            end)
            :SetHandler();
    end,
    resource = table.overload(function(eventName, callback)
        local name <const> = ('%s_%s'):format(nox.current_resource, eventName);

        return base_event()
            :SetName(name)
            :SetCallback(function(event, ...)
                nox.events.safe_callback(name, callback, event, ...);
            end)
            :SetHandler();
    end, {
        net = function(eventName, callback)
            local name <const> = ('%s_%s'):format(nox.current_resource, eventName);

            return net_event()
                :SetName(name)
                :SetCallback(function(event, ...)
                    nox.events.safe_callback(name, callback, event, ...);
                end)
                :SetHandler();
        end
    })
});

return on;
