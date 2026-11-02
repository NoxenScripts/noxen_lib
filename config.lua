---@class NoxenAccountMap
---@field cash? string
---@field bank? string
---@field black? string
---@field crypto? string

---@class NoxenConfig
---@field Framework 'auto'|'esx'|'qb'|'qbx'
---@field Inventory 'auto'|'ox'|'qb'|'esx'
---@field Target 'auto'|'ox'|'qb'
---@field Notify 'framework'|'ox_lib'
---@field TargetDistance number
---@field CallbackMinIntervalMs integer
---@field PlayerSyncDelayMs integer
---@field Accounts table<NoxenFrameworkName, NoxenAccountMap>
Config = {
    Framework = 'auto',
    Inventory = 'auto',
    Target = 'auto',
    Notify = 'framework',
    TargetDistance = 2.5,
    CallbackMinIntervalMs = 25,
    PlayerSyncDelayMs = 100,
    Accounts = {
        esx = { cash = 'money', bank = 'bank', black = 'black_money' },
        qb = { cash = 'cash', bank = 'bank', crypto = 'crypto' },
        qbx = { cash = 'cash', bank = 'bank', crypto = 'crypto' },
    },
}
