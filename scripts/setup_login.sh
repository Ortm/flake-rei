#!/usr/bin/env bash
# Turn this machine's login screen into greetd + niri + gtkgreet (see the
# README, "Login screen"). Run it from the repo, as root:
#
#     sudo ./scripts/setup_login.sh
#
# It is idempotent: re-run it after changing login/ (stylesheet, wallpaper,
# greeter config) to publish the new version.
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GREETER_USER=greeter
# Stable path the greeter reads its files from. It is a GC root, so the built
# bundle survives `nix-collect-garbage`, and it is world-readable - which is
# what makes it usable by the greeter user (see login/default.nix).
BUNDLE_LINK=/nix/var/nix/gcroots/rei-login
BUNDLE_DIR="$BUNDLE_LINK/share/rei-login"

say() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
die() { printf '\033[1;31m!!!\033[0m %s\n' "$*" >&2; exit 1; }

[ "$(id -u)" -eq 0 ] || die "run me with sudo: sudo ./scripts/setup_login.sh"
[ -f "$REPO/flake.nix" ] || die "$REPO does not look like the flake-rei checkout"

say "installing greetd, gtkgreet and swaybg"
pacman -S --needed --noconfirm greetd greetd-gtkgreet swaybg

say "making sure the '$GREETER_USER' user exists"
if ! getent passwd "$GREETER_USER" > /dev/null; then
  useradd -r -M -d /var/lib/greeter -s /usr/bin/nologin "$GREETER_USER"
fi
greeter_home="$(getent passwd "$GREETER_USER" | cut -d: -f6)"
if [ -n "$greeter_home" ] && [ ! -d "$greeter_home" ]; then
  install -d -o "$GREETER_USER" -g "$GREETER_USER" -m 700 "$greeter_home"
fi

say "building the login bundle and publishing it at $BUNDLE_LINK"
bundle="$(nix build --no-link --print-out-paths "$REPO#loginBundle")"
ln -sfn "$bundle" "$BUNDLE_LINK"

say "checking the greeter has everything it needs"
for bin in niri gtkgreet swaybg niri-session; do
  command -v "$bin" > /dev/null || die "$bin is missing - aborting before touching the display manager"
done
[ -r "$BUNDLE_DIR/niri-greeter.kdl" ] || die "$BUNDLE_DIR/niri-greeter.kdl is not readable"

say "writing /etc/greetd/config.toml"
install -d -m 755 /etc/greetd
if [ -f /etc/greetd/config.toml ] && ! grep -q 'rei-login' /etc/greetd/config.toml; then
  cp /etc/greetd/config.toml /etc/greetd/config.toml.rei-backup
  say "(previous config saved as /etc/greetd/config.toml.rei-backup)"
fi
cat > /etc/greetd/config.toml <<EOF
# Written by flake-rei (scripts/setup_login.sh). See README, "Login screen".
[terminal]
# "next" picks the first free VT, so greetd never fights a getty for tty1.
vt = "next"
switch = true

[default_session]
command = "niri --config $BUNDLE_DIR/niri-greeter.kdl"
user = "$GREETER_USER"
EOF

say "switching the display manager over to greetd"
for dm in sddm gdm lightdm ly; do
  if systemctl -q is-enabled "$dm.service" 2> /dev/null; then
    systemctl disable --now "$dm.service" || true
    say "disabled $dm.service"
  fi
done
systemctl enable greetd.service

say "done. Reboot to see the new login screen."
say ""
say "If it does not come up: switch to a TTY (Ctrl+Alt+F2), log in, and run"
say "  sudo systemctl disable --now greetd && sudo systemctl enable --now sddm"
say "to get the old login screen back."
