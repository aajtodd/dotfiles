#!/bin/bash
# Build the vendored zellij plugins from pinned source.
#
# Why this exists: some zellij plugins we rely on have no usable upstream
# release for our zellij version (e.g. zellij-autolock is broken on 0.44 and
# unmaintained -- see zellij/plugins.lock). Rather than trust a stranger's
# prebuilt .wasm, we build each plugin ourselves from a pinned commit and
# verify the checked-out SHA matches the lockfile before building.
#
# The built .wasm files are gitignored (build-on-demand); plugins.lock is the
# committed source of truth. Run this once on a new machine (or to refresh a
# pin), then `stow zellij` to symlink the plugins into ~/.config/zellij.
#
# Usage:   zellij/build-plugins.sh
# Deps:    git, cargo (rustup). The wasm target is auto-installed if missing.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOCKFILE="$SCRIPT_DIR/plugins.lock"
OUT_DIR="$SCRIPT_DIR/.config/zellij/plugins"

if ! command -v cargo >/dev/null 2>&1; then
  echo "error: cargo not found. Install rust (rustup) first." >&2
  exit 1
fi
if [ ! -f "$LOCKFILE" ]; then
  echo "error: lockfile not found at $LOCKFILE" >&2
  exit 1
fi

mkdir -p "$OUT_DIR"
BUILD_ROOT="$(mktemp -d)"
trap 'rm -rf "$BUILD_ROOT"' EXIT

built=0
# Read the lockfile: name | repo | ref | sha | target | note  (# = comment)
while IFS='|' read -r name repo ref sha target note || [ -n "$name" ]; do
  # skip blanks and comments
  case "$(printf '%s' "$name" | tr -d '[:space:]')" in ''|\#*) continue ;; esac

  name="$(printf '%s' "$name" | xargs)"
  repo="$(printf '%s' "$repo" | xargs)"
  ref="$(printf '%s' "$ref" | xargs)"
  sha="$(printf '%s' "$sha" | xargs)"
  target="$(printf '%s' "$target" | xargs)"

  echo "==> $name  ($ref @ ${sha:0:12})"

  # Ensure the wasm target is available.
  if ! rustup target list --installed 2>/dev/null | grep -qx "$target"; then
    echo "    installing rust target $target"
    rustup target add "$target"
  fi

  src="$BUILD_ROOT/$name"
  git clone --quiet --branch "$ref" --depth 1 "$repo" "$src"

  # Provenance/security: the checked-out commit MUST match the pinned SHA.
  # Guards against a force-pushed tag pointing somewhere new.
  actual="$(git -C "$src" rev-parse HEAD)"
  if [ "$actual" != "$sha" ]; then
    echo "    ERROR: $ref resolved to $actual, expected $sha (pin drifted!)" >&2
    exit 1
  fi

  ( cd "$src" && cargo build --quiet --release --target "$target" )

  wasm="$src/target/$target/release/$name.wasm"
  if [ ! -f "$wasm" ]; then
    echo "    ERROR: expected artifact not found: $wasm" >&2
    exit 1
  fi
  cp "$wasm" "$OUT_DIR/$name.wasm"

  # Write provenance next to the binary so it's obvious what this blob is.
  {
    echo "name:   $name"
    echo "repo:   $repo"
    echo "ref:    $ref"
    echo "commit: $sha"
    echo "target: $target"
    echo "note:   $note"
    echo "built:  $(date -u +%Y-%m-%dT%H:%M:%SZ) on $(uname -srm)"
  } > "$OUT_DIR/$name.provenance"

  echo "    built -> $OUT_DIR/$name.wasm"
  built=$((built + 1))
done < "$LOCKFILE"

echo "Done. Built $built plugin(s) into $OUT_DIR"
echo "Next: 'stow zellij' (if not already) to symlink into ~/.config/zellij/plugins"
