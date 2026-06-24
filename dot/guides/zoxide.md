# zoxide — smart cd ranked by frecency

Tracks visited dirs (frequency × recency); jump by substring of any path seen
before. Database is per-user, populated only by dirs entered while active.

```
z <substr>      cd to highest-ranked match           z dotfiles → ~/.dotfiles
z <a> <b>       multiple terms; last matches tail     z rs ops  → …/rs/ops
z               home                                  z -       previous dir
z ..            up one (delegates to cd)
zi <substr>     interactive fzf picker of matches
zi              browse the whole database in fzf
```

`z <arg>` resolves to a real path if one exists, else the top DB match — a
superset of `cd`.

```
zoxide query -l         list dirs            zoxide query -s   list with scores
zoxide remove <path>    drop a stale entry
```
