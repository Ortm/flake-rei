# Tier-1 desktop helpers: the user-space tools the niri configuration spawns
# (dotfiles/niri/{generic,icelake}/*.kdl, scripts/*.sh). They have no host
# integration, so they behave the same on NixOS and on any foreign distro, and
# packing them here means a fresh install does not have to hunt distro/AUR
# packages. Enabled by default; a machine whose distro already provides them sets
# `rei.desktopStack.enable = false;` (icelake does).
#
# The options above are declared here and the helper packages are added below;
# nothing in this module assumes NixOS, only a Linux Wayland session.
#
# The OCR stack (`easyocr`, ~1.5 GB with torch) is on by default too; set
# `rei.desktopStack.includeOcr = false` if you never use the Mod+X bind.
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
    grim # `screenshot` binds + the OCR script's region grab
    slurp # region selection for the OCR script
    imagemagick # OCR pre-processing (scripts/OCR_select_area.sh), blur-wallpapers
    brightnessctl # noctalia brightness keys
    swaylock-effects # `swaylock` for a manual lock (needs host /etc/pam.d/swaylock)
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

    includeOcr = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Also install `easyocr`, which the `Mod+X` OCR bind
        (scripts/OCR_select_area.sh, rendered as `~/.local/bin/rei-ocr`) runs
        after grabbing the screen region with grim/slurp. easyocr drags in
        torch, so it is the biggest piece of this module; turn it off if you
        never use the OCR bind. Its model files are fetched into `~/.EasyOCR`
        the first time the bind runs.
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
    home.packages =
      helpers ++ optional cfg.includeShell pkgs.noctalia ++ optional cfg.includeOcr pkgs.easyocr ++ cfg.extraPackages;
  };
}
