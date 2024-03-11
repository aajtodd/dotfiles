local wezterm = require('wezterm')


-- This will hold the configuration.
local config = wezterm.config_builder()

-- Fonts
config.font = wezterm.font('JetBrainsMono Nerd Font', { weight = 'Bold' })
config.font_size = 12

-- Colorscheme

config.color_schemes = {
    ['Oceanic'] = {
        background = '#263238',
    },
}

config.color_scheme = 'Oceanic'

-- and finally, return the configuration to wezterm
return config
