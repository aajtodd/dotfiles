#@@ nav : small directory-navigation conveniences
# zoxide (`z`) covers frecent jumps; these are the gaps it doesn't.

#@ mkcd : make a directory (and parents) and cd into it
mkcd() { [ -n "${1:-}" ] || { print -u2 "mkcd: <dir>"; return 1; }; mkdir -p "$1" && cd "$1"; }

#@ tmpd : make a temp directory and cd into it
tmpd() { local d; d="$(mktemp -d)" && cd "$d" && print -r -- "$d"; }

#@ up : cd up N levels (default 1)
up() {
    local n="${1:-1}" path=""
    repeat "$n"; do path="../$path"; done
    cd "$path" || return
}
