return {
    {
      'nvim-telescope/telescope.nvim',
      tag = '0.1.5',
      dependencies = { 'nvim-lua/plenary.nvim' },
      config = function()
          local builtin = require('telescope.builtin')
          vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
          vim.keymap.set('n', '<C-p>', builtin.find_files, {})
          vim.keymap.set('n', '<leader>fG', builtin.git_files, {})
          vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
          vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
          vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})

            -- Open telescope if no files specified
            vim.api.nvim_create_autocmd({"vimenter"}, {
                pattern = "*",
                callback = function()
                    if vim.fn.argc() == 0 then
                        vim.cmd('Telescope find_files')
                    end
                end
            })

      end
    },
}
