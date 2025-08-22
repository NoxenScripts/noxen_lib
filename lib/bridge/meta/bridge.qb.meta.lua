---@meta QBBridge

---@class noxen.lib.bridge.qb.job
---@field public name string # Job internal name.
---@field public label string # Job display label.
---@field public grade noxen.lib.bridge.qb.job.grade # Current job grade information.

---@class noxen.lib.bridge.qb.job.grade
---@field public name string # Grade internal name.
---@field public level number # Grade level.
---@field public isboss boolean # Whether this grade is a boss grade.

---@class noxen.lib.bridge.qb.player.functions
---@field public SetJob fun(job: string, grade: string|number) # Set player's job and grade.
---@field public SetGang fun(gang: string, grade: string|number) # Set player's gang and grade.

---@class noxen.lib.bridge.qb.player.data
---@field public job noxen.lib.bridge.qb.job # Player's current job data.

---@class noxen.lib.bridge.qb.player
---@field public Functions noxen.lib.qb.player.functions # QB-Core functions for player management.
---@field public PlayerData noxen.lib.qb.player.data # Player data structure containing job, inventory, etc.

---@class noxen.lib.qb.functions
---@field public GetPlayer fun(source: number): noxen.lib.bridge.qb.player
---@field public GetIdentifier fun(source: number, identifier: identifier): string

---@class noxen.lib.qb
---@field public Functions noxen.lib.qb.functions
