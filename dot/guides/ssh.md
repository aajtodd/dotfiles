# ssh — named hosts, remote sessions, file sync

## Named targets live in ~/.ssh/config

A `Host` alias is a real named target: `ssh`, `scp`, `rsync`, and the helpers
below all resolve it. A zsh alias can't do that. When a dev desk's hostname
changes, edit one line.

```
# ~/.ssh/config   (machine-local, not in dotfiles)
Host sshdev
    HostName dev-dsk-todaaron-1b-12bb1690.us-east-1.amazon.com
    User todaaron
```

Then `ssh sshdev`, `scp f sshdev:~/`, `rsync f sshdev:~/` all just work, and the
helpers offer `sshdev` in their pickers. Wildcard entries (`Host *`) are config
plumbing and are filtered out of pickers.

## Helpers

```
sshto [host] [flags] [name] [-- cmd]
    Connect. Default: attach/create a remote zellij session (survives drops),
    falling back to a login shell if the remote has no zellij.
      sshto                 fzf-pick a host
      sshto sshdev          zellij session 'main' on sshdev
      sshto sshdev work     session named 'work'
      sshto sshdev --bare   plain shell, no zellij
      sshto sshdev -- htop  run a command

sshput <file>... [host]     rsync local -> remote; fzf-pick host + remote dir
sshget [host:path | host]   rsync remote -> local (cwd); copies the local path
                            to the clipboard. No path given -> fzf-pick a file.
sshcp [host]                copy a remote path as host:/abs/path (fzf-pick)
```

## Why zellij on the remote (not nested locally)

Resumption requires the multiplexer to run on the remote: its server survives an
SSH drop, so `sshto` reconnects to the live session. Local zellij stays separate
(no nesting) — `sshto` runs in its own pane/tab. See the project notes for the
full rationale.

## Plain commands worth remembering

`dot run` (snippet: ssh) has the parameterized rsync/scp forms. Quick reference:

```
rsync -avzP src/ host:dst/        sync a dir, archive + compress + progress
rsync -avzP --dry-run src/ host:  preview without transferring
scp host:remote/file .            one-off copy from remote
ssh -t host 'zellij attach -c x'  manual resumable session
```
