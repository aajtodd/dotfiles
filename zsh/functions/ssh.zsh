#@@ ssh : connect to hosts (zellij by default) and sync files
# Named targets come from ~/.ssh/config Host entries, so ssh/scp/rsync and these
# helpers all share one registry. Only concrete Host names are offered in pickers
# (wildcard entries like `Host *` are config plumbing, not targets).

# Concrete Host aliases from ssh config (no glob chars). Used by the pickers.
_ssh_hosts() {
    awk 'tolower($1)=="host"{ for(i=2;i<=NF;i++) if($i !~ /[*?]/) print $i }' \
        ~/.ssh/config 2>/dev/null | sort -u
}
# Pick a host: $1 if given, else fzf over ssh-config hosts.
_ssh_pick_host() {
    if [ -n "${1:-}" ]; then print -r -- "$1"; return; fi
    command -v fzf >/dev/null 2>&1 || { print -u2 "need a host (or install fzf)"; return 1; }
    _ssh_hosts | fzf --prompt 'host> '
}

#@ sshto : connect to a host; opens a resumable zellij session by default
# usage: sshto [host] [flags] [cmd...]
#   no host -> fzf-pick.  --bare/--no-zj -> plain shell.  trailing CMD -> run it.
#   default: attach/create remote zellij session 'main' (falls back to shell if
#   zellij absent on the remote). `sshto <host> <name>` sets the session name.
sshto() {
    local host bare=0 session="main" rest=()
    host="$(_ssh_pick_host "${1:-}")" || return
    [ -n "$host" ] || return
    shift 2>/dev/null
    while [ $# -gt 0 ]; do
        case "$1" in
            --bare|--no-zj) bare=1; shift ;;
            --) shift; rest=("$@"); break ;;
            -*) print -u2 "sshto: unknown flag $1"; return 1 ;;
            *)  session="$1"; shift ;;   # first bare word = session name
        esac
    done
    if [ ${#rest} -gt 0 ]; then
        ssh -t "$host" "${rest[@]}"                       # explicit command
    elif [ "$bare" -eq 1 ]; then
        ssh "$host"                                       # plain shell
    else
        # zellij if present on the remote, else fall back to a login shell.
        ssh -t "$host" "command -v zellij >/dev/null 2>&1 && exec zellij attach -c ${(q)session} || exec \$SHELL -l"
    fi
}

#@ sshput : rsync local files to a host (fzf-pick host + remote dir)
sshput() {
    [ $# -gt 0 ] || { print -u2 "sshput: <file>... [host]"; return 1; }
    command -v rsync >/dev/null 2>&1 || { print -u2 "sshput: needs rsync"; return 1; }
    local files=() host dest
    files=("$@")
    host="$(_ssh_pick_host)" || return; [ -n "$host" ] || return
    # pick a remote dir under $HOME (fall back to ~ if fd absent remotely)
    dest="$(ssh "$host" 'command -v fd >/dev/null 2>&1 && fd -t d -H -d 4 . "$HOME" || find "$HOME" -maxdepth 4 -type d' 2>/dev/null \
        | fzf --prompt "dest on $host> ")" || return
    [ -n "$dest" ] || return
    rsync -avzP "${files[@]}" "$host:${dest}/"
}

#@ sshget : rsync a remote path to cwd, then copy the local path to the clipboard
sshget() {
    command -v rsync >/dev/null 2>&1 || { print -u2 "sshget: needs rsync"; return 1; }
    local host path
    if [[ "${1:-}" == *:* ]]; then host="${1%%:*}"; path="${1#*:}"   # host:path form
    else host="$(_ssh_pick_host "${1:-}")" || return
         path="$(ssh "$host" 'command -v fd >/dev/null 2>&1 && fd -t f -H -d 5 . "$HOME" || find "$HOME" -maxdepth 5 -type f' 2>/dev/null \
            | fzf --prompt "file on $host> ")" || return
    fi
    [ -n "$host" ] && [ -n "$path" ] || return
    rsync -avzP "$host:${path}" .
    local local_path="$PWD/${path:t}"
    printf '%s' "$local_path" | pbcopy
    print -r -- "pulled -> $local_path  (path copied)"
}

#@ sshcp : copy a remote path as host:/abs/path to the clipboard (fzf-pick)
sshcp() {
    local host path
    host="$(_ssh_pick_host "${1:-}")" || return; [ -n "$host" ] || return
    path="$(ssh "$host" 'command -v fd >/dev/null 2>&1 && fd -H -d 5 . "$HOME" || find "$HOME" -maxdepth 5' 2>/dev/null \
        | fzf --prompt "path on $host> ")" || return
    [ -n "$path" ] || return
    printf '%s' "$host:$path" | pbcopy
    print -r -- "copied: $host:$path"
}
