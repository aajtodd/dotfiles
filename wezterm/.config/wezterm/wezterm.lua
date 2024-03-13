local wezterm = require('wezterm')


-- This will hold the configuration.
local config = wezterm.config_builder()

-- Fonts
config.font = wezterm.font('JetBrainsMono Nerd Font', { weight = 'Bold' })
config.font_size = 12

-- Colorscheme

-- config.color_schemes = {
--     ['Oceanic'] = {
--         background = '#263238',
--     },
-- }

config.color_scheme = 'Ocean (dark) (terminal.sexy)'

-- Custom keybindings
config.keys = {
    -- Make Option-Left equivalent to Alt-b which many line editors interpret as backward-word
    {key="LeftArrow", mods="OPT", action=wezterm.action{SendString="\x1bb"}},
    -- Make Option-Right equivalent to Alt-f; forward-word
    {key="RightArrow", mods="OPT", action=wezterm.action{SendString="\x1bf"}},
}

-- and finally, return the configuration to wezterm
return config
