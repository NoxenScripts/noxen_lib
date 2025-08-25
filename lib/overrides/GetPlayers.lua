local export <const> = exports[nox.name];

---@return string[]
function GetPlayers()
    return export:GetPlayers();
end
