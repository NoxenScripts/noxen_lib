local menus = require 'client.menu';

RegisterCommand('open_example', function()
    menus.menu:Toggle();
end);

RegisterCommand('open_example_server', function()

    local random <const> = math.random(1, 3);
    local wasLucky <const> = nox.events.emit.callback.await('open_example_server', random);

    if (not wasLucky) then
        nox.game.notification:Send('You were not allowed to open the menu.', eHUDColorIndex.RED);
        return;
    end

    nox.game.notification:Send('You were allowed to open the menu.', eHUDColorIndex.GREEN);
    menus.menu:Toggle();
end);
