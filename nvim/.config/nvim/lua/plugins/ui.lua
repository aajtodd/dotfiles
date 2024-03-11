return {
    {
        "nvim-neo-tree/neo-tree.nvim",
        branch = "v3.x",
        dependencies = {
          "nvim-lua/plenary.nvim",
          "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
          "MunifTanjim/nui.nvim",
          -- "3rd/image.nvim", -- Optional image support in preview window: See `# Preview Mode` for more information
        },
        config = function()
            local utils = require("utils")
            utils.nmap("<C-n>", "<cmd>Neotree toggle<CR>")
            -- Open telescope if no files specified
            vim.api.nvim_create_autocmd({"vimenter"}, {
                pattern = "*",
                callback = function()
                    if vim.fn.argc() == 0 then
                        vim.cmd('Telescope find_files')
                    end
                end
            })
        end
    },

    {
        "lewis6991/gitsigns.nvim"
    },

    {
        "doums/darcula",
        config = function()
            vim.cmd.colorscheme('darcula')
        end
    },

    {
        "nvim-lualine/lualine.nvim",
        dependencies = { 'nvim-tree/nvim-web-devicons' },
        opts = {
            theme = 'nord'
        },
    },
}
