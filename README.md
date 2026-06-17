# Quickstart

macOS:

```sh
git clone git@github.com:aajtodd/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./bootstrap-macos.sh
stow nvim zsh wezterm zellij starship tmux
```

Amazon Linux 2023:

```sh
git clone git@github.com:aajtodd/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./bootstrap-al2023.sh
stow nvim zsh zellij starship
```

If `stow zsh` reports a conflict, an existing real `~/.zshrc`/`~/.zprofile` is in
the way (e.g. the cloud-desktop defaults). Back them up first, then re-stow:

```sh
mv ~/.zshrc ~/.zshrc.bak; mv ~/.zprofile ~/.zprofile.bak
stow zsh
```

See https://alexpearce.me/2016/02/managing-dotfiles-with-stow/

