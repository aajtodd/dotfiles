# Developing this repo

Notes for working *on* the dotfiles, as opposed to using them. Read when you're in
`~/.dotfiles` making changes. Runtime "how do I use tool X" recall lives in `dot`
(`dot <topic>`); repo state and in-flight work live in `bosun.md`.

## Config sandboxes (fork / collapse)

When a change to a config is large or risky — a plugin-stack rewrite, an LSP overhaul,
a new major version of the tool — don't edit the live config in place. Fork it into an
isolated sandbox, iterate until it's proven, then collapse the result back. The daily
config keeps working the whole time; git is the rollback either way.

The pattern is general, but the worked example is Neovim, where `NVIM_APPNAME` gives
first-class isolation. `nvim-dev` is a fork of `nvim`.

### Anatomy: the slot vs. the content

A sandbox is two separable things:

- **The slot** — the durable machinery that makes a fork possible: the launcher, the
  stow package name, the isolated runtime dirs, this doc. The slot is *permanent and
  reusable*. For nvim that's the `nvim-dev()` function (`zsh/functions/nvim.zsh`), the
  `NVIM_APPNAME=nvim-dev` convention, and the isolated `~/.local/{share,state,cache}/nvim-dev`
  dirs. The launcher no-ops gracefully to stock nvim when the content is absent, which
  is what lets the slot outlive any single experiment.
- **The content** — the actual config under test (`nvim-dev/.config/nvim-dev/`). The
  content is *ephemeral*: it exists only while an experiment is live, and is removed on
  collapse. We do **not** keep a standing tracked duplicate of the config between
  experiments — that just rots and diverges. Re-seeding next time is one `cp` + `stow`.

Corollary: **process docs never live in the content.** A `nvim-dev/README.md` would be
deleted on collapse, exactly when you'd next want to read it. Durable process (this
section) lives at the repo root.

### Lifecycle

```
FORK      Seed the content by copying the live package to the dev package, and rename
          the inner config dir to match the APPNAME. If the experiment needs a newer
          binary than the daily one, pin it (e.g. ~/opt/nvim-0.12) — the launcher
          prefers it and falls back to PATH, so the daily editor keeps its version.
   │        cp -R nvim/.config/nvim nvim-dev/.config/nvim-dev
   │        stow nvim-dev   # → ~/.config/nvim-dev
   │
ITERATE   Drive the sandbox on real work (`nvim-dev`). Let its isolated plugin tree +
          lock file install. Iterate until it fully verifies (for nvim: :checkhealth,
          LSP, treesitter, completion, and whatever the change touched).
   │
          FREEZE THE DAILY CONFIG while a fork is live. If you keep editing the live
          config in parallel, a long-lived fork turns collapse into a 3-way merge
          instead of a copy. Land daily fixes first, or fold them into the fork.
   │
COLLAPSE  Two modes:
          ├─ cherry-pick — a small vetted change. Copy just that diff from the dev
          │   package into the live package, re-stow. Keep iterating in the sandbox.
          └─ switchover — a wholesale rewrite. The dev content REPLACES the live
              content entirely (including lazy-lock.json, so the plugin set is
              reproducible). If it depends on a newer binary, bump the daily binary
              in the SAME commit — a config that needs 0.12 on a 0.11 daily editor is
              a broken editor. Verify the live editor after switchover, not just the
              sandbox.
   │
RESET     After a switchover, empty the slot for next time:
              git rm -r nvim-dev/                       # drop the tracked content
              rm -rf ~/.local/{share,state,cache}/nvim-dev   # wipe runtime state
              rm ~/.config/nvim-dev                     # remove the stow symlink
          The launcher, this doc, and the APPNAME convention stay. Next experiment
          re-forks from FORK above.
```

### Gotchas

- **Binary coupling is part of a switchover, not a follow-up.** Bump the tool version
  and swap the config together, or the daily tool breaks the moment you re-stow.
- **Switchover is replace, not merge.** A diverged rewrite isn't diffed into the live
  config; it supplants it. That's why freezing the daily config during ITERATE matters —
  it keeps "replace" honest.
- **Wipe runtime state on reset**, not just the tracked files. Stale
  `~/.local/share/<appname>` will silently reseed a new sandbox with old plugins.
- **The slot survives; don't delete the launcher or this doc.** Deleting the *content*
  is the whole point; deleting the *slot* means rebuilding the machinery next time.
