---@meta NoxenBridge

---@alias identifier 'license' | 'steam' | 'xbl' | 'discord' | 'live' | 'fivem' | 'ip'

---@class noxen.lib.bridge.player.job.grade
---@field public name string # Grade name.
---@field public isboss boolean # Whether this grade is a boss grade.

---@class noxen.lib.bridge.player.job
---@field public name string # Job name.
---@field public label string # Job display label.
---@field public level number # Job level.
---@field public grade noxen.lib.bridge.player.job.grade # Job grade information.

---@class noxen.lib.bridge.wrapper.account
---@field public name string # Account name.
---@field public label string # Account display label.
---@field public type 'account' | 'item' # Account type, either 'account' or 'item'.

---@class noxen.lib.bridge.wrapper.player.inventory.item
---@field public name string # Item identifier (internal name).
---@field public label string # Display name of the item.
---@field public weight number # Weight of a single unit of the item.
---@field public amount number # Quantity of the item in the player's inventory.
---@field public usable boolean # Whether the item can be used.

---@class noxen.lib.bridge.wrapper.player.inventory
---@field public getItems fun(player: noxen.lib.bridge.player): noxen.lib.bridge.wrapper.player.inventory.item[] | table<number, noxen.lib.bridge.wrapper.player.inventory.item> # Get all items in the player's inventory.
---@field public get fun(player: noxen.lib.bridge.player, itemName: string): noxen.lib.bridge.wrapper.player.inventory.item? # Get item details by name.
---@field public canCarryItem fun(player: noxen.lib.bridge.player, itemName: string, amount?: number): boolean # Check if the player can carry a specific item and amount.
---@field public add fun(player: noxen.lib.bridge.player, itemName: string, amount?: number, reason?: string) # Add a specific item and amount to the player's inventory.
---@field public remove fun(player: noxen.lib.bridge.player, itemName: string, amount?: number, reason?: string) # Remove a specific item and amount from the player's inventory.
---@field public has fun(player: noxen.lib.bridge.player, itemName: string, amount?: number): boolean # Check if the player has a specific item and amount.

---@class noxen.lib.bridge.wrapper
---@field public client noxen.lib.bridge.wrapper.client # Client-specific methods for all frameworks.
---@field public player noxen.lib.bridge.wrapper.player # Player-specific methods for all frameworks.
---@field public accounts noxen.lib.bridge.wrapper.accounts # Shared accounts across frameworks.
---@field public getPlayer fun(bridge: noxen.lib.bridge, source: number): noxen.lib.bridge.player? # Function to get player object by source ID.
---@field public isItemUsable fun(bridge: noxen.lib.bridge, itemName: string): boolean # Function to check if an item is usable.
---@field public isPVPEnabled fun(bridge: noxen.lib.bridge): boolean # Function to check if PVP is enabled on the server.

---@class noxen.lib.bridge.wrapper.client.notification
---@field public notify fun(message: string, type?: 'info' | 'success' | 'error', length?: number): void # Function to send a notification to the client.
---@field public help fun(message: string, thisFrame?: boolean, beep?: boolean, duration?: number): void # Function to show a help notification to the client.

---@class noxen.lib.bridge.wrapper.client
---@field public notification noxen.lib.bridge.wrapper.client.notification # Client notification methods.

---@class noxen.lib.bridge.wrapper.player
---@field public getIdentifier fun(player: noxen.lib.bridge.player): string # Function to get the player's unique identifier.
---@field public hasPermission fun(player: noxen.lib.bridge.player, permission: string): boolean # Function to check if the player has a specific permission.
---@field public job noxen.lib.bridge.wrapper.player.job
---@field public job2 noxen.lib.bridge.wrapper.player.job
---@field public notification noxen.lib.bridge.wrapper.player.notification
---@field public account noxen.lib.bridge.wrapper.player.account
---@field public inventory noxen.lib.bridge.wrapper.player.inventory

---@class noxen.lib.bridge.wrapper.player.job
---@field public get fun(player: noxen.lib.bridge.player): noxen.lib.bridge.player.job? # Function to get job information.
---@field public set fun(player: noxen.lib.bridge.player, job: string, grade: string|number, onDuty?: boolean): noxen.lib.bridge.player.job? # Function to set job information.

---@class noxen.lib.bridge.wrapper.player.notification
---@field public notify fun(player: noxen.lib.bridge.player, message: string, type?: 'info' | 'success' | 'error', length?: number): void # Function to send a notification to the player.

---@class noxen.lib.bridge.wrapper.accounts
---@field public money noxen.lib.bridge.wrapper.account # Money account.
---@field public bank noxen.lib.bridge.wrapper.account # Bank account.
---@field public black_money noxen.lib.bridge.wrapper.account # Black money account.

---@class noxen.lib.bridge.wrapper.player.account
---@field public get fun(player: noxen.lib.bridge.player, accountName: string): number? # Function to get account balance.
---@field public set fun(player: noxen.lib.bridge.player, accountName: string, amount: number, reason?: string): void # Function to set account balance.
---@field public add fun(player: noxen.lib.bridge.player, accountName: string, amount: number, reason?: string): void # Function to add money to an account.
---@field public remove fun(player: noxen.lib.bridge.player, accountName: string, amount: number, reason?: string): void # Function to remove money from an account.
