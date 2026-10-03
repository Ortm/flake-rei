# Auto-mount removable drives — the external SSD, the USB player, flash drives.
#
# udisks2 is the system service that does the actual mounting, but it never
# mounts anything by itself: it waits until something asks (a file manager, or
# `udisksctl mount -b /dev/sdX`). udiskie is that something, running per-user
# and watching udisks2's D-Bus signals, so a drive that is plugged in — or was
# already attached at login — ends up mounted at /run/media/<user>/<LABEL>.
# That is the path ym-player-sync expects for the player
# (rei.ymPlayerSync.playerDir) and where the SSD shows up.
#
# Host prerequisite: udisks2 (Arch: `pacman -S udisks2`, the "Disk Manager"
# service). Nothing else is needed — udiskie itself comes from this flake.
{ ... }:

{
  services.udiskie = {
    enable = true;
    automount = true; # mount new devices (and ones already attached at login)
    notify = true; # pop-up saying what was mounted
    tray = "auto"; # tray icon only while a device is attached
  };
}
