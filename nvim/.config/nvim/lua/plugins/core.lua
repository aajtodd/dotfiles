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
}
