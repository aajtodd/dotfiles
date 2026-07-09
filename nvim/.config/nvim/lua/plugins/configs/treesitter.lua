-- Parsers are installed imperatively via require("nvim-treesitter").install();
-- highlighting is enabled per-buffer with vim.treesitter.start() (see autocmd
-- below). Requires the nvim-treesitter `main` branch (pinned in the plugin spec).
local ensure = {
    "bash",
    "c",
    "cmake",
    "cpp",
    "css",
    "diff",
    "dockerfile",
    "gitignore",
    "go",
    "http",
    "json",
    "kotlin",
    "lua",
    "markdown",
    "python",
    "rust",
    "smithy",
    "sql",
    "toml",
    "yaml",
}

-- Install (or update) the parsers. Async; no-op for parsers already present.
require("nvim-treesitter").install(ensure)

-- Start treesitter highlighting per buffer, keyed on filetype. pcall guards
-- filetypes whose name != parser name (and buffers with no installed parser),
-- so a miss is silent rather than an error.
vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("TreesitterStart", { clear = true }),
    callback = function()
        pcall(vim.treesitter.start)
    end,
})
