return {
    {
        "nvim-neo-tree/neo-tree.nvim",
        branch = "v3.x",
        dependencies = {
          "nvim-lua/plenary.nvim",
          "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
          "MunifTanjim/nui.nvim",
        },
        config = function(_, opts)
            require("neo-tree").setup(opts)
            local utils = require("utils")
            utils.nmap("<C-n>", "<cmd>Neotree toggle<CR>")
        end,
        opts = {
            -- TODO - enable document_symbols sources
            sources = {
                "filesystem",
                "buffers",
                "git_status",
                "document_symbols",
            },
            filesystem = {
                filtered_items = {
                    visible = true,
                },
            }
        }
    },

    {
        "lewis6991/gitsigns.nvim"
    },

    -- FIXME - work on improving this
    -- Maybe use this as base and modify to match closer to darcula https://github.com/catppuccin/nvim#overwriting-highlight-groups
    {
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

    {
        "nvim-lualine/lualine.nvim",
        dependencies = { 'nvim-tree/nvim-web-devicons' },
        opts = {
            theme = 'nord'
        },
    },
}
