---@type noxen.lib.notification
local notification = nox.class.singleton('noxen.lib.notification', function(class)

    ---@class noxen.lib.notification: BaseObject
    ---@field public event string
    local self = class;

    function self:Constructor()
        self.event = ('%s.%s'):format(eLibEvents.sendNotification, nox.current_resource);
        if (not nox.is_server) then
            nox.events.on.net(self.event, function(_, message, hudColorIndex, isTranslation, ...)
                self:Send(message, hudColorIndex, isTranslation, ...);
            end);
        end
    end

    ---@param message string
    ---@param hudColorIndex eHudColorIndex
    ---@param isTranslation boolean
    ---@vararg any
    ---@return string
    function self:Send(message, hudColorIndex, isTranslation, ...)

        assert(not nox.is_server, 'This function can only be called on the client.');

        if (type(message) == 'string') then

            local _message = isTranslation and _U(message, ...) or message;

            BeginTextCommandThefeedPost('STRING');
            AddTextComponentSubstringPlayerName(_message);

            if (type(hudColorIndex) == 'number') then
                ThefeedSetNextPostBackgroundColor(hudColorIndex);
            end

            EndTextCommandThefeedPostTicker(false, true);

            return _message;

        end

    end

    ---@param source number
    ---@param message string
    ---@param hudColorIndex eHudColorIndex
    ---@param isTranslation boolean
    ---@vararg any
    function self:SendTo(source, message, hudColorIndex, isTranslation, ...)
        assert(nox.is_server, 'This function can only be called on the server.');
        nox.events.emit.net(self.event, source, message, hudColorIndex, isTranslation, ...);
    end

    ---@param message string
    ---@param hudColorIndex eHudColorIndex
    ---@param isTranslation boolean
    ---@vararg any
    function self:Broadcast(message, hudColorIndex, isTranslation, ...)
        assert(nox.is_server, 'This function can only be called on the server.');
        nox.events.emit.broadcast(self.event, message, hudColorIndex, isTranslation, ...);
    end

    return self;

end);


return notification;
