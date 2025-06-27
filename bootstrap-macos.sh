# TODO Install homebrew...
brew install --cask wezterm

# oh-my-zsh + theme
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
curl -L -o ~/.oh-my-zsh/custom/themes/materialshell.zsh-theme https://raw.githubusercontent.com/carloscuesta/materialshell/master/materialshell.zsh

# Install fonts
brew install --cask font-jetbrains-mono-nerd-font

# common programs
brew install neovim
brew install fzf
brew install ripgrep
brew install tmux
brew install cmake
brew install nvm
brew install go
brew install fd

# rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# setup dotfiles
