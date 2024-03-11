local E = {}

function E.map(mode, shortcut, command)
  vim.api.nvim_set_keymap(mode, shortcut, command, { noremap = true, silent = true })
end

function E.nmap(shortcut, command)
  E.map('n', shortcut, command)
end

function E.imap(shortcut, command)
  E.map('i', shortcut, command)
end

return E
