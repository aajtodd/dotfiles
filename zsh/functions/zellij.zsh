#@@ zellij : open/navigate panes & tabs (zjo/zjt/zjr) and manage sessions (zj{s,l,k,clean})
# zjo opens a NEW surface in the current session (the "go look at something" verb);
# zjt jumps between tabs; zjr renames the focused tab/pane. The zjs/zjl/zjk/zjclean
# set manages whole sessions, named after their project dir so they are meaningful and
# dedupe naturally (vs zellij's random adjective-animal names). zjo's picker targets =
# zoxide frecency ∪ children of the roots; zjs's picker = live sessions ∪ zoxide dirs.

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

#@ zjt : jump to a tab; arg fuzzy-matches (auto-jumps a single hit), no arg = picker
zjt() {
    command -v zellij >/dev/null 2>&1 || { print -u2 "zjt: zellij not installed"; return 1; }
    [ -n "${ZELLIJ:-}" ] || { print -u2 "zjt: not inside a zellij session"; return 1; }
    local tabs; tabs="$(zellij action query-tab-names 2>/dev/null)"
    [ -n "$tabs" ] || { print -u2 "zjt: no tabs to jump to"; return 1; }
    local tab
    if [ -n "${1:-}" ]; then
        if print -r -- "$tabs" | grep -qxF -- "$1"; then
            tab="$1"                                  # exact name wins
        elif command -v fzf >/dev/null 2>&1; then
            # fuzzy-filter (headless); auto-jump on one hit, picker on many, error on none.
            local matches; matches="$(print -r -- "$tabs" | fzf --filter "$1" 2>/dev/null)"
            case "$(print -r -- "$matches" | grep -c .)" in
                0) print -u2 "zjt: no tab matches '$1'"; return 1 ;;
                1) tab="$matches" ;;
                *) tab="$(print -r -- "$tabs" | fzf --query "$1" --prompt 'tab> ')" || return ;;
            esac
        else
            zellij action go-to-tab-name "$1"; return  # no fzf: best-effort exact jump
        fi
    else
        command -v fzf >/dev/null 2>&1 || { print -u2 "zjt: need a tab name, or install fzf for the picker"; return 1; }
        tab="$(print -r -- "$tabs" | fzf --prompt 'tab> ')" || return
    fi
    [ -n "$tab" ] && zellij action go-to-tab-name "$tab"
}

#@ zjr : rename the focused tab (-p renames the focused pane); no arg = prompt
zjr() {
    command -v zellij >/dev/null 2>&1 || { print -u2 "zjr: zellij not installed"; return 1; }
    [ -n "${ZELLIJ:-}" ] || { print -u2 "zjr: not inside a zellij session"; return 1; }
    local target=tab
    if [[ "${1:-}" == -p || "${1:-}" == --pane ]]; then target=pane; shift; fi
    local name="${1:-}"
    if [ -z "$name" ]; then
        # prompt interactively; vared edits an empty buffer in the live shell
        vared -p "rename $target> " name
    fi
    [ -n "$name" ] || return
    case "$target" in
        tab)  zellij action rename-tab  "$name" ;;
        pane) zellij action rename-pane "$name" ;;
    esac
}

#@ zjs : sessionizer — pick a live session OR a dir (zoxide); attaches/creates by name
zjs() {
    command -v zellij >/dev/null 2>&1 || { print -u2 "zjs: zellij not installed"; return 1; }
    local dir name
    if [ $# -gt 0 ] && [ -d "$1" ]; then
        dir="${1:A}"
    elif command -v fzf >/dev/null 2>&1; then
        # Union live sessions (tagged) with zoxide frecent dirs. Pick a session ->
        # attach it directly; pick a dir -> sessionize it (name = dir basename).
        # Rows are "<kind>\t<payload>\t<display>"; fzf shows only the display column.
        local pick kind payload
        pick="$(_zjs_candidates | fzf --delimiter=$'\t' --with-nth=3.. --prompt 'session/dir> ' ${1:+--query "$1"})" || return
        [ -n "$pick" ] || return
        kind="${pick%%$'\t'*}"
        payload="${${pick#*$'\t'}%%$'\t'*}"
        if [[ "$kind" == session ]]; then
            _zj_persist zellij attach "$payload"; return
        fi
        dir="$payload"
    else
        print -u2 "zjs: pass a dir, or install fzf (+zoxide) for the picker"; return 1
    fi
    [ -n "$dir" ] || return
    # session name = dir basename, sanitized (zellij disallows . and /)
    name="${${dir:t}//[.\/ ]/_}"
    ( cd "$dir" && _zj_persist zellij attach --create "$name" )
}
# Launch zellij so its SERVER survives SSH disconnect. On a remote systemd host we
# run it under `systemd-run --user --scope`, which parents the spawned server to the
# (lingering) per-user systemd manager instead of the SSH login-session scope — so
# logind's KillUserProcesses teardown on disconnect never reaches it. Everywhere else
# (local macOS, no systemd-run, not over SSH) we exec zellij directly. Requires the
# one-time `zellij/setup-zellij-persistence.sh` (enable-linger) to have run on the box.
_zj_persist() {
    # User manager reachable? is-system-running exits nonzero when "degraded"
    # (one failed unit) even though --user scopes work fine, so accept any state
    # except "offline"/empty rather than gating on exit code.
    local mgr; mgr="$(systemctl --user is-system-running 2>/dev/null)"
    if [[ -n "${SSH_CONNECTION:-}${SSH_TTY:-}" ]] \
        && command -v systemd-run >/dev/null 2>&1 \
        && [[ -n "$mgr" && "$mgr" != offline ]]; then
        systemd-run --user --scope --quiet --collect "$@"
    else
        "$@"
    fi
}
# zjs picker rows: "<kind>\t<payload>\t<display>". fixed --with-nth=3.. shows only
# the display; kind routes the pick, payload is the raw session name / dir to use.
# Sessions show first, marked live/exited (attaching to an exited one resurrects it).
_zjs_candidates() {
    zellij list-sessions --no-formatting 2>/dev/null \
        | awk '{ state = /EXITED/ ? "exited" : "live"; printf "session\t%s\t%s  (session, %s)\n", $1, $1, state }'
    command -v zoxide >/dev/null 2>&1 && \
        zoxide query -l 2>/dev/null | awk 'NF{ printf "dir\t%s\t%s\n", $0, $0 }'
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
