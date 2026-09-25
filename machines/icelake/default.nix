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
}
