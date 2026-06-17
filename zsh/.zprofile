# Golang
export GOPATH="$HOME/sandbox/gopath"
[ -d "$GOPATH/bin" ] && export PATH="$GOPATH/bin:$PATH"

# Rust
command -v rustc >/dev/null 2>&1 && export RUST_SRC_PATH="$(rustc --print sysroot)/lib/rustlib/src/rust/src"

# Amazon
export BRAZIL_WORKSPACE_DEFAULT_LAYOUT=short
# if you wish to use IMDS set AWS_EC2_METADATA_DISABLED=false
export AWS_EC2_METADATA_DISABLED=true
