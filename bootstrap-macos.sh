# Install homebrew
#/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

brew install --cask wezterm

# Install fonts
brew install --cask font-jetbrains-mono-nerd-font

# JVM
brew install --cask corretto

# common programs (starship = prompt, fnm = node manager, zellij = multiplexer)
brew install neovim fzf ripgrep tmux zellij cmake go fd stow starship fnm

# install + default to the current node LTS so node/npm exist out of the box
eval "$(fnm env)"
fnm install --lts
fnm default lts-latest

# rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# setup dotfiles
#   stow nvim zsh wezterm zellij starship tmux

