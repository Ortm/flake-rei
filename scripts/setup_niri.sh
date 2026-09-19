#!/usr/bin/env bash
set -euo pipefail

# Symlink niri config for the current machine.
# Usage:
#   export FLAKE_MACHINE=icelake
#   ./scripts/setup_niri.sh

if [ -z "${FLAKE_MACHINE:-}" ]; then
    echo "Error: FLAKE_MACHINE environment variable not set." >&2
    echo 'Run: export FLAKE_MACHINE=icelake' >&2
    exit 1
fi

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
FLAKE_DIR="$(dirname -- "$SCRIPT_DIR")"
NIRI_DIR="$HOME/.config/niri"

SRC_CONFIG="$FLAKE_DIR/dotfiles/niri/config_${FLAKE_MACHINE}.kdl"
SRC_GENERIC="$FLAKE_DIR/dotfiles/niri/generic"
SRC_MACHINE="$FLAKE_DIR/dotfiles/niri/${FLAKE_MACHINE}"

for src in "$SRC_CONFIG" "$SRC_GENERIC" "$SRC_MACHINE"; do
    if [ ! -e "$src" ]; then
        echo "Error: source not found: $src" >&2
        echo "Check that FLAKE_MACHINE='$FLAKE_MACHINE' is correct." >&2
        exit 1
    fi
done

# Backup existing config dir (or symlink) before overwriting
if [ -e "$NIRI_DIR" ] || [ -L "$NIRI_DIR" ]; then
    backup="$HOME/.config/niri.bak.$(date +%Y%m%d-%H%M%S)"
    echo "Backing up existing $NIRI_DIR -> $backup"
    mv -- "$NIRI_DIR" "$backup"
fi

mkdir -p -- "$NIRI_DIR"
ln -sfn -- "$SRC_CONFIG" "$NIRI_DIR/config.kdl"
ln -sfn -- "$SRC_GENERIC" "$NIRI_DIR/generic"
ln -sfn -- "$SRC_MACHINE" "$NIRI_DIR/$FLAKE_MACHINE"

echo "Niri config linked for machine '$FLAKE_MACHINE':"
ls -l -- "$NIRI_DIR"
