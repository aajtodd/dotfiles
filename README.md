# Quickstart

Install stow

Mac: `brew install stow`

See https://alexpearce.me/2016/02/managing-dotfiles-with-stow/

```
$ git clone git@github.com:aajtodd/dotfiles.git ~/.dotfiles
$ cd ~/.dotfiles
$ stow nvim zsh # plus whatever else you'd like
```


# TODO
[] bootstrap script to install dependencies and system tools we use
    * fzf
    * go
    * rust
        * cargo install racer
    * ripgrep
    * ctags (universal-ctags)
    * cscope

[] helper scripts to bootstrap other things we find ourselves often toying with
    * vim-8 ?
    * virtualenv ?
    * latest gcc/g++

Terminal settings
[ ] contour vs alacritty vs kitty vs wezterm
    - install kitty: `curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin`
    - install wezterm `brew install --cask wezterm`
[ ] Finish setting up kitty colors

nvim
-----
~/.config/nvim/init.vim
