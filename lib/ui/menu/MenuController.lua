---
--- @author Dylan MALANDAIN
--- @version 2.0.0
--- @since 2020
---
--- ui Is Advanced UI Libs in LUA for make beautiful interface like RockStar GAME.
---
---
--- Commercial Info.
--- Any use for commercial purposes is strictly prohibited and will be punished.
---
--- @see ui
---

local _IsDisabledControlJustPressed = IsDisabledControlJustPressed;
local _IsDisabledControlPressed = IsDisabledControlPressed;
local _RenderSprite = nox.ui.RenderSprite;
local _RenderRectangle = nox.ui.RenderRectangle;
local _SetScriptGfxAlign = SetScriptGfxAlign;
local _SetScriptGfxAlignParams = SetScriptGfxAlignParams;
local _CreateThread = CreateThread;
local _Wait = Wait;

nox.ui.LastControl = false

local ControlActions = {
    'Left',
    'Right',
    'Select',
    'Click',
}

---GoUp
---@param Options number
---@return nil
---@public
function nox.ui.GoUp(Options)
    local CurrentMenu = nox.ui.CurrentMenu;
    if CurrentMenu ~= nil then
        Options = CurrentMenu.Options
        if CurrentMenu then
            if (Options ~= 0) then
                if Options > CurrentMenu.Pagination.Total then
                    if CurrentMenu.Index <= CurrentMenu.Pagination.Minimum then
                        if CurrentMenu.Index == 1 then
                            CurrentMenu.Pagination.Minimum = Options - (CurrentMenu.Pagination.Total - 1)
                            CurrentMenu.Pagination.Maximum = Options
                            CurrentMenu.Index = Options
                        else
                            CurrentMenu.Pagination.Minimum = (CurrentMenu.Pagination.Minimum - 1)
                            CurrentMenu.Pagination.Maximum = (CurrentMenu.Pagination.Maximum - 1)
                            CurrentMenu.Index = CurrentMenu.Index - 1
                        end
                    else
                        CurrentMenu.Index = CurrentMenu.Index - 1
                    end
                else
                    if CurrentMenu.Index == 1 then
                        CurrentMenu.Pagination.Minimum = Options - (CurrentMenu.Pagination.Total - 1)
                        CurrentMenu.Pagination.Maximum = Options
                        CurrentMenu.Index = Options
                    else
                        CurrentMenu.Index = CurrentMenu.Index - 1
                    end
                end

                local Audio = nox.ui.Settings.Audio
                nox.ui.PlaySound(Audio[Audio.Use].UpDown.audioName, Audio[Audio.Use].UpDown.audioRef)
                nox.ui.LastControl = true
                if (CurrentMenu.onIndexChange ~= nil) then
                    _CreateThread(function()
                        CurrentMenu.onIndexChange(CurrentMenu.Index)
                    end)
                end
            else
                local Audio = nox.ui.Settings.Audio
                nox.ui.PlaySound(Audio[Audio.Use].Error.audioName, Audio[Audio.Use].Error.audioRef)
            end
        end
    end
end

---GoDown
---@param Options number
---@return nil
---@public
function nox.ui.GoDown(Options)
    local CurrentMenu = nox.ui.CurrentMenu;
    if CurrentMenu ~= nil then
        Options = CurrentMenu.Options
        if CurrentMenu then
            if (Options ~= 0) then
                if Options > CurrentMenu.Pagination.Total then
                    if CurrentMenu.Index >= CurrentMenu.Pagination.Maximum then
                        if CurrentMenu.Index == Options then
                            CurrentMenu.Pagination.Minimum = 1
                            CurrentMenu.Pagination.Maximum = CurrentMenu.Pagination.Total
                            CurrentMenu.Index = 1
                        else
                            CurrentMenu.Pagination.Maximum = (CurrentMenu.Pagination.Maximum + 1)
                            CurrentMenu.Pagination.Minimum = CurrentMenu.Pagination.Maximum - (CurrentMenu.Pagination.Total - 1)
                            CurrentMenu.Index = CurrentMenu.Index + 1
                        end
                    else
                        CurrentMenu.Index = CurrentMenu.Index + 1
                    end
                else
                    if CurrentMenu.Index == Options then
                        CurrentMenu.Pagination.Minimum = 1
                        CurrentMenu.Pagination.Maximum = CurrentMenu.Pagination.Total
                        CurrentMenu.Index = 1
                    else
                        CurrentMenu.Index = CurrentMenu.Index + 1
                    end
                end
                local Audio = nox.ui.Settings.Audio
                nox.ui.PlaySound(Audio[Audio.Use].UpDown.audioName, Audio[Audio.Use].UpDown.audioRef)
                nox.ui.LastControl = false
                if (CurrentMenu.onIndexChange ~= nil) then
                    _CreateThread(function()
                        CurrentMenu.onIndexChange(CurrentMenu.Index)
                    end)
                end
            else
                local Audio = nox.ui.Settings.Audio
                nox.ui.PlaySound(Audio[Audio.Use].Error.audioName, Audio[Audio.Use].Error.audioRef)
            end
        end
    end
