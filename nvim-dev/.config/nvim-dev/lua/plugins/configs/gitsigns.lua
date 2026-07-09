-- Gutter signs plus per-hunk stage/reset/preview, line blame, and buffer-vs-index
-- diff. Keymaps are buffer-local, bound only where gitsigns attaches (a git repo),
-- under <leader>h ("hunk"). Line blame is off by default; <leader>hB toggles the
-- inline virtual-text annotation.
require("gitsigns").setup {
    on_attach = function(bufnr)
        local gs = require("gitsigns")
        local function map(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
        end

        -- Hunk navigation. In diff mode ]c/[c are Vim's own change motions, so
        -- defer to them there and only drive gitsigns in a normal buffer.
        map("n", "]c", function()
            if vim.wo.diff then return "]c" end
            vim.schedule(function() gs.nav_hunk("next") end)
            return "<Ignore>"
        end, "gitsigns: next hunk")
        map("n", "[c", function()
            if vim.wo.diff then return "[c" end
            vim.schedule(function() gs.nav_hunk("prev") end)
            return "<Ignore>"
        end, "gitsigns: prev hunk")

        -- Stage/reset. stage_hunk toggles staged state; visual mode acts on the
        -- selected line range only.
        map("n", "<leader>hs", gs.stage_hunk, "gitsigns: [s]tage hunk")
        map("n", "<leader>hr", gs.reset_hunk, "gitsigns: [r]eset hunk")
        map("v", "<leader>hs", function() gs.stage_hunk { vim.fn.line("."), vim.fn.line("v") } end, "gitsigns: [s]tage selection")
        map("v", "<leader>hr", function() gs.reset_hunk { vim.fn.line("."), vim.fn.line("v") } end, "gitsigns: [r]eset selection")
        map("n", "<leader>hS", gs.stage_buffer, "gitsigns: [S]tage buffer")
        map("n", "<leader>hR", gs.reset_buffer, "gitsigns: [R]eset buffer")
        map("n", "<leader>hu", gs.undo_stage_hunk, "gitsigns: [u]ndo stage hunk")

        -- Inspect.
        map("n", "<leader>hp", gs.preview_hunk, "gitsigns: [p]review hunk")
        map("n", "<leader>hb", function() gs.blame_line { full = true } end, "gitsigns: [b]lame line")
        map("n", "<leader>hB", gs.toggle_current_line_blame, "gitsigns: toggle inline [B]lame")
        map("n", "<leader>hd", gs.diffthis, "gitsigns: [d]iff against index")

        -- Text object: operate on the current hunk (e.g. `vih`, `dih`).
        map({ "o", "x" }, "ih", gs.select_hunk, "gitsigns: select hunk")
    end,
}
