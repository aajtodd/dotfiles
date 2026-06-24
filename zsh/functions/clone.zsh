#@@ clone : clone a repo to a known spot (for giving Claude a library to inspect)
# Persistent clones land in ~/sandbox/rs/3P/<repo>; -t puts a throwaway in /tmp.
# Accepts full URLs or GitHub shorthand (owner/repo). cd's into the clone.

#@ clone : clone a repo to ~/sandbox/rs/3P (-t = /tmp throwaway)
clone() {
    local base="$HOME/sandbox/rs/3P"
    [[ "${1:-}" == -t ]] && { base="/tmp"; shift; }
    local url="${1:-}"
    [ -n "$url" ] || { print -u2 "clone: [-t] <url|owner/repo>"; return 1; }
    # owner/repo shorthand -> github https
    [[ "$url" != *://* && "$url" != git@* && "$url" == */* ]] && url="https://github.com/$url"
    local name="${${url##*/}%.git}"
    local dest="$base/$name"
    if [ -d "$dest/.git" ]; then
        print -r -- "clone: already at $dest (pulling)"; git -C "$dest" pull --ff-only
    else
        mkdir -p "$base" && git clone --depth 1 "$url" "$dest" || return
    fi
    cd "$dest"
}
