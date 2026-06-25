# Re-enable to profile loading with zprof
#zmodload zsh/zprof

# Dotfiles root, resolved from this file's own path (%x), with :A following the
# stow symlink to the real location. Set once here; used by `dot` and others.
export DOTFILES="${${(%):-%x}:A:h:h}"

# Roots used by zjo/clone/project tooling. Defaults below; override (machine-local,
# not committed) in ~/.config/dot/config — a sourced KEY=value file, e.g.:
#   DOT_SRC=~/sandbox/rs ; DOT_3P=~/sandbox/rs/3P ; DOT_PLANNING=~/sandbox/rs/ai
: ${DOT_SRC:=$HOME/sandbox}
: ${DOT_3P:=$HOME/sandbox/3P}
: ${DOT_PLANNING:=$HOME/sandbox/planning}
[[ -r ~/.config/dot/config ]] && source ~/.config/dot/config
export DOT_SRC DOT_3P DOT_PLANNING

# Source custom shell functions (one file per domain). Each function carries a
# `#@ name : description` doc line that `dot` extracts for its index.
for _f in "$DOTFILES"/zsh/functions/*.zsh(N); do source "$_f"; done
unset _f

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
# PATH (existence-guarded so the same file works everywhere)
# NOTE: this must run BEFORE any block that probes for a tool with
# `command -v` (starship, fzf, fnm) — those tools live in dirs added here
# (e.g. ~/.local/bin). If PATH is set up after them, the probes fail on a
# fresh login and only succeed after a manual `source ~/.zshrc`.
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
# Prompt: starship (https://starship.rs)
# Guard against double-init: sourcing .zshrc twice makes starship's
# zle-keymap-select wrapper preserve ITSELF as the "original" widget, which
# recurses infinitely on mode switch (FUNCNEST error). Only init once per shell.
#############################################################
if command -v starship >/dev/null 2>&1; then
    if [[ -z ${_STARSHIP_INITED:-} ]]; then
        eval "$(starship init zsh)"
        _STARSHIP_INITED=1
    fi
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
# Colorized ls / grep. GNU ls takes --color=auto; BSD ls uses CLICOLOR. Probe
# so the same config works on both. grep is not aliased to rg (differing regex,
# recursion, and flag semantics); invoke rg by name.
#############################################################
if ls --color=auto >/dev/null 2>&1; then
    alias ls='ls --color=auto'
else
    export CLICOLOR=1
fi
alias grep='grep --color=auto'

#############################################################
# fzf
#############################################################
export FZF_DEFAULT_COMMAND='fd --type f --strip-cwd-prefix --hidden --follow --exclude .git'
if command -v fzf >/dev/null 2>&1 && fzf --zsh >/dev/null 2>&1; then
    source <(fzf --zsh)                     # newer fzf (homebrew)
elif [ -f ~/.fzf.zsh ]; then
    source ~/.fzf.zsh                       # git-install fzf (AL2023)
fi

#############################################################
# Line-editing keymap — toggle vi/emacs to try both. `dot keys`.
#   keymap         show current        keymap vi     vim motions (ESC = normal)
#   keymap emacs   modeless emacs keys (Ctrl-A/E/K/Y, Alt-B/F)
# Choice persists in ~/.zsh_keymap (defaults to vi — zsh would infer vi from
# EDITOR=nvim anyway). Both modes keep fzf Ctrl-R + the Ctrl-P nvim binding;
# vi mode also gets emacs keys in INSERT mode so nothing is ever stranded.
# Must run AFTER fzf is sourced so we can re-point Ctrl-R into the live keymap.
#############################################################
# edit-command-line: open the current command in $EDITOR (nvim), write-quit runs it.
autoload -Uz edit-command-line && zle -N edit-command-line

_keymap_file="$HOME/.zsh_keymap"
_apply_keymap() {
    local mode="$1"
    if [[ "$mode" == emacs ]]; then
        bindkey -e
        KEYTIMEOUT=40          # ESC-prefixed Alt keys stay reliable
    else
        bindkey -v
        KEYTIMEOUT=1           # snappy ESC into normal mode (default 40 = 0.4s lag)
    fi
    # (Re)bind into whatever is now the main keymap so a live toggle keeps these.
    bindkey -s '^p' 'nvim $(fzf)\n'                       # Ctrl-P: fzf -> nvim
    whence -w fzf-history-widget >/dev/null 2>&1 && bindkey '^r' fzf-history-widget
    bindkey '^a' beginning-of-line                        # emacs keys: in emacs mode
    bindkey '^e' end-of-line                              # these ARE the mode; in vi
    bindkey '^k' kill-line                                # mode they're an insert-mode
    bindkey '^u' backward-kill-line                       # safety net so you're never
    bindkey '^w' backward-kill-word                       # stranded mid-type.
    bindkey '^y' yank
    bindkey '^x^e' edit-command-line                      # Ctrl-X Ctrl-E: edit cmd in nvim
    [[ "$mode" != emacs ]] && bindkey -M vicmd 'v' edit-command-line  # vi: 'v' too
    export KEYMAP_CHOICE="${mode:-vi}"                    # for the dot keys guide / prompt
}
# user-facing toggle: persists the choice and applies it live
keymap() {
    case "${1:-}" in
        vi|emacs) print -r -- "$1" > "$_keymap_file"; _apply_keymap "$1"
                  print -r -- "keymap: $1 (persisted)" ;;
        "")       print -r -- "keymap: ${KEYMAP_CHOICE:-vi}  (use: keymap vi | keymap emacs)" ;;
        *)        print -u2 "keymap: vi | emacs"; return 1 ;;
    esac
}
_apply_keymap "$(command cat "$_keymap_file" 2>/dev/null || echo vi)"

#############################################################
# node via fnm (fast; node/npm available immediately)
#############################################################
if command -v fnm >/dev/null 2>&1; then
    eval "$(fnm env --use-on-cd)"
fi

#############################################################
# zoxide: provides `z`/`zi`. `cheat sh zoxide` for usage. (Not using --cmd cd,
# so `cd` is unchanged and `z` is additive.)
#############################################################
if command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init zsh)"
fi

#############################################################
# bat: cat with highlighting. Nord theme to match nvim. `cat` aliased with
# --paging=never so it stays inline and pipe-safe; MANPAGER colorizes man pages.
#############################################################
if command -v bat >/dev/null 2>&1; then
    export BAT_THEME="Nord"
    export BAT_STYLE="numbers,changes,header"
    alias cat='bat --paging=never'
    export MANPAGER="sh -c 'col -bx | bat -l man -p'"
    export MANROFFOPT="-c"
fi

#############################################################
# Go
#############################################################
# get around issue with chalupa-dns-sinkhole.amazon.com
export GOPROXY=direct

#############################################################
# Java
#############################################################
if [ -x /usr/libexec/java_home ]; then
    # macOS
    export JAVA_HOME="$(/usr/libexec/java_home -v 17 2>/dev/null)"
elif [ -d /usr/lib/jvm/java ]; then
    # AL2023 (amazon-corretto)
    export JAVA_HOME="/usr/lib/jvm/java"
fi

#############################################################
# Clipboard: pbcopy/pbpaste (macOS native or OSC52 fallback)
#############################################################
if ! command -v pbcopy >/dev/null 2>&1; then
    # OSC52 clipboard — works over SSH through zellij/WezTerm.
    # Usage: echo "text" | pbcopy
    pbcopy() {
        local data
        data=$(cat)
        # \e]52;c;<base64>\a — system clipboard via OSC52
        printf '\033]52;c;%s\a' "$(printf '%s' "$data" | base64 | tr -d '\n')"
    }
    pbpaste() {
        # OSC52 paste is unreliable; this is a best-effort stub.
        printf '\033]52;c;?\a'
    }
fi

#############################################################
# dot: personal reference + runnable snippets, all from this repo.
#   dot              index: guides, custom functions, cheat tags
#   dot <topic>      render a prose guide (dot/guides/<topic>.md)
#   dot -s <query>   full-text search guides -> fzf -> open match
#   dot run [query]  navi: pick a parameterized snippet, fill, run
# Guides = concepts (markdown). Cheats = executable/parameterized (navi .cheat).
# Functions = zsh/functions/*.zsh, self-documented via `#@ name : desc` lines.
#############################################################
_dot_dir="$DOTFILES/dot"
# Point navi at our in-repo cheats so `dot run` finds them with no extra config.
command -v navi >/dev/null 2>&1 && export NAVI_PATH="$_dot_dir/cheats"
_dot_render() {
    if command -v bat >/dev/null 2>&1; then bat --language=markdown --style=plain --paging=auto "$1"
    else "${PAGER:-less}" "$1"; fi
}
# Index: list guides, custom functions (from #@ doc lines), and navi cheat tags.
_dot_index() {
    local f title
    print -r -- "# dot — personal reference"
    print -r -- "  dot <topic>     render a guide        dot -s <q>   search guides"
    print -r -- "  dot run [q]     run a navi snippet"
    print -r --
    print -r -- "GUIDES (dot <topic>):"
    for f in "$_dot_dir"/guides/*.md(N); do
        title="$(sed -n 's/^# //p' "$f" | head -1)"
        printf '  %-12s %s\n' "${f:t:r}" "${title#* — }"
    done
    print -r --
    print -r -- "FUNCTIONS (zsh/functions/):"
    # One group per domain file. `#@@ domain : desc` = header; `#@ name : desc` = function.
    local fnfile dom fn
    for fnfile in "$DOTFILES"/zsh/functions/*.zsh(N); do
        dom="$(sed -n 's/^#@@ //p' "$fnfile" | head -1)"
        [ -n "$dom" ] && printf '  %s — %s\n' "${dom%% : *}" "${dom#* : }"
        sed -n 's/^#@ //p' "$fnfile" | awk -F' : ' '{ printf "      %-10s %s\n", $1, $2 }'
    done
    if command -v navi >/dev/null 2>&1; then
        local tags
        # %-lines hold comma-separated tags; split, trim, unique, rejoin.
        tags="$(grep -rh '^%' "$_dot_dir"/cheats/*.cheat(N) 2>/dev/null \
            | sed 's/^% *//; s/,/\n/g' | sed 's/^ *//; s/ *$//' | sort -u | paste -sd',' - | sed 's/,/, /g')"
        print -r --
        print -r -- "SNIPPETS (dot run):  $tags"
    fi
}
dot() {
    case "${1:-}" in
        "")   _dot_index | _dot_render /dev/stdin ;;
        -s)   shift; _dot_search "$@" ;;
        run)  shift; _dot_run "$@" ;;
        *)    if [ -f "$_dot_dir/guides/$1.md" ]; then _dot_render "$_dot_dir/guides/$1.md"
              else print -u2 "dot: no guide '$1'"; _dot_index | _dot_render /dev/stdin; return 1; fi ;;
    esac
}
# Full-text search across guides; fzf-pick a matching line, open that guide.
_dot_search() {
    command -v rg >/dev/null 2>&1 || { print -u2 "dot -s: needs ripgrep"; return 1; }
    command -v fzf >/dev/null 2>&1 || { print -u2 "dot -s: needs fzf"; return 1; }
    local hit file
    hit="$(rg --line-number --no-heading --color=never "${*:-.}" "$_dot_dir"/guides 2>/dev/null \
        | fzf --delimiter=: --with-nth=1,3.. --preview 'bat --color=always --highlight-line {2} {1}')" || return
    file="${hit%%:*}"
    [ -n "$file" ] && _dot_render "$file"
}
# navi: --print emits the filled command to the prompt buffer instead of running it.
_dot_run() {
    command -v navi >/dev/null 2>&1 || { print -u2 "dot run: navi not installed"; return 1; }
    local cmd
    if [ $# -gt 0 ]; then cmd="$(navi --query "$*" --print 2>/dev/null)"
    else cmd="$(navi --print 2>/dev/null)"; fi
    [ -n "$cmd" ] && print -z -- "$cmd"   # place on the editing buffer; user reviews + hits enter
}
# completion: subcommands + guide names at level 1.
_dot() {
    if (( CURRENT == 2 )); then
        compadd -- run -s $(ls "$_dot_dir"/guides 2>/dev/null | sed 's/\.md$//')
    fi
}
compdef _dot dot 2>/dev/null

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

# if you wish to use IMDS set AWS_EC2_METADATA_DISABLED=false

export AWS_EC2_METADATA_DISABLED=true


# Added by AIM CLI
export PATH="$HOME/.aim/mcp-servers:$PATH"
