
require("mason").setup()
require("mason-lspconfig").setup({
    ensure_installed = { "lua_ls", "pyright" }
})

local lspconfig = require("lspconfig")

local capabilities = require("cmp_nvim_lsp").default_capabilities()

lspconfig.lua_ls.setup {
    capabilities = capabilities
}

lspconfig.pyright.setup {
    capabilities = capabilities
}

lspconfig.tsserver.setup {}
lspconfig.pyright.setup {}
lspconfig.gopls.setup {}
