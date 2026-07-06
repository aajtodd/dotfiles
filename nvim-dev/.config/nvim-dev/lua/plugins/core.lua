return {
    {
        "tpope/vim-fugitive",
        dependencies = {
            -- open in GH with :GBrowse
            "tpope/vim-rhubarb",
        },
    },
    {
        "kylechui/nvim-surround",
        event = "VeryLazy",
        config = function()
            require("nvim-surround").setup()
        end
    },
    {
        "numToStr/Comment.nvim",
        config = function()
            require("Comment").setup()
        end
    },
    {
        'andymass/vim-matchup',
    },
    {
        "L3MON4D3/LuaSnip",
        version = "v2.*",
        build = "make install_jsregexp",
        dependencies = {
            "rafamadriz/friendly-snippets",
        },
        config = function()
            require("luasnip.loaders.from_vscode").lazy_load()
            local ls = require("luasnip")
            vim.keymap.set({ "i" }, "<C-K>", function() ls.expand() end, { silent = true })
            vim.keymap.set({ "i", "s" }, "<C-L>", function() ls.jump(1) end, { silent = true })
            vim.keymap.set({ "i", "s" }, "<C-J>", function() ls.jump(-1) end, { silent = true })

            vim.keymap.set(
                { "i", "s" }, "<C-E>",
                function()
                    if ls.choice_active() then
                        ls.change_choice(1)
                    end
                end,
                { silent = true }
            )
        end
    },
    {
        "ggandor/leap.nvim",
        dependencies = {
            "tpope/vim-repeat"
        },
        config = function()
            local leap = require("leap")
            leap.opts.equivalence_classes = { ' \t\r\n', '([{', ')]}', '\'"`' }
            leap.add_default_mappings(true)
            -- vim.keymap.del({ "x", "o" }, "x")
            -- vim.keymap.del({ "x", "o" }, "X")
            vim.keymap.set("n", "s", function()
                require("leap").leap({ target_windows = { vim.api.nvim_get_current_win() } })
            end, { desc = "[s]earch with leap"} )
        end
    }
}
