{ ... }:
{
  home.sessionVariables.FLAKE_MACHINE = "icelake";

  # Identity of this machine's user. Anything left out falls back to the
  # auto-detected values from hm-modules/user.nix (login name, home directory).
  rei.user = {
    name = "Vix";
    fullName = "Artem";
    email = "aartemchik66@gmail.com";
  };

  # This box gets the desktop stack (niri, noctalia, wofi, cliphist, grim, ...)
  # from the distro/AUR, so the flake's nixpkgs copies would only shadow them
  # in the session PATH. Flip to true to let the flake provide them instead.
  rei.desktopStack.enable = false;

  # Yandex Music -> USB player (token comes from secrets/secrets.yaml).
  rei.playerConverter = {
    enable = true;
    # Adjust to the label the player gets when plugged in
    # (udisks mounts it at /run/media/<user>/<LABEL>).
    playerDir = "/run/media/vix/PLAYER/Music";
  };
}
