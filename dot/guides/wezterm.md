# wezterm — the outer terminal (tabs, keys, two keyboards)

wezterm is the GUI terminal; **zellij runs inside it**. Two tab layers exist — keep
them straight:

- **wezterm tabs** = outer. One per context that isn't a zellij session: a local
  shell, an SSH'd remote (don't nest zellij — SSH lives in its own wezterm tab).
- **zellij tabs** = inner, within one session. Day-to-day tab work is here (`zjt`).

Rule of thumb: **CMD drives wezterm, Ctrl drives zellij.** zellij/nvim never see CMD
(wezterm intercepts it), so CMD bindings can't shadow a zellij mode-prefix or an nvim
map. Ctrl/Alt keys fall *through* to zellij — e.g. `Ctrl-t` is zellij's tab prefix,
not wezterm's.

## Two keyboards (laptop vs external PC)

macOS maps an external PC keyboard by key identity, not position:

```
PC Windows key  ->  Command (⌘ / SUPER)
PC Alt key      ->  Option  (⌥ / OPT)
```

So a CMD binding fires from **both** keyboards — the Windows key *is* Cmd. What trips
you up is position, not function: bottom row is `Ctrl|Win|Alt|Space` on the PC vs
`Ctrl|Opt|Cmd|Space` on the laptop, so ⌘ sits one key further right on the Mac.
(Assumes you haven't remapped modifiers in System Settings → Keyboard → Modifier Keys.)

## Tab keys (CMD = ⌘ = the PC Windows key)

Custom (in wezterm.lua):

```
⌘P            fuzzy tab switcher — type to filter, Enter to jump   (the zjt analog)
⌘E            rename the active tab (ESC cancels; empty = auto title)
⌘⇧← / ⌘⇧→     move/reorder the current tab left / right
```

Built-in defaults (no config):

```
⌘T            new tab                      ⌘W           close tab (confirms)
⌘1 … ⌘8       jump to tab 1–8              ⌘9           jump to last tab
⌘⇧[ / ⌘⇧]     previous / next tab          ⌃Tab / ⌃⇧Tab next / prev (also works)
⌃⇧P           command palette (all actions, fuzzy)
```

`⌘P` (custom switcher) vs `⌃⇧P` (palette): the switcher is tabs-only and faster for
jumping; the palette is everything wezterm can do. Rename tabs (`⌘E`) so both read well.

## Panes

Splitting/pane nav is left to zellij (the inner layer) on purpose — one set of split
muscle-memory, not two. Use wezterm panes only if you ever run without zellij.

## Other

```
⌥← / ⌥→       backward / forward one word (mapped to Alt-b / Alt-f for the shell)
```

Config: `wezterm/.config/wezterm/wezterm.lua`. Reloads live on save (no restart).
Inspect all active binds: `wezterm show-keys --lua`.