end

function nox.ui.GoActionControl(Controls, Action)
    if Controls[Action or 'Left'].Enabled then
        for Index = 1, #Controls[Action or 'Left'].Keys do
            if not Controls[Action or 'Left'].Pressed then
                if _IsDisabledControlJustPressed(Controls[Action or 'Left'].Keys[Index][1], Controls[Action or 'Left'].Keys[Index][2]) then
                    Controls[Action or 'Left'].Pressed = true
                    _CreateThread(function()
                        Controls[Action or 'Left'].Active = true
                        _Wait(0.01)
                        Controls[Action or 'Left'].Active = false
                        _Wait(175)
                        while Controls[Action or 'Left'].Enabled and _IsDisabledControlPressed(Controls[Action or 'Left'].Keys[Index][1], Controls[Action or 'Left'].Keys[Index][2]) do
                            Controls[Action or 'Left'].Active = true
                            _Wait(1)
                            Controls[Action or 'Left'].Active = false
                            _Wait(124)
                        end
                        Controls[Action or 'Left'].Pressed = false
                        if (Action ~= ControlActions[5]) then
                            _Wait(10)
                        end
                    end)
                    break
                end
            end
        end
    end
end

function nox.ui.GoActionControlSlider(Controls, Action)
    if Controls[Action].Enabled then
        for Index = 1, #Controls[Action].Keys do
            if not Controls[Action].Pressed then
                if _IsDisabledControlJustPressed(Controls[Action].Keys[Index][1], Controls[Action].Keys[Index][2]) then
                    Controls[Action].Pressed = true
                    _CreateThread(function()
                        Controls[Action].Active = true
                        _Wait(1)
                        Controls[Action].Active = false
                        while Controls[Action].Enabled and _IsDisabledControlPressed(Controls[Action].Keys[Index][1], Controls[Action].Keys[Index][2]) do
                            Controls[Action].Active = true
                            _Wait(1)
                            Controls[Action].Active = false
                        end
                        Controls[Action].Pressed = false
                    end)
                    break
                end
            end
        end
    end
end

local _SetMouseCursorActiveThisFrame = SetMouseCursorActiveThisFrame;
local _IsDisabledControlJustPressed = IsDisabledControlJustPressed;
local _DisableAllControlActions = DisableAllControlActions;
local _EnableControlAction = EnableControlAction;

