{ pkgs, config, ... }:
{
  gtk = {
    enable = true;
    theme = {
      name = "catppuccin-mocha-lavender-standard";
      package = pkgs.catppuccin-gtk.override {
        accents = [ "lavender" ];
        variant = "mocha";
      };
    };
  };

  # Symlink GTK4 theme files so GTK4/Libadwaita applications respect the theme
  xdg.configFile = with config.gtk.theme; {
    "gtk-4.0/assets".source = "${package}/share/themes/${name}/gtk-4.0/assets";
    "gtk-4.0/gtk.css".source = "${package}/share/themes/${name}/gtk-4.0/gtk.css";
    "gtk-4.0/gtk-dark.css".source = "${package}/share/themes/${name}/gtk-4.0/gtk-dark.css";
  };

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
  };
}
