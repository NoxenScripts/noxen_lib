local MAX_AMOUNT <const> = 9007199254740991
local DEFAULT_NOTIFY_DURATION <const> = 5000
local NOTIFY_KINDS <const> = { info = true, success = true, error = true, warning = true }
local OX_NOTIFY_TYPES <const> = { info = 'inform', success = 'success', error = 'error', warning = 'warning' }

local SYNC_EVENT <const> = 'noxen_lib:client:playerData'
local SYNC_REQUEST_EVENT <const> = 'noxen_lib:server:requestPlayerData'
local SYNCED_EVENT <const> = 'noxen:server:playerSynced'

local frameworkName = Bridge.detectFramework()
assert(frameworkName, 'noxen_lib: no supported framework is started, ensure it before noxen_lib')

---@return NoxenInventoryName
local function detectInventory()
    if Config.Inventory ~= 'auto' then
        return Config.Inventory
    end

    if Bridge.isResourceActive('ox_inventory') then
        return 'ox'
    end

    return frameworkName == 'esx' and 'esx' or 'qb'
end

local inventoryName = detectInventory()
local framework = Bridge.frameworks[frameworkName] --[[@as NoxenFrameworkAdapter]]
local inventory = Bridge.inventories[inventoryName]
local accounts = Config.Accounts[frameworkName]

---@type table<string, { handler: function, owner: string }>
local usableItems = {}
---@type table<integer, true>
local pendingSyncs = {}

---@param value any
---@return integer?
local function toPositiveInteger(value)
    if type(value) ~= 'number' or value ~= value or value == math.huge then
        return nil
    end

    local integer = math.floor(value)

    if integer < 1 or integer > MAX_AMOUNT then
        return nil
    end

    return integer
end

---@param source any
---@return boolean
local function isValidSource(source)
    return type(source) == 'number' and source > 0 and framework.isLoaded(source)
end

---@param action string
---@param fn function
---@param ... any
---@return boolean
local function attempt(action, fn, ...)
    local ok, result = pcall(fn, ...)

    if not ok then
        console.err(('%s failed: %s'):format(action, result))
        return false
    end

    return result == true
end

---@param account NoxenAccount
---@return string?
local function resolveAccount(account)
    local native = accounts[account]

    if not native then
        console.warn(('account "%s" is not mapped for %s'):format(tostring(account), frameworkName))
    end

    return native
end

---@return NoxenFrameworkName
local function getFramework()
    return frameworkName
end

---@return NoxenInventoryName
local function getInventory()
    return inventoryName
end

---@param source integer
---@return NoxenPlayer?
local function getPlayer(source)
    if type(source) ~= 'number' then
        return nil
    end

    return framework.getPlayer(source)
end

---@param identifier string
---@return NoxenPlayer?
local function getPlayerByIdentifier(identifier)
    if type(identifier) ~= 'string' then
        return nil
    end

    return framework.getPlayerByIdentifier(identifier)
end

---@return NoxenPlayer[]
local function getPlayers()
    return framework.getPlayers()
end

---@param source integer
---@param account NoxenAccount
---@return number
local function getMoney(source, account)
    local native = resolveAccount(account)

    if not native or not isValidSource(source) then
        return 0
    end

    return framework.getBalance(source, native) or 0
end

---@param source integer
---@param account NoxenAccount
---@param amount number
---@param reason? string
---@return boolean
local function addMoney(source, account, amount, reason)
    local native = resolveAccount(account)
    local value = toPositiveInteger(amount)

    if not native or not value or not isValidSource(source) then
        return false
    end

    return attempt('addMoney', framework.addMoney, source, native, value, reason or 'noxen')
end

---@param source integer
---@param account NoxenAccount
---@param amount number
---@param reason? string
---@return boolean
local function removeMoney(source, account, amount, reason)
    local native = resolveAccount(account)
    local value = toPositiveInteger(amount)

    if not native or not value or not isValidSource(source) then
        return false
    end

    if (framework.getBalance(source, native) or 0) < value then
        return false
    end

    return attempt('removeMoney', framework.removeMoney, source, native, value, reason or 'noxen')
end

---@param source integer
---@param account NoxenAccount
---@param amount number
---@param reason? string
---@return boolean
local function setMoney(source, account, amount, reason)
    local native = resolveAccount(account)
    local value = amount == 0 and 0 or toPositiveInteger(amount)

    if not native or not value or not isValidSource(source) then
        return false
    end

    return attempt('setMoney', framework.setMoney, source, native, value, reason or 'noxen')
