nox = {};
_lib = nox; -- For compatibility with old code
nox.cache = {};
nox.classes = {};
nox.is_server = IsDuplicityVersion();
nox.name = 'noxen_lib';
nox.current_resource = GetCurrentResourceName();
nox.debug = GetConvar('noxen_lib_debug', "false") == "true";

if (nox.current_resource ~= nox.name) then
    local state <const> = GetResourceState(nox.name);

    if (not state:find('start')) then
        print('^7(^6lib^7)^0 => ^1Unable to import noxen_lib! Please start noxen_lib before using it.^0');
        if (nox.is_server) then
            StopResource(nox.current_resource);
        end
    end
end

local current_resource = nox.name;

local modules <const> = {};
local _require <const> = require;
local _path <const> = './?.lua;';

---@return string
function nox.get_required_resource()
    return current_resource;
end

---@param resource? string
function nox.set_required_resource(resource)
    current_resource = type(resource) == 'string' and resource or nox.current_resource;
end

---@param modname string
---@return any
function require(modname)
    if type(modname) ~= 'string' then return; end

    local mod_id <const> = ('%s.%s'):format(current_resource, modname);
    local module = modules[mod_id];

    if (not module) then
        if (module == false) then
            error(("^1circular-dependency occurred when loading module '%s'^0"):format(modname), 0);
        end

        local success <const>, result <const> = pcall(_require, modname);

        if (success) then
            modules[mod_id] = result;
            return result;
        end

        local modpath <const> = modname:gsub('%.', '/');

        for path in _path:gmatch('[^;]+') do
            local script = path:gsub('?', modpath):gsub('%.+%/+', '');
            local resourceFile <const> = LoadResourceFile(current_resource, script);

            if (type(resourceFile) == 'string') then
                modules[mod_id] = false;
                script = ('@@%s/%s'):format(current_resource, script)

                local chunk <const>, err <const> = load(resourceFile, script)

                if (err or not chunk) then
                    modules[mod_id] = nil;
                    return error(err or ("Unable to load module '%s'"):format(modname), 0);
                end

                if (type(console) == 'table' and type(console.debug) == 'function') then
                    if (nox.current_resource == current_resource) then
                        console.debug(('Loaded module ^7\'^2%s^7\'^0'):format(modname));
                    else
                        console.debug(('Loaded module ^7\'^2%s^7\'^0 from ^7\'^3%s^7\'^0'):format(modname, current_resource));
                    end
                end

                module = chunk(modname) or true;
                modules[mod_id] = module;

                return module;
            end
        end
        return error(("module ^7\'^3%s^7\'^1 not found^0"):format(modname), 0);
    end
    return module;
end

nox.enums = require 'enums.index';

nox.console = require 'system.console';
nox.class = require 'system.class';

nox.math = require 'system.modules.math';
nox.string = require 'system.modules.string';
nox.table = require 'system.modules.table';
nox.async = require 'system.modules.async';
nox.uuid = require 'system.modules.uuid';
nox.error_handler = require 'system.modules.error_handler';

nox.classes.locale = require 'system.modules.locale';
nox.classes.events = require 'system.modules.classes.EventEmitter';
nox.classes.list = require 'system.modules.classes.List';
nox.classes.map = require 'system.modules.classes.Map';
nox.classes.color = require 'system.modules.classes.Color';

require 'lib.index';
