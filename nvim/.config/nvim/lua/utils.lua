local E = {}

function E.map(mode, shortcut, command, description)
  vim.api.nvim_set_keymap(mode, shortcut, command, { noremap = true, silent = true, desc = description })
end

function E.nmap(shortcut, command, description)
  E.map('n', shortcut, command, description)
end

function E.imap(shortcut, command, description)
  E.map('i', shortcut, command, description)
end

return E
