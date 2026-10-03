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

  # Yandex Music -> USB player (token comes from secrets/secrets.yaml).
  rei.ymPlayerSync = {
    enable = true;
    # The ECHO MINI player: its volume label is "ECHO MINI", so udisks mounts it
    # at /run/media/<user>/<LABEL> under that name (space included). The "Music"
    # folder has to exist on the player — the sync service only runs while it does.
    playerDir = "/run/media/vix/ECHO MINI/Music";
  };
}
