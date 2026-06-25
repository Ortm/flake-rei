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
  qt = {
    platformTheme.name = mkIf config.catppuccin.enable "kvantum";
    style.name = "kvantum";
    style.package = pkgs.libsForQt5.qtstyleplugins;
  };
}
