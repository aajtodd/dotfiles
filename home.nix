{ config, pkgs, ... }:

{

  home = {
    username = "ajt";
    homeDirectory = "/home/ajt";

    # Specify packages not explicitly configured below
    packages = with pkgs; [
      neovim
      ripgrep
      jq
      fd
      tree
    ];

    sessionVariables = {
      EDITOR = "nvim";
    };

    stateVersion = "21.11";
  };

  programs = {
    zsh = {
        enable = true;
        enableCompletion = true;
        shellAliases = {
            du = "du -hs";
        };
        promptInit = "source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
        oh-my-zsh = {
            enable = true;
            plugins = [ "git" "aws" "docker" "docker-compose" "thefuck" ];
            theme = "powerlevel10k";
        };
        initExtra = ''
            # ctrl-P to quickly edit file using nvim from results of fzf
            bindkey -s '^p' 'nvim $(fzf)\n'
        '';
    };
    bat = {
      enable = true;
      config = {
        theme = "GitHub";
        italic-text = "always";
      };
    };

    direnv = {
      enable = true;
      nix-direnv = {
        enable = true;
      };
    };

    exa = {
      enable = true;
      enableAliases = true;
    };


    fzf = {
      enable = true;
      enableZshIntegration = true;
      defaultCommand = "rg --files --no-ignore --hidden --follow --glob '!.git/*'";
    };

    gh = {
      enable = true;
      settings = {
        aliases = {
          co = "pr checkout";
          pv = "pr view";
        };
        git_protocol = "ssh";
      };
    };

    git = {
      enable = true;
      userName = "Aaron Todd";
      userEmail = "aajtodd@gmail.com";
      aliases = {
        prettylog = "log --graph --abbrev-commit --decorate --date=relative --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(bold yellow)%d%C(reset)' --all";
      };
      delta = {
        enable = true;
        options = {
          navigate = true;
          line-numbers = true;
          syntax-theme = "GitHub";
        };
      };
      extraConfig = {
        core = {
          editor = "nvim";
          # If git uses `ssh` from Nix the macOS-specific configuration in
          # `~/.ssh/config` won't be seen as valid
          # https://github.com/NixOS/nixpkgs/issues/15686#issuecomment-865928923
          sshCommand = "/usr/bin/ssh";
        };
        color = {
          ui = true;
        };
        push = {
          default = "current";
        };
        pull = {
          ff = "only";
        };
        init = {
          defaultBranch = "main";
        };
        # Clone git repos with URLs like "gh:alexpearce/dotfiles"
        url."git@github.com:" = {
          insteadOf = "gh:";
          pushInsteadOf = "gh:";
        };
      };
      ignores = [
        ".*.swp"
        ".bundle"
        "vendor/bundle"
        ".DS_Store"
        "Icon"
        "*.pyc"
        ".envrc"
        "environment.yaml"
      ];
    };

    home-manager.enable = true;

    starship = {
      enable = true;
      enableZshIntegration = true;
      settings = {
        add_newline = true;
      };
    };

    zoxide = {
      enable = true;
      enableZshIntegration = true;
    };
  };

  xdg.configFile."nix/nix.conf".text = ''
    experimental-features = nix-command flakes
  '';

  # FIXME The init.vim unconditionally installed by this module conflicts with
  # our init.lua, so we cannot use the module for now and must install the
  # configuration explicitly
  xdg.configFile.nvim = {
    source = ./config/neovim;
    recursive = true;
  };
}
