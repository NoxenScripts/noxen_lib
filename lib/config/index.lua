---@class noxen.lib.config @Config
---@field public class table
---@field public default table<string, Config>
nox.config = {};
nox.config.class = {};
nox.config.default = {};

nox.config.class.config = require 'lib.config.classes.Config';
nox.config.register = require 'lib.config.register';

Config = nox.config.register('Global');

return nox.config;
