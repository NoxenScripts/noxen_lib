---@enum eLibEvents
eLibEvents = {
    emitCallback = 'noxen.events.callback.emit',
    receiveCallback = 'noxen.events.callback.receive',
    sendNotification = 'noxen.game.notification.send',
    zoneAdd = 'noxen.game.zone.add',
    zoneUpdate = 'noxen.game.zone.update',
    zoneStateChange = 'noxen.game.zone.stateChange',
    zoneRemove = 'noxen.game.zone.remove',
    commandRegistered = 'noxen.lib.command.registered',
    setPlayerData = 'bridge:player:setPlayerData',
    playerLoaded = 'bridge:player:playerLoaded',
    resourceRefreshed = 'noxen_lib:bridge:resource:refreshed',
};

return eLibEvents;
