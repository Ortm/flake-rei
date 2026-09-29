{
  config,
  pkgs,
  ...
}:
{
  # Secrets live encrypted in ./secrets/*.yaml (sops). The age key that can
  # decrypt them stays outside the repo at ~/.config/sops/age/keys.txt, so a
  # clone of this flake can be published as-is.
  #
  #   just secrets              edit the encrypted file
  #   sops --set '["ym-token"] "…"' secrets/secrets.yaml   non-interactive
  sops = {
    age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";

    defaultSopsFile = ../../secrets/secrets.yaml;
    defaultSopsFormat = "yaml";

    # Yandex Music OAuth token for ym-player-sync, decrypted to
    # ~/.config/sops-nix/secrets/ym-token (0600) at activation time.
    secrets."ym-token" = { };
  };

  # `sops` is only needed to edit the encrypted files.
  home.packages = [ pkgs.sops ];
}
