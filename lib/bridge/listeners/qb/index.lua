if (nox.is_server) then
    require 'lib.bridge.listeners.qb.server';
else
    require 'lib.bridge.listeners.qb.client';
end
