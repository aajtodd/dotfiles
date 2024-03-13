return {
    -- help for init.lua and plugin development
    {
        "folke/neodev.nvim",
    },

    -- Go
    {
        "fatih/vim-go",
        -- only load for go files
        ft = "go",
    },
    {
      'mrcjkb/rustaceanvim',
      version = '^4',
      ft = { 'rust' },
    },
}
