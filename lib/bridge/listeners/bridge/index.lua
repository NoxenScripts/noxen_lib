if (nox.is_server) then
    require 'lib.bridge.listeners.bridge.server';
else
    require 'lib.bridge.listeners.bridge.client';
end
