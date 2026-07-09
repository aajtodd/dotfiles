-- Completion engine. LSP/path/snippets/buffer sources and kind icons are
-- built in; snippet expansion is delegated to LuaSnip (see core.lua).
require("blink.cmp").setup({
    -- 'enter' preset: Enter accepts, C-n/C-p select, C-e hides. Each mapping runs
    -- its commands in order until one succeeds; 'fallback' defers to any existing
    -- or built-in binding. Tab confirms the current item; C-u/C-d scroll the docs.
    keymap = {
        preset = "enter",
        ["<Tab>"] = { "select_and_accept", "fallback" },
        ["<S-Tab>"] = { "select_prev", "fallback" },
        ["<C-u>"] = { "scroll_documentation_up", "fallback" },
        ["<C-d>"] = { "scroll_documentation_down", "fallback" },
    },

    snippets = { preset = "luasnip" },

    -- Nerd Font kind icons in the completion menu.
    appearance = { nerd_font_variant = "mono" },

    completion = {
        -- No preselection: <CR> accepts only an explicit selection, otherwise it
        -- inserts a newline.
        list = { selection = { preselect = false } },
        menu = { border = "rounded" },
        documentation = { auto_show = true, window = { border = "rounded" } },
    },

    -- lua_ls covers Neovim API completion when editing Lua, so no dedicated
    -- lua source is needed here.
    sources = {
        default = { "lsp", "path", "snippets", "buffer" },
    },

    -- Rust fuzzy matcher (prebuilt binary via version = '1.*'); fall back to the
    -- Lua implementation with a warning if the binary is unavailable.
    fuzzy = { implementation = "prefer_rust_with_warning" },
})
