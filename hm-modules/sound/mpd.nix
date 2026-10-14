# MPD — the music player daemon that the rmpc TUI (hm-modules/sound/rmpc) is a
# client of. Runs as a user service and listens on localhost only (the defaults
# rmpc's config.ron expects: 127.0.0.1:6600).
#
# The library is ~/Music, which is also where `ym-player-sync download` stages
# the Yandex Music playlist (~/Music/ym-player-sync), so music shows up in rmpc
# as soon as it lands there — the USB player is a copy of the same files.
{ config, lib, ... }:
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

  # ~/Music is the library root — mpd indexes it, `ym-player-sync download`
  # stages files inside it. Home Manager only creates it as a side effect of
  # managing something under it, so create it on every activation (mkdir -p
  # is a no-op when it already exists).
  home.activation.createMusicDir = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run mkdir -p "$HOME/Music"
  '';
}
