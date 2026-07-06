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

## Config sandbox (testing config changes in isolation)

`NVIM_APPNAME` makes nvim read an entirely separate set of dirs, so a second config
lives beside the daily one:

```
                config               data / plugins           state       cache        binary
default nvim    ~/.config/nvim       ~/.local/share/nvim      …/state/nvim …/cache/nvim brew / tarball (0.11)
nvim-dev        ~/.config/nvim-dev   ~/.local/share/nvim-dev  …/nvim-dev   …/nvim-dev   ~/opt/nvim-0.12 (if present)
```

`NVIM_APPNAME` isolates *config*, not the *binary*. To test config needing a newer
Neovim, `nvim-dev` prefers a separate pinned build (`~/opt/nvim-0.12/bin/nvim`) and
falls back to whatever `nvim` is on PATH — so the daily editor keeps its own version.

`nvim-dev` (a shell function, `dot` group "nvim") launches the sandbox:

```
nvim-dev [files…]     run nvim against ~/.config/nvim-dev (isolated plugins + lazy-lock)
nvim                  your untouched daily editor
```

`nvim-dev` is a STANDING sandbox — a permanent place to try a plugin swap, an LSP
rewrite, or a risky setting with zero risk to the working setup, since it has its own
plugin tree and lock file. If `~/.config/nvim-dev` doesn't exist yet, `nvim-dev` just
starts stock nvim (harmless).

**Workflow:**
1. Seed the sandbox: `nvim-dev/` is a stow package → `~/.config/nvim-dev`. Stow it,
   open `nvim-dev`, let lazy install into the isolated dir.
2. Iterate there until `:checkhealth`, LSP, treesitter, completion all verify.
3. **Promote a vetted change:** copy it from `nvim-dev/` into `nvim/`, re-stow; the
   daily `nvim` picks it up. Keep `nvim-dev` around for the next experiment. (Git is
   the rollback either way.)

Wipe the sandbox to retest a clean install:
`rm -rf ~/.local/{share,state,cache}/nvim-dev`
