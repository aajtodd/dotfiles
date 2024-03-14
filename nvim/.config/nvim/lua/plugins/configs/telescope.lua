local builtin = require('telescope.builtin')

vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'telescope: [f]ind [f]iles' })
vim.keymap.set('n', '<C-p>', builtin.find_files, { desc = 'telescope: find files' })
vim.keymap.set('n', '<leader>fG', builtin.git_files, { desc = 'telescope: [f]ind [G]it files' })
vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'telescope: [f]ind live [g]rep' })
vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'telescope: [f]ind [b]uffers' })
vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'telescope: [f]ind [h]elp tags' })

-- Open telescope if no files specified
vim.api.nvim_create_autocmd({"vimenter"}, {
    pattern = "*",
    callback = function()
        if vim.fn.argc() == 0 then
            vim.cmd('Telescope find_files')
        end
    end
})

require('telescope').setup()
