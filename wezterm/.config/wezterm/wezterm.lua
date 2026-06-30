local wezterm = require('wezterm')
local act = wezterm.action


-- This will hold the configuration.
local config = wezterm.config_builder()

-- Fonts
config.font = wezterm.font('JetBrainsMono Nerd Font', { weight = 'Bold' })
config.font_size = 12.5
-- config.line_height = 1.0

-- Colorscheme

-- config.color_schemes = {
--     ['Oceanic'] = {
--         background = '#263238',
--     },
-- }

config.color_scheme = 'Ocean (dark) (terminal.sexy)'

-- Custom keybindings.
-- CMD (SUPER) is the safe layer for wezterm: zellij/nvim run INSIDE wezterm and
-- never use CMD, so these can't shadow a zellij mode-prefix (Ctrl-t/p/n/o/...) or
-- an nvim mapping. On an external PC keyboard macOS maps the Windows key -> CMD,
-- so every SUPER binding fires from both the laptop and the PC keyboard.
config.keys = {
    -- Make Option-Left equivalent to Alt-b which many line editors interpret as backward-word
    {key="LeftArrow", mods="OPT", action=wezterm.action{SendString="\x1bb"}},
    -- Make Option-Right equivalent to Alt-f; forward-word
    {key="RightArrow", mods="OPT", action=wezterm.action{SendString="\x1bf"}},

    -- Fuzzy tab switcher (the `zjt` analog, one layer out). Type to filter tab
    -- titles, Enter to jump. CMD-P is unbound by default (palette is CTRL-SHIFT-P).
    {key="p", mods="CMD", action=act.ShowLauncherArgs{flags="FUZZY|TABS"}},

    -- Rename the active tab (the `zjr` analog) so the switcher + tab bar are
    -- meaningful. CMD-E is unbound by default.
    {key="e", mods="CMD", action=act.PromptInputLine{
        description="Tab name:",
        action=wezterm.action_callback(function(window, _, line)
            -- nil = ESC (cancel); "" = cleared name -> wezterm reverts to auto title.
            if line ~= nil then window:active_tab():set_title(line) end
        end),
    }},

    -- Reorder the current tab. Defaults give CMD-SHIFT-[ / ] for NAVIGATION; these
    -- arrow variants MOVE it. (CMD-SHIFT-arrows are unbound by default.)
    {key="LeftArrow",  mods="CMD|SHIFT", action=act.MoveTabRelative(-1)},
    {key="RightArrow", mods="CMD|SHIFT", action=act.MoveTabRelative(1)},
}

-- and finally, return the configuration to wezterm
return config
