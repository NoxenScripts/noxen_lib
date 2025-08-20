---@class noxen.lib.config @Config
---@field public class table
---@field public default table<string, Config>
nox.config = {};
nox.config.class = {};
nox.config.default = {};

nox.config.class.config = require 'lib.config.classes.Config';

nox.config.register = require 'lib.config.register';
nox.config.register_sub = require 'lib.config.register_sub';
nox.config.get_valid = require 'lib.config.get_valid';
nox.config.get = nox.config.get_valid;
nox.config.get_valid_sub = require 'lib.config.get_valid_sub';
nox.config.get_sub = nox.config.get_valid_sub;

return nox.config;
