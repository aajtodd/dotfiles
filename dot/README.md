# dot — personal reference

In-repo knowledge + runnable snippets, surfaced by the `dot` shell command.
Not stowed; resolved at runtime via `$DOTFILES`, so it travels with the repo
(including to remote boxes).

```
dot              index: guides, custom functions, snippet tags
dot <topic>      render a prose guide
dot -s <query>   full-text search guides, pick a hit, open it
dot run [query]  pick a navi snippet, fill its blanks, drop it on the prompt
```

## Layout

- `guides/*.md` — **prose**: how something works (concepts, models, gotchas).
  Read with `dot <topic>`; searched with `dot -s`.
- `cheats/*.cheat` — **navi snippets**: executable, parameterized commands you
  forget the exact syntax of. Run with `dot run`. `<var>` placeholders are filled
  interactively, optionally from live command output.
- Custom shell functions live in `../zsh/functions/*.zsh`, each carrying a
  `#@ name : description` line that `dot` lists automatically.

## The split

| You want to…                          | Put it in   | Reach it via |
|---------------------------------------|-------------|--------------|
| Explain/remember how a tool works     | `guides/`   | `dot <topic>` |
| Run a command you forget the syntax of| `cheats/`   | `dot run` |
| A short everyday shortcut             | a function  | `dot` lists it |

Single source of truth: a guide's `# title — tagline` and a function's `#@`
line are what `dot` indexes. Edit the thing; the index follows. No separate
doc to keep in sync.
