local bridge <const> = require 'lib.bridge.bridge';

---[[
--- EXAMPLE USAGE (SERVER)
--- bridge:AddEventHandler('custom', 'custom:playerLoaded', function(source, playerData)
---   console.log(("Custom player loaded: %s"):format(json.encode(playerData)));
--- end);
---]]
