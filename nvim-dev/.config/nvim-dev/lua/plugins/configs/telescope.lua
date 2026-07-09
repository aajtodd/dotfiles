local builtin = require('telescope.builtin')
local telescope = require("telescope")
local telescopeConfig = require("telescope.config")


vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'telescope: [f]ind [f]iles' })
vim.keymap.set('n', '<C-p>', builtin.find_files, { desc = 'telescope: find files' })
vim.keymap.set('n', '<leader>fG', builtin.git_files, { desc = 'telescope: [f]ind [G]it files' })
vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'telescope: [f]ind live [g]rep' })
vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'telescope: [f]ind [b]uffers' })
vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'telescope: [f]ind [h]elp tags' })
-- Discoverability: fuzzy-search bindings by their description ("I know it exists,
-- forgot the key") and ex-commands. Answers what which-key's popup can't -- you
-- search by intent instead of needing to know the prefix.
vim.keymap.set('n', '<leader>fk', builtin.keymaps, { desc = 'telescope: [f]ind [k]eymaps' })
vim.keymap.set('n', '<leader>fc', builtin.commands, { desc = 'telescope: [f]ind [c]ommands' })

-- LSP jumps
vim.keymap.set('n', 'gd', builtin.lsp_definitions, { desc = 'lsp: [g]o to [d]efinition or open all options in telescope' })
vim.keymap.set('n', 'gi', builtin.lsp_implementations, { desc = 'lsp: [g]o to [i]mplementation or open all options in telescope' })
vim.keymap.set('n', '<space>D', builtin.lsp_type_definitions, { desc = 'lsp: [g]o to type [D]efinition or open all options in telescope' })
vim.keymap.set('n', '<leader>ds', builtin.lsp_document_symbols, { desc = 'lsp: list [d]ocument [s]ymbols' })
vim.keymap.set('n', '<leader>ws', builtin.lsp_workspace_symbols, { desc = 'lsp: list [w]ocument [s]ymbols' })

-- Open telescope if no files specified. Defer with vim.schedule so it runs
-- after the UI has finished initializing -- otherwise the picker opens
-- unfocused and you have to mash <esc> to dismiss it.
vim.api.nvim_create_autocmd({"VimEnter"}, {
    pattern = "*",
    callback = function()
        if vim.fn.argc() == 0 then
            vim.schedule(function()
                builtin.find_files()
            end)
        end
    end
})

-- 
-- Add hidden files to default search
-- 

-- Clone the default Telescope configuration
local vimgrep_arguments = { unpack(telescopeConfig.values.vimgrep_arguments) }

-- I want to search in hidden/dot files.
table.insert(vimgrep_arguments, "--hidden")
-- I don't want to search in the `.git` directory.
table.insert(vimgrep_arguments, "--glob")
table.insert(vimgrep_arguments, "!**/.git/*")

telescope.setup({
	defaults = {
		-- `hidden = true` is not supported in text grep commands.
		vimgrep_arguments = vimgrep_arguments,
	},
	pickers = {
		find_files = {
			-- `hidden = true` will still show the inside of `.git/` as it's not `.gitignore`d.
			find_command = { "rg", "--files", "--hidden", "--glob", "!**/.git/*" },
		},
	},
})
