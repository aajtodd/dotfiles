# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Repo Is

Personal dotfiles managed with **GNU Stow**. Each top-level directory (e.g., `nvim/`, `zsh/`, `tmux/`, `wezterm/`) is a Stow package. Running `stow <package>` from `~/.dotfiles` creates symlinks in `~` that mirror the package's internal directory structure.

## Installing / Applying Changes

```sh
# Install all packages at once
stow nvim zsh wezterm zellij starship tmux bin

# Install a single package
stow nvim

# Re-stow after adding files to a package
stow --restow nvim

# Preview what stow would do (dry-run)
stow -n --verbose nvim
```

Bootstrap scripts exist for initial machine setup:
- `bootstrap-macos.sh` — Homebrew-based, installs Neovim, tmux, zellij, fzf, ripgrep, Go, Rust, starship, fnm, WezTerm
- `bootstrap-al2023.sh` — Amazon Linux 2023 (dnf). The internal AL2023 repos only carry build tooling + `rust`/`cargo`, so `ripgrep`/`fd` come via `cargo install`, `fzf` via git clone, `stow` from the GNU source tarball, Neovim/Go from release tarballs, and zellij from a prebuilt musl binary into `~/.local/bin`. Arch-aware (x86_64/aarch64). Note it sources `~/.cargo/env` mid-script so `cargo` is on PATH after rustup.
- `bootstrap-al2.sh` — legacy Amazon Linux 2 (yum). Superseded by the al2023 script.

## Architecture

### Stow Package Layout

Each package mirrors the target directory structure relative to `~`:
- `zsh/.zshrc` → `~/.zshrc`
- `nvim/.config/nvim/` → `~/.config/nvim/`
- `tmux/.tmux.conf` → `~/.tmux.conf`
- `zellij/.config/zellij/` → `~/.config/zellij/`
- `bin/opt/bin/` → `~/opt/bin/` (personal scripts; `~/opt/bin` is on PATH via `.zshrc`)
- `wezterm/.config/wezterm/` → `~/.config/wezterm/`

### Zsh (`zsh/`)

The config is **OS-agnostic** — one `.zshrc`/`.zprofile` works on both macOS and AL2023. Anything machine-specific is wrapped in an existence guard (`command -v` / `[ -x ... ]`) so missing tools degrade silently instead of erroring.

`.zprofile` (login shell) sets env that should exist before the interactive shell: `GOPATH`, Rust `RUST_SRC_PATH`, and Amazon vars (`BRAZIL_WORKSPACE_DEFAULT_LAYOUT`, `AWS_EC2_METADATA_DISABLED`).

`.zshrc` (interactive shell):
- **No oh-my-zsh** — it was dropped for startup speed. Completion is bootstrapped directly via a cached `compinit` (full security check runs at most once/day, else `compinit -C`).
- **Prompt: starship** (`eval "$(starship init zsh)"`), guarded with a minimal `%~ %#` fallback if starship isn't installed. Config in the `starship/` package.
- **node: fnm**, loaded eagerly (`eval "$(fnm env --use-on-cd)"`) so `node`/`npm` are available immediately. This replaces the old lazy-nvm wrappers, whose side effect was that `npm` didn't exist until you first ran `nvm`.
- **PATH** is built with `_prepend_path`/`_append_path` helpers that only add a dir if it exists — so the same file references Homebrew, `~/.cargo/bin`, `/opt/nvim-linux-x86_64/bin`, `/usr/local/go/bin`, etc. without breaking on whichever host lacks them. Bootstrap scripts no longer `>>`-append PATH lines (that would write into the stow symlink).
- **fzf**: uses `fd` as the finder; sources `fzf --zsh` on newer (Homebrew) fzf, else falls back to `~/.fzf.zsh` (git-install fzf on AL2023).
- The git/aws/docker oh-my-zsh plugins are gone; the only carryover is small `asp`/`acp` AWS-profile helpers and the brazil aliases.
- Machine-local overrides go in `~/.zshrc_custom` (not committed).
- `GOPROXY=direct` is set intentionally to avoid an Amazon DNS sinkhole issue.

### Neovim (`nvim/`)

Lua-based config. Entry point: `init.lua` → loads `lua/config.lua` (core settings) then bootstraps **lazy.nvim**.

