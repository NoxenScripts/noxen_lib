local Radius <const> = require 'lib.game.classes.ZoneRadius';
local PLAYER_PED_ID <const> = PlayerPedId;
local GET_ENTITY_COORDS <const> = GetEntityCoords;
local zones <const> = {};

---@class Zone : EventEmitter
---@field public id string
---@field private resource string
---@field public active boolean
---@field public actions List
---@field public position vector3
---@field public size number
---@field public radius Map
---@field public markers Map
---@field public metadata Map
---@overload fun(): Zone
local Zone <const> = Class.extends('Zone', 'EventEmitter');

function Zone:Constructor()
    assert(not nox.is_server, 'Zone class is only available on client.');
    self:super();
    self.id = nox.uuid();
    self.resource = nox.current_resource;
    self.active = false;
    self.actions = List();
    self.position = nil;
    self.size = 0;
    self.radius = Map();
    self.markers = Map();
    self.metadata = Map();
    zones[self.id] = self;
    nox.events.emit(eLibEvents.zoneAdd, self);
end

---@param id string
---@return Zone
function Zone.Get(id)
    return zones[id];
end

---@return table<string, Zone>
function Zone.GetAll()
    return zones;
end

---@private
--- Should not be called directly.
function Zone:Start()
    assert(not nox.is_server, 'InternalZone class is only available on client.');
    async(function()
        while self.active do
            self.radius:forEach(function(_, radius)
                radius:Handle();
            end);
            self.actions:forEach(function(index, action)
                if (is_function(action)) then
                    action(self);
                end
            end);
            async.wait(0);
        end
    end);
end

---@private
--- Should not be called directly.
function Zone:Stop()
    assert(not nox.is_server, 'InternalZone class is only available on client.');
    self.active = false;
    self.radius:forEach(function(_, radius)
        radius.active = false;
    end);
end

---@param action fun(self: Zone)
function Zone:AddAction(action)
    assert(not nox.is_server, 'InternalZone class is only available on client.');
    self.actions:add(action);
    return self;
end

---@param position vector3
function Zone:SetPosition(position)
    assert(not nox.is_server, 'InternalZone class is only available on client.');
    self.position = position;
    nox.events.emit(eLibEvents.zoneUpdate, self.id, 'position', self.position);
    return self;
end

---@param size number
function Zone:SetSize(size)
    assert(not nox.is_server, 'InternalZone class is only available on client.');
    self.size = size;
    nox.events.emit(eLibEvents.zoneUpdate, self.id, 'size', self.size);
    return self;
end

---@param marker Marker | MarkerCircle
function Zone:AddMarker(marker)
    assert(not nox.is_server, 'InternalZone class is only available on client.');
    self.markers:set(marker.id, marker);
    marker.position = self.position;
    return marker;
end

---@param marker Marker | MarkerCircle
function Zone:RemoveMarker(marker)
    assert(not nox.is_server, 'InternalZone class is only available on client.');
    self.markers:remove(marker.id);
    return self;
end

---@return ZoneRadius
function Zone:AddRadius()
    assert(not nox.is_server, 'InternalZone class is only available on client.');
    local radius = Radius();
    self.radius:set(radius.id, radius);
    radius.position = self.position;
    return radius;
end

---@param radius ZoneRadius
function Zone:RemoveRadius(radius)
    assert(not nox.is_server, 'InternalZone class is only available on client.');
    self.radius:remove(radius.id);
    return self;
end

---@param callback fun(self: Zone)
function Zone:OnEnter(callback)
    assert(not nox.is_server, 'InternalZone class is only available on client.');
    self:on('enter', callback);
    return self;
end

---@param callback fun(self: Zone)
function Zone:OnExit(callback)
    assert(not nox.is_server, 'InternalZone class is only available on client.');
    self:on('exit', callback);
    return self;
end

function Zone:Remove()
    assert(not nox.is_server, 'InternalZone class is only available on client.');
    zones[self.id] = nil;
    self:Stop();
    nox.events.emit(eLibEvents.zoneRemove, self.id);
end

return Zone;

