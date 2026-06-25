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
sshto [host] [-- cmd]       connect (fzf-pick host if no arg); login shell
      sshto                 fzf-pick a host
      sshto sshdev          connect to sshdev
      sshto sshdev -- htop  run a one-off command instead of a shell

sshput <file>... [host]     rsync local -> remote; fzf-pick host + remote dir
sshget [host:path | host]   rsync remote -> local (cwd); copies the local path
                            to the clipboard. No path given -> fzf-pick a file.
sshcp [host]                copy a remote path as host:/abs/path (fzf-pick)
```

## zellij on the remote

`sshto` just connects — it does NOT launch zellij. Once on the remote (with these
dotfiles deployed), use the sessionizer there: `zjs` to attach/create a named
session. Keeping ssh and zellij separate avoids baking multiplexer assumptions
into the connect path, and the remote's own login shell resolves zellij's path.

For resumption: a zellij session's server survives an SSH drop, so reconnecting
and `zjs`/`zellij attach -c <name>` returns you to the live session. Don't nest a
local zellij — connect in a separate tab/window.

## Plain commands worth remembering

`dot run` (snippet: ssh) has the parameterized rsync/scp forms. Quick reference:

```
rsync -avzP src/ host:dst/        sync a dir, archive + compress + progress
rsync -avzP --dry-run src/ host:  preview without transferring
scp host:remote/file .            one-off copy from remote
ssh -t host 'zellij attach -c x'  manual resumable session
```
