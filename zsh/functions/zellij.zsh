#@@ zellij : open dirs in panes/tabs (zjo) and manage named sessions (zj{s,l,k,clean})
# zjo opens a NEW surface in the current session (the "go look at something" verb).
# The zjs/zjl/zjk/zjclean set manages whole sessions, named after their project dir
# so they are meaningful and dedupe naturally (vs zellij's random adjective-animal
# names). Named targets for zjo's picker = zoxide frecency ∪ children of the roots.

# Candidate dirs for zjo: zoxide frecency ∪ direct children of the roots.
_zjo_candidates() {
    command -v zoxide >/dev/null 2>&1 && zoxide query -l 2>/dev/null
    print -rl -- "$DOT_SRC"/*(N/) "$DOT_3P"/*(N/)
}

#@ zjo : open a dir in a new pane (-t tab, -f floating); no arg = picker
zjo() {
    local mode=pane
    while [[ "${1:-}" == -* ]]; do
        case "$1" in
            -t|--tab)      mode=tab; shift ;;
            -f|--float)    mode=float; shift ;;
            -p|--pane)     mode=pane; shift ;;
            --project)     print -u2 "zjo --project: not built yet (deferred — needs layout design)"; return 2 ;;
            *)             print -u2 "zjo: unknown flag $1"; return 1 ;;
        esac
    done
    local dir
    if [ -n "${1:-}" ] && [ -d "$1" ]; then
        dir="${1:A}"
    elif [ -n "${1:-}" ] && command -v zoxide >/dev/null 2>&1 && dir="$(zoxide query "$1" 2>/dev/null)" && [ -n "$dir" ]; then
        :   # zoxide resolved the query to a single dir
    else
        command -v fzf >/dev/null 2>&1 || { print -u2 "zjo: need a dir arg, or install fzf for the picker"; return 1; }
        dir="$(_zjo_candidates | awk '!seen[$0]++' | fzf --prompt 'open> ' ${1:+--query "$1"})" || return
    fi
    [ -n "$dir" ] || return
    # Outside zellij: just cd (the helper still works everywhere).
    if [ -z "${ZELLIJ:-}" ]; then cd "$dir"; return; fi
    local name="${dir:t}"
    # new-pane/new-tab echo the new pane id to stdout (0.44 scripting feature);
    # we don't use it, so silence it.
    case "$mode" in
        pane)  zellij action new-pane --cwd "$dir" --name "$name" >/dev/null ;;
        float) zellij action new-pane --floating --cwd "$dir" --name "$name" >/dev/null ;;
        tab)   zellij action new-tab  --cwd "$dir" --name "$name" >/dev/null ;;
    esac
}

#@ zjs : fuzzy-pick a dir (zoxide) and attach/create a session named for it
zjs() {
    command -v zellij >/dev/null 2>&1 || { print -u2 "zjs: zellij not installed"; return 1; }
    local dir name
    if [ $# -gt 0 ] && [ -d "$1" ]; then
        dir="${1:A}"
    elif command -v zoxide >/dev/null 2>&1 && command -v fzf >/dev/null 2>&1; then
        dir="$(zoxide query -l | fzf --prompt 'session dir> ')" || return
    else
        print -u2 "zjs: pass a dir, or install zoxide+fzf for the picker"; return 1
    fi
    [ -n "$dir" ] || return
    # session name = dir basename, sanitized (zellij disallows . and /)
    name="${${dir:t}//[.\/ ]/_}"
    ( cd "$dir" && zellij attach --create "$name" )
}

#@ zjl : list zellij sessions (live and exited)
zjl() {
    command -v zellij >/dev/null 2>&1 || { print -u2 "zjl: zellij not installed"; return 1; }
    zellij list-sessions
}

#@ zjk : fuzzy-pick exited zellij sessions and delete them
zjk() {
    command -v zellij >/dev/null 2>&1 || { print -u2 "zjk: zellij not installed"; return 1; }
    command -v fzf >/dev/null 2>&1 || { print -u2 "zjk: needs fzf"; return 1; }
    # --no-formatting gives plain names; pick the EXITED ones, multi-select.
    local picks
    picks="$(zellij list-sessions --no-formatting 2>/dev/null | grep EXITED \
        | awk '{print $1}' | fzf --multi --prompt 'delete> ')" || return
    [ -n "$picks" ] || return
    print -r -- "$picks" | while read -r s; do zellij delete-session "$s"; done
}

#@ zjclean : delete ALL exited zellij sessions in one shot
zjclean() {
    command -v zellij >/dev/null 2>&1 || { print -u2 "zjclean: zellij not installed"; return 1; }
    zellij delete-all-sessions --yes --force
}
