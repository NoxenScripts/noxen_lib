nox.game = {};
nox.game.classes = {};

nox.game.hash = require 'lib.game.hash';
nox.game.input = require 'lib.game.input';
nox.game.notification = require 'lib.game.notification';
nox.game.crash = require 'lib.game.crash';
nox.game.loaded = require 'lib.game.loaded';
nox.game.text = require 'lib.game.text';
nox.game.classes.zone = require 'lib.game.classes.Zone';
nox.game.classes.marker = require 'lib.game.classes.Marker';
nox.game.classes.marker_circle = require 'lib.game.classes.MarkerCircle';

return nox.game;
