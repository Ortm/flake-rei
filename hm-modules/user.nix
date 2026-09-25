{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkOption types;

  # Detected from the environment of whoever runs the switch. That is why
  # install.sh and the `just` recipes pass --impure: in a pure evaluation
  # builtins.getEnv returns "" for everything, so the values below would fall
  # back to the placeholders.
  envUser = builtins.getEnv "USER";
  envHome = builtins.getEnv "HOME";

  capitalize = s: if s == "" then "" else lib.toUpper (lib.substring 0 1 s) + lib.substring 1 (lib.stringLength s - 1) s;
in
{
  options.rei.user = {
    username = mkOption {
      type = types.str;
      default = if envUser == "" then "user" else envUser;
      defaultText = lib.literalExpression ''builtins.getEnv "USER"'';
      example = "vix";
      description = ''
        Login name this configuration is installed for. Auto-detected from the
        user running `home-manager switch`, so a fresh clone works for anyone;
        pin it in `machines/<name>/default.nix` to install for another account.
      '';
    };

    homeDirectory = mkOption {
      type = types.str;
      default = if envHome == "" then "/home/${config.rei.user.username}" else envHome;
      defaultText = lib.literalExpression ''builtins.getEnv "HOME"'';
      example = "/home/vix";
      description = "Home directory of {option}`rei.user.username`.";
    };

    name = mkOption {
      type = types.str;
      default = capitalize config.rei.user.username;
      example = "Vix";
      description = "Commit name used for git and jujutsu.";
    };

    fullName = mkOption {
      type = types.str;
      default = config.rei.user.name;
      defaultText = lib.literalExpression "config.rei.user.name";
      example = "Artem";
      description = "Name used for document metadata (pandoc); defaults to {option}`rei.user.name`.";
    };

    email = mkOption {
      type = types.str;
      default = "";
      example = "you@example.com";
      description = ''
        Email used for git and jujutsu commits. When empty the `user.email`
        setting is left alone, so git keeps whatever you configure yourself.
      '';
    };
  };

  config = {
    home.username = config.rei.user.username;
    home.homeDirectory = config.rei.user.homeDirectory;
  };
}
