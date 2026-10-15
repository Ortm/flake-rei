{ ... }:
{
  home.sessionVariables.FLAKE_MACHINE = "icelake";

  # Identity of this machine's user. The login name and home directory are
  # pinned here as well, so this machine's configuration does not depend on the
  # environment of whoever runs the switch (a pure evaluation, i.e. one without
  # --impure, would otherwise fall back to the placeholder user "user").
  rei.user = {
    username = "vix";
    homeDirectory = "/home/vix";
    name = "Vix";
    fullName = "Artem";
    email = "aartemchik66@gmail.com";
  };

  # This box gets the desktop stack (niri, noctalia, wofi, cliphist, grim, ...)
  # from the distro/AUR, so the flake's nixpkgs copies would only shadow them
  # in the session PATH. Flip to true to let the flake provide them instead.
  rei.desktopStack.enable = false;

  # Yandex Music -> USB player: the "Мне нравится" likes collection, token from
  # secrets/secrets.yaml (wiring in hm-modules/ym-player-sync.nix). The DAP is
  # mounted by /etc/fstab at /mnt/player (PARTUUID 0049c3bc-01); sync mirrors
  # into its `favourite` folder, which has to exist on the player — a missing
  # folder or an unplugged player fails loudly, never a silent partial sync.
  # quality, tags and outputDir keep the module defaults (lossless, tags on,
  # cache in ~/Music/ym-player-sync).
  rei.ymPlayerSync = {
    enable = true;
    playerDir = "/mnt/player/favourite";
    embedCover = false;
    maxTotalMb = 6000;
    workers = 8;
    # 001, 002, … — a literal width on purpose (the default `{width}` widens
    # to 0001 by itself once the playlist passes 999 tracks)
    filenameTemplate = "{position:03d}-{title} - {artists}.{ext}";
  };
}
