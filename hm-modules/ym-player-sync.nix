{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf mkOption types;

  cfg = config.rei.ymPlayerSync;
in
{
  # One option per `programs.ym-player-sync` setting: everything a hand-written
  # config.yaml can carry (see nix/module.nix in ym-player-sync for the
  # descriptions). Machines set only what differs from these defaults.
  options.rei.ymPlayerSync = {
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
      default = "/run/media/${config.rei.user.username}/PLAYER/Music";
      example = "/mnt/player/favourite";
      description = ''
        The music folder on the mounted player — a udisks mount
        (`/run/media/<user>/<LABEL>`) or a fixed fstab mount. It must exist
        when `ym-player-sync sync` runs, and `sync` mirrors the cache into
        exactly this folder.
      '';
    };

    token = mkOption {
      type = types.str;
      default = "\${YM_TOKEN}";
      description = ''
        Yandex Music OAuth token, expanded from the environment when written
        as `''${VAR}`. Prefer `tokenFile`: a literal token would end up in
        the world-readable Nix store.
      '';
    };

    tokenFile = mkOption {
      type = types.nullOr types.str;
      default = config.sops.secrets."ym-token".path;
      example = "/run/secrets/ym-token";
      description = ''
        File holding the token — the bare token or an `YM_TOKEN=...` line
        (agenix/sops-nix style). Defaults to the sops secret decrypted at
        activation (see hm-modules/security/sops.nix). Read when a command
        runs, so the token never enters the Nix store.
      '';
    };

    quality = mkOption {
      type = types.enum [
        "lossless"
        "high"
        "low"
      ];
      default = "lossless";
      description = "Download tier: lossless (FLAC), high (MP3 320 kbps), low (smallest variant).";
    };

    source = mkOption {
      type = types.nullOr (types.enum [ "yandex" ]);
      default = null;
      description = "Music source; null auto-detects from the playlist URL.";
    };

    tags = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Write artist, title, album, album artist, year and track number into
        every file — what rmpc and the player display comes from the tags,
        not the filename.
      '';
    };

    embedCover = mkOption {
      type = types.bool;
      default = true;
      description = "Also embed the album cover into each file (needs `tags`).";
    };

    maxTracks = mkOption {
      type = types.nullOr types.ints.positive;
      default = null;
      description = "Mirror only the first N playlist tracks; null mirrors the whole playlist.";
    };

    maxTotalMb = mkOption {
      type = types.nullOr types.number;
      default = null;
      description = ''
        Cap on the cache size in MB (estimated first, then enforced on the
        bytes actually taken); null = no cap. Tracks over the budget are
        deleted from cache and player.
      '';
    };

    outputDir = mkOption {
      type = types.str;
      default = "${config.home.homeDirectory}/Music/ym-player-sync";
      description = ''
        Local cache: downloads and the sync state live here. Point it at a
        dedicated folder — `sync` mirrors the cache exactly, deleting every
        audio file in it that is no longer in the queue.
      '';
    };

    filenameTemplate = mkOption {
      type = types.str;
      default = "{position:0{width}d}-{title} - {artists}.{ext}";
      description = ''
        Filename template: `{position}` (1-based), `{width}` (zero-pad width,
        derived from the playlist size), `{title}`, `{artists}`, `{ext}`,
        `{name}` ("Title - Artist"). Rendered once at load, so a broken
        template fails before anything downloads.
      '';
    };

    workers = mkOption {
      type = types.ints.positive;
      default = 4;
      description = "Parallel downloads on the download stage (1 = sequential).";
    };

    schedule = mkOption {
      type = types.nullOr types.str;
      default = null;
      example = "daily";
      description = ''
        `OnCalendar` schedule for a systemd user timer that runs
        `ym-player-sync download` then `ym-player-sync sync`; null disables
        the timer (the unit is skipped while `playerDir` is absent anyway).
      '';
    };

    settings = mkOption {
      type = types.attrsOf types.anything;
      default = { };
      description = "Extra config.yaml keys, merged over the options above.";
    };
  };

  config = mkIf cfg.enable {
    programs.ym-player-sync = {
      enable = true;

      inherit (cfg)
        playlistUrl
        playerDir
        token
        tokenFile
        quality
        source
        tags
        embedCover
        maxTracks
        maxTotalMb
        outputDir
        filenameTemplate
        workers
        schedule
        settings
        ;
    };
  };
}