end

---@param source integer
---@return NoxenJob?
local function getJob(source)
    local player = getPlayer(source)
    return player and player.job or nil
end

---@param source integer
---@return NoxenGang?
local function getGang(source)
    local player = getPlayer(source)
    return player and player.gang or nil
end

---@param source integer
---@param jobs string|string[]
---@param minGrade? integer
---@return boolean
local function hasJob(source, jobs, minGrade)
    return Mappers.matchesJob(getJob(source), jobs, minGrade)
end

---@param source integer
---@param name string
---@param grade? integer
---@return boolean
local function setJob(source, name, grade)
    local level = math.tointeger(grade or 0)

    if type(name) ~= 'string' or not level or level < 0 or not isValidSource(source) then
        return false
    end

    return attempt('setJob', framework.setJob, source, name, level)
end

---@param source integer
---@param onDuty boolean
---@return boolean
local function setDuty(source, onDuty)
    if type(onDuty) ~= 'boolean' or not isValidSource(source) then
        return false
    end

    return attempt('setDuty', framework.setDuty, source, onDuty)
end

---@param source integer
---@param name string
---@param grade? integer
---@return boolean
local function setJob2(source, name, grade)
    local level = math.tointeger(grade or 0)

    if type(name) ~= 'string' or not level or level < 0 or not isValidSource(source) then
        return false
    end

    return attempt('setJob2', framework.setJob2, source, name, level)
end

---@param source integer
---@param permission string
---@return boolean
local function hasPermission(source, permission)
    return type(permission) == 'string' and isValidSource(source) and framework.hasPermission(source, permission) == true
end

---@return boolean
local function isPvpEnabled()
    return framework.isPvpEnabled() == true
end

---@param item string
---@return boolean
local function isItemUsable(item)
    return type(item) == 'string' and framework.isItemUsable(item) == true
end

---@param item string
---@return NoxenItem?
local function getItem(item)
    if type(item) ~= 'string' then
        return nil
    end

    return inventory.getItem(item)
end

---@param source integer
---@param item string
---@param metadata? table
---@return integer
local function getItemCount(source, item, metadata)
    if type(item) ~= 'string' or not isValidSource(source) then
        return 0
    end

    return inventory.getCount(source, item, metadata)
end

---@param entry table
---@return NoxenInventoryItem
local function toInventoryItem(entry)
    return {
        name = entry.name,
        label = entry.label,
        weight = entry.weight,
        amount = entry.count or entry.amount or 0,
        usable = entry.usable == true or framework.isItemUsable(entry.name),
    }
end

