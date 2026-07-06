local function desc(description)
  return { noremap = true, silent = true, desc = description }
end

local neotest = require('neotest')

---Neotest is quite heavy on startup, so this initializes it lazily, on keymap
neotest.setup {
  adapters = {
    require('rustaceanvim.neotest'),
  },
  discovery = {
    enabled = true,
  },
  icons = {
    failed = '',
    passed = '',
    running = '',
    skipped = '',
    unknown = '',
  },
  quickfix = {
    enabled = false,
    open = false,
  },
}

vim.keymap.set('n', '<leader>nr', neotest.run.run, desc('[n]eotest: [r]un nearest'))

vim.keymap.set('n', '<leader>nf', function()
  neotest.run.run(vim.api.nvim_buf_get_name(0))
end, desc('[n]eotest: run [f]ile'))

vim.keymap.set('n', '<leader>nw', function()
  neotest.watch.toggle(vim.api.nvim_buf_get_name(0))
end, desc('[n]eotest: [w]atch file'))

vim.keymap.set('n', '<leader>no', neotest.output.open, desc('[n]eotest: open [o]utput'))

vim.keymap.set('n', '<leader>np', neotest.output_panel.open, desc('[n]eotest: open output [p]anel'))

vim.keymap.set('n', '<leader>ns', neotest.summary.toggle, desc('[n]eotest: toggle [s]ummary'))
