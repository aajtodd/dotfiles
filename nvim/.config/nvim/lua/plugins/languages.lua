return {
    -- help for init.lua and plugin development
    {
        "folke/neodev.nvim",
        ft = "lua",
    },

    -- Go
    {
        "fatih/vim-go",
        -- only load for go files
        ft = "go",
    },
    {
      'mrcjkb/rustaceanvim',
      version = '^5',
      ft = { 'rust' },
      lazy = false,
    },
}
