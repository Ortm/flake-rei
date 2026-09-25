{
  # ══════════════════════════════════════════════════════════════════════════
  # flake-rei — Home Manager configuration for my laptops
  #
  # A flake is the file nix looks for when you point it at this directory. It
  # does three things, in order:
  #
  #   1. inputs  — the sources everything is built from (nixpkgs, home-manager,
  #                catppuccin, the yazi plugins, hermes)
  #   2. modules — the files under ./hm-modules that describe the configuration
  #                (./home.nix is the main one; machines/<name>/default.nix
  #                holds whatever is specific to one laptop)
  #   3. outputs — one `homeConfiguration` per machine, which is what
  #                `./install.sh` and `home-manager switch --flake` select
  #
  # Everyday commands:
  #   ./install.sh            install on this machine (asks which one)
  #   just hm                 rebuild after editing anything
  #   nix flake check         sanity-check that the flake still evaluates
  # ══════════════════════════════════════════════════════════════════════════

  inputs = {
    # The base package set. Everything else follows it, so one
    # `nix flake update` moves the whole system forward together.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Home Manager turns the modules below into `home-manager switch`.
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Catppuccin theming for every program that supports it (mocha, blue).
    catppuccin.url = "github:catppuccin/nix";
    catppuccin.inputs.nixpkgs.follows = "nixpkgs";

    # Hermes agent + its desktop app; enabled in ./home.nix.
    hermes-agent.url = "github:NousResearch/hermes-agent";

    # Yazi plugins. `flake = false` because these repos are plain source
    # trees, not flakes; their files are handed to the yazi module below.
    open-with-cmd.url = "github:Ape/open-with-cmd.yazi";
    open-with-cmd.flake = false;
    close-and-restore-tab.url = "github:MasouShizuka/close-and-restore-tab.yazi";
    close-and-restore-tab.flake = false;
  };

  outputs =
    { nixpkgs, home-manager, ... }@inputs:
    let
      lib = nixpkgs.lib;

      # ── which system to build for ─────────────────────────────────────────
      # install.sh exports FLAKE_SYSTEM=<this machine's system> before
      # switching, so a fresh clone builds for the machine it runs on
      # (x86_64-linux, aarch64-linux, ...). Override it by hand for cross
      # builds:  FLAKE_SYSTEM=aarch64-linux ./install.sh
      # `nix flake check` evaluates without an environment and falls back to
      # the default below.
      defaultSystem = "x86_64-linux";
      system = if builtins.getEnv "FLAKE_SYSTEM" == "" then defaultSystem else builtins.getEnv "FLAKE_SYSTEM";

      # ── the package set ───────────────────────────────────────────────────
      pkgs = import nixpkgs {
        localSystem = system;

        # Unfree software is refused unless it is named here. discord is only
        # installed when `rei.desktopSession.sessionApps` is on (tier 2).
        config = {
          allowUnfree = false;
          allowUnfreePredicate =
            pkg:
            builtins.elem (lib.getName pkg) [
              "unrar"
              "obsidian"
              "discord"
              "discord-unwrapped"
            ];
        };
      };

      # ── yazi plugins ──────────────────────────────────────────────────────
      # Plugin repos ship READMEs, licences and screenshots; drop those (and
      # empty directories) so only the plugin itself is copied into the store.
      stripDocs =
        src:
        lib.cleanSourceWith {
          src = src;
          filter =
            path: type:
            let
              name = baseNameOf path;
            in
            !(
              builtins.any (suffix: lib.hasSuffix suffix name) [
                ".md"
                "LICENSE"
                ".png"
                ".jpg"
              ]
              || name == "README"
              || lib.hasInfix "LICENSE" name
              || (type == "directory" && builtins.pathExists path && builtins.readDir path == { })
            );
        };

      # Handed to every module as `yazi-plugins` (see hm-modules/termTools/yazi).
      moduleArgs = {
        yazi-plugins = builtins.mapAttrs (_: stripDocs) {
          inherit (inputs) open-with-cmd close-and-restore-tab;
        };
      };

      # ── modules: what the configuration is made of ───────────────────────
      # Every file listed here applies to every machine: add a line and it
      # becomes part of the configuration. The headings are only for reading.
      baseModules = [
        ./home.nix # the main file: programs, packages, session settings

        ./hm-modules/sound/mpv.nix

        # CLI/TUI tools
        ./hm-modules/termTools/yazi
        ./hm-modules/termTools/fish
        ./hm-modules/termTools/helix
        ./hm-modules/termTools/neovim
        ./hm-modules/termTools/less.nix

        # Who is installing: login name, home directory, git identity
        ./hm-modules/user.nix

        # gpg + gpg-agent
        ./hm-modules/security/keys.nix

        # Wayland / desktop
        ./hm-modules/wayland/foot.nix # the terminal
        ./hm-modules/wayland/niri-assets.nix # files the niri config spawns
        ./hm-modules/desktop-stack.nix # tier 1: clipboard, screenshots, OCR, media keys
        ./hm-modules/desktop-session.nix # tier 2: compositor + session helpers

        # Theming
        inputs.hermes-agent.homeManagerModules.default
        inputs.catppuccin.homeModules.catppuccin
        ./hm-modules/themes/gtk.nix
        ./hm-modules/themes/qt.nix
      ];

      # ── machines: one configuration per ./machines/<name> ─────────────────
      # A directory with a default.nix in it is a machine; nothing to register
      # by hand. `./install.sh` lists exactly these.
      machineDir = ./machines;
      isMachineDir = name: type: type == "directory" && builtins.pathExists (machineDir + "/${name}/default.nix");
      machineNames = builtins.attrNames (lib.filterAttrs isMachineDir (builtins.readDir machineDir));
    in
    {
      # `home-manager switch --flake .#icelake` builds this attribute.
      homeConfigurations = lib.genAttrs machineNames (
        machine:
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = baseModules ++ [
            { _module.args = moduleArgs; } # yazi plugins, available to every module
            (machineDir + "/${machine}") # this machine's own settings
          ];
        }
      );
    };
}
