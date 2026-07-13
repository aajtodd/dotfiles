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

-- colors and fonts
vim.opt.syntax = "on"
vim.opt.cursorline = true

vim.opt.colorcolumn = "120"

-- moving around, tabs, windows and buffers
utils.nmap("<C-j>", "<C-W>j", "move to window below")
utils.nmap("<C-k>", "<C-W>k", "move to window above")
utils.nmap("<C-h>", "<C-W>h", "move to window left")
utils.nmap("<C-l>", "<C-W>l", "move to window right")

utils.nmap("<leader>tn", ":tabnew<cr>", "[t]ab [n]ew")
utils.nmap("<leader>to", ":tabonly<cr>", "[t]ab [o]nly")
utils.nmap("<leader>tc", ":tabclose<cr>", "[t]ab [c]lose")
utils.nmap("<leader>tm", ":tabmove", "[t]ab [m]ove")

vim.opt.splitbelow = true
vim.opt.splitright = true

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

-- Clipboard: remote boxes (e.g. AL2023 dev desks) have no pbcopy/xclip/wl-copy
-- and no display, so the only thing that reaches the local clipboard is OSC52.
-- Neovim 0.10+ ships an OSC52 provider; point the + and * registers at it when
-- no native clipboard tool is reachable. On macOS (or any host with a real
-- clipboard binary + display) leave the default provider in place.
--
-- Gating on tool availability rather than $SSH_TTY is deliberate: inside a
-- detached/persisted zellij (or tmux/mosh) session, SSH_TTY is stale or empty
-- because the multiplexer is parented to systemd, not sshd. A stale SSH_TTY
-- meant this block never ran, and nvim 0.12's built-in OSC52 provider then did
-- a blocking paste-time terminal query ("Waiting for OSC 52 response...").
local function native_clipboard_available()
    if vim.fn.has('mac') == 1 then
        return true
    end
    if vim.env.WAYLAND_DISPLAY and vim.fn.executable('wl-copy') == 1 then
        return true
    end
    if vim.env.DISPLAY and (vim.fn.executable('xclip') == 1 or vim.fn.executable('xsel') == 1) then
        return true
    end
    return false
end

if not native_clipboard_available() then
    local osc52 = require('vim.ui.clipboard.osc52')
    vim.g.clipboard = {
        name = 'OSC 52',
        copy = {
            ['+'] = osc52.copy('+'),
            ['*'] = osc52.copy('*'),
        },
        paste = {
            -- OSC52 paste is poorly supported by terminals; fall back to the
            -- internal register so pasting still works within nvim.
            ['+'] = function() return { vim.fn.split(vim.fn.getreg(''), '\n'), vim.fn.getregtype('') } end,
            ['*'] = function() return { vim.fn.split(vim.fn.getreg(''), '\n'), vim.fn.getregtype('') } end,
        },
    }
end

-- native plugins
vim.cmd.packadd('cfilter')

