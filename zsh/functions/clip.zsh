#@@ clip : copy paths and file contents to the clipboard
# pbcopy is native on macOS or the OSC52 fallback defined in .zshrc, so these
# work locally and over SSH.

#@ cpath : copy a file's absolute path to the clipboard (no arg = cwd)
cpath() {
    local p
    if [ $# -gt 0 ]; then p="${1:A}"; else p="$PWD"; fi
    printf '%s' "$p" | pbcopy
    print -r -- "copied: $p"
}

#@ cfpath : fuzzy-pick a file and copy its absolute path
cfpath() {
    command -v fzf >/dev/null 2>&1 || { print -u2 "cfpath: needs fzf"; return 1; }
    local f
    f="$(${FZF_DEFAULT_COMMAND:-fd --type f} 2>/dev/null | fzf --prompt 'copy path> ')" || return
    [ -n "$f" ] && cpath "$f"
}

#@ cfile : copy a file's CONTENTS to the clipboard
cfile() {
    [ -f "${1:-}" ] || { print -u2 "cfile: need a file"; return 1; }
    pbcopy < "$1"
    print -r -- "copied contents of: ${1:A}"
}
