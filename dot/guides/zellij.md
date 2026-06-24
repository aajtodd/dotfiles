# zellij — sessions & workflow

Keybinds: press **F1** inside zellij (zellij-forgot reads the live config) rather
than memorizing them here — that stays correct as the config changes.

## Sessions (the `zj*` helpers + CLI)

```
zjs [dir]     attach/create a session NAMED for a dir (fzf-pick if no arg)
zjl           list sessions (live + exited)
zjk           fzf-pick exited sessions to delete
zjclean       delete all exited sessions

zellij attach -c <name>    attach or create by name (what zjs wraps)
zellij ls                  list                   zellij kill-session <name>
```

Name sessions after their project (what `zjs` does) so they're meaningful and
dedupe — otherwise zellij assigns random adjective-animal names and they pile up.

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
