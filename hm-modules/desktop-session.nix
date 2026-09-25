# Tier 2: the session itself, as far as a user-space tool can provide it.
#
# Tier 1 (desktop-stack.nix) ships the helpers the niri config spawns. This
# module ships the compositor and the login-time helpers, so a freshly
# installed distro needs as little preinstalled as possible:
#
#   - niri itself, via home-manager's own module: `niri`, `niri-session`, its
#     systemd user units, `xwayland-satellite` for X11 apps, and niri's D-Bus
#     portal configuration (gnome portal implementation, which niri prefers)
#   - a `wayland-sessions` entry in ~/.local/share, in case your display
#     manager looks at user data dirs (many do not - see README)
#   - a polkit authentication agent (polkit-gnome) started with the session
#   - gnome-keyring + libsecret
#   - the apps the niri autostart spawns: Telegram and Discord
#   - ~/Pictures/Screenshots, where niri's `screenshot-path` writes
#
# NOT here, because they need root or the host's session (this is the whole
# remaining manual list for a fresh distro):
#   - the display manager/greeter and its /usr/share/wayland-sessions entry;
#     alternatively log in on a TTY and run `niri-session`
#   - GPU drivers (mesa/vulkan/...) and /run/opengl-driver
#   - logind/seat and udev rules (input, backlight)
#   - the system polkit daemon, and /etc/pam.d/* (keyring auto-unlock)
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    concatLists
    getExe'
    mkEnableOption
    mkIf
    mkOption
    optional
    types
    ;

  cfg = config.rei.desktopSession;
in
{
  options.rei.desktopSession = {
    enable = mkEnableOption ''
      the Wayland session itself (compositor, portal config, polkit agent,
      keyring, session apps) from nixpkgs instead of the distro
    '';

    compositor = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Install niri through home-manager's module: the compositor,
        {command}`niri-session` (start it from a TTY), its systemd user units,
        the XWayland satellite, niri's portal configuration, and a
        `wayland-sessions` entry under `~/.local/share`.
      '';
    };

    polkitAgent = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Install polkit-gnome and start its authentication agent with the
        session (systemd user service), so privilege prompts work without a
        desktop-specific agent. Needs the system polkit daemon, which every
        distro ships.
      '';
    };

    keyring = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Enable GNOME Keyring (plus libsecret for apps to store secrets). The
        daemon starts with the session; unlocking it at login needs a PAM hook,
        which stays host-side (it works without one, it just asks).
      '';
    };

    sessionApps = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Install the apps `dotfiles/niri/generic/autostart.kdl` spawns:
        telegram-desktop and discord (discord is unfree - allowed in flake.nix).
      '';
    };

    userDirs = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Create the XDG user directories, including `~/Pictures/Screenshots`,
        which niri's `screenshot-path` writes to.
      '';
    };

    extraPackages = mkOption {
      type = types.listOf types.package;
      default = [ ];
      example = lib.literalExpression "[ pkgs.xwayland-satellite ]";
      description = "Extra packages for this session.";
    };
  };

  config = mkIf cfg.enable {
    # niri + session plumbing. home-manager's module also turns on xdg.portal
    # with niri's own portal configuration and installs xwayland-satellite.
    wayland.windowManager.niri.enable = cfg.compositor;

    # Some display managers scan user data directories for sessions; ones that
    # do not are covered by the README (or start `niri-session` from a TTY).
    xdg.dataFile."wayland-sessions/niri.desktop" = mkIf cfg.compositor {
      text = ''
        [Desktop Entry]
        Name=niri
        Comment=Scrollable-tiling Wayland compositor
        Exec=${getExe' pkgs.niri "niri-session"}
        Type=Application
      '';
    };

    home.packages = concatLists [
      (optional cfg.polkitAgent pkgs.polkit_gnome)
      (optional cfg.keyring pkgs.libsecret)
      (optional cfg.sessionApps pkgs.telegram-desktop)
      (optional cfg.sessionApps pkgs.discord)
      cfg.extraPackages
    ];

    systemd.user.services.rei-polkit-agent = mkIf cfg.polkitAgent {
      Unit = {
        Description = "polkit authentication agent (polkit-gnome)";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
        Restart = "on-failure";
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };

    services.gnome-keyring.enable = cfg.keyring;

    xdg.userDirs = mkIf cfg.userDirs {
      enable = true;
      createDirectories = true;
    };

    # niri's screenshot-path points at ~/Pictures/Screenshots.
    home.file."Pictures/Screenshots/.keep" = mkIf cfg.userDirs {
      text = "";
    };
  };
}
