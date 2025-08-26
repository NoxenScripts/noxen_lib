local player <const> = require 'lib.bridge.player.classes.net';
local wrapper <const> = require 'lib.bridge.wrapper';

local getPlayers <const> = GetPlayers;

--- <h3>Both(Client/Server) Authority</h3>
---@class noxen.lib.bridge
---@field public name 'esx' | 'qb' | 'custom'
---@field public resource_name string
---@field public framework noxen.lib.esx | noxen.lib.qb
---@field public version string
---@field public wrapper noxen.lib.bridge.wrapper
---@field public loaded boolean
---@field public playersIdentifier table<string, number> Maps player identifiers to their source IDs
---@field public player noxen.lib.bridge.player.local
---@overload fun(): noxen.lib.bridge
local bridge <const> = nox.class.new 'noxen.lib.bridge';

function bridge:Constructor()
    local success <const>, err <const> = pcall(bridge.Load, self);

    if (not success) then
        console.err(("Failed to load bridge: %s^7"):format(err));
        if (nox.is_server) then
            StopResource(nox.current_resource);
        end
        return;
    end

    self.playersIdentifier = {};
    self.loaded = true;

    local class <const> = not nox.is_server and require('lib.bridge.player.classes.local') or nil;

    self.player = class and class(self);

    console.log(("Bridge loaded successfully with framework: ^3%s^7, version: ^3%s^7"):format(self.name, self.version));
end

--- <h3>Both(Client/Server) Authority</h3>
---@private
---@param name string
---@param resourceName string
---@param version string
---@param framework table
function bridge:LoadVariables(name, resourceName, version, framework)
    assert(not self.loaded, "bridge.SetVariables() - Bridge is already loaded");
    assert(type(name) == 'string', "bridge.SetVariables() - name must be a string");
    assert(type(resourceName) == 'string', "bridge.SetVariables() - resourceName must be a string");
    assert(type(version) == 'string', "bridge.SetVariables() - version must be a string");
    assert(type(framework) == 'table', "bridge.SetVariables() - framework must be a table");
    assert(type(wrapper) == 'table', "bridge.SetVariables() - wrapper must be a table");
    assert(type(wrapper[name].accounts) == 'function', "bridge.SetVariables() - accounts must be a function");
    assert(wrapper[name].player, "bridge.SetVariables() - wrapper must contain player methods");

    self.name = name;
    self.resource_name = resourceName;
    self.version = version;
    self.framework = framework;
    self.wrapper = table.clone(wrapper[name]);
    self.wrapper.accounts = wrapper[name].accounts();

    assert(self.wrapper.accounts.bank, "bridge.SetVariables() - accounts must contain 'bank' account");
    assert(self.wrapper.accounts.black_money, "bridge.SetVariables() - accounts must contain 'black_money' account");
    assert(self.wrapper.accounts.money, "bridge.SetVariables() - accounts must contain 'cash' account");

    return self;
end

--- <h3>Both(Client/Server) Authority</h3>
function bridge:IsLoaded()
    return self.loaded == true;
end

--- <h3>Both(Client/Server) Authority</h3>
--- Waits until the bridge is fully loaded
---@async
function bridge:Await()
    if (self:IsLoaded()) then
        return;
    end

    local promise <const> = promise.new();

    async(function()
        while (not self:IsLoaded()) do
            async.wait();
        end
        promise:resolve();
    end);
    Citizen.Await(promise);
end

--- <h3>Both(Client/Server) Authority</h3>
---@param framework 'esx' | 'qb' | 'custom'
---@param name string
---@param handler fun(...: any)
---@return EventHandlerData
function bridge:AddEventHandler(framework, name, handler)
    assert(type(name) == 'string', "bridge.AddEventHandler() - name must be a string");
    assert(type(handler) == 'function', "bridge.AddEventHandler() - handler must be a function");

    return AddEventHandler(name, function(...)
        if (self.name ~= framework) then
            console.warn(("bridge.AddEventHandler() - Attempt to trigger %s event on %s framework"):format(name, self.name));
            return;
        end
        handler(...);
    end);
end

--- <h3>Both(Client/Server) Authority</h3>
---@param framework 'esx' | 'qb' | 'custom'
---@param name string
---@param handler fun(...: any)
---@return EventHandlerData?
function bridge:RegisterNetEvent(framework, name, handler)
    assert(type(name) == 'string', "bridge.RegisterNetEvent() - name must be a string");
    assert(type(handler) == 'function', "bridge.RegisterNetEvent() - handler must be a function");

    return RegisterNetEvent(name, function(...)
        if (self.name ~= framework) then
            console.warn(("bridge.RegisterNetEvent() - Attempt to trigger %s event on %s framework"):format(name, self.name));
            return;
        end
        handler(...);
    end);
