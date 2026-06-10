{
  pkgs,
  lib,
  config,
  ...
}:
let
  inherit (lib) mkIf;
in
{
  programs.ghostty = {
    enable = true;
    installVimSyntax = true;
    settings = {
      font-size = 14;
      shell-integration = mkIf config.programs.fish.enable "fish";
      window-padding-x = 0;
      window-padding-y = 0;
      cursor-style = "bar";
      cursor-style-blink = false;
      scrollback-limit = 10000;
      mouse-hide-while-typing = true;
    };
  };
}
