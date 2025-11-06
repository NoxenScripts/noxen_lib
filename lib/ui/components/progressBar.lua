---@async
---@param options { text?: string, time?: number }
local function ProgressBar(options)
    return exports[nox.name]:ShowProgressBar(
        options.time or 1000,
        options.text or "Progress"
    );
end

---@return boolean
local function CancelProgressBar()
    return exports[nox.name]:CancelProgressBar();
end

---@return boolean
local function IsProgressBarActive()
    return exports[nox.name]:IsProgressBarActive();
end

return {
    ProgressBar = ProgressBar,
    CancelProgressBar = CancelProgressBar,
    IsProgressBarActive = IsProgressBarActive
};
