# Install homebrew
#/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

brew install --cask wezterm

# Install fonts
brew install --cask font-jetbrains-mono-nerd-font

# JVM
brew install --cask corretto

# common programs
brew install neovim fzf ripgrep tmux cmake nvm go fd stow 

# rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# oh-my-zsh + theme
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
curl -L -o ~/.oh-my-zsh/custom/themes/materialshell.zsh-theme https://raw.githubusercontent.com/carloscuesta/materialshell/master/materialshell.zsh

# setup dotfiles

