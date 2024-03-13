
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
    }
}

local utils = require("utils")
utils.nmap("<C-n>", "<cmd>Neotree toggle<CR>")
