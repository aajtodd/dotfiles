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
      version = '^9',        -- v9 requires nvim >= 0.12
      ft = { 'rust' },
      lazy = false,
    },
}
