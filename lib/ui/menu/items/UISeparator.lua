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

local _RenderText = nox.ui.RenderText;

---@type table
local SettingsButton = {

    Rectangle = { Y = 0, Width = 431, Height = 38 },
    Text = { X = 10, Y = 3, Scale = 0.33 },

}

function UIItems:Separator(Label)

    local CurrentMenu = nox.ui.CurrentMenu;

    if (CurrentMenu ~= nil) then

        if (CurrentMenu) then

            local Option = nox.ui.Options + 1;

            if (CurrentMenu.Pagination.Minimum <= Option and CurrentMenu.Pagination.Maximum >= Option) then

                if (Label ~= nil) then

                    _RenderText(Label, CurrentMenu.X + SettingsButton.Text.X + (CurrentMenu.WidthOffset * 2.5 ~= 0 and CurrentMenu.WidthOffset * 2.5 or 200), CurrentMenu.Y + SettingsButton.Text.Y + CurrentMenu.SubtitleHeight + nox.ui.ItemOffset, 0, SettingsButton.Text.Scale, 245, 245, 245, 255, 1)

                end

                nox.ui.ItemOffset = nox.ui.ItemOffset + SettingsButton.Rectangle.Height;

                if (CurrentMenu.Index == Option) then

                    if (nox.ui.LastControl) then

                        CurrentMenu.Index = Option - 1;
                        if (CurrentMenu.Index < 1) then
                            CurrentMenu.Index = nox.ui.CurrentMenu.Options;
                        end

                    else
                        CurrentMenu.Index = Option + 1;
                    end

                end

            end

            nox.ui.Options = nox.ui.Options + 1;

        end

    end

end

