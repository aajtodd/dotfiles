local R = {}
local dap = require('dap')
local dapui = require('dapui')
local dapvt = require('nvim-dap-virtual-text')
local widgets = require('dap.ui.widgets')


function R.setup()
    -- Virtual text
    vim.g.dap_virtual_text = true
    -- request variable values for all frames (experimental)
    vim.g.dap_virtual_text = 'all frames'

    -- dap

    dap.toggle_conditional_breakpoint = function()
        dap.toggle_breakpoint(vim.fn.input { prompt = 'Breakpoint condition: ' }, nil, nil, true)
    end

    dap.sidebar = widgets.sidebar(widgets.scopes)

    vim.fn.sign_define('DapBreakpoint', { text = '', texthl = '', linehl = '', numhl = '' })

    local commands = {
        {
            'DapContinue',
            dap.continue,
            {},
        },
        {
            'DapBreakpoints',
            dap.list_breakpoints,
            {},
        },
        -- {
        --   'DapSidebar',
        --   function()
        --     require('dap-setup').sidebar.toggle()
        --   end,
        --   {},
        -- },
    }
    for _, command in ipairs(commands) do
        vim.api.nvim_create_user_command(unpack(command))
    end

    -- dap.defaults.fallback.external_terminal = {
    --   command = 'alacritty',
    --   args = { '-e' },
    -- }
    dapui.setup()
    dapvt.setup {}
end

function R.on_dap_attach(bufnr)
    local function desc(description)
        return { noremap = true, silent = true, buffer = bufnr, desc = description }
    end

    vim.keymap.set('n', '<leader>dS', dap.stop, desc('[d]ap: [S]top'))

    -- FIXME - remap to F<N>
    vim.keymap.set('n', '<Up>', dap.step_out, desc('dap: step out'))
    vim.keymap.set('n', '<Down>', dap.step_into, desc('dap: step into'))
    vim.keymap.set('n', '<Right>', dap.step_over, desc('dap: step over'))
    vim.keymap.set('n', '<space>dC', dap.continue, desc('[d]ap: [C]ontinue'))
    vim.keymap.set('n', '<leader>b', dap.toggle_breakpoint, desc('dap: toggle [b]reakpoint'))
    -- vim.keymap.set('n', '<leader>B', dap.toggle_conditional_breakpoint, opts) -- FIXME
    vim.keymap.set('n', '<leader>dr', function()
        dap.repl.toggle { height = 15 }
    end, desc('[d]ap: toggl [r]epl'))
    vim.keymap.set('n', '<leader>dl', dap.run_last, desc('[d]ap: run [l]ast debug session'))
    vim.keymap.set('n', '<leader>dS', function()
        widgets.centered_float(widgets.frames)
    end, desc('[d]ap: centered floating widget (frames) [S]'))
    vim.keymap.set('n', '<leader>ds', function()
        widgets.centered_float(widgets.scopes)
    end, desc('[d]ap: centered floating widget ([s]copes)'))
    vim.keymap.set('n', '<leader>dh', widgets.hover, desc('[d]ap: [h]over'))
    vim.keymap.set('v', '<leader>dh', function()
        widgets.hover(dap_utils.get_visual_selection_text)
    end, desc('[d]ap: [h]over'))
    vim.keymap.set('v', '<leader>de', dapui.eval, desc('[d]ap: [e]valuate'))
    vim.keymap.set('v', '<M-k>', dapui.float_element, desc('dap: show element in floating window'))
    vim.keymap.set('n', '<leader>du', dapui.toggle, desc('[d]ap: toggle [u]i'))
end

return R
