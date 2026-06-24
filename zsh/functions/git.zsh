#@@ git : everyday git shortcuts (fzf-backed where it helps)
# Standard short names that transfer from other setups, plus fzf pickers for
# branches and files. Guarded so they no-op cleanly outside a repo.

#@ gs : git status (short, with branch)
gs() { git status -sb "$@"; }

#@ glog : commit graph, one line per commit
glog() { git log --oneline --graph --decorate "$@"; }

#@ gco : checkout a branch (fzf-pick if no arg)
gco() {
    if [ -n "${1:-}" ]; then git checkout "$@"; return; fi
    command -v fzf >/dev/null 2>&1 || { print -u2 "gco: branch name or fzf needed"; return 1; }
    local b
    b="$(git branch --all --format='%(refname:short)' 2>/dev/null \
        | sed 's#^origin/##' | grep -v '^HEAD$' | sort -u | fzf --prompt 'checkout> ')" || return
    [ -n "$b" ] && git checkout "$b"
}

#@ gcm : commit with an inline message
gcm() { git commit -m "$*"; }

#@ gclean : fzf-pick MERGED branches to delete (never offers current/main/master)
gclean() {
    command -v fzf >/dev/null 2>&1 || { print -u2 "gclean: needs fzf"; return 1; }
    local picks
    picks="$(git branch --merged 2>/dev/null \
        | grep -vE '^\*|^\s*(main|master|develop)$' | sed 's/^[ *]*//' \
        | fzf --multi --prompt 'delete merged> ')" || return
    [ -n "$picks" ] || return
    print -r -- "$picks" | while read -r b; do git branch -d "$b"; done
}

#@ groot : cd to the repository root
groot() { local r; r="$(git rev-parse --show-toplevel 2>/dev/null)" && cd "$r" || print -u2 "groot: not in a git repo"; }
