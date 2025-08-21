
local SET_TEXT_FONT <const> = SetTextFont;
local SET_TEXT_SCALE <const> = SetTextScale;
local SET_TEXT_COLOUR <const> = SetTextColour;
local SET_TEXT_CENTRE <const> = SetTextCentre;
local SET_DRAW_ORIGIN <const> = SetDrawOrigin;
local CLEAR_DRAW_ORIGIN <const> = ClearDrawOrigin;
local GET_GAMEPLAY_CAM_FOV <const> = GetGameplayCamFov;
local SET_TEXT_PROPORTIONAL <const> = SetTextProportional;
local GET_FINAL_RENDERED_CAM_COORD <const> = GetFinalRenderedCamCoord;
local END_TEXT_COMMAND_DISPLAY_TEXT <const> = EndTextCommandDisplayText;
local BEGIN_TEXT_COMMAND_DISPLAY_TEXT <const> = BeginTextCommandDisplayText;
local ADD_TEXT_COMPONENT_SUBSTRING_PLAYER_NAME <const> = AddTextComponentSubstringPlayerName;

---@param text string
---@param coords vector3 | table
---@param size number
---@param font number
---@return void
return function(text, coords, size, font)
	assert(not nox.is_server, 'This function can only be used on the client side.');
	assert(type(text) == 'string', 'lib.game.text - The text must be a string.');
	local vector <const> = type(coords) == "vector3" and coords
		or vector3(coords.x, coords.y, coords.z);
    local camCoords <const> = GET_FINAL_RENDERED_CAM_COORD();
    local distance <const> = #(vector - camCoords);
	local _size <const> = type(size) == 'number' and size or 1;
	local _font <const> = type(font) == 'number' and font or 0;
    local scale <const> = (_size / distance) * 2;
    local fov <const> = (1 / GET_GAMEPLAY_CAM_FOV()) * 100;
	local _scale <const> = (scale * fov);

    SET_TEXT_SCALE(0.0, 0.55 * _scale);
    SET_TEXT_FONT(_font);
    SET_TEXT_PROPORTIONAL(1);
    SET_TEXT_COLOUR(255, 255, 255, 215);
    BEGIN_TEXT_COMMAND_DISPLAY_TEXT('STRING');
    SET_TEXT_CENTRE(true);
    ADD_TEXT_COMPONENT_SUBSTRING_PLAYER_NAME(text);
    SET_DRAW_ORIGIN(vector, 0);
    END_TEXT_COMMAND_DISPLAY_TEXT(0.0, 0.0);
    CLEAR_DRAW_ORIGIN();
end
