local methods <const> = {
    esx = {
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
        ---@return noxen.lib.bridge.esx.player?
        getPlayer = function(bridge, source)
            return bridge.framework.GetPlayerFromId(source);
        end,
        ---@param bridge noxen.lib.bridge
        ---@param itemName string
        ---@return boolean
        isItemUsable = function(bridge, itemName)
            local usableItems <const> = bridge.framework.GetUsableItems();
            return usableItems[itemName] == true;
        end,
        ---@param bridge noxen.lib.bridge
        ---@return boolean
        isPVPEnabled = function(bridge)
            local config <const> = bridge.framework.GetConfig();
            return (config and config.EnablePVP == true) or false;
        end,
        player = {
            ---@param player noxen.lib.bridge.player
            ---@return string
            getIdentifier = function(player)
                return player.handle.license;
            end,
            ---@param player noxen.lib.bridge.player
            ---@param permission string (e.g "admin")
            ---@return string?
            hasPermission = function(player, permission)
                return player.handle.getGroup() == permission;
            end,
            job = {
                ---@param player noxen.lib.bridge.player
                ---@return noxen.lib.bridge.esx.job
                get = function(player)
                    return player.handle.getJob();
                end,
                ---@param player noxen.lib.bridge.player
                ---@param job string
                ---@param grade string|number
                ---@param onDuty? boolean
                set = function(player, job, grade, onDuty)
                    return player.handle.setJob(job, grade);
                end
            },
            job2 = {
                ---@param player noxen.lib.bridge.player
                ---@return noxen.lib.bridge.esx.job?
                get = function(player)
                    if (not player.handle.getJob2) then
                        console.debug("Player handle does not support getJob2 method.");
                        return nil;
                    end

                    return player.handle.getJob2();
                end,
                ---@param player noxen.lib.bridge.player
                ---@param job string
                ---@param grade string|number
                ---@param onDuty? boolean
                set = function(player, job, grade, onDuty)
                    if (not player.handle.setJob2) then
                        console.debug("Player handle does not support setJob2 method.");
                        return;
                    end

                    return player.handle.setJob2(job, grade, onDuty);
                end
            },
            notification = {
                ---@param player noxen.lib.bridge.player
                ---@param message string
                ---@param type? 'info' | 'success' | 'error'
                ---@param length? number
                notify = function(player, message, type, length)
                    return player.handle.showNotification(message, type, length);
                end,
            },
            account = {
                ---@param player noxen.lib.bridge.player
                ---@param accountName string
                ---@return number?
                get = function(player, accountName)
                    local account <const> = player.handle.getAccount(accountName);
                    return type(account) == 'table' and account.money or nil;
                end,
                ---@param player noxen.lib.bridge.player
                ---@param accountName string
                ---@param amount number
                ---@param reason? string
                set = function(player, accountName, amount, reason)
                    return player.handle.setAccountMoney(accountName, amount, reason);
                end,
                ---@param player noxen.lib.bridge.player
                ---@param accountName string
                ---@param amount number
                ---@param reason? string
                add = function(player, accountName, amount, reason)
                    return player.handle.addAccountMoney(accountName, amount, reason);
                end,
                ---@param player noxen.lib.bridge.player
                ---@param accountName string
                ---@param amount number
                ---@param reason? string
                remove = function(player, accountName, amount, reason)
                    return player.handle.removeAccountMoney(accountName, amount, reason);
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
                    return player.handle.canCarryItem(itemName, amount);
                end,
                ---@param player noxen.lib.bridge.player
                ---@param itemName string
                ---@param amount? number
                ---@return boolean
                has = function(player, itemName, amount)
                    return player.handle.hasItem(itemName, amount);
                end,
                ---@param player noxen.lib.bridge.player
                ---@param itemName string
                ---@return noxen.lib.bridge.esx.item
                get = function(player, itemName)
                    return player.handle.getInventoryItem(itemName);
                end,
                ---@param player noxen.lib.bridge.player
                ---@param itemName string
                ---@param amount? number
                ---@param reason? string
                add = function(player, itemName, amount, reason)
                    return player.handle.addInventoryItem(itemName, amount, reason);
                end,
                ---@param player noxen.lib.bridge.player
                ---@param itemName string
                ---@param amount? number
                ---@param reason? string
                remove = function(player, itemName, amount, reason)
                    return player.handle.removeInventoryItem(itemName, amount, reason);
                end
            }
        },
        client = {
            notification = {
                ---@param bridge noxen.lib.bridge
                ---@param message string
                ---@param type? 'info' | 'success' | 'error'
                ---@param length? number
                notify = function(bridge, message, type, length)
                    bridge.framework.ShowNotification(message, type, length);
                end,
                ---@param bridge noxen.lib.bridge
                ---@param message string
                ---@param thisFrame boolean
                ---@param beep boolean
                ---@param duration number
                help = function(bridge, message, thisFrame, beep, duration)
                    bridge.framework.ShowHelpNotification(message, thisFrame, beep, duration);
                end
            }
        }
    },
    qb = {
        accounts = function()
            return {
                bank = {
                    name = 'bank',
                    label = 'Bank',
                    type = 'account'
                },
                black_money = {
                    name = 'crypto',
                    label = 'Crypto',
                    type = 'item'
                },
                money = {
                    name = 'cash',
                    label = 'Cash',
                    type = 'item'
                }
            };
        end,
        ---@param bridge noxen.lib.bridge
        ---@param source number
        ---@return noxen.lib.bridge.qb.player?
        getPlayer = function(bridge, source)
            return bridge.framework.Functions.GetPlayer(source);
        end,
        ---@param bridge noxen.lib.bridge
        ---@param itemName string
        ---@return boolean
        isItemUsable = function(bridge, itemName)
            return bridge.framework.Functions.CanUseItem(itemName) ~= nil;
        end,
        ---@param bridge noxen.lib.bridge
        ---@return boolean
        isPVPEnabled = function(bridge)
            local config <const> = bridge.framework.Config;
            return (config and config.Server and config.Server.PVP == true) or false;
        end,
        player = {
            ---@param player noxen.lib.bridge.player
            ---@return string
            getIdentifier = function(player)
                return player.handle.PlayerData.license;
            end,
            ---@param player noxen.lib.bridge.player
            ---@param permission string (e.g "admin")
            ---@return string?
            hasPermission = function(player, permission)
                --return player.bridge.framework.Functions.HasPermission(player.source, permission);
                return IsPlayerAceAllowed(player.source, permission);
            end,
            job = {
                ---@param player noxen.lib.bridge.player
                ---@return noxen.lib.bridge.qb.job
                get = function (player)
                    return player.handle.PlayerData.job;
                end,
                ---@param player noxen.lib.bridge.player
                ---@param job string
                ---@param grade string|number
                ---@param onDuty? boolean
                set = function(player, job, grade, onDuty)
                    return player.handle.Functions.SetJob(job, grade, onDuty);
                end
            },
            job2 = {
                ---@param player noxen.lib.bridge.player
                ---@return noxen.lib.bridge.qb.job?
                get = function(player)
                    if (not player.handle.PlayerData.gang) then
                        console.debug("Player handle does not support gang data.");
                        return nil;
                    end

                    return player.handle.PlayerData.gang;
                end,
                ---@param player noxen.lib.bridge.player
                ---@param job string
                ---@param grade string|number
                ---@param onDuty? boolean
                set = function(player, job, grade, onDuty)
                    if (not player.handle.Functions.SetGang) then
                        console.debug("Player handle does not support SetGang method.");
                        return;
                    end

                    return player.handle.Functions.SetGang(job, grade, onDuty);
                end
            },
            notification = {
                ---@param player noxen.lib.bridge.player
                ---@param message string
                ---@param type? 'info' | 'success' | 'error'
                ---@param length? number
                notify = function(player, message, type, length)
                    return player.handle.Functions.Notify(message, type, length);
                end
            },
            account = {
                ---@param player noxen.lib.bridge.player
                ---@param accountName string
                ---@return number?
                get = function(player, accountName)
                    local account <const> = player.handle.PlayerData.money[accountName];
                    return type(account) == 'number' and account or nil;
                end,
                ---@param player noxen.lib.bridge.player
                ---@param accountName string
                ---@param amount number
                ---@param reason? string
                set = function(player, accountName, amount, reason)
                    return player.handle.Functions.SetMoney(accountName, amount, reason);
                end,
                ---@param player noxen.lib.bridge.player
                ---@param accountName string
                ---@param amount number
                ---@param reason? string
                add = function(player, accountName, amount, reason)
                    return player.handle.Functions.AddMoney(accountName, amount, reason);
                end,
                remove = function(player, accountName, amount, reason)
                    return player.handle.Functions.RemoveMoney(accountName, amount, reason);
                end
            },
            inventory = {
                ---@param player noxen.lib.bridge.player
                getItems = function(player)
                    return player.handle.PlayerData.items;
                end,
                ---@param player noxen.lib.bridge.player
                ---@param itemName string
                ---@param amount? number
                ---@return boolean
                canCarryItem = function(player, itemName, amount)
                    assert(GetResourceState('qb-inventory') == 'started', "QB-Inventory resource is not started.");
                    return exports['qb-inventory']:CanAddItem(player.source, itemName, amount);
                end,
                ---@param player noxen.lib.bridge.player
                ---@param itemName string
                ---@param amount? number
                ---@return boolean
                has = function(player, itemName, amount)
                    assert(GetResourceState('qb-inventory') == 'started', "QB-Inventory resource is not started.");
                    return exports['qb-inventory']:HasItem(player.source, itemName, amount);
                end,
                ---@param player noxen.lib.bridge.player
                ---@param itemName string
                ---@return noxen.lib.bridge.qb.player.inventory.item
                get = function(player, itemName)
                    assert(GetResourceState('qb-inventory') == 'started', "QB-Inventory resource is not started.");
                    return exports['qb-inventory']:GetItemByName(player.source, itemName);
                end,
                ---@param player noxen.lib.bridge.player
                ---@param itemName string
                ---@param amount? number
                ---@param reason? string
                add = function(player, itemName, amount, reason)
                    assert(GetResourceState('qb-inventory') == 'started', "QB-Inventory resource is not started.");
                    return exports['qb-inventory']:AddItem(player.source, itemName, amount, nil, nil, reason);
                end,
                ---@param player noxen.lib.bridge.player
                ---@param itemName string
                ---@param amount? number
                ---@param reason? string
                remove = function(player, itemName, amount, reason)
                    assert(GetResourceState('qb-inventory') == 'started', "QB-Inventory resource is not started.");
                    return exports['qb-inventory']:RemoveItem(player.source, itemName, amount, nil, reason);
                end
            }
        },
        client = {
            notification = {
                ---@param bridge noxen.lib.bridge
                ---@param message string
                ---@param type? 'info' | 'success' | 'error'
                ---@param length? number
                notify = function(bridge, message, type, length)
                    bridge.framework.Functions.Notify(message, type, length);
                end,
                ---@param bridge noxen.lib.bridge
                ---@param message string
                ---@param thisFrame boolean
                ---@param beep boolean
                ---@param duration number
                help = function(bridge, message, thisFrame, beep, duration)
                    ---[[
                    --- @credit ESX Framework (https://github.com/esx-framework/esx_core/blob/main/%5Bcore%5D/es_extended/client/functions.lua#L196)
                    ---]]

                    local entry <const> = "noxen..notify.help";

                    AddTextEntry(entry, message);
                    if (thisFrame) then
                        DisplayHelpTextThisFrame(entry, false);
                        return;
                    end
                    BeginTextCommandDisplayHelp(entry);
                    EndTextCommandDisplayHelp(0, false, beep == nil or beep, duration or -1);
                end
            }
        }
    }
};

return methods;
