---@type Locale
local Locale <const> = nox.class.singleton('Locale', function(class)

    ---@class Locale: BaseObject
    ---@field public lang string
    ---@field public color string
    ---@field public locales table<string, table<string, string>>
    local self <const> = class;

    function self:Constructor()
        self.lang = GetConvar("noxen_scripts_locale", "en");
        self.locales = {};
        assert(type(self.lang) == 'string', 'Locale:Constructor: noxen_scripts_locale must be a string');
    end

    --- Format using indexes (e.g., {0}, {1}, ...)
    --- Also search for `!^` to replace with current color
    ---@param str string
    ---@vararg any
    ---@return string
    function self:Format(str, ...)
        assert(type(str) == 'string', ("Locale:Format: Attempt to index a '%s' value field: 'str'"):format(type(str)));

        local args <const> = {...};

        if (#args > 0) then
            str = str:gsub("{(%d+)}", function(index)
                local integer <const> = tonumber(index);
                local string <const> = tostring(index);

                assert(integer ~= nil, ("Locale:Format: Invalid index '%s' in string: '%s'"):format(string, str));
                assert(integer >= 0 and integer < #args, ("Locale:Format: Index '%s' out of bounds in string: '%s'"):format(string, str));

                return tostring(args[integer + 1]) or 'MISSING_ARG_{'..integer..'}';
            end);
        end

        return str:gsub("!^", nox.color.get_current());
    end

    ---@private
    ---@param str string
    ---@param ... any
    function self:ConvertStr(str, ...)  -- Translate string
        assert(type(str) == 'string', ("Locale:ConvertStr: Attempt to index a '%s' value field: 'str'"):format(type(str)));

        local _lang <const> = self.lang:upper();
        local language <const> = self.locales[_lang];
        local final <const> = str:lower();

        if (type(language) == 'table') then
            if (type(language[final]) == 'string') then
                return self:Format(language[final], ...);
            else
                if (not nox.is_server) then
                    return 'Missing entry for [~r~'..final..'~s~]'
                else
                    return '^7Missing entry for ^0[^1'..final..'^0]^7'
                end
            end
        else
            if (not nox.is_server) then
                return 'Locale [~r~' .. _lang .. '~s~] does not exist.'
            else
                return '^7Locale ^0[^1' .. _lang .. '^0]^7 does not exist.'
            end
        end
    end

    ---@param name string
    ---@param data table
    function self:Register(name, data)
        assert(type(name) == 'string', 'Locale:Register: name must be a string');
        assert(type(data) == 'table', 'Locale:Register: data must be a table');

        local _name <const>, count = name:upper(), 0;

        self.locales[_name] = type(self.locales[_name]) == 'table' and self.locales[_name] or {};

        for key, value in pairs(data) do
            if (type(self.locales[_name][key:lower()]) == 'string') then
                count = count + 1;
                console.warn(('Locale:Register: overwritting key ^3%s^0 in locale ^1%s^0'):format(key, _name));
            end
            self.locales[_name][key:lower()] = value;
        end

        if (count > 0) then
            console.debug(('Locale:Register: Replaced ^3x%s^0 keys in locale ^1%s^0'):format(count, _name));
        end
        return self;
    end

    ---@param str string
    ---@vararg any
    ---@return string
    function self:Translate(str, ...)
        return tostring(self:ConvertStr(str, ...));
    end

    return self;
end);

--- Translate a string with the current locale
---@param str string
---@vararg any
function _T(str, ...)
    return Locale:Translate(str, ...);
end

--- Register a new locale with its data
--- **Example:**
--- ```lua
--- translation 'en' {
---   ['hello.world'] = 'Hello World',
--- };
--- print(_T('hello.world')); -- Output: Hello World
--- ```
---@param lang string
---@return fun(data: table)
function translation(lang)
    assert(type(lang) == 'string', 'translation: lang must be a string');
    console.debug(('^7(^6Locale^7)^0 => Registering ^7(^1%s^7)'):format(lang:upper()));
    return function(data)
        assert(type(data) == 'table', 'translation: data must be a table');
        Locale:Register(lang, data);
    end;
end

return Locale;
