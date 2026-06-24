# fzf — fuzzy finder

File source is `fd` (`FZF_DEFAULT_COMMAND`): hidden files included, `.git`
excluded, .gitignore respected.

```
Ctrl-P          pick a file → open in nvim (zsh binding)
Ctrl-R          fuzzy history search
Ctrl-T          paste a chosen path onto the command line
Alt-C           cd into a chosen subdir
**<Tab>         completion trigger:  cd **<Tab>,  vim **<Tab>
```

Pipe any list in: `git branch | fzf`, `rg --files | fzf`.
