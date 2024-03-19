return {
    -- colortheme
    -- {
    --     -- FIXME - work on improving this
    --     -- Maybe use this as base and modify to match closer to darcula https://github.com/catppuccin/nvim#overwriting-highlight-groups
    --     "catppuccin/nvim",
    --     name = "catppuccin",
    --     priority = 1000,
    --     opts = {
    --         flavour = "mocha",
    --         integrations = {
    --             cmp = true,
    --             gitsigns = true,
    --             treesitter = true,
    --             neotree = true,
    --         },
    --         color_overrides = {
    --             mocha = {
    --                 base = "#1C1D1F",
    --                 mantle = '#262829',
    --                 crust = '#262829',
    --                 -- text = '#B4B6BC',
    --                 -- blue = '#4683BD',
    --                 -- yellow = '#FEBF6A',
    --                 -- green = '#589162',
    --
    --                 -- surface = '#262829',
    --                 -- base = '#2b303b',
    --                 -- -- mantle = '',
    --                 -- -- crust = '',
    --                 -- -- surface 0,1,2
    --                 -- -- overlay 0,1,2
    --                 -- text = '#c0c5ce',
    --                 -- black =   '#2b303b',
    --                 -- red =     '#bf616a',
    --                 -- green =   '#a3be8c',
    --                 -- yellow =  '#ebcb8b',
    --                 -- blue =    '#8fa1b3',
    --                 -- magenta = '#b48ead',
    --                 -- cyan =    '#96b5b4',
    --                 -- white =   '#c0c5ce',
    --                 -- mauve = '#ebcb8b',
    --             },
    --         },
    --         custom_highlights = function(colors)
    --             return {}
    --         end,
    --     },
    --     config = function(_, opts)
    --         require("catppuccin").setup(opts)
    --         vim.cmd.colorscheme("catppuccin")
    --     end
    -- },
    -- {
    --     "doums/darcula",
    --     config = function()
    --         vim.cmd.colorscheme('darcula')
    --     end
    -- },
    {
        "rebelot/kanagawa.nvim",
        lazy = false,
        priority = 1000,
        config = function()
            require('kanagawa').setup({
                colors = {
                    palette = {
                        dragonBlack0 = '#26282A',
                        dragonBlack3 = "#1C1D1F",
                        dragonBlack5 = '#222428'
                    },
                    theme = {
                        dragon = {
                            ui = {
                                -- bg_gutter = "none"
                            }
                        },
                    },
                    overrides = function(colors)
                        return {
                            CursorLine = { bg = '#222428' },
                            CursorLineNr = { fg = '#9799A1', bold = true },
                        }
                    end
                },
            })
            vim.cmd.colorscheme("kanagawa-dragon")
        end
    },
    -- {
    --     'shaunsingh/nord.nvim',
    --     lazy = false,
    --     priority = 1000,
    --     config = function()
    --         vim.cmd.colorscheme('nord')
    --     end
    -- },

    -- statusline
    {
        "nvim-lualine/lualine.nvim",
        dependencies = { 'nvim-tree/nvim-web-devicons' },
        opts = {
            theme = 'nord'
        },
    },

    -- git related enhancements (e.g. changed lines)
    {
        "lewis6991/gitsigns.nvim",
        config = function()
            require('gitsigns').setup()
        end
    },
}
