# MPD — the music player daemon that the rmpc TUI (hm-modules/sound/rmpc) is a
# client of. Runs as a user service and listens on localhost only (the defaults
# rmpc's config.ron expects: 127.0.0.1:6600).
#
# The library is ~/Music, which is also where `ym-player-sync download` stages
# the Yandex Music playlist (~/Music/ym-player-sync), so music shows up in rmpc
# as soon as it lands there — the USB player is a copy of the same files. The
# SSD's collection is linked into the same directory (hm-modules/music-library.nix).
{ config, pkgs, ... }:
{
  services.mpd = {
    enable = true;
    musicDirectory = "${config.home.homeDirectory}/Music";

    # mpd plays nothing until an output is declared. This is the same stack mpv
    # uses (ao = "pipewire,alsa" in hm-modules/sound/mpv.nix).
    extraConfig = ''
      audio_output {
        type "pipewire"
        name "PipeWire"
      }

      # Notice files that appear in the library without a manual update.
      auto_update "yes"
      restore_paused "yes"
    '';
  };

  # The SSD's fstab mount can land after mpd starts (the disk is slow to spin
  # up: systemd's mount attempt times out and udiskie mounts it a moment
  # later). mpd scans only at startup and never notices a mount appearing
  # inside an already-scanned directory, so on those boots the SSD half of the
  # library stayed out of the db until a manual update. This timer re-checks
  # every minute: if mpd's db holds no ssd/ tracks it asks for a rescan, and
  # it's a cheap no-op otherwise. It also self-heals a db that went stale some
  # other way (e.g. an update that ran while the SSD was unmounted).
  systemd.user.services.mpd-rescan = {
    Unit.Description = "Ask mpd to rescan if the SSD tracks are missing from the db";
    Service = {
      Type = "oneshot";
      ExecStart = "${pkgs.bash}/bin/bash -c 'ok=0; for ((i=0;i<90;i++)); do { exec 3<>/dev/tcp/127.0.0.1/6600; } 2>/dev/null && { ok=1; break; }; ${pkgs.coreutils}/bin/sleep 1; done; [ \"$ok\" = 1 ] || exit 0; read -t 3 -u 3 _banner; printf \"listall \\\"ssd\\\"\\n\" >&3; n=0; while read -t 3 -u 3 line; do case \"$line\" in OK) break;; ACK*) break;; file:*) n=$((n+1));; esac; done; [ \"$n\" -gt 0 ] && { exec 3<&-; exit 0; }; printf \"update\\nclose\\n\" >&3; exec 3<&-'";
    };
  };

  systemd.user.timers.mpd-rescan = {
    Unit.Description = "Periodically check that the SSD tracks are in mpd's db";
    Timer.OnStartupSec = "15s";
    Timer.OnUnitInactiveSec = "1min";
    Install.WantedBy = [ "default.target" ];
  };
}
