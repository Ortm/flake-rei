# rmpc — a TUI MPD client (Rusty MPD Client).
#
# config.ron next to this file is deliberately partial: rmpc fills every field
# it leaves out with the built-in default, so only the choices that differ are
# written down. `rmpc config` prints the full annotated default config.
#
# The theme is a catppuccin mocha port (catppuccin-nix does not cover rmpc yet)
# and is what `theme: "catppuccin-mocha"` in config.ron points at.
{ ... }:
{
  programs.rmpc = {
    enable = true;
    config = builtins.readFile ./config.ron;
  };

  xdg.configFile."rmpc/themes/catppuccin-mocha.ron".source = ./themes/catppuccin-mocha.ron;
}