Plugins are split into four spec files under `lua/plugins/`:
- `core.lua` — general editing: fugitive, surround, Comment.nvim, LuaSnip, leap.nvim
- `editor.lua` — IDE features: treesitter, Telescope, Neo-tree, LSP (nvim-lspconfig + Mason), nvim-dap, nvim-cmp, neotest, toggleterm, trouble.nvim
- `ui.lua` — appearance: onenord.nvim colorscheme (active), lualine (nord theme), gitsigns
- `languages.lua` — language-specific: vim-go, rustaceanvim v5, neodev.nvim

Leader key is `,`. Key bindings of note:
- `Ctrl-P` / `<leader>ff` — Telescope find files
- `<leader>fg` — Telescope live grep
- `Ctrl-N` — Neo-tree toggle
- `gd` — Go to definition (via Telescope)
- `<space>f` — Format buffer
- `<leader>b` — DAP breakpoint toggle
- `Ctrl-T` — Toggleterm

After fresh install, run in Neovim: `:MasonInstall codelldb pyright`

**Config sandbox (`NVIM_APPNAME`):** the `nvim-dev` shell function (`zsh/functions/nvim.zsh`) runs `NVIM_APPNAME=nvim-dev nvim`, which reads a fully isolated config/data/state/cache set (`~/.config/nvim-dev`, `~/.local/share/nvim-dev`, …) sharing only the binary with the default `nvim`. It's a standing sandbox for building/testing config changes (own plugins + lazy-lock) without risk to the daily editor; when a `nvim-dev/` stow package exists it maps to `~/.config/nvim-dev`. See `dot nvim` for the promote workflow.

**Clipboard over SSH:** `config.lua` switches Neovim's `+`/`*` registers to the built-in OSC52 provider when `$SSH_TTY` is set. Remote boxes (AL2023 dev desks) have no `pbcopy`/`xclip`/`wl-copy` and no display, so OSC52 (caught by the local terminal, e.g. WezTerm) is the only path that reaches the local clipboard. Locally on macOS the default system-clipboard provider is left in place. OSC52 paste is unreliable, so paste falls back to the internal register.

### starship (`starship/`)

Cross-shell prompt config at `.config/starship.toml`. Two-line prompt (dir + git + cmd duration, then the `$` character). Shows AWS profile/region and rust/go/node versions contextually. Git status runs async, which is the main startup win over the old oh-my-zsh prompt.

### zellij (`zellij/`)

Primary terminal multiplexer. Single `config.kdl`. Uses zsh as the pane shell, `nvim` as the scrollback editor, and OSC52 for clipboard (works locally and over SSH on OSC52-capable terminals like WezTerm — `copy_command` is intentionally left unset to keep the OSC52 path). KDL has no per-OS branching, so machine-specific clipboard tweaks would go in a local override rather than this committed file.

### tmux (`tmux/`)

Kept as a fallback for hosts without zellij. Platform-detected at runtime: `.tmux.conf` sources `.tmux-macos.conf` on Darwin or `.tmux-linux.conf` on Linux. Clipboard integration uses `pbcopy` (macOS) or `wl-copy` (Linux/Wayland).

### WezTerm (`wezterm/`)

Single file: `.config/wezterm/wezterm.lua`. Font: JetBrains Mono Nerd Font Bold 12.5pt. Colorscheme: Ocean (dark).

### bin (`bin/`)

Personal scripts/utilities, stowed to `~/opt/bin` (on PATH via `.zshrc`, distinct from `~/.local/bin` which is where the bootstrap scripts drop downloaded release binaries). This is the deliberate "my own stuff" dir — anything hand-written and repo-tracked goes here.
- `cargo-reclaim` — recursively finds cargo `target/` dirs and reclaims disk. Safety: only deletes a `target/` whose `CACHEDIR.TAG` carries cargo's signature, so it never nukes a coincidentally-named dir; also catches orphaned target dirs whose `Cargo.toml` is gone. Dry-run by default (`--apply` to delete, `--rm` for raw `rm -rf`, `--min-size N`). The `cargo-` prefix makes it invokable as `cargo reclaim` too. Being compared against `cargo-clean-all` (installed via cargo in both bootstraps) before settling on one.

## Notes

- `shell/bashrc.symlink` is a legacy file using an old naming convention — it is not processed by Stow and is not currently active.
- No `.vimrc` — Neovim only.
- Git config is not tracked in this repo.
