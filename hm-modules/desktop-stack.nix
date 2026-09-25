# Tier-1 desktop helpers: the user-space tools the niri configuration spawns
# (dotfiles/niri/{generic,icelake}/*.kdl, scripts/*.sh). They have no host
# integration, so they behave the same on NixOS and on any foreign distro, and
# packing them here means a fresh install does not have to hunt distro/AUR
# packages. Enabled by default; a machine whose distro already provides them
# sets `rei.desktopStack.enable = false;` (icelake does).
#
# Deliberately NOT here (tier 2/3 - keep them host-side):
#   - the compositor session: niri itself, the greeter, seat/logind and GPU
#     driver handling. A store compositor needs a wayland-sessions .desktop
#     entry plus host driver work (nixGL-style) for proprietary drivers.
#   - xdg-desktop-portal*: two portal stacks on one D-Bus session fight over
#     the same names, which breaks screenshots and file pickers in confusing
#     ways. Keep the distro's.
#   - PAM-backed tools: a store `swaylock` reads /etc/pam.d/swaylock from the
#     host, so it only unlocks when the distro ships that file.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkIf
    mkOption
    optional
    types
    ;

  cfg = config.rei.desktopStack;

  # One entry per consumer in the config; see the comments.
  helpers = with pkgs; [
    wofi # clipboard menu (Mod+V, dotfiles/wofi/*)
    cliphist # history store: `wl-paste --watch cliphist store`
    wl-clipboard # wl-copy / wl-paste plumbing
    playerctl # media keys (Mod+Shift+Equal / Minus, Mod+Backspace)
    grim # `screenshot` bind + scripts/OCR_select_area.sh
    slurp # region selection for the OCR script
    imagemagick # OCR pre-processing, scripts/swaylock_fancy.sh, blur-wallpapers
    brightnessctl # noctalia brightness keys
    swaylock-effects # provides the `swaylock` binary for scripts/{swaylock_fancy,power-menu}.sh
  ];
in
{
  options.rei.desktopStack = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Install the tier-1 desktop helpers (clipboard, screenshots, OCR, media
        keys) from nixpkgs instead of relying on distro packages. Turn off on a
        machine that already has them, otherwise the flake's copies shadow the
        distro ones in the session `PATH`.
      '';
    };

    includeShell = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Also install `pkgs.noctalia`, the shell behind the `noctalia msg ...`
        binds and the `spawn-sh-at-startup` entry. nixpkgs ships it as a beta;
        the legacy v4 `noctalia-shell` package is a different program whose
        binary is called {command}`noctalia-shell`, which the binds would not
        find.
      '';
    };

    extraPackages = mkOption {
      type = types.listOf types.package;
      default = [ ];
      example = lib.literalExpression "[ pkgs.fuzzel ]";
      description = "Extra desktop packages for this machine.";
    };
  };

  config = mkIf cfg.enable {
    home.packages = helpers ++ optional cfg.includeShell pkgs.noctalia ++ cfg.extraPackages;
  };
}
