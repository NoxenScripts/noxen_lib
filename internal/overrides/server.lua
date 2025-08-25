local sources <const>, playersCount = {}, 0;
local table_remove <const> = table.remove;
local resource <const> = nox.current_resource;
local addEventHandler <const> = AddEventHandler;
local resultAsInteger <const> = Citizen.ResultAsInteger();
local resultAsString <const> = Citizen.ResultAsString();

addEventHandler('onResourceStart', function(resourceName)
    if (resourceName ~= resource) then
        return;
    end

    local numPlayers <const> = Citizen.InvokeNative(0x63D13184 --[[ GetNumPlayerIndices ]], resultAsInteger);

    for i = 0, numPlayers - 1 do
        sources [#sources + 1] = Citizen.InvokeNative(0xC8A9CE08 --[[ GetPlayerFromIndex ]], i, resultAsString);
    end

    playersCount = #sources;

    console.debug(("Resource ^3%s^7 has started with ^2%d^7 players connected."):format(resource, #sources));
end);

addEventHandler('playerJoining', function()
    local src <const> = source;

    sources[#sources + 1] = tostring(src);
    playersCount += 1;
    console.debug(("Player ^3%s^7 has connected."):format(src));
end);

addEventHandler('playerDropped', function()
    local src <const> = source;

    for i = 1, #sources do
        if (sources[i] == tostring(src)) then
            table_remove(sources, i);
            console.debug(("Player ^3%s^7 has disconnected."):format(src));
            playersCount -= 1;
            break;
        end
    end
end);

exports('GetPlayers', function()
    return sources;
end);

exports('GetNumPlayerIndices', function()
    return playersCount;
end);
