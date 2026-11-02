local EMIT_EVENT <const> = 'noxen.events.callback.emit'
local RECEIVE_EVENT <const> = 'noxen.events.callback.receive'

---@class NoxenCallbackEntry
---@field handler function
---@field owner string

---@class NoxenCallbackRequest
---@field callback function
---@field source integer

---@type table<string, NoxenCallbackEntry>
local callbacks = {}
---@type table<integer, NoxenCallbackRequest>
local requests = {}
---@type table<integer, table<string, integer>>
local lastCalls = {}
local nextRequestId = 0

---@param source integer
---@param name string
---@return boolean
local function isAllowed(source, name)
    local calls = lastCalls[source]

    if not calls then
        calls = {}
        lastCalls[source] = calls
    end

    local now = GetGameTimer()
    local last = calls[name]

    if last and now - last < Config.CallbackMinIntervalMs then
        return false
    end

    calls[name] = now
    return true
end

---@param name string
---@param source integer
---@param id integer
---@param ... any
local function dispatch(name, source, id, ...)
    local replied = false

    local function reply(...)
        if replied then
            return
        end

        replied = true
        TriggerClientEvent(RECEIVE_EVENT, source, id, ...)
    end

    local entry = callbacks[name]

    if not entry or not isAllowed(source, name) then
        reply()
        return
    end

    local ok, err = pcall(entry.handler, source, reply, ...)

    if not ok then
        console.err(('callback "%s" failed: %s'):format(name, err))
        reply()
    end
end

---@param name string
---@param handler fun(source: integer, reply: fun(...), ...)
local function registerCallback(name, handler)
    callbacks[name] = { handler = handler, owner = GetInvokingResource() or nox.name }
end

---@param name string
---@param callback fun(...)
---@param source integer
---@param ... any
local function emitCallback(name, callback, source, ...)
    nextRequestId = nextRequestId + 1
    requests[nextRequestId] = { callback = callback, source = source }
    TriggerClientEvent(EMIT_EVENT, source, name, nextRequestId, ...)
end

RegisterNetEvent(EMIT_EVENT, function(name, id, ...)
    local src <const> = source

    if type(name) == 'string' and math.type(id) == 'integer' then
        dispatch(name, src, id, ...)
    end
end)

RegisterNetEvent(RECEIVE_EVENT, function(id, ...)
    local request = requests[id]

    if not request or request.source ~= source then
        return
    end

    requests[id] = nil

    local ok, err = pcall(request.callback, ...)

    if not ok then
        console.err(('callback response failed: %s'):format(err))
    end
end)

AddEventHandler('playerDropped', function()
    local src <const> = source
    lastCalls[src] = nil

    for id, request in pairs(requests) do
        if request.source == src then
            requests[id] = nil
            pcall(request.callback)
        end
    end
end)

AddEventHandler('onResourceStop', function(resource)
    for name, entry in pairs(callbacks) do
        if entry.owner == resource then
            callbacks[name] = nil
        end
    end
end)

exports('register_callback', registerCallback)
exports('emit_callback', emitCallback)
