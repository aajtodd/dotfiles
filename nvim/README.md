# Neovim configuration


Dictionaries
------------

To setup dictionaries for Neovim that support unicode quotes (e.g. `you’re` 
rather than `you're`), download the `en_US` and `en_GB-large` dictionaries from 
[SCOWL](http://wordlist.aspell.net/dicts/), and then install them:

```
$ mkdir -p ~/.local/share/nvim/site/spell
$ cp en_GB-large.aff ~/.local/share/nvim/site/spell/en_GB.aff
$ cp en_GB-large.dic ~/.local/share/nvim/site/spell/en_GB.dic
$ cp en_US.* ~/.local/share/nvim/site/spell/
```

Then open Neovim in the `spell` directory and execute `:mkspell! en en_US 
en_GB` to build the Neovim dictionaries.


# TODO
- Include hidden files in telescope
- Finish setting up neo-tree more https://github.com/nvim-neo-tree/neo-tree.nvim
    * FIXME - colors aren't working
    * mapping for `:Neotree float git_status git_base=main`

- Figure out how to close lsp.buf.hover window with esc
    - https://vi.stackexchange.com/questions/37225/how-do-i-close-a-hovered-window-with-lsp-information-escape-does-not-work

- Finish nvim-lspconfig setup

- Look into lazygit over fugitive
- Look into nnn

- Investigate telescope more

- Additional plugins to consider:
    - https://github.com/ray-x/lsp_signature.nvim
    - https://github.com/tpope/vim-abolish
    - https://github.com/stevearc/oil.nvim
    - neotest
    - dap, dap ui
    - conform for formatting
    - https://github.com/mrjones2014/smart-splits.nvim
    - snippet engine: https://github.com/L3MON4D3/LuaSnip
    - better moving around?: https://github.com/ggandor/leap.nvim
    - Symbol navigation: https://github.com/stevearc/aerial.nvim
    - FIXME/TODO hilight: https://github.com/folke/todo-comments.nvim
    - Relative numbers with fixes: 'nkakouros-original/numbers.nvim',
    - git conflicts: https://github.com/rhysd/conflict-marker.vim
    - look at astrovim for inspiration

- Setup bootstrap
    [ ] Capture fonts and macos/terminal settings
        brew install font-jetbrains-mono-nerd-font
        https://github.com/ryanoasis/nerd-fonts
