local registeredCommands = {};
local commandsIndexes <const> = {};

nox.events.on(eLibEvents.commandRegistered, function(_, commandName, handler, help, arguments)
    assert(type(commandName) == 'string', 'commandName must be a string');
    assert(is_function(handler), 'handler must be a function');
    assert(type(help) == 'string' or help == nil, 'help must be a string or nil');
    assert(type(arguments) == 'table' or arguments == nil, 'arguments must be a table or nil');

    local invoking <const> = GetInvokingResource();

    assert(type(invoking) == 'string', 'GetInvokingResource did not return a string');
    assert(invoking ~= '', 'GetInvokingResource returned nothing, this event must be called from a resource');

    if (registeredCommands[commandName]) then
        console.warn(('[noxen_lib] Command %q is already registered, overwriting...'):format(commandName));
    end

    commandsIndexes[#commandsIndexes + 1] = {
        rawName = commandName,
        name = ('/%s'):format(commandName),
        help = help or '',
        params = arguments or {},
        resource = invoking
    };
    registeredCommands[commandName] = #commandsIndexes;

    nox.events.emit.broadcast('chat:addSuggestion', '/' .. commandName, help or '', arguments or {});
    console.debug(('Command ^3%q^7 registered by resource ^3%q^7'):format(commandName, invoking));
end);

nox.events.on('onResourceStop', function(_, resourceName)
    for i = #commandsIndexes, 1, -1 do
        if (commandsIndexes[i].resource == resourceName) then
            nox.events.emit.broadcast('chat:removeSuggestion', commandsIndexes[i].name);
            table.remove(commandsIndexes, i);
        end
    end

    registeredCommands = {};

    for i = 1, #commandsIndexes do
        registeredCommands[commandsIndexes[i].rawName] = i;
    end

    console.debug(("Resource ^3%s^7 stopped, chat suggestions cleaned up"):format(resourceName));
end);

nox.events.on.resource(eLibEvents.playerLoaded, function(_, source)
    nox.events.emit.net('chat:addSuggestions', source, commandsIndexes);
    console.debug(("Player ^3%s^7 loaded, chat suggestions synced"):format(source));
end);

nox.events.on(eLibEvents.resourceRefreshed, function(_)
    local resource <const> = GetInvokingResource();
    nox.events.emit.broadcast('chat:addSuggestions', commandsIndexes);
    console.debug(("Resource ^3%s^7 refreshed, chat suggestions synced"):format(resource));
end);
