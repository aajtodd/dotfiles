return {
    {
        "tpope/vim-fugitive",
        dependencies = {
            -- open in GH with :GBrowse
            "tpope/vim-rhubarb",
        },
    },
    {
        "kylechui/nvim-surround",
        event = "VeryLazy",
        config = function()
            require("nvim-surround").setup()
        end
    },
    -- Commenting (gcc / gc{motion} / gbc) is provided by built-in Neovim.
    {
        'andymass/vim-matchup',
    },
    {
        "L3MON4D3/LuaSnip",
        version = "v2.*",
        build = "make install_jsregexp",
        dependencies = {
            "rafamadriz/friendly-snippets",
        },
        config = function()
            require("luasnip.loaders.from_vscode").lazy_load()
            local ls = require("luasnip")
            vim.keymap.set({ "i" }, "<C-K>", function() ls.expand() end, { silent = true })
            vim.keymap.set({ "i", "s" }, "<C-L>", function() ls.jump(1) end, { silent = true })
            vim.keymap.set({ "i", "s" }, "<C-J>", function() ls.jump(-1) end, { silent = true })

            vim.keymap.set(
                { "i", "s" }, "<C-E>",
                function()
                    if ls.choice_active() then
                        ls.change_choice(1)
                    end
                end,
                { silent = true }
            )
        end
    },
    -- Label-based motion. `s` jumps (type chars to narrow, then a label), `S`
    -- selects a treesitter node, <c-s> toggles flash for the current `/` `?` search.
    --
    -- Two modes are OFF so the deepest-muscle-memory motions stay native. Each is
    -- a one-line flip to `enabled = true`; effect if enabled:
    --   modes.char (f/t/F/T): after `f{char}` flash labels EVERY match across the
    --     screen (not just the current line), so the 4th `x` is `fx<label>` in one
    --     shot instead of `fx;;;`. Trade: a label overlay + keystroke on every
    --     f/t, including the common "just the first hit" case.
    --   modes.search (/ ?): while typing a search, flash labels every on-screen
    --     match at once, so you jump to a specific one by label instead of
    --     Enter+n/n/n. Also lets ops target a match (d/foo<label>). Trade: labels
    --     overlay every search as you type. <c-s> already gives this per-search on
    --     demand, which is why the always-on mode stays off.
    {
        "folke/flash.nvim",
        event = "VeryLazy",
        ---@type Flash.Config
        opts = {
            modes = {
                search = { enabled = false },   -- `/` `?` stay native unless toggled
                char = { enabled = false },     -- f/t/F/T stay native motions
            },
        },
        keys = {
            { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash jump" },
            { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash treesitter" },
            { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle flash search" },
        },
    },
}
