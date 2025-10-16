---@param options { label?: string, time?: number, icon?: string, style?: 'rectangle' | 'circle', position?: 'bottom' | 'center' }
local function ProgressBar(options)
    return exports[nox.name]:ProgressBar(
        options.label or "Progress",
        options.time or 1000,
        options.icon or "🔄",
        options.style or 'rectangle',
        options.position or 'bottom'
    );
end

local function CancelProgressBar()
    return exports[nox.name]:CancelProgressBar();
end

return {
    ProgressBar = ProgressBar,
    CancelProgressBar = CancelProgressBar,
};