---@param source integer
---@return NoxenInventoryItem[]
local function getInventoryItems(source)
    local items = {}

    if not isValidSource(source) then
        return items
    end

    for _, entry in pairs(inventory.getItems(source)) do
        if type(entry) == 'table' and entry.name then
            items[#items + 1] = toInventoryItem(entry)
        end
    end

    return items
end

---@param source integer
---@param item string
---@return NoxenInventoryItem?
local function getInventoryItem(source, item)
    for _, entry in ipairs(getInventoryItems(source)) do
        if entry.name == item then
            return entry
        end
    end
end

---@param source integer
---@param item string
---@param count? integer
---@param metadata? table
---@return boolean
local function hasItem(source, item, count, metadata)
    return getItemCount(source, item, metadata) >= (toPositiveInteger(count or 1) or math.huge)
end

---@param source integer
---@param item string
---@param count? integer
---@param metadata? table
---@return boolean
local function canCarry(source, item, count, metadata)
    local value = toPositiveInteger(count or 1)

    if not value or type(item) ~= 'string' or not isValidSource(source) or not inventory.getItem(item) then
        return false
    end

    return attempt('canCarry', inventory.canCarry, source, item, value, metadata)
end

---@param source integer
---@param item string
---@param count? integer
---@param metadata? table
---@param reason? string
---@return boolean
local function addItem(source, item, count, metadata, reason)
    local value = toPositiveInteger(count or 1)

    if not value or not canCarry(source, item, value, metadata) then
        return false
    end

    return attempt('addItem', inventory.add, source, item, value, metadata, reason or 'noxen')
end

---@param source integer
---@param item string
---@param count? integer
---@param metadata? table
---@param reason? string
---@return boolean
local function removeItem(source, item, count, metadata, reason)
    local value = toPositiveInteger(count or 1)

    if not value or getItemCount(source, item, metadata) < value then
        return false
    end

    return attempt('removeItem', inventory.remove, source, item, value, metadata, reason or 'noxen')
end

---@param item string
---@param handler fun(source: integer, item: string, ...)
local function registerUsableItem(item, handler)
    local isNew = usableItems[item] == nil
    usableItems[item] = { handler = handler, owner = GetInvokingResource() or nox.name }

    if not isNew then
        return
    end

    framework.registerUsableItem(item, function(source, ...)
        local entry = usableItems[item]

        if entry and entry.handler then
            entry.handler(source, item, ...)
        end
    end)
end

---@param source integer
---@param message string
---@param kind? NoxenNotifyType
---@param duration? integer
local function notify(source, message, kind, duration)
    kind = NOTIFY_KINDS[kind] and kind or 'info'
    duration = duration or DEFAULT_NOTIFY_DURATION

    if Config.Notify == 'ox_lib' then
        TriggerClientEvent('ox_lib:notify', source, { description = message, type = OX_NOTIFY_TYPES[kind], duration = duration })
        return
    end

    framework.notify(source, message, kind, duration)
end

---@param entries table<string, { owner: string }>
---@param resource string
local function releaseOwnedEntries(entries, resource)
    for key, entry in pairs(entries) do
        if entry.owner == resource then
            entries[key] = nil
        end
    end
end

---@param source integer
local function pushPlayerData(source)
    local player = framework.getPlayer(source)

    if player then
        player.inventory = getInventoryItems(source)
        TriggerClientEvent(SYNC_EVENT, source, player)
        TriggerEvent(SYNCED_EVENT, source, player)
    end
end

---@param source integer
local function scheduleSync(source)
    if pendingSyncs[source] then
        return
    end

    pendingSyncs[source] = true

    SetTimeout(Config.PlayerSyncDelayMs, function()
        if pendingSyncs[source] then
            pendingSyncs[source] = nil
            pushPlayerData(source)
        end
    end)
end

AddEventHandler('onResourceStop', function(resource)
    releaseOwnedEntries(usableItems, resource)
end)

framework.registerEvents(function(event, source, ...)
    if event == 'playerUnloaded' then
        pendingSyncs[source] = nil
    else
        scheduleSync(source)
    end

    if event ~= 'dataChanged' then
        TriggerEvent(('noxen:server:%s'):format(event), source, ...)
    end
end)

RegisterNetEvent(SYNC_REQUEST_EVENT, function()
    local src <const> = source

    if type(src) == 'number' and framework.isLoaded(src) then
        scheduleSync(src)
    end
end)

---@return boolean
local function supportsStash()
    return inventory.openStash ~= nil
end

---@param id string
---@param label string
---@param slots integer
---@param weight integer
---@param coords? vector3
---@return boolean
local function registerStash(id, label, slots, weight, coords)
    if not supportsStash() or type(id) ~= 'string' then
        return false
    end

    return attempt('registerStash', function()
        inventory.registerStash(id, label, slots, weight, coords)
        return true
    end)
end

---@param source integer
---@param id string
---@param label string
---@param slots integer
---@param weight integer
---@return boolean
local function openStash(source, id, label, slots, weight)
    if not supportsStash() or type(id) ~= 'string' or not isValidSource(source) then
        return false
    end

    return attempt('openStash', inventory.openStash, source, id, label, slots, weight)
end

exports('SupportsStash', supportsStash)
exports('RegisterStash', registerStash)
exports('OpenStash', openStash)
exports('GetFramework', getFramework)
exports('GetInventory', getInventory)
exports('GetPlayer', getPlayer)
exports('GetPlayerByIdentifier', getPlayerByIdentifier)
exports('GetPlayers', getPlayers)
exports('GetMoney', getMoney)
exports('AddMoney', addMoney)
exports('RemoveMoney', removeMoney)
exports('SetMoney', setMoney)
exports('GetJob', getJob)
exports('GetGang', getGang)
exports('HasJob', hasJob)
exports('SetJob', setJob)
exports('SetJob2', setJob2)
exports('SetDuty', setDuty)
exports('HasPermission', hasPermission)
exports('IsPvpEnabled', isPvpEnabled)
exports('GetItem', getItem)
exports('GetItemCount', getItemCount)
exports('GetInventoryItems', getInventoryItems)
exports('GetInventoryItem', getInventoryItem)
exports('IsItemUsable', isItemUsable)
exports('HasItem', hasItem)
exports('CanCarry', canCarry)
exports('AddItem', addItem)
exports('RemoveItem', removeItem)
exports('RegisterUsableItem', registerUsableItem)
exports('Notify', notify)
