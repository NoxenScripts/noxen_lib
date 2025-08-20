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

nox.ui.Window.Heritage = {};
local _RenderSprite = nox.ui.RenderSprite;

---@type table
local Heritage = {
    Background = { Dictionary = "pause_menu_pages_char_mom_dad", Texture = "mumdadbg", Width = 431, Height = 228 },
    Dictionary = "char_creator_portraits",
    Mum = { Dictionary = "char_creator_portraits", X = 25, Width = 228, Height = 228 },
    Dad = { Dictionary = "char_creator_portraits", X = 195, Width = 228, Height = 228 },
}

function nox.ui.Window.Heritage.RegisterBackground()

    ---@type UIMenu
    local CurrentMenu = nox.ui.CurrentMenu;

    if (CurrentMenu) then
        _RenderSprite(
            Heritage.Background.Dictionary,
            Heritage.Background.Texture,
            CurrentMenu.X,
            CurrentMenu.Y + CurrentMenu.SubtitleHeight + nox.ui.ItemOffset,
            Heritage.Background.Width + (CurrentMenu.WidthOffset / 1),
            Heritage.Background.Height
        );
    end

end

---@param currentIndex number
function nox.ui.Window.Heritage.RegisterFirstParent(currentIndex)

    ---@type UIMenu
    local CurrentMenu = nox.ui.CurrentMenu;
    local _index = currentIndex;

    if (CurrentMenu) then

        if _index < 0 then _index = 0 end

        _RenderSprite(
            Heritage.Dictionary,
            nox.ui.EnumHeritage.Parent1[currentIndex], CurrentMenu.X + Heritage.Mum.X + (CurrentMenu.WidthOffset / 2),
            CurrentMenu.Y + CurrentMenu.SubtitleHeight + nox.ui.ItemOffset,
            Heritage.Mum.Width,
            Heritage.Mum.Height
        );
    end

end

---@param currentIndex number
function nox.ui.Window.Heritage.RegisterSecondParent(currentIndex)

    ---@type UIMenu
    local CurrentMenu = nox.ui.CurrentMenu;
    local _index = currentIndex;

    if (CurrentMenu) then

        if _index < 0 then _index = 0 end

        _RenderSprite(
            Heritage.Dictionary,
            nox.ui.EnumHeritage.Parent2[currentIndex],
            CurrentMenu.X + Heritage.Dad.X + (CurrentMenu.WidthOffset / 2),
            CurrentMenu.Y + CurrentMenu.SubtitleHeight + nox.ui.ItemOffset,
            Heritage.Dad.Width,
            Heritage.Dad.Height
        );
    end

end

function nox.ui.Window.Heritage.Render()
    nox.ui.ItemOffset = nox.ui.ItemOffset + Heritage.Background.Height;
end

