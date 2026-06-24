# bat — cat with syntax highlighting

`cat` is aliased to `bat --paging=never` (inline, pipe-safe). Theme Nord,
style `numbers,changes,header`. `MANPAGER` routes man pages through bat.

```
cat file.rs       highlighted inline (alias)
bat file.rs       highlighted, paged for long files
bat -p file       plain: no decorations (clean copy)
bat -A file       reveal whitespace / tabs / CRLF
bat f1 f2         multiple files with headers
git diff | bat    highlights piped diffs
```

```
bat --list-themes           available themes
BAT_THEME=ansi bat file     override theme for one call
```

Decorations auto-disable when output is not a terminal, so pipes stay clean.