---Controls
---@return nil
---@public
function nox.ui.Controls()
    local CurrentMenu = nox.ui.CurrentMenu;
    if CurrentMenu ~= nil then
        if CurrentMenu then
            if CurrentMenu:IsOpen() then

                local Controls = CurrentMenu.Controls;
                ---@type number
                local Options = CurrentMenu.Options
                nox.ui.Options = CurrentMenu.Options
                if CurrentMenu.EnableMouse then
                    _DisableAllControlActions(2);
                end

                if not IsInputDisabled(2) then
                    for Index = 1, #Controls.Enabled.Controller do
                        _EnableControlAction(Controls.Enabled.Controller[Index][1], Controls.Enabled.Controller[Index][2], true)
                    end
                else
                    for Index = 1, #Controls.Enabled.Keyboard do
                        _EnableControlAction(Controls.Enabled.Keyboard[Index][1], Controls.Enabled.Keyboard[Index][2], true)
                    end
                end

                if Controls.Up.Enabled then
                    for Index = 1, #Controls.Up.Keys do
                        if not Controls.Up.Pressed then
                            if _IsDisabledControlJustPressed(Controls.Up.Keys[Index][1], Controls.Up.Keys[Index][2]) then
                                Controls.Up.Pressed = true
                                _CreateThread(function()
                                    nox.ui.GoUp(Options)
                                    _Wait(175)
                                    while Controls.Up.Enabled and _IsDisabledControlPressed(Controls.Up.Keys[Index][1], Controls.Up.Keys[Index][2]) do
                                        nox.ui.GoUp(Options)
                                        _Wait(50)
                                    end
                                    Controls.Up.Pressed = false
                                end)
                                break
                            end
                        end
                    end
                end

                if Controls.Down.Enabled then
                    for Index = 1, #Controls.Down.Keys do
                        if not Controls.Down.Pressed then
                            if _IsDisabledControlJustPressed(Controls.Down.Keys[Index][1], Controls.Down.Keys[Index][2]) then
                                Controls.Down.Pressed = true
                                _CreateThread(function()
                                    nox.ui.GoDown(Options)
                                    _Wait(175)
                                    while Controls.Down.Enabled and _IsDisabledControlPressed(Controls.Down.Keys[Index][1], Controls.Down.Keys[Index][2]) do
                                        nox.ui.GoDown(Options)
                                        _Wait(50)
                                    end
                                    Controls.Down.Pressed = false
                                end)
                                break
                            end
                        end
                    end
                end

                for i = 1, #ControlActions do
                    nox.ui.GoActionControl(Controls, ControlActions[i])
                end

                nox.ui.GoActionControlSlider(Controls, 'SliderLeft')
                nox.ui.GoActionControlSlider(Controls, 'SliderRight')

                if Controls.Back.Enabled then
                    for Index = 1, #Controls.Back.Keys do
                        if not Controls.Back.Pressed then
                            if _IsDisabledControlJustPressed(Controls.Back.Keys[Index][1], Controls.Back.Keys[Index][2]) then
                                Controls.Back.Pressed = true
                                _CreateThread(function()
                                    _Wait(175)
                                    Controls.Down.Pressed = false
                                end)
                                break
                            end
                        end
                    end
                end

            end
        end
    end
end

