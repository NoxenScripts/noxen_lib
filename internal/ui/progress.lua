local showing, canceled = false, false;

exports('ProgressBar', function(label, time, icon, style, position)
    if (showing) then
        return false;
    end

    showing = true;

    SendNUIMessage({
        action = 'showProgress',
        data = {
            label = label,
            value = 0,
            icon = icon,
            style = style or 'rectangle',
            position = position or 'bottom'
        }
    });

    local startTime = GetGameTimer()
    local endTime = startTime + time

    CreateThread(function()
        while showing and not canceled do
            local now <const> = GetGameTimer();

            local progress = (now - startTime) / time;

            if (progress > 1.0) then
                progress = 1.0;
            end

            value = progress * 100;

            SendNUIMessage({
                action = 'updateProgress',
                data = {
                    value = value
                }
            });

            if (progress >= 1.0) then
                showing = false;
            end

            Wait(100);
        end

        showing = false;

        SendNUIMessage({
            action = 'hideProgress'
        });

        if (not canceled) then
            return true;
        end

        canceled = false;

        return false;
    end);
end);

exports('CancelProgressBar', function()
    canceled = true;
end);
