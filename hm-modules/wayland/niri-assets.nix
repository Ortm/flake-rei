# Files the niri configuration points at by an absolute $HOME path.
#
# dotfiles/niri/** is symlinked into ~/.config/niri by scripts/setup_niri.sh
# rather than built by home-manager, so every path a bind spawns has to live in
# a fixed, user-independent location: ~/.config/rei/... for configs and
# ~/.local/bin/... for helpers.
#
# Keep in sync with dotfiles/niri/{generic,icelake}/binds.kdl.
{
  xdg.configFile."rei/wofi/icelake_config".source = ../../dotfiles/wofi/icelake_config;
  xdg.configFile."rei/wofi/style.css".source = ../../dotfiles/wofi/style.css;

  home.file.".local/bin/rei-ocr".source = ../../scripts/OCR_select_area.sh;
}
