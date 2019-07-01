# Golang
export GOPATH="$HOME/sandbox/gopath"
export PATH="$GOPATH/bin:$PATH"

# Rust
export PATH="$HOME/.cargo/bin:$PATH"
export RUST_SRC_PATH="$(rustc --print sysroot)/lib/rustlib/src/rust/src"

# Misc

# by default don't search golang vendor directories when grepping with rg
alias rg="rg --glob '!/vendor'"

# FZF
export FZF_DEFAULT_COMMAND="rg --files --no-ignore --hidden --follow --glob '!.git/*' --glob '!.svn/*'"
#bind -x '"\C-p": nvim $(fzf);'

#fzf-edit() {
#    nvim "$(fzf)"
#}
#
#zle -N fzf-edit
#bindkey '^p' fzf-edit
bindkey -s '^p' 'nvim $(fzf)\n'

# Misc

