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