end

--- <h3>Both(Client/Server) Authority</h3>
---@private
function bridge:Load()
    assert(not self.loaded, "bridge.Load() - Bridge is already loaded");

    local esx_success <const>, esx_result <const> = pcall(function()
        local object <const> = exports['es_extended']:getSharedObject();
        local version <const> = GetResourceMetadata('es_extended', 'version', 0);

        self:LoadVariables(
            'esx',
            'es_extended',
            version,
            object
        );
    end);

    local qb_success <const>, qb_result <const> = pcall(function()
        local object <const> = exports['qb-core']:GetCoreObject();
        local version <const> = GetResourceMetadata('qb-core', 'version', 0);

        self:LoadVariables(
            'qb',
            'qb-core',
            version,
            object
        );
    end);

    local custom_success <const>, custom_result <const> = pcall(function()
        local wrapper_custom <const> = require 'lib.patches.bridge.wrapper';
        local object <const> = wrapper_custom.getSharedObject();
        local framework <const> = wrapper_custom.framework;
        assert(type(framework) == 'table', "Custom framework must provide valid framework settings");

        local version = GetResourceMetadata(framework.resource_name, 'version', 0);

        if (not version) then
            assert(framework.version, "Custom framework must provide a version");
            version = framework.version;
        end

        wrapper.custom = wrapper_custom.methods;

        self:LoadVariables(
            'custom',
            framework.resource_name,
            version,
            object
        );
    end);

    local errors <const> = {};

    if (not esx_success) then
        errors[#errors + 1] = ("^1ESX framework failed to load: ^7%s^7"):format(esx_result);
    end

    if (not qb_success) then
        errors[#errors + 1] = ("^1QB-Core framework failed to load: ^7%s^7"):format(qb_result);
    end

    if (not custom_success) then
        errors[#errors + 1] = ("^1Custom framework failed to load: ^7%s^7"):format(custom_result);
    end

    assert(#errors < 3, ("Failed to load framework (ESX/QB/Custom). Please ensure it is properly configured.\n%s"):format(table.concat(errors, '\n')));
    assert(self.framework, "No valid framework found. Please ensure either ESX or QB-Core is installed.");
    assert(self.version, "Failed to retrieve version of the framework. Please ensure the resource is properly configured.");
end

--- <h3>Server Authority</h3>
---@return (noxen.lib.bridge.player|nil)[]
function bridge:GetPlayers()
    assert(nox.is_server, 'noxen.lib.bridge.GetPlayers is not available on client.');
    local sources <const> = getPlayers();

    return setmetatable({}, {
        __index = function(_, i)
            local source <const> = tonumber(sources[i]);

            if (not source) then
                return nil;
            end

            local handle <const> = self.wrapper.getPlayer(self, source);

            return handle and player(self, source, handle) or nil;
        end,
        __len = function() return #sources; end,
        __pairs = function()
            local i = 0;
            return function()
                i += 1;

                local source <const> = tonumber(sources[i]);

                if (not source) then
                    return nil;
                end

                local handle <const> = self.wrapper.getPlayer(self, source);

                return i, handle and player(self, source, handle) or nil;
            end
        end
    });
end

--- <h3>Server Authority</h3>
--- Get a player object by their source ID.
---@param source number
---@return noxen.lib.bridge.player?
function bridge:GetPlayer(source)
    assert(nox.is_server, 'noxen.lib.bridge.GetPlayer is not available on client.');
    assert(type(source) == 'number' or type(source) == 'string', "bridge.GetPlayer() - source must be a number");
    local src <const> = tonumber(source);
    local handle <const> = self.wrapper.getPlayer(self, src);
    return handle and player(self, src, handle) or nil;
end

--- <h3>Server Authority</h3>
---@param identifier string
---@return noxen.lib.bridge.player?
function bridge:GetPlayerByIdentifier(identifier)
    assert(nox.is_server, 'noxen.lib.bridge.GetPlayerByIdentifier is not available on client.');
    assert(type(identifier) == 'string', "bridge.GetPlayerByIdentifier() - identifier must be a string");
    local source <const> = self.playersIdentifier[identifier];
    return source and self:GetPlayer(source) or nil;
end

--- <h3>Server Authority</h3>
--- Check if an item is registered as usable.
---@param itemName string
---@return boolean
function bridge:IsItemUsable(itemName)
    assert(nox.is_server, 'noxen.lib.bridge.IsItemUsable is not available on client.');
    assert(type(itemName) == 'string', "bridge.IsItemUsable() - itemName must be a string");

    return self.wrapper.isItemUsable(self, itemName);
end

return bridge();
