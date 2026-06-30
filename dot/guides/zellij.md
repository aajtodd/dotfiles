# zellij — sessions & workflow

Keybinds: press **F1** inside zellij (zellij-forgot reads the live config) rather
than memorizing them here — that stays correct as the config changes.

## Inside a session: open, jump, rename

```
zjo [dir]     open a dir in a NEW pane (-t tab, -f floating); no arg = picker
zjt [name]    jump to a tab by name (no arg = fzf-pick from live tabs)
zjr [name]    rename the focused tab (-p renames the focused pane)
```

`zjo` is the "go look at something" verb — picker = zoxide frecency ∪ children of
`$DOT_SRC`/`$DOT_3P`. `zjt`/`zjr` lean on named tabs, so name tabs as you go.

## Sessions (the `zj*` helpers + CLI)

```
zjs [dir]     sessionizer: pick a live SESSION or a dir; attach/create by name
zjl           list sessions (live + exited)
zjk           fzf-pick exited sessions to delete
zjclean       delete all exited sessions

zellij attach -c <name>    attach or create by name (what zjs wraps)
zellij ls                  list                   zellij kill-session <name>
```

`zjs` is dir-first but also lists live + exited sessions in the same picker: pick a
session to attach (resurrecting it if exited), or pick a dir to sessionize it. Names
come from the project dir, so they're meaningful and dedupe — re-pick the same dir
and you land in the same session, vs zellij's random adjective-animal names. Reach
for raw `zellij attach <name>` only when you already know the name.

## Resurrection

Exited sessions are serialized to disk and can be resurrected: `zjl` shows them
as EXITED, and attaching brings back the layout + a "press ENTER to run" prompt
per pane. Survives reboots; the live server already survives client disconnects.

## Remote (SSH)

Don't nest zellij. Run it only on the remote; `sshto <host>` opens a resumable
remote session (see `dot ssh`). The remote server survives SSH drops, so
reconnecting resumes the live session.

## Built-in session manager

`Ctrl-o w` (default) opens zellij's own session manager — switch, create, or
resurrect from inside a session. `dot run` (snippet: zellij) — pending.
