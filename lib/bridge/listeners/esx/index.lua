if (nox.is_server) then
    require 'lib.bridge.listeners.esx.server';
else
    require 'lib.bridge.listeners.esx.client';
end
