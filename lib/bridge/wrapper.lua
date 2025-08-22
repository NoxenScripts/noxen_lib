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
        player = {
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
                        console.warn("Player handle does not support getJob2 method.");
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
                        console.warn("Player handle does not support setJob2 method.");
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
        ---@return noxen.lib.bridge.qb.player?
        getPlayer = function(bridge, source)
            return bridge.framework.Functions.GetPlayer(source);
        end,
        player = {
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
                        console.warn("Player handle does not support gang data.");
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
                        console.warn("Player handle does not support SetGang method.");
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
            }
        }
    }
};

return methods;
