nox.entity = {};
nox.entity.classes = {};
nox.entity.players = {};

nox.entity.request_model = require 'lib.entity.request_model';
nox.entity.release_model = require 'lib.entity.release_model';
nox.entity.is_model_loaded = require 'lib.entity.is_model_loaded';
nox.entity.freeze_position = require 'lib.entity.freeze_position';
nox.entity.get_coords = require 'lib.entity.get_coords';
nox.entity.set_coords = require 'lib.entity.set_coords';
nox.entity.does_exist = require 'lib.entity.does_exist';

nox.entity.classes.entity = require 'lib.entity.classes.entity';
nox.entity.classes.ped = require 'lib.entity.classes.ped.ped';
nox.entity.classes.player_ped = require 'lib.entity.classes.ped.player_ped';
nox.entity.classes.net_player = require 'lib.entity.classes.player.net';
nox.entity.classes.local_player = require 'lib.entity.classes.player.local';

return nox.entity;
