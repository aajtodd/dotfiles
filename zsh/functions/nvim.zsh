#@@ nvim : editor launchers, incl. an isolated config sandbox (NVIM_APPNAME)
# NVIM_APPNAME makes nvim read a DIFFERENT set of dirs — config ~/.config/<name>,
# data ~/.local/share/<name>, state ~/.local/state/<name>, cache ~/.cache/<name> —
# fully isolated from the default `nvim`. `nvim-dev` is a STANDING sandbox for trying
# a plugin/setting/config change without any risk to the daily editor (own plugins +
# own lazy-lock). See `dot nvim` for the workflow.
#
# NVIM_APPNAME isolates CONFIG, not the BINARY. To test config that needs a newer
# Neovim than the daily one, nvim-dev prefers a separate pinned build if present
# (~/opt/nvim-0.12) and otherwise falls back to whatever `nvim` is on PATH. This keeps
# the daily editor on its own version while the sandbox runs the newer one.

#@ nvim-dev : launch the sandbox config (~/.config/nvim-dev) on a newer nvim if present
nvim-dev() {
    local bin="$HOME/opt/nvim-0.12/bin/nvim"
    [ -x "$bin" ] || bin="$(command -v nvim)"
    NVIM_APPNAME=nvim-dev "$bin" "$@"
}
