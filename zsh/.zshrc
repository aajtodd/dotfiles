# Re-enable to profile loading with zprof
#zmodload zsh/zprof

fpath+=~/.zfunc

#############################################################
# History
#############################################################
HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000
setopt append_history inc_append_history share_history
setopt hist_ignore_dups hist_ignore_space

#############################################################
# Completion (replaces oh-my-zsh's compinit bootstrap)
#############################################################
autoload -Uz compinit
# Cache the dump; only run the full security check once a day.
if [ -n "$(find ~/.zcompdump -mtime +1 2>/dev/null)" ] || [ ! -f ~/.zcompdump ]; then
    compinit
else
    compinit -C
fi
zstyle ':completion:*' menu select
setopt complete_in_word

#############################################################
# Prompt: starship (https://starship.rs)
#############################################################
if command -v starship >/dev/null 2>&1; then
    eval "$(starship init zsh)"
else
    # Minimal fallback if starship isn't installed yet.
    setopt prompt_subst
    PROMPT='%~ %# '
fi

#############################################################
# Editor
#############################################################
export EDITOR=nvim

#############################################################
# PATH (existence-guarded so the same file works everywhere)
#############################################################
# Homebrew (macOS / Apple Silicon)
[ -x /opt/homebrew/bin/brew ] && eval "$(/opt/homebrew/bin/brew shellenv)"

# helper: prepend a dir to PATH if it exists and isn't already present
_prepend_path() { [ -d "$1" ] && case ":$PATH:" in *":$1:"*) ;; *) PATH="$1:$PATH" ;; esac; }
_append_path()  { [ -d "$1" ] && case ":$PATH:" in *":$1:"*) ;; *) PATH="$PATH:$1" ;; esac; }

_prepend_path /usr/local/bin
_prepend_path "$HOME/.cargo/bin"
_prepend_path "$HOME/.local/bin"
_append_path  "$HOME/opt/bin"
_append_path  "$HOME/.toolbox/bin"          # Amazon internal tooling
_append_path  /opt/nvim-linux-x86_64/bin    # AL2023 neovim tarball
_append_path  /usr/local/go/bin             # go tarball
export PATH

#############################################################
# fzf
#############################################################
export FZF_DEFAULT_COMMAND='fd --type f --strip-cwd-prefix --hidden --follow --exclude .git'
if command -v fzf >/dev/null 2>&1 && fzf --zsh >/dev/null 2>&1; then
    source <(fzf --zsh)                     # newer fzf (homebrew)
elif [ -f ~/.fzf.zsh ]; then
    source ~/.fzf.zsh                       # git-install fzf (AL2023)
fi
# Ctrl-P: fuzzy-pick a file and open it in nvim
bindkey -s '^p' 'nvim $(fzf)\n'

#############################################################
# node via fnm (fast; node/npm available immediately)
#############################################################
if command -v fnm >/dev/null 2>&1; then
    eval "$(fnm env --use-on-cd)"
fi

#############################################################
# Go
#############################################################
# get around issue with chalupa-dns-sinkhole.amazon.com
export GOPROXY=direct

#############################################################
# Java (macOS only; uses java_home)
#############################################################
if [ -x /usr/libexec/java_home ]; then
    export JAVA_HOME="$(/usr/libexec/java_home -v 17 2>/dev/null)"
fi

#############################################################
# AWS profile switchers (replaces the oh-my-zsh aws plugin)
#############################################################
asp() { export AWS_PROFILE="$1"; }          # set profile
acp() { unset AWS_PROFILE; }                # clear profile

#############################################################
# Brazil (Amazon build system) aliases. Harmless where brazil is absent.
#############################################################
alias bb=brazil-build
alias bba='brazil-build apollo-pkg'
alias bre='brazil-runtime-exec'
alias brc=brazil-recursive-cmd
alias bws='brazil ws'
alias bwsuse='bws use -p'
alias bwscreate='bws create -n'
alias bbr='brc brazil-build'
alias bball='brc --allPackages'
alias bbb='brc --allPackages brazil-build'
alias bbra='bbr apollo-pkg'

#############################################################
# Local customizations we don't want to check in
#############################################################
[ -f "$HOME/.zshrc_custom" ] && source "$HOME/.zshrc_custom"
