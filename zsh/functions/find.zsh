#@@ find : fzf-powered search/pick helpers
# rg/fd piped through fzf for the common "find it and act on it" loops.

#@ frg : ripgrep -> fzf -> open the chosen match in nvim at its line
frg() {
    command -v rg  >/dev/null 2>&1 || { print -u2 "frg: needs ripgrep"; return 1; }
    command -v fzf >/dev/null 2>&1 || { print -u2 "frg: needs fzf"; return 1; }
    [ -n "${1:-}" ] || { print -u2 "frg: <pattern>"; return 1; }
    local hit file line
    hit="$(rg --line-number --no-heading --color=always "$@" 2>/dev/null \
        | fzf --ansi --delimiter=: --with-nth=1,3.. \
              --preview 'bat --color=always --highlight-line {2} {1}')" || return
    file="${hit%%:*}"; line="${${hit#*:}%%:*}"
    [ -n "$file" ] && ${EDITOR:-nvim} "+${line}" "$file"
}

#@ ff : fd -> fzf -> open the chosen file in nvim
ff() {
    command -v fzf >/dev/null 2>&1 || { print -u2 "ff: needs fzf"; return 1; }
    local f
    f="$(${FZF_DEFAULT_COMMAND:-fd --type f} 2>/dev/null | fzf --prompt 'open> ' \
        --preview 'bat --color=always {}')" || return
    [ -n "$f" ] && ${EDITOR:-nvim} "$f"
}

#@ fkill : fzf-pick a process and kill it
fkill() {
    command -v fzf >/dev/null 2>&1 || { print -u2 "fkill: needs fzf"; return 1; }
    local pids
    pids="$(ps -eo pid,ppid,%cpu,%mem,comm 2>/dev/null | sed 1d \
        | fzf --multi --prompt 'kill> ' --header 'PID PPID %CPU %MEM COMMAND' \
        | awk '{print $1}')" || return
    [ -n "$pids" ] || return
    print -r -- "$pids" | while read -r p; do kill "${p}" 2>/dev/null || kill -9 "${p}"; done
}

#@ fcd : fd directories -> fzf -> cd into the chosen one
fcd() {
    command -v fzf >/dev/null 2>&1 || { print -u2 "fcd: needs fzf"; return 1; }
    local d
    d="$(fd --type d 2>/dev/null | fzf --prompt 'cd> ')" || return
    [ -n "$d" ] && cd "$d"
}
