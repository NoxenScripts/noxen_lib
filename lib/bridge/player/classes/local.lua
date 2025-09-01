---@class noxen.lib.bridge.player.local
---@field private bridge noxen.lib.bridge
---@field public source number
---@field public localId number
---@overload fun(bridge: noxen.lib.bridge): noxen.lib.bridge.player.local
local player <const> = nox.class.new 'noxen.lib.bridge.player.local';

---@param bridge noxen.lib.bridge
---@param source number
function player:Constructor(bridge)
    assert(not nox.is_server, 'noxen.lib.bridge.player.local is not available on server.');
    self.bridge = bridge;
    self.localId = PlayerId();
    self.source = GetPlayerServerId(self.localId);
    self.data = {};
end

--- Get the player's unique identifier.
---
--- In most frameworks, this is the player's license identifier without the "license:" prefix.
---@return string
function player:GetIdentifier()
    return self.data['identifier'];
end

--- Get the player's FiveM name.
---@return string
function player:GetUserName()
    return GetPlayerName(self.source) or 'Unknown';
end

--- Get the player's primary job information.
---@return noxen.lib.bridge.player.job
function player:GetJob()
    return self.data['job'];
end

--- Get the player's secondary job information (e.g., gang).
---@return noxen.lib.bridge.player.job
function player:GetJob2()
    return self.data['job2'];
end

--- Get the amount of money in a specific account.
---@param accountName 'money' | 'bank' | 'black_money'
---@return number?
function player:GetAccountMoney(accountName)
    assert(type(accountName) == 'string', "player:GetAccountMoney() - accountName must be a string");

    return self.data[accountName];
end

--- Get the player's inventory.
---@return noxen.lib.bridge.wrapper.player.inventory.item[]
function player:GetInventory()
    return self.data['inventory'] or {};
end

--- Check if the player has the specified item.
---@param itemName string
---@param amount? number
---@return boolean
function player:HasItem(itemName, amount)
    assert(type(itemName) == 'string', "player:HasItem() - itemName must be a string");
    assert(amount == nil or type(amount) == 'number', "player:HasItem() - amount must be a number if provided");
    for i = 1, #self.data['inventory'] do
        if (self.data['inventory'][i].name == itemName) then
            return (type(amount) == 'number' and amount <= self.data['inventory'][i].amount) or self.data['inventory'][i] ~= nil;
        end
    end
end

--- Get details about a specific item in the player's inventory.
---@param itemName string
---@return noxen.lib.bridge.wrapper.player.inventory.item?
function player:GetItem(itemName)
    assert(type(itemName) == 'string', "player:GetItem() - itemName must be a string");
    for i = 1, #self.data['inventory'] do
        if (self.data['inventory'][i].name == itemName) then
            return self.data['inventory'][i];
        end
    end
end

--- Show a notification to the player.
---@param message string
---@param type? 'error' | 'info' | 'success'
---@param length? number
function player:ShowNotification(message, type, length)
    self.bridge.wrapper.client.notification.notify(self.bridge, message, type, length);
    return self;
end

--- Show a help notification to the player.
---@param message string
---@param thisFrame? boolean
---@param beep? boolean
---@param duration? number
function player:ShowHelpNotification(message, thisFrame, beep, duration)
    self.bridge.wrapper.client.notification.help(self.bridge, message, thisFrame, beep, duration);
    return self;
end

return player;
