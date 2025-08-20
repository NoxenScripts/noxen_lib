---@param name string
---@param metadata string
---@return string
return function(name, metadata)
    if (not nox.resource.does_exist(name)) then return nil; end
    return GetResourceMetadata(name, metadata);
end
