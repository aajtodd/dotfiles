-- which-key answers "I pressed a prefix, now what?" -- but only for maps that
-- carry a desc, and only once you know the prefix. Two things make it useful:
--   1. group labels (below) turn the raw prefix popup into a labelled menu.
--   2. <leader>? shows every mapping available in the current buffer on demand,
--      which is the "what can I do here" entry point.
-- For "I know it exists but forgot the key", search by intent with
-- <leader>fk (:Telescope keymaps) -- which-key's popup isn't searchable.
local wk = require("which-key")

wk.setup({})

-- Prefix group labels. Keys mirror the namespaces actually in use:
--   f find/telescope   g git   h gitsigns hunks   d diagnostics+dap
--   n neotest   t tabs   x trouble   w lsp workspace
wk.add({
    { "<leader>f", group = "find" },
    { "<leader>g", group = "git" },
    { "<leader>h", group = "hunk (gitsigns)" },
    { "<leader>d", group = "diagnostics / dap" },
    { "<leader>n", group = "neotest" },
    { "<leader>t", group = "tab" },
    { "<leader>x", group = "trouble" },
    { "<leader>w", group = "lsp workspace" },
})

-- On-demand "what's available in this buffer" -- includes buffer-local maps
-- (LSP, gitsigns) that only exist once a server/plugin attaches.
vim.keymap.set("n", "<leader>?", function()
    wk.show({ global = false })
end, { desc = "which-key: buffer-local keymaps" })
