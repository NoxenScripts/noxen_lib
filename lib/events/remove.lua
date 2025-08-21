local REMOVE_EVENT_HANDLER <const> = RemoveEventHandler;

---@param eventData eventData
return function(eventData)
    return REMOVE_EVENT_HANDLER(eventData);
end
