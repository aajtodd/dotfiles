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

-- Start treesitter highlighting per buffer, keyed on filetype. pcall guards
-- filetypes whose name != parser name (and buffers with no installed parser),
-- so a miss is silent rather than an error. Registered BEFORE install() so a
-- failure there (e.g. the wrong branch is checked out and `install` is nil)
-- can't take the autocmd down with it -- highlighting still starts for any
-- parser already on disk. vim.treesitter.start is core Nvim, not branch-bound.
vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("TreesitterStart", { clear = true }),
    callback = function()
        pcall(vim.treesitter.start)
    end,
})

-- Install (or update) the parsers. Async; no-op for parsers already present.
-- `install` exists only on the `main` branch (pinned in the plugin spec); guard
-- so a stale `master` checkout degrades to "no auto-install" instead of erroring
-- out of this whole config (which would also skip the autocmd above if ordered
-- after it). Warn loudly enough to prompt a :Lazy update.
local ts = require("nvim-treesitter")
if type(ts.install) == "function" then
    ts.install(ensure)
else
    vim.notify(
        "nvim-treesitter: `install` missing -- expected the `main` branch. "
            .. "Run :Lazy update nvim-treesitter (the checkout is likely stale `master`).",
        vim.log.levels.WARN
    )
end
