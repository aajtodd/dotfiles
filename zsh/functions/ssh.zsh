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
# Trim surrounding whitespace: a trailing space makes ssh treat the target as a
# non-matching name, dropping any `HostName` rewrite in ~/.ssh/config (e.g. a
# dev-desk alias that rewrites to a Corp-Fabric short name), which surfaces as a
# wssh "403: unable to resolve" instead of connecting.
_ssh_pick_host() {
    local h hosts
    if [ -n "${1:-}" ]; then h="$1"
    else
        command -v fzf >/dev/null 2>&1 || { print -u2 "ssh: pass a host name, or install fzf for the picker"; return 1; }
        hosts="$(_ssh_hosts)"
        [ -n "$hosts" ] || { print -u2 "ssh: no concrete Host entries in ~/.ssh/config to pick from"; return 1; }
        h="$(print -r -- "$hosts" | fzf --prompt 'host> ')" || return
    fi
    print -r -- "${h//[[:space:]]/}"   # strip any stray whitespace
}

#@ sshto : connect to a host (fzf-pick if no arg); trailing args run as a command
# usage: sshto [host] [-- cmd...]
#   Just connects — a plain login shell, so the remote's own dotfiles/PATH apply.
#   On a dotfiles host, use the sessionizer (zjs) there for zellij; ssh stays ssh.
sshto() {
    local host rest=()
    host="$(_ssh_pick_host "${1:-}")" || return
    [ -n "$host" ] || return
    shift 2>/dev/null
    [[ "${1:-}" == -- ]] && { shift; rest=("$@"); }
    if [ ${#rest} -gt 0 ]; then
        ssh -t "$host" "${rest[@]}"      # explicit command
    else
        ssh -t "$host"                   # login shell; remote dotfiles handle the rest
    fi
}

#@ sshput : rsync local files to a host (fzf-pick or TYPE the remote dest)
# usage: sshput <file>... [host[:dest]]
#   - Bare host (or no host): fzf-pick the host, then pick/type the remote dest.
#   - host:dest given explicitly: skip both pickers (dest may be a dir or a
#     filename; ~ and relative paths resolve against the remote $HOME).
# In the dest picker, $HOME is the first candidate and you can TYPE any path
# (even one that isn't listed) — Enter accepts what you typed. A dest ending in
# "/", or selected from the list, lands INTO that dir; otherwise it's the literal
# target path (so single-file renames work). Prints where it landed.
sshput() {
    [ $# -gt 0 ] || { print -u2 "sshput: <file>... [host[:dest]]"; return 1; }
    command -v rsync >/dev/null 2>&1 || { print -u2 "sshput: needs rsync"; return 1; }
    local files=() host dest last is_dir=0
    last="${@[-1]}"
    # Explicit host:dest as the final arg -> no pickers. Detected without relying
    # on extendedglob: last arg contains a ':' and the part before it has no '/'
    # (so a local path like /a/b or ./x:y is never mistaken for a host).
    if [[ "$last" == *:* && "${last%%:*}" != */* ]]; then
        host="${last%%:*}"; dest="${last#*:}"
        files=("${@[1,-2]}")
        [ ${#files} -gt 0 ] || { print -u2 "sshput: no files (last arg was host:dest)"; return 1; }
    else
        files=("$@")
        host="$(_ssh_pick_host)" || return; [ -n "$host" ] || return
        # Candidate dirs under $HOME, with $HOME itself first. --print-query lets
        # us accept a TYPED path that isn't in the list.
        local out rc
        out="$(ssh "$host" 'printf "%s\n" "$HOME"; command -v fd >/dev/null 2>&1 && fd -t d -H -d 4 . "$HOME" || find "$HOME" -maxdepth 4 -type d' 2>/dev/null \
            | fzf --print-query --prompt "dest on $host (pick or type)> ")"
        rc=$?
        case $rc in
            0) dest="$(printf '%s\n' "$out" | sed -n 2p)"; is_dir=1 ;;  # picked from list -> a dir
            1) dest="$(printf '%s\n' "$out" | sed -n 1p)" ;;           # typed a custom path (no match)
            *) return ;;                                              # ESC / abort
        esac
    fi
    [ -n "$dest" ] || { print -u2 "sshput: empty destination"; return 1; }
    # A listed dir, or a trailing slash, means "copy INTO this dir".
    local target="$host:$dest"
    if [ "$is_dir" -eq 1 ] || [[ "$dest" == */ ]]; then target="$host:${dest%/}/"; fi
    print -r -- "sshput -> $target"
    rsync -avzP "${files[@]}" "$target"
}

#@ sshget : rsync a remote path to cwd, then copy the local path to the clipboard
sshget() {
    command -v rsync >/dev/null 2>&1 || { print -u2 "sshget: needs rsync"; return 1; }
    # NB: never name a local 'path' — zsh ties $path to $PATH, so `local path`
    # blanks PATH for the rest of the function (and its subshells), breaking
    # every later command lookup. Use rpath for the remote path.
    local host rpath
    if [[ "${1:-}" == *:* ]]; then host="${1%%:*}"; rpath="${1#*:}"   # host:path form
    else host="$(_ssh_pick_host "${1:-}")" || return
         rpath="$(ssh "$host" 'command -v fd >/dev/null 2>&1 && fd -t f -H -d 5 . "$HOME" || find "$HOME" -maxdepth 5 -type f' 2>/dev/null \
            | fzf --prompt "file on $host> ")" || return
    fi
    [ -n "$host" ] && [ -n "$rpath" ] || return
    rsync -avzP "$host:${rpath}" .
    local local_path="$PWD/${rpath:t}"
    printf '%s' "$local_path" | pbcopy
    print -r -- "pulled -> $local_path  (path copied)"
}

#@ sshcp : copy a remote path as host:/abs/path to the clipboard (fzf-pick)
sshcp() {
    local host rpath   # not 'path': zsh binds $path to $PATH (see sshget note)
    host="$(_ssh_pick_host "${1:-}")" || return; [ -n "$host" ] || return
    rpath="$(ssh "$host" 'command -v fd >/dev/null 2>&1 && fd -H -d 5 . "$HOME" || find "$HOME" -maxdepth 5' 2>/dev/null \
        | fzf --prompt "path on $host> ")" || return
    [ -n "$rpath" ] || return
    printf '%s' "$host:$rpath" | pbcopy
    print -r -- "copied: $host:$rpath"
}
