# Amazon Q pre block. Keep at the top of this file.
[[ -f "${HOME}/Library/Application Support/amazon-q/shell/zprofile.pre.zsh" ]] && builtin source "${HOME}/Library/Application Support/amazon-q/shell/zprofile.pre.zsh"
# Golang
export GOPATH="$HOME/sandbox/gopath"
export PATH="$GOPATH/bin:$PATH"

# Rust
export RUST_SRC_PATH="$(rustc --print sysroot)/lib/rustlib/src/rust/src"
source "$HOME/.cargo/env"

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

# Amazon Q post block. Keep at the bottom of this file.
[[ -f "${HOME}/Library/Application Support/amazon-q/shell/zprofile.post.zsh" ]] && builtin source "${HOME}/Library/Application Support/amazon-q/shell/zprofile.post.zsh"
