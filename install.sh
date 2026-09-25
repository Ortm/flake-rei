#!/usr/bin/env bash
set -euo pipefail

# First system-build with home-manager.
# Usage:
#   ./install.sh [--machine <name>] [--no-niri] [--yes]
#   ./install.sh icelake
#   FLAKE_MACHINE=icelake ./install.sh
#
# Replaces the manual README steps:
#   export FLAKE_MACHINE=<machine name>
#   nix run ... home-manager/master -- switch --flake ...

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
FLAKE_DIR="$SCRIPT_DIR"

MACHINE="${FLAKE_MACHINE:-}"
NO_NIRI=0
ASSUME_YES=0

usage() {
    echo "Usage: ./install.sh [--machine <name>] [--no-niri] [--yes]"
    echo ""
    echo "Available machines:"
    for d in "$FLAKE_DIR"/machines/*/; do
        [ -d "$d" ] && echo "  - $(basename "$d")"
    done
}

while [ $# -gt 0 ]; do
    case "$1" in
        -m|--machine)
            MACHINE="${2:-}"
            shift 2
            ;;
        --no-niri)
            NO_NIRI=1
            shift
            ;;
        -y|--yes)
            ASSUME_YES=1
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        -*)
            echo "Unknown option: $1" >&2
            usage >&2
            exit 1
            ;;
        *)
            # positional machine name
            if [ -n "$MACHINE" ]; then
                echo "Machine already set to '$MACHINE', unexpected argument: $1" >&2
                exit 1
            fi
            MACHINE="$1"
            shift
            ;;
    esac
done

# Interactive choice when nothing given
if [ -z "$MACHINE" ]; then
    mapfile -t AVAILABLE < <(for d in "$FLAKE_DIR"/machines/*/; do [ -d "$d" ] && basename "$d"; done)
    if [ "${#AVAILABLE[@]}" -eq 0 ]; then
        echo "No machines found in $FLAKE_DIR/machines/" >&2
        exit 1
    fi
    if [ "${#AVAILABLE[@]}" -eq 1 ]; then
        MACHINE="${AVAILABLE[0]}"
        echo "Using machine: $MACHINE"
    else
        echo "Select machine:"
        select choice in "${AVAILABLE[@]}"; do
            if [ -n "${choice:-}" ]; then
                MACHINE="$choice"
                break
            fi
        done < /dev/tty
    fi
fi

if [ -z "$MACHINE" ]; then
    echo "Machine name not set." >&2
    usage >&2
    exit 1
fi

if [ ! -d "$FLAKE_DIR/machines/$MACHINE" ]; then
    echo "Unknown machine '$MACHINE'. Available:" >&2
    for d in "$FLAKE_DIR"/machines/*/; do [ -d "$d" ] && echo "  - $(basename "$d")" >&2; done
    exit 1
fi

export FLAKE_MACHINE="$MACHINE"

# Preflight: nix binary
if ! command -v nix >/dev/null 2>&1; then
    echo "nix not found. Install it first:" >&2
    echo "  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install" >&2
    exit 1
fi

# Preflight: daemon (non-NixOS multi-user)
if systemctl list-unit-files 2>/dev/null | grep -q nix-daemon; then
    if ! systemctl is-active --quiet nix-daemon.service nix-daemon.socket 2>/dev/null; then
        echo "nix-daemon is not running, starting it..."
        sudo systemctl enable --now nix-daemon.socket nix-daemon.service
    fi
fi

# Preflight: nix-users group (distro/Determinate multi-user setups)
if getent group nix-users >/dev/null 2>&1 && ! id -nG "$USER" | tr ' ' '\n' | grep -qx nix-users; then
    echo "Adding $USER to nix-users group (needs re-login to take effect)..."
    sudo usermod -aG nix-users "$USER"
    if [ "$ASSUME_YES" -eq 0 ]; then
        echo "NOTE: group membership applies after re-login. Continuing anyway..." >&2
    fi
fi

echo "Switching home-manager for machine '$MACHINE'..."
nix --experimental-features "nix-command flakes" run home-manager/master -- \
    switch --flake "$FLAKE_DIR#$MACHINE" -b backup \
    --experimental-features "nix-command flakes"

if [ "$NO_NIRI" -eq 0 ] && [ -x "$FLAKE_DIR/scripts/setup_niri.sh" ]; then
    if [ -e "$FLAKE_DIR/dotfiles/niri/config_${MACHINE}.kdl" ] || [ -e "$FLAKE_DIR/dotfiles/niri/${MACHINE}" ]; then
        echo "Linking niri config..."
        "$FLAKE_DIR/scripts/setup_niri.sh"
    else
        echo "No niri dotfiles for '$MACHINE', skipping setup_niri.sh."
    fi
fi

echo "Done. Machine '$MACHINE' installed."