---Navigation
---@return nil
---@public
function nox.ui.Navigation()
    local CurrentMenu = nox.ui.CurrentMenu;
    if CurrentMenu ~= nil then
        if CurrentMenu and (CurrentMenu.Display.Navigation) then
            if CurrentMenu.EnableMouse then
                _SetMouseCursorActiveThisFrame()
            end
            if nox.ui.Options > CurrentMenu.Pagination.Total then

                ---@type boolean
                local UpHovered = false

                ---@type boolean
                local DownHovered = false

                if not CurrentMenu.SafeZoneSize then
                    CurrentMenu.SafeZoneSize = { X = 0, Y = 0 }

                    if CurrentMenu.Safezone then
                        CurrentMenu.SafeZoneSize = nox.ui.GetSafeZoneBounds()

                        _SetScriptGfxAlign(76, 84)
                        _SetScriptGfxAlignParams(0, 0, 0, 0)
                    end
                end

                if CurrentMenu.EnableMouse then
                    UpHovered = nox.ui.IsMouseInBounds(CurrentMenu.X + CurrentMenu.SafeZoneSize.X, CurrentMenu.Y + CurrentMenu.SafeZoneSize.Y + CurrentMenu.SubtitleHeight + nox.ui.ItemOffset, nox.ui.Settings.Items.Navigation.Rectangle.Width + CurrentMenu.WidthOffset, nox.ui.Settings.Items.Navigation.Rectangle.Height)
                    DownHovered = nox.ui.IsMouseInBounds(CurrentMenu.X + CurrentMenu.SafeZoneSize.X, CurrentMenu.Y + nox.ui.Settings.Items.Navigation.Rectangle.Height + CurrentMenu.SafeZoneSize.Y + CurrentMenu.SubtitleHeight + nox.ui.ItemOffset, nox.ui.Settings.Items.Navigation.Rectangle.Width + CurrentMenu.WidthOffset, nox.ui.Settings.Items.Navigation.Rectangle.Height)

                    if CurrentMenu.Controls.Click.Active then
                        if UpHovered then
                            nox.ui.GoUp(nox.ui.Options)
                        elseif DownHovered then
                            nox.ui.GoDown(nox.ui.Options)
                        end
                    end

                    if UpHovered then
                        _RenderRectangle(CurrentMenu.X, CurrentMenu.Y + CurrentMenu.SubtitleHeight + nox.ui.ItemOffset, nox.ui.Settings.Items.Navigation.Rectangle.Width + CurrentMenu.WidthOffset, nox.ui.Settings.Items.Navigation.Rectangle.Height, 30, 30, 30, 255)
                    else
                        _RenderRectangle(CurrentMenu.X, CurrentMenu.Y + CurrentMenu.SubtitleHeight + nox.ui.ItemOffset, nox.ui.Settings.Items.Navigation.Rectangle.Width + CurrentMenu.WidthOffset, nox.ui.Settings.Items.Navigation.Rectangle.Height, 0, 0, 0, 200)
                    end

                    if DownHovered then
                        _RenderRectangle(CurrentMenu.X, CurrentMenu.Y + nox.ui.Settings.Items.Navigation.Rectangle.Height + CurrentMenu.SubtitleHeight + nox.ui.ItemOffset, nox.ui.Settings.Items.Navigation.Rectangle.Width + CurrentMenu.WidthOffset, nox.ui.Settings.Items.Navigation.Rectangle.Height, 30, 30, 30, 255)
                    else
                        _RenderRectangle(CurrentMenu.X, CurrentMenu.Y + nox.ui.Settings.Items.Navigation.Rectangle.Height + CurrentMenu.SubtitleHeight + nox.ui.ItemOffset, nox.ui.Settings.Items.Navigation.Rectangle.Width + CurrentMenu.WidthOffset, nox.ui.Settings.Items.Navigation.Rectangle.Height, 0, 0, 0, 200)
                    end
                else
                    _RenderRectangle(CurrentMenu.X, CurrentMenu.Y + CurrentMenu.SubtitleHeight + nox.ui.ItemOffset, nox.ui.Settings.Items.Navigation.Rectangle.Width + CurrentMenu.WidthOffset, nox.ui.Settings.Items.Navigation.Rectangle.Height, 0, 0, 0, 200)
                    _RenderRectangle(CurrentMenu.X, CurrentMenu.Y + nox.ui.Settings.Items.Navigation.Rectangle.Height + CurrentMenu.SubtitleHeight + nox.ui.ItemOffset, nox.ui.Settings.Items.Navigation.Rectangle.Width + CurrentMenu.WidthOffset, nox.ui.Settings.Items.Navigation.Rectangle.Height, 0, 0, 0, 200)
                end
                _RenderSprite(nox.ui.Settings.Items.Navigation.Arrows.Dictionary, nox.ui.Settings.Items.Navigation.Arrows.Texture, CurrentMenu.X + nox.ui.Settings.Items.Navigation.Arrows.X + (CurrentMenu.WidthOffset / 2), CurrentMenu.Y + nox.ui.Settings.Items.Navigation.Arrows.Y + CurrentMenu.SubtitleHeight + nox.ui.ItemOffset, nox.ui.Settings.Items.Navigation.Arrows.Width, nox.ui.Settings.Items.Navigation.Arrows.Height)
                nox.ui.ItemOffset = nox.ui.ItemOffset + (nox.ui.Settings.Items.Navigation.Rectangle.Height * 2)
            end
        end
    end
end

---GoBack
---@return nil
---@public
function nox.ui.GoBack()
    local CurrentMenu = nox.ui.CurrentMenu
    if CurrentMenu ~= nil then
        local Audio = nox.ui.Settings.Audio
        nox.ui.PlaySound(Audio[Audio.Use].Back.audioName, Audio[Audio.Use].Back.audioRef)
        if CurrentMenu.Parent ~= nil then
            if CurrentMenu.Parent then
                nox.ui.NextMenu = CurrentMenu.Parent
            else
                nox.ui.NextMenu = nil
                nox.ui.Visible(CurrentMenu, false)
            end
        else
            nox.ui.NextMenu = nil
            nox.ui.Visible(CurrentMenu, false)
            nox.ui.TextEnabled = true;
        end
    end
end

---GoBackTo
---@param menu UIMenu
---@param callback function
---@public
function nox.ui.GoBackTo(menu, callback)
    local CurrentMenu = nox.ui.CurrentMenu;
    if (CurrentMenu ~= nil) then

        local Audio = nox.ui.Settings.Audio;
        nox.ui.PlaySound(Audio[Audio.Use].Back.audioName, Audio[Audio.Use].Back.audioRef);

        if (menu and menu.IsOpen and not menu:IsOpen()) then
            nox.ui.NextMenu = menu;
        else

            nox.ui.NextMenu = nil
            nox.ui.Visible(CurrentMenu, false)
            nox.ui.TextEnabled = true;

        end

        if (callback) then callback() end

    end
end

---Reset Current Menu description
function nox.ui.ResetDescription()

    local currentMenu = nox.ui.GetCurrentMenu();

    currentMenu.Description = nil;

end
