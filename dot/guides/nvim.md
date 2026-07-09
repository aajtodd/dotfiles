# nvim — notable keymaps

Leader is `,`. This lists the keys worth memorizing; for the full live set press
`,` and wait (which-key shows what's bound), or `,fh` → search help.

## Find (telescope)

```
Ctrl-P / ,ff     find files          ,fg     live grep (search contents)
,fG              find git files      ,fb     open buffers
,fh              help tags
```

## LSP / code

```
gd               go to definition (telescope picker)
gi               go to implementation        gD    go to declaration
gr               references                  <space>D   type definition
,ds              document symbols            ,ws   workspace symbols
<space>rn        rename symbol               <space>ca  code action
<space>f         format buffer
```

## Windows & tabs

```
Ctrl-h/j/k/l     move between splits (left/down/up/right)
,tn / ,to        tab new / tab only
,tc / ,tm        tab close / tab move
,<CR>            clear search highlight
```

## Files & UI

```
Ctrl-N           Neo-tree toggle      (,r reveals current file in tree)
s                leap (jump to location)
```

## Editing (plugins)

```
gc / gcc         comment (Comment.nvim) — motion / current line
cs"' ds" ys      surround (nvim-surround): change/delete/add
Ctrl-K           snippet expand (LuaSnip)   Ctrl-L/Ctrl-J  jump fwd/back
```

Live source of truth: `,` (which-key) and `:Telescope keymaps`. After a fresh
install run `:MasonInstall codelldb pyright`.

## Config sandbox

`nvim-dev` launches an isolated fork of the config (via `NVIM_APPNAME`) for testing
risky changes with zero risk to the daily editor:

```
nvim-dev [files…]     run against ~/.config/nvim-dev (own plugins + lazy-lock)
nvim                  your untouched daily editor
```

`NVIM_APPNAME` isolates *config*, not the *binary*: `nvim-dev` prefers a pinned build
(`~/opt/nvim-0.12/bin/nvim`) if present and falls back to PATH, so the daily editor keeps
its own version. Absent a `~/.config/nvim-dev`, `nvim-dev` just starts stock nvim.

The fork → iterate → collapse → reset lifecycle (and its gotchas) is a repo-development
concern, not everyday usage — see `DEVELOPMENT.md` at the dotfiles root.
