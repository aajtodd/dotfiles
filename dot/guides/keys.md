# keys — command-line editing (zsh)

Editing the line you're typing at the prompt. Switch modes anytime:

```
keymap          show current mode        keymap vi      vim motions
keymap emacs    modeless emacs keys
```

Choice persists in `~/.zsh_keymap`. Both modes keep `Ctrl-R` (fzf history),
`Ctrl-P` (fzf→nvim), and the emacs keys below work in *either* mode.

## Always works (both modes)

```
Ctrl-A / Ctrl-E    jump to start / end of line
Ctrl-U             kill from cursor to start of line
Ctrl-K             kill from cursor to end of line
Ctrl-W             delete the word before the cursor
Ctrl-Y            yank (paste) the last killed text
Ctrl-L             clear the screen
Ctrl-R             fuzzy history search (fzf)
Ctrl-C             abort the current line
Ctrl-D             EOF / exit shell on empty line
Ctrl-X Ctrl-E      edit the current command in nvim (write-quit runs it)
```

## emacs mode extras (modeless — keys act immediately)

```
Alt-B / Alt-F      move back / forward one word
Alt-D              delete the word after the cursor
Alt-Backspace      delete the word before the cursor
Ctrl-_             undo
Alt-.              insert last argument of previous command
```

## vi mode (ESC = normal, then vim motions)

The prompt character turns amber `❮` in normal mode, green `❯` in insert.

```
ESC                enter normal mode      i / a   back to insert (before/after)
0 / $              start / end of line    I / A   insert at line start / end
b / w              word back / forward    e       end of word
dd                 delete whole line      D       delete to end of line
dw / db            delete word fwd / back  cw     change word
ciw / diw          change / delete inner word
x                  delete char            r<c>    replace char with c
u                  undo                   .       repeat last change
v                  open the command in nvim (write-quit runs it)
```
