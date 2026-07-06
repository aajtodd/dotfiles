
require("neo-tree").setup {
    sources = {
        "filesystem",
        "buffers",
        "git_status",
        "document_symbols",
    },
    filesystem = {
        filtered_items = {
            visible = true,
        },
        follow_current_file = {
            enabled = true
        },
    },
}


local utils = require("utils")

-- Toggle file browser
utils.nmap("<C-n>", "<cmd>Neotree toggle<CR>", "toggle Neotree")

-- Toggle LSP document symbols
local function document_symbols()
    vim.cmd('Neotree toggle document_symbols right')
end

vim.keymap.set('n', '<C-d>', document_symbols, { desc = 'neotree: [d]ocument [s]ymbols' })
vim.keymap.set('n', '<leader>r', "<cmd>Neotree reveal<CR>", { desc = 'neotree: [r]eveal file in tree' })
