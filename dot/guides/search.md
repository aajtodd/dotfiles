# search — ripgrep (rg) + fd

Not aliased to grep/find: different regex, recursion, and flag semantics. Invoke
by name.

```
rg pattern               recursive, respects .gitignore, colorized
rg -i pattern            case-insensitive
rg -t rust pattern       restrict to a type (-t py, -t js, …)
rg -l pattern            filenames only
rg -F 'literal'          fixed-string, no regex
rg pattern -g '!*.lock'  exclude a glob
```

```
fd pattern               name search, respects .gitignore
fd -e rs                 by extension
fd -H pattern            include hidden
fd -t d pattern          dirs only (-t f = files)
fd pattern -x cmd {}     run cmd per result
```
