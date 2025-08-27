---@class noxen.lib.events.net_event: noxen.lib.events.base_event
---@overload fun(): noxen.lib.events.net_event
local NetEvent <const> = Class.extends('noxen.lib.events.net_event', 'noxen.lib.events.base_event');

function NetEvent:Constructor()
	self:super();
	self.type = 'NetEvent';
end

function NetEvent:SetHandler()
	self.handler = RegisterNetEvent(self.name, function(...)
		self.callback(...);
	end);
	return self;
end

return NetEvent;

