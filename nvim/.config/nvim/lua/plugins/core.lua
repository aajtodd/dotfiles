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
        config = function() 
            local ls = require("luasnip")
            vim.keymap.set({"i"}, "<C-K>", function() ls.expand() end, {silent = true})
            vim.keymap.set({"i", "s"}, "<C-L>", function() ls.jump( 1) end, {silent = true})
            vim.keymap.set({"i", "s"}, "<C-J>", function() ls.jump(-1) end, {silent = true})

            vim.keymap.set(
                {"i", "s"}, "<C-E>",
                function()
                    if ls.choice_active() then
                        ls.change_choice(1)
                    end
                end, 
                {silent = true}
            )
        end
    }
}
