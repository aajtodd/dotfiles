#!/bin/bash
# Bootstrap for Amazon Linux 2023 (dnf-based).
#
# Note: on the internal AL2023 repos, fzf / ripgrep / fd / stow are NOT
# packaged, so they are installed from source / cargo / git below.
set -euo pipefail

ARCH="$(uname -m)" # x86_64 or aarch64

# Available from dnf: build tooling + rust/cargo (used to install rg & fd) + jq.
sudo dnf install -y git tar gzip cmake gcc make perl autoconf texinfo cargo rust \
    java-21-amazon-corretto-devel openssl-devel jq

# install rustup-managed toolchain (cargo/rust above are the OS packages; this
# gives an up-to-date user toolchain + rustup for rustaceanvim etc.)
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
# shellcheck disable=SC1091
source "$HOME/.cargo/env"

# ripgrep + fd + bat + zoxide + navi via cargo (none packaged in the AL2023 repos).
# All Rust; compiles, takes a few min. bat = cat w/ highlighting, zoxide = smart cd,
# navi = `dot run` snippet engine. cargo-clean-all = recursive target/ reclaimer
# (test-driving alongside our own bin/cargo-reclaim to decide which to keep).
# tree-sitter-cli: REQUIRED by nvim-treesitter's `main` branch, which compiles
# parsers from grammar source. Without it, parser install fails silently and
# there is NO treesitter highlighting. (cc/gcc for the parser build come from the
# dnf line above.)
cargo install ripgrep fd-find bat zoxide navi cargo-clean-all tree-sitter-cli

# install fzf
if [ ! -d ~/.fzf ]; then
  git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
fi
~/.fzf/install --all

# install GNU stow from source (not packaged)
STOW_VERSION="2.4.1"
curl -LO "https://ftp.gnu.org/gnu/stow/stow-${STOW_VERSION}.tar.gz"
tar -xzf "stow-${STOW_VERSION}.tar.gz"
pushd "stow-${STOW_VERSION}"
./configure --prefix=/usr/local && make && sudo make install
popd
rm -rf "stow-${STOW_VERSION}" "stow-${STOW_VERSION}.tar.gz"

# install latest neovim (release tarballs are now arch-suffixed)
# PATH for nvim/go is handled in the committed zsh/.zshrc (existence-guarded),
# so nothing is appended to ~/.zshrc / ~/.bashrc here -- those become stow symlinks.
NVIM_TARBALL="nvim-linux-${ARCH}.tar.gz"
curl -LO "https://github.com/neovim/neovim/releases/latest/download/${NVIM_TARBALL}"
sudo rm -rf "/opt/nvim-linux-${ARCH}"
sudo tar -C /opt -xzf "${NVIM_TARBALL}"
rm "${NVIM_TARBALL}"

# install go
GO_VERSION="1.22.1"
case "$ARCH" in
  x86_64)  GO_ARCH="amd64" ;;
  aarch64) GO_ARCH="arm64" ;;
  *) echo "unsupported arch: $ARCH" >&2; exit 1 ;;
esac
GO_TARBALL="go${GO_VERSION}.linux-${GO_ARCH}.tar.gz"
curl -LO "https://go.dev/dl/${GO_TARBALL}"
sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf "${GO_TARBALL}"
rm "${GO_TARBALL}"

# install uv (fast Python package/script manager; PEP 723 inline-deps) -> ~/.local/bin
curl -LsSf https://astral.sh/uv/install.sh | env UV_INSTALL_DIR="$HOME/.local/bin" sh

# install starship prompt -> ~/.local/bin
curl -sS https://starship.rs/install.sh | sh -s -- --yes --bin-dir ~/.local/bin

# install fnm (fast node manager; replaces nvm) -> ~/.local/bin
curl -fsSL https://fnm.vercel.app/install | bash -s -- --install-dir ~/.local/bin --skip-shell
# install + default to the current node LTS so node/npm exist out of the box
eval "$(~/.local/bin/fnm env)"
~/.local/bin/fnm install --lts
~/.local/bin/fnm default lts-latest

# install zellij (prebuilt musl binary -> ~/.local/bin, not packaged)
case "$ARCH" in
  x86_64)  ZJ_ARCH="x86_64-unknown-linux-musl" ;;
  aarch64) ZJ_ARCH="aarch64-unknown-linux-musl" ;;
esac
mkdir -p ~/.local/bin
curl -L "https://github.com/zellij-org/zellij/releases/latest/download/zellij-${ZJ_ARCH}.tar.gz" \
  | tar -C ~/.local/bin -xz zellij
chmod +x ~/.local/bin/zellij

# Make zellij sessions survive SSH disconnect (enable user linger; idempotent,
# no-op off systemd). The other half of the fix lives in zjs (systemd-run scope).
./zellij/setup-zellij-persistence.sh

# After this, apply the stow packages, e.g.:
#   stow nvim zsh zellij starship tmux bin
# (`bin` symlinks our own scripts, bin/opt/bin/*, into ~/opt/bin on PATH)
# then build the vendored zellij plugins from pinned source (needs cargo):
#   ./zellij/build-plugins.sh
