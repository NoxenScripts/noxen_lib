---@class noxen.lib.bridge.player
---@field private bridge noxen.lib.bridge
---@field public source number
---@field private handle noxen.lib.bridge.esx.player | noxen.lib.bridge.qb.player
---@overload fun(bridge: noxen.lib.bridge, source: number): noxen.lib.bridge.player
local player <const> = nox.class.new 'noxen.lib.bridge.player';

---@param bridge noxen.lib.bridge
---@param source number
function player:Constructor(bridge, source, handle)
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
    TriggerClientEvent(eventName, self.source, ...);
    return self;
end

--- Get the player's FiveM name.
---@return string
function player:GetUserName()
    return GetPlayerName(self.source) or 'Unknown';
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

--- Show a notification to the player.
---@param message string
---@param type? 'error' | 'info' | 'success'
---@param length? number
function player:ShowNotification(message, type, length)
    self.bridge.wrapper.player.notification.notify(self, message, type, length);
    return self;
end

return player;
