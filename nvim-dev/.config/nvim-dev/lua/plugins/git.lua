-- Git stack (fugitive-free):
--   gitsigns  - gutter signs, hunk stage/reset/preview, line blame, index diff
--   neogit    - magit-style staging/commit/rebase/log UI
--   codediff  - side-by-side / multi-file diff viewer; neogit's diff backend
--   gitportal - two-way permalinks: current line -> host URL, and a pasted host
--               URL -> the matching local file+line
--
-- Blame is provided by gitsigns (who-wrote-this-line). Neogit does not do blame.
-- Namespaces: <leader>h = gitsigns hunks (buffer-local), <leader>g = neogit +
-- gitportal.
--
-- Getting out: `q` closes every pane in this stack; <Esc> also works almost
-- everywhere. Never need `:q`.
--   neogit (opens as a tab)      q / <Esc> / <C-c>   -> Close, back to your buffer
--   codediff (:CodeDiff, <leader>gd/gh)  q           -> closes the diff tab
--   codediff keymap help (g?)    q / <Esc>           -> closes the float
--   gitsigns blame/preview floats            no pane to exit -- move the cursor
--       (<C-w>w) or re-trigger the map to dismiss
-- Nuclear option if a pane is wedged (e.g. a merge view): `:tabclose` drops the
-- whole tab; codediff fires CodeDiffClose to clean up its virtual buffers.
--
-- Discovering keys in a pane: inside codediff press `g?` for its full cheatsheet
-- (explorer/history/conflict modes each have their own maps -- zc/zM folds, etc.).
-- Elsewhere, <leader>? (which-key, buffer-local) lists what's bound in the current
-- buffer; codediff's view maps are buffer-local with descriptions, so they show
-- up there too. To search by intent when you've forgotten a key, <leader>fk
-- (:Telescope keymaps).
return {
    -- Signs + hunk operations + blame. Keymaps live in the on_attach (configs/gitsigns).
    {
        "lewis6991/gitsigns.nvim",
        event = { "BufReadPre", "BufNewFile" },
        config = function()
            require("plugins.configs.gitsigns")
        end,
    },

    -- Magit-style git UI. Auto-detects the installed picker (telescope) and diff
    -- backend (codediff); both are listed as deps for load order.
    {
        "NeogitOrg/neogit",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-telescope/telescope.nvim",
            "esmuellert/codediff.nvim",
        },
        cmd = "Neogit",
        keys = {
            { "<leader>gg", "<cmd>Neogit<cr>",        desc = "neogit: status" },
            { "<leader>gc", "<cmd>Neogit commit<cr>", desc = "neogit: commit" },
            { "<leader>gl", "<cmd>Neogit log<cr>",    desc = "neogit: log" },
            { "<leader>gp", "<cmd>Neogit pull<cr>",   desc = "neogit: pull" },
            { "<leader>gP", "<cmd>Neogit push<cr>",   desc = "neogit: push" },
        },
        opts = {
            kind = "tab",
            graph_style = "unicode",
            diff_viewer = "codediff",
        },
    },

    -- Diff viewer. Fetches a prebuilt diff library on first use (no build step).
    -- Everything routes through the single :CodeDiff command (e.g. `:CodeDiff main`,
    -- `:CodeDiff history`, `:CodeDiff merge`).
    {
        "esmuellert/codediff.nvim",
        cmd = "CodeDiff",
        keys = {
            { "<leader>gd", "<cmd>CodeDiff<cr>",         desc = "codediff: working tree" },
            { "<leader>gh", "<cmd>CodeDiff history<cr>", desc = "codediff: file [h]istory" },
        },
        opts = {},
    },

    -- Two-way permalinks. Codeberg-hosted, so lazy needs the explicit url. to_remote
    -- and clip_remote honor the visual selection for a line range; from_remote reads
    -- a URL (arg or clipboard) and jumps to that file+line, switching branch if asked.
    {
        url = "https://codeberg.org/trevorhauter/gitportal.nvim",
        keys = {
            { "<leader>go", mode = { "n", "v" }, function() require("gitportal").to_remote() end,   desc = "gitportal: [o]pen line in browser" },
            { "<leader>gy", mode = { "n", "v" }, function() require("gitportal").clip_remote() end,  desc = "gitportal: [y]ank permalink" },
            { "<leader>gi", function() require("gitportal").from_remote() end,                       desc = "gitportal: [i]ngest URL into nvim" },
        },
        opts = {
            switch_branch_or_commit_upon_ingestion = "ask_first",
        },
    },
}
