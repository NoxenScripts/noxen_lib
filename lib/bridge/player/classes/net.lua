---@class noxen.lib.bridge.player
---@field private bridge noxen.lib.bridge
---@field public source number
---@field private handle noxen.lib.bridge.esx.player | noxen.lib.bridge.qb.player
---@overload fun(bridge: noxen.lib.bridge, source: number, handle: noxen.lib.bridge.esx.player | noxen.lib.bridge.qb.player): noxen.lib.bridge.player
local player <const> = nox.class.new 'noxen.lib.bridge.player';

---@param bridge noxen.lib.bridge
---@param source number
---@param handle noxen.lib.bridge.esx.player | noxen.lib.bridge.qb.player
function player:Constructor(bridge, source, handle)
    assert(nox.is_server, 'noxen.lib.bridge.player is not available on client.');
    self.bridge = bridge;
    self.source = source;
    self.handle = handle;
end

---@private
---@param jobType 'job' | 'job2'
function player:getJobInternal(jobType)
    local data <const> = self.bridge.wrapper.player[jobType].get(self);
    local isQBGrade <const> = type(data.grade) == 'table';

    return data and {
        name = data.name,
        label = data.label,
        grade = {
            name = isQBGrade and data.grade.name or data.grade_name,
            level = isQBGrade and data.grade.level or data.grade,
            isboss = isQBGrade and data.grade.isboss or data.grade_name == 'boss',
            level = isQBGrade and data.grade.level or data.grade
        }
    } or nil;
end

--- Get the player's unique identifier.
---
--- In most frameworks, this is the player's license identifier without the "license:" prefix.
---@return string
function player:GetIdentifier()
    return self.bridge.wrapper.player.getIdentifier(self);
end

--- Trigger a client event for this player.
---@param eventName string
---@vararg any
function player:TriggerEvent(eventName, ...)
    nox.events.emit.net(eventName, self.source, ...);
    return self;
end

--- Trigger an event that will be received only by this resource for this player.
---@param eventName string
---@vararg any
function player:TriggerResourceEvent(eventName, ...)
    nox.events.emit.resource.net(eventName, self.source, ...);
    return self;
end

--- Get the player's FiveM name.
---@return string
function player:GetUserName()
    return GetPlayerName(self.source) or 'Unknown';
end

--- Get the player's group
---@return string?
function player:GetGroup()
    return self.bridge.wrapper.player.getGroup(self); --- TODO : Implement for QBCore/ESX/Custom
end

--- Check if the player is in the specified group
---@param groupName string
---@return boolean
function player:HasGroup(groupName)
    assert(type(groupName) == 'string', "player:hasGroup() - groupName must be a string");
    local playerGroup <const> = self:GetGroup();
    return playerGroup == groupName;
end

--- Get the player's primary job information.
---@return noxen.lib.bridge.player.job
function player:GetJob()
    return self:getJobInternal('job');
end

--- Get the player's secondary job information (e.g., gang).
---@return noxen.lib.bridge.player.job
function player:GetJob2()
    return self:getJobInternal('job2');
end

--- Internal method to set job information.
---@private
---@param jobType 'job' | 'job2'
---@param job string
---@param grade string|number
---@param onDuty? boolean
function player:SetJobInternal(jobType, job, grade, onDuty)
    assert(type(job) == 'string', "player:SetJobInternal() - job must be a string");
    assert(type(grade) == 'string' or type(grade) == 'number', "player:SetJobInternal() - grade must be a string or number");

    self.bridge.wrapper.player[jobType].set(self, job, grade, onDuty);
    return self;
end

--- Set the player's primary job.
---@param job string
---@param grade string|number
---@param onDuty? boolean
function player:SetJob(job, grade, onDuty)
    return self:SetJobInternal('job', job, grade, onDuty);
end

--- Set the player's secondary job (e.g., gang).
---@param job string
---@param grade string|number
---@param onDuty? boolean
function player:SetJob2(job, grade, onDuty)
    return self:SetJobInternal('job2', job, grade, onDuty);
end

--- Get the amount of money in a specific account.
---@param accountName 'money' | 'bank' | 'black_money'
---@return number?
function player:GetAccountMoney(accountName)
    assert(type(accountName) == 'string', "player:GetAccountMoney() - accountName must be a string");

    local account <const> = self.bridge.wrapper.accounts[accountName];
    assert(account, ("player:AddAccountMoney() - Invalid account name '%s'"):format(accountName));

    return self.bridge.wrapper.player.account.get(self, account.name);
end

--- Set the amount of money in a specific account.
---@param accountName 'money' | 'bank' | 'black_money'
---@param amount number
---@param reason? string
function player:SetAccountMoney(accountName, amount, reason)
    assert(type(accountName) == 'string', "player:SetAccountMoney() - accountName must be a string");
    assert(type(amount) == 'number', "player:SetAccountMoney() - amount must be a number");

    local account <const> = self.bridge.wrapper.accounts[accountName];
    assert(account, ("player:AddAccountMoney() - Invalid account name '%s'"):format(accountName));

    self.bridge.wrapper.player.account.set(self, account.name, amount, reason);
    return self;
