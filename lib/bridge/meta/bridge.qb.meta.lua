---@meta QBBridge

---@class noxen.lib.bridge.qb.job
---@field public name string # Job internal name.
---@field public label string # Job display label.
---@field public grade noxen.lib.bridge.qb.job.grade # Current job grade information.

---@class noxen.lib.bridge.qb.job.grade
---@field public name string # Grade internal name.
---@field public level number # Grade level.
---@field public isboss boolean # Whether this grade is a boss grade.

---@class noxen.lib.bridge.qb.item
---@field name string # Item identifier (internal name).
---@field label string # Display name of the item.
---@field weight number # Weight of a single unit of the item.
---@field type string # Type of the item ('item', 'weapon', 'account', etc.).
---@field image string # Image filename for the item (located in `html/images/items/`).
---@field unique boolean # Whether the item is unique.
---@field useable boolean # Whether the item can be used.
---@field shouldClose boolean|nil # Whether the inventory should close after using the item (optional).
---@field description string # Description of the item.
---@field combinable table|nil # Information about item combinations (optional).

---@class noxen.lib.bridge.qb.item_weapon: noxen.lib.bridge.qb.item
---@field ammotype string|nil # Type of ammo used (e.g., "AMMO_PISTOL", nil if not applicable).

---@class noxen.lib.bridge.qb.player.inventory.item
---@field public name string # Item identifier (internal name).
---@field public label string # Display name of the item.
---@field public weight number # Weight of a single unit of the item.
---@field public amount number # Quantity of the item in the player's inventory.
---@field public type string # Type of the item ('item', 'weapon', 'account', etc.).
---@field public info table # Additional information about the item (e.g., weapon details).
---@field public slot number # Inventory slot number where the item is located.

---@class noxen.lib.bridge.qb.player.functions
---@field public SetJob fun(job: string, grade: string|number) # Set player's job and grade.
---@field public SetGang fun(gang: string, grade: string|number) # Set player's gang and grade.
---@field public Notify fun(message: string, messageType?: string, length?: number) # Send a notification to the player.
---@field public HasItem fun(item: string, amount?: number): boolean # Check if the player has a specific item and amount.
---@field public GetName fun(): string # Get the player's name (Character).
---@field public SetJobDuty fun(onDuty: boolean) # Set the player's job duty status.
---@field public SetPlayerData fun(key: string, value: any) # Set a specific key in the player's data.
---@field public SetMetaData fun(key: string, value: any) # Set a specific key in the player's metadata.
---@field public GetMetaData fun(key: string): any # Get a specific key from the player's metadata.
---@field public AddRep fun(type: string, amount: number) # Add reputation points of a specific type to the player.
---@field public RemoveRep fun(type: string, amount: number) # Remove reputation points of
---@field public GetRep fun(type: string): number # Get the current reputation points of a specific type for the player.
---@field public AddMoney fun(type: string, amount: number, reason?: string) # Add money of a specific type to the player.
---@field public RemoveMoney fun(type: string, amount: number, reason?: string) # Remove money of a specific type from the player.
---@field public SetMoney fun(type: string, amount: number) # Set the player's money of a specific type to an exact amount.
---@field public GetMoney fun(type: string): number # Get the player's current money amount of
---@field public Save fun() # Save the player's current data to the database.
---@field public Logout fun() # Log the player out of the server.
---@field public AddMethod fun(methodName: string, handler: fun()) # Add a custom method to the player object.
---@field public AddField fun(fieldName: string, data: any) # Add a custom field to the player object.

---@class noxen.lib.bridge.qb.player.data.charinfo
---@field public firstname string # Player's first name.
---@field public lastname string # Player's last name.
---@field public birthdate string # Player's date of birth.
---@field public gender 0|1 # Player's character gender
---@field public nationality string # Player's character nationality
---@field public phone string # Player's character phone number.
---@field public account string # Player's character account number.

---@class noxen.lib.bridge.qb.player.data
---@field public source number # Player's source ID.
---@field public license string # Player's license identifier.
---@field public name string # Player's name (FiveM).
---@field public money number # Player's cash amount.
---@field public cid number # Player's character ID.
---@field public citizenid string # Player's citizen ID.
---@field public optin boolean
---@field public charinfo noxen.lib.bridge.qb.player.data.charinfo # Character information such as first name, last name, date of birth, etc.
---@field public position {x: number, y: number, z: number, w:number} # Player's current position.
---@field public metadata table<string, any> # Additional metadata associated with the player.
---@field public charinfo table<string, any> # Character information such as first name, last name, date of birth, etc.
---@field public job noxen.lib.bridge.qb.job # Player's current job data.
---@field public gang noxen.lib.bridge.qb.job # Player's current gang data.
---@field public items table<number, noxen.lib.bridge.qb.player.inventory.item> # List of items in the player's inventory ordered by slot.

---@class noxen.lib.bridge.qb.player
---@field public Functions noxen.lib.bridge.qb.player.functions # QB-Core functions for player management.
---@field public PlayerData noxen.lib.bridge.qb.player.data # Player data structure containing job, inventory, etc.

---@class noxen.lib.bridge.qb.functions
---@field public GetPlayer fun(source: number): noxen.lib.bridge.qb.player
---@field public GetIdentifier fun(source: number, identifier?: identifier): string
---@field public CreateUseableItem fun(itemName: string, handler: fun(source: number, item: noxen.lib.bridge.qb.item | noxen.lib.bridge.qb.item_weapon)) # Register a usable item with a handler function.
---@field public CanUseItem fun(itemName: string): boolean # Check if an item is registered as usable.

---@class noxen.lib.qb
---@field public Functions noxen.lib.bridge.qb.functions
