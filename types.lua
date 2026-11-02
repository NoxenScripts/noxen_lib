---@meta

---@alias NoxenFrameworkName 'esx'|'qb'|'qbx'
---@alias NoxenInventoryName 'ox'|'qb'|'esx'
---@alias NoxenTargetName 'ox'|'qb'
---@alias NoxenAccount 'cash'|'bank'|'black'|'crypto'
---@alias NoxenNotifyType 'info'|'success'|'error'|'warning'

---@class NoxenJob
---@field name string
---@field label string
---@field grade integer
---@field gradeName string
---@field gradeLabel string
---@field salary number
---@field onDuty boolean
---@field isBoss boolean
---@field type? string

---@class NoxenGang
---@field name string
---@field label string
---@field grade integer
---@field gradeName string
---@field isBoss boolean

---@class NoxenPlayer
---@field source integer
---@field identifier string
---@field license string
---@field name string
---@field firstName string
---@field lastName string
---@field job NoxenJob
---@field job2? NoxenJob
---@field gang? NoxenGang
---@field money table<string, number>
---@field inventory? NoxenInventoryItem[]

---@class NoxenInventoryItem
---@field name string
---@field label string
---@field weight number
---@field amount integer
---@field usable boolean

---@class NoxenItem
---@field name string
---@field label string
---@field weight number

---@class NoxenFrameworkAdapter
---@field isLoaded fun(source: integer): boolean
---@field getPlayer fun(source: integer): NoxenPlayer?
---@field getPlayerByIdentifier fun(identifier: string): NoxenPlayer?
---@field getPlayers fun(): NoxenPlayer[]
---@field hasPermission fun(source: integer, permission: string): boolean
---@field isPvpEnabled fun(): boolean
---@field getBalance fun(source: integer, account: string): number?
---@field addMoney fun(source: integer, account: string, amount: integer, reason: string): boolean
---@field removeMoney fun(source: integer, account: string, amount: integer, reason: string): boolean
---@field setMoney fun(source: integer, account: string, amount: integer, reason: string): boolean
---@field setJob fun(source: integer, name: string, grade: integer): boolean
---@field setJob2 fun(source: integer, name: string, grade: integer): boolean
---@field setDuty fun(source: integer, onDuty: boolean): boolean
---@field notify fun(source: integer, message: string, kind: NoxenNotifyType, duration: integer)
---@field isItemUsable fun(item: string): boolean
---@field registerUsableItem fun(item: string, handler: fun(source: integer, ...))
---@field registerEvents fun(emit: fun(event: string, ...))

---@class NoxenInventoryAdapter
---@field getCount fun(source: integer, item: string, metadata?: table): integer
---@field getItems fun(source: integer): table
---@field add fun(source: integer, item: string, count: integer, metadata?: table, reason: string): boolean
---@field remove fun(source: integer, item: string, count: integer, metadata?: table, reason: string): boolean
---@field canCarry fun(source: integer, item: string, count: integer, metadata?: table): boolean
---@field getItem fun(item: string): NoxenItem?
---@field registerStash? fun(id: string, label: string, slots: integer, weight: integer, coords?: vector3)
---@field openStash? fun(source: integer, id: string, label: string, slots: integer, weight: integer): boolean

---@class NoxenClientFrameworkAdapter
---@field isLoaded fun(): boolean
---@field getPlayerData fun(): NoxenPlayer?
---@field isPvpEnabled fun(): boolean
---@field notify fun(message: string, kind: NoxenNotifyType, duration: integer)
---@field registerEvents fun(emit: fun(event: string, ...))

---@class NoxenTargetOption
---@field label string
---@field icon? string
---@field distance? number
---@field job? string|string[]
---@field minGrade? integer
---@field canInteract? fun(entity: integer, distance: number): boolean
---@field onSelect fun(entity: integer)

---@class NoxenResolvedOption
---@field name string
---@field label string
---@field icon? string
---@field distance number
---@field canInteract fun(entity: integer, distance: number): boolean
---@field onSelect fun(entity: integer)

---@class NoxenBoxZone
---@field coords vector3
---@field size vector3
---@field rotation? number
---@field debug? boolean

---@class NoxenSphereZone
---@field coords vector3
---@field radius number
---@field debug? boolean

---@class NoxenTargetAdapter
---@field addBoxZone fun(id: string, zone: NoxenBoxZone, options: NoxenResolvedOption[]): any
---@field addSphereZone fun(id: string, zone: NoxenSphereZone, options: NoxenResolvedOption[]): any
---@field removeZone fun(handle: any)
---@field addEntity fun(entities: integer|integer[], options: NoxenResolvedOption[])
---@field removeEntity fun(entities: integer|integer[], options: NoxenResolvedOption[])
---@field addModel fun(models: string|string[]|integer|integer[], options: NoxenResolvedOption[])
---@field removeModel fun(models: string|string[]|integer|integer[], options: NoxenResolvedOption[])
---@field addGlobalVehicle fun(options: NoxenResolvedOption[])
---@field removeGlobalVehicle fun(options: NoxenResolvedOption[])
---@field addGlobalPed fun(options: NoxenResolvedOption[])
---@field removeGlobalPed fun(options: NoxenResolvedOption[])
