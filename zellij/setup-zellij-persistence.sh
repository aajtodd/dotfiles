#!/bin/bash
# Make zellij sessions survive SSH disconnect / logout on a Linux (systemd) host.
#
# Why this is needed
# ------------------
# systemd-logind defaults to KillUserProcesses=yes: when your last login session
# ends (e.g. an SSH drop), it tears down that session's cgroup scope and SIGTERMs
# everything in it -- including the zellij server. The session is resurrectable,
# but the PROCESSES running inside it (an overnight build/test) are killed.
#
# The fix is two halves; this script does the one-time half:
#   1. (here) enable "lingering" so the per-user `systemd --user` manager keeps
#      running even with no active login session.
#   2. (in zjs) start the zellij SERVER inside a lingering `systemd-run --user`
#      SERVICE via `zellij attach --create-background` -- the service is owned by
#      the user manager and survives logout. (A `--scope` does NOT survive here:
#      it is bound to the SSH session cgroup and is killed with it on disconnect,
#      which is why a service, not a scope, is used.)
#
# Lingering ALONE is not enough (a bare process in the session scope is killed on
# disconnect); the user-service wrapper in zjs is the other required half.
#
# Idempotent + safe to run standalone (to fix an existing box) or from
# bootstrap-al2023.sh (fresh box). No-op on non-systemd hosts (e.g. macOS).
set -euo pipefail

# macOS / any host without systemd: nothing to do.
if ! command -v loginctl >/dev/null 2>&1; then
    echo "zellij-persistence: no loginctl (not a systemd host) -- nothing to do."
    exit 0
fi

if ! command -v systemd-run >/dev/null 2>&1; then
    echo "zellij-persistence: WARNING -- systemd-run not found; the zjs scope" >&2
    echo "  wrapper won't work even with linger enabled. Install systemd tooling." >&2
fi

user="${USER:-$(id -un)}"

# enable-linger is idempotent, but check first so a re-run is quiet + informative.
if [ "$(loginctl show-user "$user" --property=Linger --value 2>/dev/null)" = "yes" ]; then
    echo "zellij-persistence: linger already enabled for $user."
else
    echo "zellij-persistence: enabling linger for $user (needs sudo)..."
    sudo loginctl enable-linger "$user"
    echo "zellij-persistence: linger enabled."
    echo "  NOTE: takes full effect on your next fresh login. Existing sessions"
    echo "  started before this may still be tied to the old session scope."
fi

echo "zellij-persistence: done. New zellij sessions started via 'zjs' on this host"
echo "  will survive SSH disconnect."
