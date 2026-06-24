# aliases — profile, clipboard, brazil

`ls` and `grep` are colorized (GNU `--color=auto` or BSD `CLICOLOR`, auto-detected).
`~/.zshrc_custom` is sourced if present for machine-local overrides.

**AWS profile**
```
asp <profile>    set AWS_PROFILE        acp    clear AWS_PROFILE
```

**Clipboard** (native pbcopy, or OSC52 over SSH via zellij/WezTerm)
```
echo text | pbcopy      copy to system clipboard
pbpaste                 paste (best-effort over OSC52)
```

**Brazil** (no-op where brazil is absent)
```
bb     brazil-build                 bws       brazil ws
bba    brazil-build apollo-pkg      bwsuse    bws use -p
bre    brazil-runtime-exec          bwscreate bws create -n
brc    brazil-recursive-cmd         bbr       brc brazil-build
bball  brc --allPackages            bbb       brc --allPackages brazil-build
bbra   bbr apollo-pkg
```
