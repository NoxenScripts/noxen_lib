---@class Config: BaseObject
---@field public value any
---@field public type string
---@field public secondary_type string
---@field public data Config[]
---@overload fun(value: any, valueType: string, secondaryType: string, parent: string): Config
local Config = nox.class.new 'Config';

---@param value any
---@param valueType string
---@param secondaryType string
---@param parent string
function Config:Constructor(value, valueType, secondaryType, parent)
    self.value = value;
    self.type = valueType;
    self.secondary_type = secondaryType;
    self.parent = parent;
end

return Config;
