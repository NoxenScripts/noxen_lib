local player <const> = require 'lib.bridge.player.classes.player';
local wrapper <const> = require 'lib.bridge.wrapper';

---@class noxen.lib.bridge
---@field public name 'esx' | 'qb' | 'custom'
---@field public resource_name string
---@field public framework noxen.lib.esx | noxen.lib.qb
---@field public version string
---@field public wrapper noxen.lib.bridge.wrapper
---@field public loaded boolean
---@overload fun(): noxen.lib.bridge
local bridge <const> = nox.class.new 'noxen.lib.bridge';

function bridge:Constructor()
    local success <const>, err <const> = pcall(bridge.Load, self);

    if (not success) then
        console.err(("Failed to load bridge: ^1%s^7"):format(err));
        StopResource(nox.current_resource);
        return;
    end

    self.loaded = true;

    if (self.name == 'qb') then
        local register <const> = nox.is_server and AddEventHandler or RegisterNetEvent;
        local name <const> = ('QBCore:%s:UpdateObject'):format(nox.is_server and 'Server' or 'Client');

        register(name, function(obj)
            self.framework = obj;
            console.debug('QBCore framework updated');
        end);
    end

    console.log(("Bridge loaded successfully with framework: ^3%s^7, version: ^3%s^7"):format(self.name, self.version));
end

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
        errors[#errors + 1] = ("ESX framework failed to load: %s"):format(esx_result);
    end

    if (not qb_success) then
        errors[#errors + 1] = ("QB-Core framework failed to load: %s"):format(qb_result);
    end

    if (not custom_success) then
        errors[#errors + 1] = ("Custom framework failed to load: %s"):format(custom_result);
    end

    assert(#errors < 3, ("Failed to load framework (ESX/QB/Custom). Please ensure it is properly configured.\n%s"):format(table.concat(errors, '\n')));
    assert(self.framework, "No valid framework found. Please ensure either ESX or QB-Core is installed.");
    assert(self.version, "Failed to retrieve version of the framework. Please ensure the resource is properly configured.");
end

---@param source number
---@return noxen.lib.bridge.player?
function bridge:GetPlayer(source)
    assert(type(source) == 'number', "bridge.GetPlayer() - source must be a number");
    local handle <const> = self.wrapper.getPlayer(self, source);
    return handle and player(self, source, handle);
end

return bridge();
