-- LSP is configured through Neovim's native vim.lsp.config/vim.lsp.enable API.
-- nvim-lspconfig supplies the per-server defaults (its lsp/<name>.lua files).
-- mason installs server binaries; mason-lspconfig auto-enables installed ones
-- (automatic_enable, default true, calls vim.lsp.enable()).

require("mason").setup()
require("mason-lspconfig").setup({
    -- servers to install via mason; auto-enabled once present
    ensure_installed = {
        "lua_ls",
        "pyright",
    },
})

-- Extra client capabilities merged into every server. blink.cmp advertises the
-- completion capabilities it supports; the dynamic-watched-files flag lets
-- servers register file watchers. Applied to all servers via the '*' config.
local capabilities = require("blink.cmp").get_lsp_capabilities()
capabilities.workspace = { didChangeWatchedFiles = { dynamicRegistration = true } }
vim.lsp.config("*", {
    capabilities = capabilities,
})

-- Servers whose binaries come from the system (not mason-installed), so they
-- aren't covered by automatic_enable and are enabled explicitly here.
vim.lsp.enable({
    "ts_ls",
    "gopls",
})



-- ---@param filter 'Function' | 'Module' | 'Struct'
-- local function filtered_document_symbol(filter)
--     vim.lsp.buf.document_symbol()
--     -- FIXME - this doesn't seem to work...
--     vim.cmd.Cfilter(('[[%s]]'):format(filter))
-- end

-- local function document_functions()
--     filtered_document_symbol('Function')
-- end
--
-- local function document_modules()
--     filtered_document_symbol('Module')
-- end
--
-- local function document_structs()
--     filtered_document_symbol('Struct')
-- end

local function on_lsp_attach(client, bufnr)
    local function desc(description)
        return { noremap = true, silent = true, buffer = bufnr, desc = description }
    end

    -- Enable completion triggered by <c-x><c-o>
    vim.bo[bufnr].omnifunc = 'v:lua.vim.lsp.omnifunc'

    -- Buffer local mappings.
    -- See `:help vim.lsp.*` for documentation on any of the below functions

    -- NOTE: Overridden by UFO to enable preview of folds OR LSP
    -- vim.keymap.set('n', 'K', vim.lsp.buf.hover, desc('lsp: symbol information'))
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, desc('lsp: go to [D]eclaration'))
    -- NOTE: We set these in telescope which has the same effect but handles when there are multiple choices
    -- vim.keymap.set('n', 'gd', vim.lsp.buf.definition, desc('lsp: go to [d]efinition'))
    -- vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, desc('lsp: go to [i]mplementation'))
    -- vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, desc('lsp: go to type [D]efinition'))
    vim.keymap.set('n', '<C-s>', vim.lsp.buf.signature_help, desc('lsp: signature help'))
    vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, desc('lsp: [w]orkspace folder [a]dd'))
    vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, desc('lsp: [w]orskdpace folder [r]emove'))
    vim.keymap.set('n', '<space>wl', function()
        print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, desc('lsp: [w]orkspace [l]ist folders'))
    vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, desc('lsp: [r]e[n]ame'))

    -- vim.keymap.set('n', '<space>df', document_functions, desc('lsp: [d]ocument [f]unctions'))
    -- vim.keymap.set('n', '<space>ds', document_structs, desc('lsp: [d]ocument [s]tructs'))
    -- vim.keymap.set('n', '<space>di', document_modules, desc('lsp: [d]ocument modules/[i]mports'))

    vim.keymap.set({ 'n', 'v' }, '<space>ca', vim.lsp.buf.code_action, desc('lsp: code action'))
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, desc('lsp: [g]et [r]eferences'))
    vim.keymap.set('n', '<space>f', function()
        vim.lsp.buf.format { async = true }
    end, desc('lsp: [f]ormat buffer'))
end


-- Use LspAttach autocommand to only map the following keys
-- after the language server attaches to the current buffer
vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('UserLspConfig', {}),
    callback = function(args)
        local bufnr = args.buf
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        on_lsp_attach(client, bufnr)

        -- configure debugger bindings
        require("plugins.configs.dap").on_dap_attach(bufnr)
    end,
})


