{
  description = "Gidrex flake configuration for working machines.";

  inputs = {
    # Core
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";

    # Theming
    catppuccin.url = "github:catppuccin/nix";
    catppuccin.inputs.nixpkgs.follows = "nixpkgs";

    # Yazi plugins
    open-with-cmd.url = "github:Ape/open-with-cmd.yazi";
    open-with-cmd.flake = false;
    close-and-restore-tab.url = "github:MasouShizuka/close-and-restore-tab.yazi";
    close-and-restore-tab.flake = false;
  };

  outputs =
    { nixpkgs, home-manager, ... }@inputs:
    let
      # Clean yazi plugins from docs
      cleanPlugin =
        src:
        nixpkgs.lib.cleanSourceWith {
          src = src;
          filter =
            path: type:
            let
              baseName = baseNameOf path;
            in
            !(
              builtins.any (suffix: nixpkgs.lib.hasSuffix suffix baseName) [
                ".md"
                "LICENSE"
                ".png"
                ".jpg"
              ]
              || baseName == "README"
              || nixpkgs.lib.hasInfix "LICENSE" baseName # exclude this files
              || (
                type == "directory" && builtins.pathExists path && builtins.length (builtins.attrNames (builtins.readDir path)) == 0
              )
            ); # empty dirs
        };

      # Module arguments
      moduleArgs = {
        yazi-plugins = builtins.mapAttrs (_: cleanPlugin) {
          inherit (inputs) open-with-cmd close-and-restore-tab;
        };
      };

      # Common modules
      commonModules = [
        ./home.nix

        # Sounds settings
        ./hm-modules/sound/mpv.nix

        # My cli/tui tools
        ./hm-modules/termTools/yazi
        ./hm-modules/termTools/fish
        ./hm-modules/termTools/helix
        ./hm-modules/termTools/neovim
        ./hm-modules/termTools/less.nix

        # Security
        ./hm-modules/security/keys.nix

        # Wayland apps
        ./hm-modules/wayland/foot.nix
        ./hm-modules/wayland/kitty.nix
        ./hm-modules/wayland/ghostty.nix

        # Theming (Im prefer catppuccin mocha theme)
        inputs.catppuccin.homeModules.catppuccin
        ./hm-modules/themes/gtk.nix
        ./hm-modules/themes/qt.nix

        { _module.args = moduleArgs; }
      ];

      pkgs = import nixpkgs {
        localSystem = "x86_64-linux";

        config = {
          allowUnfree = false;
          allowUnfreePredicate =
            pkg:
            builtins.elem (nixpkgs.lib.getName pkg) [
              "unrar"
              "obsidian"
            ];
        };
      };

      # Machine configurations
      machines = {
        icelake = ./machines/icelake;
      };

    in
    {

      # Home Manager builder
      homeConfigurations = nixpkgs.lib.genAttrs (builtins.attrNames machines) (
        name:
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = commonModules ++ [ machines.${name} ];
        }
      );
    };
}
