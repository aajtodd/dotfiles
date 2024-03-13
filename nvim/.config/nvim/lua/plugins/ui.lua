return {
    -- colortheme
    {
        -- FIXME - work on improving this
        -- Maybe use this as base and modify to match closer to darcula https://github.com/catppuccin/nvim#overwriting-highlight-groups
        "catppuccin/nvim",
        name = "catppuccin",
        priority = 1000,
        opts = {
            flavour = "frappe",
            integrations = {
                cmp = true,
                gitsigns = true,
                treesitter = true,
                neotree = true,

            }
        },
        config = function(_, opts)
            require("catppuccin").setup(opts)
            vim.cmd.colorscheme("catppuccin")
        end
    },
    -- {
    --     "doums/darcula",
    --     config = function()
    --         vim.cmd.colorscheme('darcula')
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
