# Golang
export GOPATH="$HOME/sandbox/gopath"
[ -d "$GOPATH/bin" ] && export PATH="$GOPATH/bin:$PATH"

# Rust
command -v rustc >/dev/null 2>&1 && export RUST_SRC_PATH="$(rustc --print sysroot)/lib/rustlib/src/rust/src"

# Amazon
export BRAZIL_WORKSPACE_DEFAULT_LAYOUT=short
# if you wish to use IMDS set AWS_EC2_METADATA_DISABLED=false
export AWS_EC2_METADATA_DISABLED=true

# SSH connection env, published for multiplexer panes
#
# The zellij server runs as a detached, lingering systemd --user service, so it
# captures its environment once and every later `zellij attach` connects to that
# frozen env. Panes therefore inherit stale/empty SSH_* vars — SSH_AUTH_SOCK
# points at a dead agent socket (git push / ssh break after a reconnect),
# SSH_CONNECTION/SSH_TTY are empty (SSH detection fails). This login shell is the
# only place the *live* values exist, so publish them for panes to pick up (see
# the consume block in .zshrc), and stabilize the agent socket behind a fixed
# symlink so forwarded auth survives reconnects. tmux gets the same benefit.
if [[ -n "$SSH_CONNECTION" ]]; then
    _ssh_env_dir="${XDG_RUNTIME_DIR:-$HOME/.cache}"
    # Repoint a stable path at this login's forwarded agent socket, then hand
    # that stable path to everything downstream — so old panes keep resolving a
    # live socket as the underlying forwarded sock changes each reconnect.
    if [[ -S "$SSH_AUTH_SOCK" ]]; then
        ln -sfn "$SSH_AUTH_SOCK" "$_ssh_env_dir/ssh-agent.sock" 2>/dev/null \
            && export SSH_AUTH_SOCK="$_ssh_env_dir/ssh-agent.sock"
    fi
    # Publish the live connection env (single-quoted: SSH_CONNECTION has spaces).
    {
        print -r -- "export SSH_CONNECTION='${SSH_CONNECTION}'"
        print -r -- "export SSH_CLIENT='${SSH_CLIENT}'"
        print -r -- "export SSH_TTY='${SSH_TTY}'"
        print -r -- "export SSH_AUTH_SOCK='${SSH_AUTH_SOCK}'"
        [[ -n "$DISPLAY" ]] && print -r -- "export DISPLAY='${DISPLAY}'"
    } > "$_ssh_env_dir/ssh-env" 2>/dev/null
    unset _ssh_env_dir
fi
