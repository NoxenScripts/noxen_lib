local current_id = 1;
local callbacks = {};
local requests = {};

---@return number
local function increment_request_id()
    current_id = current_id > 65535 and 1 or current_id + 1;
    console.debug(('Incrementing request id to ^7(%s%s^7)^0'):format(nox.color.get_current(nil, true) ,current_id));
    return current_id;
end

---@param callback fun(...: any)
local function is_callback_valid(callback)
    return type(callback) == 'function' or type(callback) == 'table' and callback['__cfx_functionReference'] ~= nil;
end

---@param eventName string
---@param callback fun(src: number, ...: any)
---@vararg any
---@overload fun(eventName: string, callback: fun(...: any), ...: any)
local function safe_callback(eventName, callback, ...)
    local success <const>, result <const> = pcall(callback, ...);

    if (not success) then
        console.err(("An error occured while executing event ^7(%s%s^7)^0, stack: ^7(^1%s^7)"):format(nox.color.get_current(nil, true), eventName, result));
    end
end

---@param eventName string
---@param callback fun(src: number, response: fun(...: any), ...: any) | fun(response: fun(...: any), ...: any)
---@param ... any
local function register_callback(eventName, callback, ...)
    if (not is_callback_valid(callback)) then
        console.err(('An error occured while registering event callback ^7(%s%s^7)^0, stack: ^7(^1Invalid callback^7)'):format(nox.color.get_current(nil, true), eventName or 'nil'));
        return;
    end

    if (not is_callback_valid(callbacks[eventName])) then
        console.debug(('Registering event callback ^7(%s%s^7)^0'):format(nox.color.get_current(nil, true), eventName or 'nil'));
    else
        console.warn(('Event callback ^7(%s%s^7)^0 already has a callback registered, overwriting...'):format(nox.color.get_current(nil, true), eventName));
    end

    callbacks[eventName] = callback;
end

---@param eventName string
---@param callback fun(...: any)
---@param src number
---@vararg any
local function emit_callback(eventName, callback, src, ...)
    local args <const> = {...};

    if (not is_callback_valid(callback)) then
        console.err(('An error occured while emitting event callback ^7(%s%s^7)^0, stack: ^7(^1Invalid callback^7)'):format(
            nox.color.get_current(nil, true), eventName or 'nil'
        ));
        return;
    end

    requests[current_id] = function(...)
        local success <const>, result <const> = pcall(callback, ...);

        if (not success) then
            console.err(("An error occured while executing event ^7(%s%s^7)^0, stack: ^7(^1%s^7)"):format(nox.color.get_current(nil, true) ,eventName, result));
        end
    end;

    if (nox.is_server) then
        nox.events.emit.net(eLibEvents.emitCallback, src, eventName, current_id, table.unpack(args));
    else
        nox.events.emit.net(eLibEvents.emitCallback, eventName, current_id, src, table.unpack(args));
    end

    increment_request_id();
end

nox.events.on.net(eLibEvents.emitCallback, function(_, eventName, requests_id, ...)
    local src <const> = source;
    local args <const> = {...};

    if (nox.is_server) then
        safe_callback(eventName, callbacks[eventName], src, function(...)
            console.debug(('Sent callback response to ^3%s^7 for event ^7(^3%s^7)^0 with request id ^7(^6%s^7) args:^2%s^0'):format(
                src or 'N/A',
                eventName or 'N/A',
                requests_id or 'N/A',
                json.encode({...}) or 'with no arguments'
            ));
            nox.events.emit.net(eLibEvents.receiveCallback, src, eventName, requests_id, ...);
        end, table.unpack(args));
    else
        safe_callback(eventName, callbacks[eventName], function(...)
            nox.events.emit.net(eLibEvents.receiveCallback, eventName, requests_id, ...);
        end, table.unpack(args));
    end
end);

nox.events.on.net(eLibEvents.receiveCallback, function(_, eventName, requests_id, ...)
    if (not nox.is_server) then
        local invoking <const> = GetInvokingResource();

        if (invoking ~= nil) then
            nox.game.crash(eLibEvents.receiveCallback);
        end
        console.debug(('Received callback response for event ^7(^3%s^7)^0 with request id ^7(^6%s^7) args:^2%s^0'):format(
            eventName or 'nil',
            requests_id or 'N/A',
            json.encode({...}) or 'with no arguments'
        ));
    end

    safe_callback(eventName, requests[requests_id], ...);
    requests[requests_id] = nil;
end);

exports('register_callback', register_callback);
exports('emit_callback', emit_callback);
