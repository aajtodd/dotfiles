# TODO

* source the shell + instructions
* figure out nvim
    * switch to lua? 
    * auto install package manager on startup

* split config up
    e.g. https://github.com/manveru/dotfiles/blob/master/common.nix

* Figure out zsh configuration/theme
    * https://blog.devgenius.io/how-to-make-look-your-nix-terminal-aesthetic-eb34658ede2d
    * https://github.com/romkatv/powerlevel10k
    * Add abbreviations
        * https://github.com/olets/zsh-abbr

# Quickstart

1. Install [nix](https://nixos.org/download.html)

```sh
sh <(curl -L https://nixos.org/nix/install) --daemon
```

2. Install [home-manager](https://github.com/nix-community/home-manager)

```sh
nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
nix-channel --update
nix-shell '<home-manager>' -A install
```

3. Clone this repo to `~/.config/nixpkgs`

```sh
git clone git@github.com:aajtodd/dotfiles.git ~/.config/nixpkgs
```

NOTE: edit home path/username if needed

Build and activate `home.nix`

```sh
home-manager switch
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

