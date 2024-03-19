local utils = require('utils')

-- true color support
vim.opt.termguicolors = true
vim.opt.background = dark

-- General options
vim.g.mapleader = ","
vim.opt.swapfile = false
vim.opt.bs = "indent,eol,start"

-- Enable line numbers
vim.opt.number = true

-- spaces instead of tabs
vim.opt.expandtab = true

-- Be smart when using tabs
vim.opt.smarttab = true

vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4

-- auto/smart indent
vim.opt.ai = true
vim.opt.si = true


-- casing/search
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- highlight search results
vim.opt.hlsearch = true

-- incremental search
vim.opt.incsearch = true

-- show command in last line of screen as it's typed
vim.opt.showcmd = true

-- Allow visual block mode to select outside bound of text (i.e. into whitespace)
vim.opt.virtualedit = "block"

-- (neovim) see substitutions real-time
vim.opt.inccommand = "split"

-- turn on folding
vim.opt.foldcolumn = "1"
vim.opt.foldmethod = "syntax"
vim.opt.foldnestmax = 10
vim.opt.foldenable = false
vim.opt.foldlevel = 2

-- colors and fonts
vim.opt.syntax = "on"
vim.opt.cursorline = true


-- moving around, tabs, windows and buffers
utils.nmap("<C-j>", "<C-W>j", "move to window below")
utils.nmap("<C-k>", "<C-W>k", "move to window above")
utils.nmap("<C-h>", "<C-W>h", "move to window left")
utils.nmap("<C-l>", "<C-W>l", "move to window right")

utils.nmap("<leader>tn", ":tabnew<cr>", "[t]ab [n]ew")
utils.nmap("<leader>to", ":tabonly<cr>", "[t]ab [o]nly")
utils.nmap("<leader>tc", ":tabclose<cr>", "[t]ab [c]lose")
utils.nmap("<leader>tm", ":tabmove", "[t]ab [m]ove")

-- disable hilight
utils.nmap("<leader><cr>", ":noh<cr>", "clear hilight")

-- return to last position when opening files
local lastplace = vim.api.nvim_create_augroup("LastPlace", {})
vim.api.nvim_create_autocmd("BufReadPost", {
    group = lastplace,
    pattern = { "*" },
    desc = "remember last cursor place",
    callback = function()
        local mark = vim.api.nvim_buf_get_mark(0, '"')
        local lcount = vim.api.nvim_buf_line_count(0)
        if mark[1] > 0 and mark[1] <= lcount then
            pcall(vim.api.nvim_win_set_cursor, 0, mark)
        end
    end,
})

-- save info about open buffers
vim.opt.shada = vim.opt.shada + "%"

-- native plugins
vim.cmd.packadd('cfilter')

