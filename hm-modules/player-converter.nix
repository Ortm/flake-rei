{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf mkOption types;

  cfg = config.rei.playerConverter;
in
{
  options.rei.playerConverter = {
    enable = mkEnableOption "mirroring a Yandex Music playlist onto the USB player";

    playlistUrl = mkOption {
      type = types.str;
      default = "https://music.yandex.ru/users/Ortimm/tracks";
      example = "https://music.yandex.ru/users/<login>/playlists/<kind>";
      description = ''
        Playlist to mirror. Accepts the canonical form
        (`…/users/<login>/playlists/<kind>`), the Liked-tracks collection
        (`…/users/<login>/tracks`) and share links (`…/playlists/<uid>.<uuid>`).
      '';
    };

    playerDir = mkOption {
      type = types.str;
      example = "/run/media/vix/WALKMAN/Music";
      default = "/run/media/${config.rei.user.username}/PLAYER/Music";
      description = ''
        Where the USB player is mounted (udisks uses
        `/run/media/<user>/<LABEL>`). Point it at the music folder on the
        player; it must exist when `player-converter sync` runs.
      '';
    };
  };

  config = mkIf cfg.enable {
    programs.player-converter = {
      enable = true;

      inherit (cfg) playlistUrl playerDir;

      # Decrypted by sops-nix at activation (see hm-modules/security/sops.nix);
      # the token itself is never in this repo or in the Nix store.
      tokenFile = config.sops.secrets."ym-token".path;

      # Everything else (quality, maxTracks, maxTotalMb, workers,
      # filenameTemplate, settings, schedule) keeps the module defaults.
      # A daily run would be: schedule = "daily";
    };
  };
}
