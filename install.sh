#!/usr/bin/env bash
set -euo pipefail

# First system-build with home-manager.
# Usage:
#   ./install.sh [--machine <name>] [--no-niri] [--yes]
#   ./install.sh icelake
#   FLAKE_MACHINE=icelake ./install.sh
#
# The configuration is installed for whoever runs this script: hm-modules/user.nix
# fills home.username / home.homeDirectory from the environment (that is why the
# switch below passes --impure), so a fresh clone needs no edit first.
#
# Replaces the manual README steps:
#   export FLAKE_MACHINE=<machine name>
#   nix run ... home-manager/master -- switch --flake ... --impure

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
FLAKE_DIR="$SCRIPT_DIR"

INSTALL_USER="$(id -un)"
INSTALL_HOME="$(getent passwd "$INSTALL_USER" 2>/dev/null | cut -d: -f6 || true)"
[ -n "$INSTALL_HOME" ] || INSTALL_HOME="$HOME"

MACHINE=""
MACHINE_FROM_ENV="${FLAKE_MACHINE:-}"
NO_NIRI=0
ASSUME_YES=0

# Machine dirs are exactly the ones the flake exposes as `.#<name>`
# (machines/<name>/default.nix).
list_machines() {
    for d in "$FLAKE_DIR"/machines/*/; do
        [ -f "${d}default.nix" ] && basename "$d"
    done
}

usage() {
    echo "Usage: ./install.sh [--machine <name>] [--no-niri] [--yes]"
    echo ""
    echo "Available machines:"
    list_machines | sed 's/^/  - /'
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
            # positional machine name; an explicit name beats FLAKE_MACHINE
            if [ -n "$MACHINE" ]; then
                echo "Only one machine name expected, unexpected argument: $1" >&2
                exit 1
            fi
            MACHINE="$1"
            shift
            ;;
    esac
done

# FLAKE_MACHINE=<name> in the environment (it is a session variable on
# already-installed machines) applies when nothing was given on the CLI.
[ -n "$MACHINE" ] || MACHINE="$MACHINE_FROM_ENV"

# Interactive choice when nothing given
if [ -z "$MACHINE" ]; then
    mapfile -t AVAILABLE < <(list_machines)
    if [ "${#AVAILABLE[@]}" -eq 0 ]; then
        echo "No machines found in $FLAKE_DIR/machines/" >&2
        echo "Create one with a default.nix in machines/<name>/ and re-run." >&2
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

if [ ! -f "$FLAKE_DIR/machines/$MACHINE/default.nix" ]; then
    echo "Unknown machine '$MACHINE'. Available:" >&2
    list_machines | sed 's/^/  - /' >&2
    exit 1
fi

export FLAKE_MACHINE="$MACHINE"

# Preflight: nix binary
if ! command -v nix >/dev/null 2>&1; then
    echo "nix not found. Install it first:" >&2
    echo "  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install" >&2
    exit 1
fi

# Flakes only see git-tracked files: a machine directory that was just added
# must be registered or evaluation fails with "not tracked by Git".
if [ -d "$FLAKE_DIR/.git" ] && command -v git >/dev/null 2>&1; then
    if [ -n "$(git -C "$FLAKE_DIR" ls-files --others --exclude-standard -- "machines/$MACHINE")" ]; then
        echo "Registering machines/$MACHINE with git (flakes ignore untracked files)..."
        git -C "$FLAKE_DIR" add --intent-to-add -- "machines/$MACHINE"
    fi
fi

# Preflight: daemon (non-NixOS multi-user)
if systemctl list-unit-files 2>/dev/null | grep -q nix-daemon; then
    if ! systemctl is-active --quiet nix-daemon.service nix-daemon.socket 2>/dev/null; then
        echo "nix-daemon is not running, starting it..."
        sudo systemctl enable --now nix-daemon.socket nix-daemon.service
    fi
fi

# Preflight: nix-users group (distro/Determinate multi-user setups)
if getent group nix-users >/dev/null 2>&1 && ! id -nG "$INSTALL_USER" | tr ' ' '\n' | grep -qx nix-users; then
    echo "Adding $INSTALL_USER to nix-users group (needs re-login to take effect)..."
    sudo usermod -aG nix-users "$INSTALL_USER"
    if [ "$ASSUME_YES" -eq 0 ]; then
        echo "NOTE: group membership applies after re-login. Continuing anyway..." >&2
    fi
fi

# Nix needs to know which system to build for. Detect it so the same checkout
# installs on x86_64-linux and aarch64-linux alike; FLAKE_SYSTEM=<system>
# overrides it (e.g. for a cross build).
if [ -z "${FLAKE_SYSTEM:-}" ]; then
    FLAKE_SYSTEM="$(nix --experimental-features "nix-command flakes" eval --raw --impure --expr builtins.currentSystem 2>/dev/null || true)"
    FLAKE_SYSTEM="${FLAKE_SYSTEM:-x86_64-linux}"
fi
export FLAKE_SYSTEM

echo "Installing machine '$MACHINE' for user '$INSTALL_USER' (home: $INSTALL_HOME, system: $FLAKE_SYSTEM)"
nix --experimental-features "nix-command flakes" run home-manager/master -- \
    switch --flake "$FLAKE_DIR#$MACHINE" -b backup --impure \
    --experimental-features "nix-command flakes"

if [ "$NO_NIRI" -eq 0 ] && [ -x "$FLAKE_DIR/scripts/setup_niri.sh" ]; then
    if [ -e "$FLAKE_DIR/dotfiles/niri/config_${MACHINE}.kdl" ] || [ -e "$FLAKE_DIR/dotfiles/niri/${MACHINE}" ]; then
        echo "Linking niri config..."
        "$FLAKE_DIR/scripts/setup_niri.sh"
    else
        echo "No niri dotfiles for '$MACHINE', skipping setup_niri.sh."
    fi
fi

# Identity is optional: without rei.user.email git keeps asking until it is set.
if ! grep -q "rei\.user" "$FLAKE_DIR/machines/$MACHINE/default.nix"; then
    echo
    echo "No git/jujutsu identity set for '$MACHINE'. Add to machines/$MACHINE/default.nix:"
    echo "  rei.user = { name = \"Your Name\"; email = \"you@example.com\"; };"
fi

echo "Done. Machine '$MACHINE' installed."
