local framework <const> = {
    resource_name = 'your-framework-resource-name',
    version = 'your-framework-version'
};

local getSharedObject <const> = function()
    if (framework.resource_name == 'your-framework-resource-name') then
        error('No custom framework setup. Please implement a custom framework using your own exports.');
    end

    --[[
    -- Custom object for custom framework. (e.g., exports['custom-framework']:getSharedObject() or direct object implemented using shared_script)
    -- return exports[framework.resource_name]:getSharedObject();
    -- return AwesomeFrameworkObject;
    --]]

    return {};
end

local methods <const> = {
    accounts = function()
        return {
            bank = {
                name = 'bank',
                label = 'Bank',
                type = 'account'
            },
            black_money = {
                name = 'black_money',
                label = 'Black Money',
                type = 'item'
            },
            money = {
                name = 'money',
                label = 'Cash',
                type = 'item'
            }
        };
    end,
    ---@param bridge noxen.lib.bridge
    ---@param source number
    ---@return noxen.lib.bridge.custom.player?
    getPlayer = function(bridge, source)
        return;
    end,
    ---@param bridge noxen.lib.bridge
    ---@param itemName string
    ---@return boolean
    isItemUsable = function(bridge, itemName)
        return false;
    end,
    player = {
        ---@param player noxen.lib.bridge.player
        ---@return string
        getIdentifier = function(player)
            return nil;
        end,
        job = {
            ---@param player noxen.lib.bridge.player
            ---@return noxen.lib.bridge.custom.job?
            get = function(player)
                return nil; -- Custom implementation needed
            end,
            ---@param player noxen.lib.bridge.player
            ---@param job string
            ---@param grade string|number
            ---@param onDuty? boolean
            set = function(player, job, grade, onDuty)
                return nil; -- Custom implementation needed
            end
        },
        job2 = {
            ---@param player noxen.lib.bridge.player
            ---@return noxen.lib.bridge.custom.job?
            get = function(player)
                return nil; -- Custom implementation needed
            end,
            ---@param player noxen.lib.bridge.player
            ---@param job string
            ---@param grade string|number
            ---@param onDuty? boolean
            set = function(player, job, grade, onDuty)
                return nil; -- Custom implementation needed
            end
        },
        notification = {
            ---@param player noxen.lib.bridge.player
            ---@param message string
            ---@param type? 'info' | 'success' | 'error'
            ---@param length? number
            notify = function(player, message, type, length)
                return nil; -- Custom implementation needed
            end
        },
        account = {
            ---@param player noxen.lib.bridge.player
            ---@param accountName string
            ---@return number?
            get = function(player, accountName)
                return nil; -- Custom implementation needed
            end,
            ---@param player noxen.lib.bridge.player
            ---@param accountName string
            ---@param amount number
            ---@param reason? string
            set = function(player, accountName, amount, reason)
                return nil; -- Custom implementation needed
            end,
            ---@param player noxen.lib.bridge.player
            ---@param accountName string
            ---@param amount number
            ---@param reason? string
            add = function(player, accountName, amount, reason)
                return nil; -- Custom implementation needed
            end,
            remove = function(player, accountName, amount, reason)
                return nil; -- Custom implementation needed
            end
        },
        inventory = {
            ---@param player noxen.lib.bridge.player
            getItems = function(player)
                return player.handle.getInventory();
            end,
            ---@param player noxen.lib.bridge.player
            ---@param itemName string
            ---@param amount? number
            ---@return boolean
            canCarryItem = function(player, itemName, amount)
                return false; -- Custom implementation needed
            end,
            ---@param player noxen.lib.bridge.player
            ---@param itemName string
            ---@param amount? number
            ---@return boolean
            has = function(player, itemName, amount)
                return false; -- Custom implementation needed
            end,
            ---@param player noxen.lib.bridge.player
            ---@param itemName string
            ---@return noxen.lib.bridge.qb.player.inventory.item
            get = function(player, itemName)
                return nil; -- Custom implementation needed
            end,
            ---@param player noxen.lib.bridge.player
            ---@param itemName string
            ---@param amount? number
            ---@param reason? string
            add = function(player, itemName, amount, reason)
                return nil; -- Custom implementation needed
            end,
            ---@param player noxen.lib.bridge.player
            ---@param itemName string
            ---@param amount? number
            ---@param reason? string
            remove = function(player, itemName, amount, reason)
                return nil; -- Custom implementation needed
            end
        end
    },
    client = {
        notification = {
            ---@param message string
            ---@param type? 'info' | 'success' | 'error'
            ---@param length? number
            notify = function(message, type, length)
                BeginTextCommandDisplayText('STRING');
                AddTextComponentSubstringPlayerName(message);
                EndTextCommandDisplayText(0.5, 0.5);
            end
        }
    }
};

return {
    methods = methods,
    framework = framework,
    getSharedObject = getSharedObject
};
