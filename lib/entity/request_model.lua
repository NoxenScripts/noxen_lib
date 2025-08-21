local IS_MODEL_IN_CDIMAGE <const> = IsModelInCdimage;
local HAS_MODEL_LOADED <const> = HasModelLoaded;
local REQUEST_MODEL <const> = RequestModel;

---@async
---@param model string | number
---@return number
return function(model)
    assert(not nox.is_server, 'This function can only be called on the client.');
    local _model <const> = nox.game.hash(model);

    if (IS_MODEL_IN_CDIMAGE(_model)) then
        while (not HAS_MODEL_LOADED(_model)) do
            REQUEST_MODEL(_model);
            async.wait(0);
        end
        return _model;
    end

    return -1;
end
