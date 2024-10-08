local bufnr = vim.api.nvim_get_current_buf()
local function desc(description)
    return { noremap = true, silent = true, buffer = bufnr, desc = description }
end

vim.keymap.set('n', '<space>rdd', function()
    vim.cmd.RustLsp('debuggables')
end, desc('[r]ust: [dd]ebuggables'))
vim.keymap.set('n', '<space>rdl', function()
    vim.cmd.RustLsp { 'debuggables', bang = true }
end, desc('[r]ust: run [d]ebuggables [l]ast'))
vim.keymap.set('n', '<space>rr', function()
    vim.cmd.RustLsp('runnables')
end, desc('[r]ust: [r]unnables'))
vim.keymap.set('n', '<space>rl', function()
    vim.cmd.RustLsp { 'runnables', bang = true }
end, desc('[r]ust: [r]unnables [l]ast'))
vim.keymap.set('n', '<space>rtt', function()
    vim.cmd.RustLsp('testables')
end, desc('[r]ust: [t]es[t]ables'))
vim.keymap.set('n', '<space>rtl', function()
    vim.cmd.RustLsp { 'testables', bang = true }
end, desc('[r]ust: run [t]estables [l]ast'))
vim.keymap.set('n', '<space>rme', function()
    vim.cmd.RustLsp('expandMacro')
end, desc('[r]ust: [m]acro [e]xpand'))
vim.keymap.set('n', '<space>rk', function()
    vim.cmd.RustLsp { 'moveItem', 'up' }
end, desc('[r]ust: move item up [k]'))
vim.keymap.set('n', '<space>rj', function()
    vim.cmd.RustLsp { 'moveItem', 'down' }
end, desc('[r]ust: move item down [j]'))
vim.keymap.set('v', 'K', function()
    vim.cmd.RustLsp { 'hover', 'range' }
end, desc('rust: hover range'))
vim.keymap.set('n', '<space>re', function()
    vim.cmd.RustLsp('explainError')
end, desc('[r]ust: [e]xplain error'))
vim.keymap.set('n', '<space>rd', function()
    vim.cmd.RustLsp('renderDiagnostic')
end, desc('rust: [r]ender [d]iagnostic'))
vim.keymap.set('n', '<space>gc', function()
    vim.cmd.RustLsp('openCargo')
end, desc('rust: [g]o to [c]argo.toml'))
vim.keymap.set('n', '<space>gp', function()
    vim.cmd.RustLsp('parentModule')
end, desc('rust: [g]o to [p]arent module'))
vim.keymap.set('n', 'J', function()
    vim.cmd.RustLsp('joinLines')
end, desc('rust: join lines'))
vim.keymap.set('n', '<space>rs', function()
    vim.cmd.RustLsp('ssr')
end, desc('[r]ust: [s]sr'))


-- vim.g.rustaceanvim = {
--     server = {
--         default_settings = {
--             ['rust-analyzer'] = {
--                 cargo = {
--                     features = {"all"}
--                 }
--             },
--         }
--         -- settings = function(project_root)
--         --     local ra = require('rustaceanvim.config.server')
--         --     return ra.load_rust_analyzer_settings(project_root, {
--         --         settings_file_pattern = '.rust-analyzer.json'
--         --     })
--         -- end,
--     },
-- }
