{
  pkgs,
  lib,
  config,
  ...
}:
let
  inherit (lib)
    mkIf
    mkDefault
    mkForce
    optionalAttrs
    ;
  inherit (builtins) pathExists;

  # Login name, home directory and git identity come from hm-modules/user.nix:
  # detected from whoever runs the switch, overridable per machine in
  # machines/<name>/default.nix.
  inherit (config.rei.user) name fullName email;

  # email is optional (git keeps its own setting when we leave it alone), so
  # build the block with every field present instead of merging sub-attrsets.
  identity = {
    name = name;
  }
  // optionalAttrs (email != "") { inherit email; };

in
{
  nix = {
    package = mkDefault pkgs.nix;
    settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
  };

  # Programs
  programs = {
    zoxide.enable = true;
    home-manager.enable = true;
    nix-your-shell.enable = true;
    fish.enable = true;
    # foot lives in hm-modules/wayland/foot.nix (Wayland/Linux only)
    helix.enable = true;
    neovim.enable = true;

    hermes-agent = {
      enable = true;
      desktop.enable = true;
    };

    yazi = {
      enable = true;
      package = pkgs.yazi;
    };
    # less.enable = true;

    fastfetch.enable = true;
    lazygit = {
      enable = true;
      settings.gui.nerdFontsVersion = "3";
    };
    jujutsu = {
      enable = true;
      settings = {
        user = identity;
        ui.color = "always";
      };
    };

    aria2 = {
      enable = true;
      settings = {
        # enable-rpc = true;
        # rpc-listen-all = false;
        # rpc-listen-port = 6800;
        max-concurrent-downloads = 5;
        continue = true;
        max-connection-per-server = 16;
        min-split-size = "10M";
        split = 10;
      };
    };

    btop = {
      enable = true;
      settings = {
        color_theme = mkForce "horizon";
        show_gpu_info = true;
        vim_keys = true;
        proc_sorting = "memory";
        proc_gradient = false;
        proc_per_core = false;
        graph_symbol = "block";
        graph_symbol_cpu = "braille";
        graph_symbol_net = "braille";
        show_battery = false;
      };
    };

    fzf = {
      enable = true;
      defaultCommand = "${pkgs.fd}/bin/fd --type f";
    };

    skim.enable = true;

    fd = {
      enable = true;
      extraOptions = [ "--absolute-path" ];
      ignores = [ ".git/" ];
    };

    ripgrep = {
      enable = true;
      arguments = [
        "--colors=line:style:bold"
        "--colors=match:fg:yellow"
        "--colors=match:style:bold"
        "--colors=path:fg:cyan"
        "--colors=path:style:bold"
        "--smart-case"
        "--hidden"
        "--follow"
        "--no-line-number"
      ];
    };

    eza = {
      enable = true;
      icons = "auto";
      git = true;
      extraOptions = [
        "--oneline"
        "--group-directories-first"
      ];
    };

    git = {
      enable = true;
      lfs.enable = true;
      settings = {
        user = identity // {
          signingkey = "~/.ssh/id_rsa.pub";
        };
        init.defaultBranch = "main";
        pull.rebase = true;
        rebase.autostash = true;
        rebase.autosquash = true;
        push.autoSetupRemote = true;
        commit.gpgsign = false;
        rerere.enabled = true;
        core.whitespace = "trailing-space,space-before-tab";
        core.editor = "hx";
        safe = mkIf (pathExists "/opt/flutter") { directory = "/opt/flutter"; };
      };
    };

    pandoc.defaults = {
      metadata.author = fullName;
      pdf-engine = "xelatex";
      citeproc = true;
    };
  };

  # global theaming if enabled
  catppuccin = {
    enable = true;
    autoEnable = true;
    flavor = "mocha";
    accent = "blue";
    foot.enable = false;
    gtk = {
      icon.enable = true;
      icon.accent = "sky";
    };
  };

  fonts.fontconfig.enable = true;

  home = {
    packages =
      with pkgs;
      [
        # utility
        unrar
        nix-prefetch-github
        rip2
        glow
        ripdrag
        ueberzugpp
        poppler
        chafa
        mediainfo
        hexyl
        duckdb
        libqalculate
        tldr

        # fancy
        gum

        # web
        bind.dnsutils # provides dig and host
        speedtest-cli
        ipfetch

        # dev
        just
        lazydocker
        deno
        lazyjj

        # apps (obsidian is unfree - allowed in flake.nix)
        obsidian

        # fonts
      ]
      ++ (with nerd-fonts; [
        symbols-only
        geist-mono
      ]);

    sessionVariables =
      builtins.listToAttrs (
        map
          (name: {
            inherit name;
            value = mkIf config.programs.helix.enable "hx";
          })
          [
            "EDITOR"
            "VISUAL"
          ]
      )
      // {

        SHELL = mkIf config.programs.fish.enable "fish";
        TERM = mkIf config.programs.foot.enable "foot";
        ANDROID_HOME = "${config.home.homeDirectory}/Android/Sdk";
        ANDROID_AVD_HOME = "${config.home.homeDirectory}/.android/avd";

        QT_WAYLAND_DISABLE_WINDOWDECORATION = 1;
        NIXOS_OZONE_WL = 1;

        XDG_CONFIG_HOME = "${config.xdg.configHome}";
        XDG_SCREENSHOTS_DIR = "${config.home.homeDirectory}/Pictures/screenshots";
      };

    sessionPath = [
      "${config.home.homeDirectory}/.local/bin"
      "${config.home.homeDirectory}/.nix-profile/bin"
      "${config.home.homeDirectory}/.kimi-code/bin"
      "/usr/bin"

      # Packet managers
      "${config.home.homeDirectory}/.volta/bin"
      "${config.home.homeDirectory}/.cargo/bin"
      "${config.home.homeDirectory}/.npm-global/bin"
      "${config.home.homeDirectory}/.deno/bin"
      "${config.home.homeDirectory}/go/bin"

      # Flutter dev
      "/opt/flutter/bin"
      "/opt/android-sdk/tools/bin"
      "${config.home.homeDirectory}/Android/Sdk/cmdline-tools/latest/bin"
      "${config.home.homeDirectory}/Android/Sdk/platform-tools"
      "${config.home.homeDirectory}/Android/Sdk/emulator"
    ];

    enableNixpkgsReleaseCheck = false;
    stateVersion = "26.05";

    #   pointerCursor = {
    #     package = pkgs.capitaine-cursors;
    #     name = "capitaine-cursors";
    #     size = 24;
    #     gtk.enable = true;
    #     x11.enable = true;
    #   };
  };

  xdg.configFile."glow/glow.yml".text = ''
    style: "tokyo-night"
    width: 0
    mouse: false
  '';

  # Non-NixOS only: this wires up the driver / GL paths a store binary needs on
  # a foreign distro (see README, "Any Linux distro"). Set it to false on NixOS.
  targets.genericLinux.enable = true;

  news.display = "silent";
}
