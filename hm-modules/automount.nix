# Auto-mount removable drives — the USB player, flash drives.
#
# udisks2 is the system service that does the actual mounting, but it never
# mounts anything by itself: it waits until something asks (a file manager, or
# `udisksctl mount -b /dev/sdX`). udiskie is that something, running per-user
# and watching udisks2's D-Bus signals, so a drive that is plugged in — or was
# already attached at login — ends up mounted at /run/media/<user>/<LABEL>.
# That is the path ym-player-sync expects for the player
# (rei.ymPlayerSync.playerDir).
#
# Every disk is also mirrored into /mnt: udisks2's mount location is compiled
# in and cannot be configured, so the mirror script below keeps /mnt/<name> as
# a symlink to whatever is mounted under /run/media — created on mount,
# removed when the disk is unmounted or unplugged. One-time host step: /mnt
# must be writable by your user (`sudo chown $USER /mnt`).
#
# Host prerequisite: udisks2 (Arch: `pacman -S udisks2`, the "Disk Manager"
# service). Nothing else is needed — udiskie itself comes from this flake.
{ pkgs, ... }:

let
  # Runs on every udiskie device event, and once at startup. It reconciles
  # /mnt with the real mount state, so it takes no arguments and is
  # idempotent: every mount under /run/media gets a /mnt symlink; symlinks
  # whose disk is gone get removed.
  mntMirror = pkgs.writeShellScript "mnt-mirror" ''
    set -u
    media="/run/media/$(id -un)"

    if [ -d "$media" ]; then
      findmnt -lno TARGET 2>/dev/null | grep -F "$media/" | while read -r mp; do
        [ -n "$mp" ] || continue
        mp="''${mp//\\x20/ }" # findmnt escapes spaces in labels as \x20
        ln -sfn "$mp" "/mnt/''${mp#"$media"/}"
      done
    fi

    for l in /mnt/*; do
      [ -L "$l" ] || continue
      target="$(readlink "$l")"
      case "$target" in
        "$media"/*) [ -e "$target" ] || rm -f "$l" ;;
      esac
    done
    exit 0
  '';
in
{
  services.udiskie = {
    enable = true;
    automount = true; # mount new devices (and ones already attached at login)
    notify = true; # pop-up saying what was mounted
    tray = "auto"; # tray icon only while a device is attached

    # event_hook is udiskie's supported way to run a command on device events
    # (mount, unmount, add, remove, lock, unlock) — used here to keep the
    # /mnt mirrors in sync.
    settings.program_options.event_hook = "${mntMirror}";
  };

  # Once more at startup, for disks that were already mounted when udiskie
  # (re)started.
  systemd.user.services.udiskie.Service.ExecStartPost = "${mntMirror}";
}
