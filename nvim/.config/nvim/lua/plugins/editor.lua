return {
    -- hilight/structural understanding
    {
        "nvim-treesitter/nvim-treesitter",
        config = function() 
          require("plugins.configs.treesitter")
        end,
    },

    -- fuzzy search
    {
      'nvim-telescope/telescope.nvim',
      tag = '0.1.5',
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
            -- manage external packages (e.g. language servers, debuggers, etc)
            "williamboman/mason.nvim",
            "williamboman/mason-lspconfig.nvim",
            "hrsh7th/cmp-nvim-lsp",
            -- LSP progress UI
            "j-hui/fidget.nvim",
        },
        config = function()
            require("plugins.configs.lsp")
        end
    },

    -- completion engine
    {
        "hrsh7th/nvim-cmp",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "hrsh7th/cmp-cmdline",
            "hrsh7th/cmp-nvim-lua",
            "onsails/lspkind.nvim",
            "saadparwaiz1/cmp_luasnip",
        },
        config = function()
            require("plugins.configs.cmp")
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
    },

    -- error/warning diagnostics
    {
        "folke/trouble.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            require("plugins.configs.trouble")
        end
    },

}