end

--- Add money to a specific account.
---@param accountName 'money' | 'bank' | 'black_money'
---@param amount number
---@param reason? string
function player:AddAccountMoney(accountName, amount, reason)
    assert(type(accountName) == 'string', "player:AddAccountMoney() - accountName must be a string");
    assert(type(amount) == 'number', "player:AddAccountMoney() - amount must be a number");

    local account <const> = self.bridge.wrapper.accounts[accountName];
    assert(account, ("player:AddAccountMoney() - Invalid account name '%s'"):format(accountName));

    self.bridge.wrapper.player.account.add(self, account.name, amount, reason);
    return self;
end

--- Remove money from a specific account.
---@param accountName 'money' | 'bank' | 'black_money'
---@param amount number
---@param reason? string
function player:RemoveAccountMoney(accountName, amount, reason)
    assert(type(accountName) == 'string', "player:RemoveAccountMoney() - accountName must be a string");
    assert(type(amount) == 'number', "player:RemoveAccountMoney() - amount must be a number");

    local account <const> = self.bridge.wrapper.accounts[accountName];
    assert(account, ("player:AddAccountMoney() - Invalid account name '%s'"):format(accountName));

    self.bridge.wrapper.player.account.remove(self, account.name, amount, reason);
    return self;
end

--- Get the player's entire inventory.
---@return noxen.lib.bridge.wrapper.player.inventory.item[]
function player:GetInventory()
    local items <const> = self.bridge.wrapper.player.inventory.getItems(self);
    local table_type <const> = table.type(items);
    local result <const> = {};

    if (table_type == 'array') then
        for i = 1, #items do
            result[#result + 1] = items[i] and {
                name = items[i].name,
                label = items[i].label,
                weight = items[i].weight,
                amount = type(items[i].count) == 'number' and items[i].count or items[i].amount,
                usable = (type(items[i].usable) == 'boolean' and items[i].usable == true) or self.bridge:IsItemUsable(items[i].name)
            } or nil;
        end
    end

    if (table_type == 'hash' or table_type == 'mixed') then
        for _, item in pairs(items) do
            result[#result + 1] = item and {
                name = item.name,
                label = item.label,
                weight = item.weight,
                amount = type(item.count) == 'number' and item.count or item.amount,
                usable = (type(item.usable) == 'boolean' and item.usable == true) or self.bridge:IsItemUsable(item.name)
            } or nil;
        end
    end

    return result;
end

--- Check if the player has the specified item.
---@param itemName string
---@param amount? number
---@return boolean
function player:HasItem(itemName, amount)
    assert(type(itemName) == 'string', "player:HasItem() - itemName must be a string");
    return self.bridge.wrapper.player.inventory.has(self, itemName, amount);
end

--- Check if the player can carry the specified item and amount.
---@param itemName string
---@param amount? number
---@return boolean
function player:CanCarryItem(itemName, amount)
    assert(type(itemName) == 'string', "player:CanCarryItem() - itemName must be a string");
    assert(amount == nil or type(amount) == 'number', "player:CanCarryItem() - amount must be a number if provided");
    return self.bridge.wrapper.player.inventory.canCarryItem(self, itemName, amount);
end

--- Get details about a specific item in the player's inventory.
---@param itemName string
---@return noxen.lib.bridge.wrapper.player.inventory.item?
function player:GetItem(itemName)
    assert(type(itemName) == 'string', "player:GetItem() - itemName must be a string");
    local item <const> = self.bridge.wrapper.player.inventory.get(self, itemName);
    return item and {
        name = item.name,
        label = item.label,
        weight = item.weight,
        amount = type(item.count) == 'number' and item.count or item.amount,
        usable = (type(item.usable) == 'boolean' and item.usable == true) or self.bridge:IsItemUsable(item.name)
    } or nil;
end

--- Add an item to the player's inventory.
---@param itemName string
---@param amount? number
---@param reason? string
function player:AddItem(itemName, amount, reason)
    assert(type(itemName) == 'string', "player:AddItem() - itemName must be a string");
    assert(amount == nil or type(amount) == 'number', "player:AddItem() - amount must be a number if provided");

    self.bridge.wrapper.player.inventory.add(self, itemName, amount, reason);
    return self;
end

--- Remove an item from the player's inventory.
---@param itemName string
---@param amount? number
---@param reason? string
function player:RemoveItem(itemName, amount, reason)
    assert(type(itemName) == 'string', "player:RemoveItem() - itemName must be a string");
    assert(amount == nil or type(amount) == 'number', "player:RemoveItem() - amount must be a number if provided");

    self.bridge.wrapper.player.inventory.remove(self, itemName, amount, reason);
    return self;
end

--- Show a notification to the player.
---@param message string
---@param type? 'error' | 'info' | 'success'
---@param length? number
function player:ShowNotification(message, type, length)
    self.bridge.wrapper.player.notification.notify(self, message, type, length);
    return self;
end

return player;
