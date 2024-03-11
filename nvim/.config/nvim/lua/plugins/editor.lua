return {
    "folke/neodev.nvim",

    {
        "nvim-treesitter/nvim-treesitter",
        opts = {
            ensure_installed = {
                "cmake",
                "c",
                "css",
                "diff",
                "fish",
                "bash",
                "gitignore",
                "go",
                "http",
                "json",
                "markdown",
                "rust",
                "smithy",
                "sql",
                "python",
                "kotlin"
            }
        }
    }

}
