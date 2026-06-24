#@@ sessions : zellij session management (named, deduped)
# Sessions named after their project dir, so they are meaningful and dedupe
# naturally (vs zellij's random adjective-animal names).

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
