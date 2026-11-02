local EMIT_EVENT <const> = 'noxen.events.callback.emit'
local RECEIVE_EVENT <const> = 'noxen.events.callback.receive'

---@class NoxenClientCallbackEntry
---@field handler function
---@field owner string

---@type table<string, NoxenClientCallbackEntry>
local callbacks = {}
---@type table<integer, function>
local requests = {}
local nextRequestId = 0

---@param name string
---@param handler fun(reply: fun(...), ...)
local function registerCallback(name, handler)
    callbacks[name] = { handler = handler, owner = GetInvokingResource() or nox.name }
end

---@param name string
---@param callback fun(...)
---@param ... any
local function emitCallback(name, callback, ...)
    nextRequestId = nextRequestId + 1
    requests[nextRequestId] = callback
    TriggerServerEvent(EMIT_EVENT, name, nextRequestId, ...)
end

RegisterNetEvent(EMIT_EVENT, function(name, id, ...)
    local replied = false

    local function reply(...)
        if replied then
            return
        end

        replied = true
        TriggerServerEvent(RECEIVE_EVENT, id, ...)
    end

    local entry = callbacks[name]

    if not entry then
        reply()
        return
    end

    local ok, err = pcall(entry.handler, reply, ...)

    if not ok then
        console.err(('callback "%s" failed: %s'):format(name, err))
        reply()
    end
end)

RegisterNetEvent(RECEIVE_EVENT, function(id, ...)
    local callback = requests[id]

    if not callback then
        return
    end

    requests[id] = nil

    local ok, err = pcall(callback, ...)

    if not ok then
        console.err(('callback response failed: %s'):format(err))
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
