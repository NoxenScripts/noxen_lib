if (nox.is_server) then
    return;
end

local active, complete, cancelled = false, false, false;

---@param duration number Duration in milliseconds
---@param text string Text to display on the progress bar
local function show(duration, text)
    if (active) then
        return false;
    end

    active, complete, cancelled = true, false, false;

    SendNUIMessage({
        type = 'progressBar:show',
        payload = {
            duration = duration,
            text = text
        }
    });

    local startTime <const> = GetGameTimer();
    local endTime <const> = startTime + duration;

    local promise <const> = promise.new();

    async(function()
        while (active and GetGameTimer() < endTime) do
            if (complete or cancelled) then
                break;
            end
            async.wait(10);
        end
        promise:resolve();
    end);

    Citizen.Await(promise);

    active = false;

    if (cancelled) then
        cancelled = false;
        return false;
    end

    return true;
end

local function cancel()
    if (not active) then
        return false;
    end

    cancelled, active = true, false;

    SendNUIMessage({
        type = 'progressBar:cancel',
        payload = {}
    });

    return true;
end

local function isActive()
    return active;
end

RegisterNUICallback('progressComplete', function(data, cb)
    complete = true;
    cb('ok');
end);

RegisterNUICallback('progressCancelled', function(data, cb)
    cancelled = true;
    cb('ok');
end);

exports('ShowProgressBar', show);
exports('CancelProgressBar', cancel);
exports('IsProgressBarActive', isActive);
