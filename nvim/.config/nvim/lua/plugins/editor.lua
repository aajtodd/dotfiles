return {
    -- hilight/structural understanding
    {
        "nvim-treesitter/nvim-treesitter",
        branch = "main",        -- requires nvim >= 0.12
        build = ":TSUpdate",
        lazy = false,           -- the main branch does not support lazy-loading
        config = function()
            require("plugins.configs.treesitter")
        end,
    },
-- fuzzy search
    {
        'nvim-telescope/telescope.nvim',
        version = '*',          -- latest tagged release (needs nvim >= 0.10.4)
        dependencies = { 'nvim-lua/plenary.nvim' },
        config = function()
            require("plugins.configs.telescope")
        end
    },

    -- file browser
    {
        "nvim-neo-tree/neo-tree.nvim",
        branch = "v3.x",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
            "MunifTanjim/nui.nvim",
        },
        config = function()
            require("plugins.configs.neotree")
        end,
    },

    -- language server protocols
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            -- installs language server binaries and auto-enables installed ones
            "mason-org/mason.nvim",
            "mason-org/mason-lspconfig.nvim",
            -- LSP progress UI
            "j-hui/fidget.nvim",
        },
        config = function()
            require("plugins.configs.lsp")
        end
    },

    -- LSP progress UI / notifications plugin
    {
        "j-hui/fidget.nvim",
        config = function()
            require("plugins.configs.fidget")
        end
    },

    -- Debugging
    {
        "rcarriga/nvim-dap-ui",
        dependencies = {
            "mfussenegger/nvim-dap",
            "nvim-neotest/nvim-nio",
            "theHamsta/nvim-dap-virtual-text",
        },
        config = function()
            require("plugins.configs.dap").setup()
        end
    },

    -- completion engine. lsp/path/buffer/snippets sources and kind icons are
    -- built in; version '1.*' pulls the prebuilt Rust fuzzy-matcher binary.
    -- LuaSnip provides snippet expansion.
    {
        "saghen/blink.cmp",
        version = "1.*",
        dependencies = { "L3MON4D3/LuaSnip" },
        config = function()
            require("plugins.configs.blink")
        end
    },
    -- dispaly possible key bindings for commands as well as registers and marks
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        init = function()
            vim.o.timeout = true
            vim.o.timeoutlen = 300
        end,
        config = function()
            require("plugins.configs.whichkey")
        end,
    },

    -- error/warning diagnostics
    {
        "folke/trouble.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            require("plugins.configs.trouble")
        end
    },
    {
        "nvim-neotest/neotest",
        event = "VeryLazy",
        dependencies = {
            "nvim-neotest/nvim-nio",
            "nvim-lua/plenary.nvim",
            "nvim-treesitter/nvim-treesitter",
            "mrcjkb/rustaceanvim",
        },
        config = function() 
            require("plugins.configs.neotest")
        end
    },
    {
        "kevinhwang91/nvim-ufo",
        dependencies = {
            "kevinhwang91/promise-async"
        },
        config = function()
            require("plugins.configs.ufo")
        end
    },
    {
        "akinsho/toggleterm.nvim",
        config = function()
            require("plugins.configs.toggleterm")
        end,
    }
}
