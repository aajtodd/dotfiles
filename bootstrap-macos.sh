#!/bin/bash
# Bootstrap for macOS (Homebrew-based).
#
# Mirrors bootstrap-al2023.sh in rigor but uses mac-idiomatic tooling: Homebrew
# for everything it packages, the official installers for the few things it
# doesn't (uv, rust). The committed zsh config is OS-agnostic and existence-
# guarded, so PATH/tool wiring is handled there -- this script only installs.
set -euo pipefail

# Install Homebrew if absent (no-op if already present).
if ! command -v brew >/dev/null 2>&1; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
eval "$(/opt/homebrew/bin/brew shellenv)"

# Casks: terminal, fonts, JVM.
brew install --cask wezterm
brew install --cask font-jetbrains-mono-nerd-font
brew install --cask corretto

# CLI tools. starship = prompt, fnm = node manager, zellij = multiplexer,
# zoxide = smart cd, bat = cat w/ highlighting, navi = `dot run` snippet engine.
# (rust/cargo come from rustup below, not brew, to match AL2023's user toolchain.)
brew install neovim fzf ripgrep fd tmux zellij cmake go stow starship fnm zoxide bat navi jq

# uv: fast Python package/script manager (PEP 723 inline deps). Parity with
# AL2023. Homebrew also packages uv, but the official installer matches the
# Linux box and keeps it in ~/.local/bin on both.
curl -LsSf https://astral.sh/uv/install.sh | env UV_INSTALL_DIR="$HOME/.local/bin" sh

# rust via rustup (up-to-date user toolchain + rustup for rustaceanvim etc.).
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
# shellcheck disable=SC1091
source "$HOME/.cargo/env"

# node: install + default to current LTS so node/npm exist out of the box.
eval "$(fnm env)"
fnm install --lts
fnm default lts-latest

# cargo-clean-all: recursive cargo target/ reclaimer (keep-days, parallel, TUI).
# Test-driving alongside our own bin/cargo-reclaim to decide which to keep.
cargo install cargo-clean-all

# Second, pinned Neovim 0.12 build for the `nvim-dev` config sandbox, kept SEPARATE
# from the daily brew nvim so a config that needs a newer nvim can be tested in
# isolation (NVIM_APPNAME isolates config, not the binary). Installed to ~/opt so it
# doesn't shadow brew's nvim. `nvim-dev` (zsh func) prefers this build if present.
NVIM_DEV_VERSION="v0.12.4"
case "$(uname -m)" in
  arm64)  NVIM_DEV_ASSET="nvim-macos-arm64" ;;
  x86_64) NVIM_DEV_ASSET="nvim-macos-x86_64" ;;
esac
curl -fsSL -o /tmp/nvim-dev.tar.gz \
  "https://github.com/neovim/neovim/releases/download/${NVIM_DEV_VERSION}/${NVIM_DEV_ASSET}.tar.gz"
xattr -c /tmp/nvim-dev.tar.gz 2>/dev/null || true    # clear quarantine so it runs
rm -rf "$HOME/opt/nvim-0.12"
mkdir -p "$HOME/opt"
tar -C /tmp -xzf /tmp/nvim-dev.tar.gz
mv "/tmp/${NVIM_DEV_ASSET}" "$HOME/opt/nvim-0.12"
xattr -cr "$HOME/opt/nvim-0.12" 2>/dev/null || true
rm /tmp/nvim-dev.tar.gz

# Apply the stow packages (creates the ~/ symlinks). starship MUST be included
# or the prompt loads its defaults instead of the committed two-line config.
# `bin` symlinks our own scripts (bin/opt/bin/*) into ~/opt/bin (on PATH).
cd "$(dirname "$0")"
stow nvim zsh wezterm zellij starship tmux bin

# Build vendored zellij plugins from pinned source (gitignored .wasm; built
# on-demand from zellij/plugins.lock). Needs cargo, which rustup installed above.
./zellij/build-plugins.sh
