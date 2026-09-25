{
  pkgs,
  lib,
  config,
  ...
}:
let
  jsTsConfig = {
    shebangs = [ "deno" ];
    roots = [
      "biome.json"
      "package.json"
      "deno.json"
      "deno.jsonc"
    ];
    auto-format = true;
    language-servers = [
      "biome"
      "deno-lsp"
    ];
    formatter = {
      command = "${pkgs.biome}/bin/biome";
      args = [
        "format"
        "--stdin-file-path"
        "file.ts"
      ];
    };
    indent = {
      tab-width = 2;
      unit = "  ";
    };
  };

  mkJsTs =
    name: ext:
    jsTsConfig
    // {
      inherit name;
      formatter = jsTsConfig.formatter // {
        args = [
          "format"
          "--stdin-file-path"
          "file.${ext}"
        ];
      };
    };

in
{
  home.packages =
    with pkgs;
    lib.mkIf config.programs.helix.enable [
      # Nix
      nil
      nixd
      nixfmt

      # C/C++
      # cmake-language-server
      lldb
      libclang

      # Docker
      dockerfile-language-server

      # Kubernetes
      helm-ls

      # Shells
      bash-language-server
      fish-lsp

      # Lua
      lua-language-server

      # Go
      gopls
      golangci-lint
      golangci-lint-langserver
      delve

      # python
      ty
      python313Packages.jedi-language-server
      python313Packages.python-lsp-server

      # toml
      taplo
      tombi

      # html + css + json + js/ts
      vscode-langservers-extracted
      biome

      # yaml
      yaml-language-server
      ansible-language-server

      # markdown
      markdown-oxide
      marksman

      # just
      just-lsp
    ];

  programs.ruff = {
    enable = true;
    settings = {
      # line-length = 120;
      lint.per-file-ignores = {
        "__init__.py" = [ "F401" ];
      };
      lint = {
        select = [
          "E" # pycodestyle (error)
          "W" # warns
          "F" # pyflakes
          "B" # bugbear
          "C4" # flake8-comprehensions
          "SIM" # flake8-simplify
          "I" # isort
          "UP" # pyupgrade
          "PIE" # flake8-pie
          "PGH" # pygrep-hooks
          "PYI" # flake8-pyi
          "RUF"
        ];
        ignore = [
          "B011"
          "E501"
          "RUF001"
          "RUF003"
        ];
      };
    };
  };

  programs.helix = {
    languages.language = [
      {
        name = "nix";
        auto-format = true;
        formatter = {
          command = "${pkgs.nixfmt}/bin/nixfmt";
          args = [
            "--width"
            "120"
          ];
        };
      }
      {
        name = "python";
        auto-format = true;
      }
      {
        name = "lua";
        auto-format = true;
      }
      (mkJsTs "typescript" "ts")
      (mkJsTs "javascript" "js")
      (mkJsTs "tsx" "tsx")
      (mkJsTs "jsx" "jsx")
      {
        name = "json";
        auto-format = true;
        language-servers = [
          "biome"
          "vscode-json-language-server"
        ];
        formatter = {
          command = "${pkgs.biome}/bin/biome";
          args = [
            "format"
            "--stdin-file-path"
            "file.json"
          ];
        };
      }
      {
        name = "dart";
        auto-format = true;
        language-servers = [ "dart" ];
        formatter = {
          command = "dart";
          args = [ "format" ];
        };
      }
    ];

    languages.language-server = {
      biome = {
        command = "biome";
        args = [ "lsp-proxy" ];
      };

      vscode-json-language-server = {
        command = "${pkgs.vscode-langservers-extracted}/bin/vscode-json-language-server";
        args = [ "--stdio" ];
      };

      deno-lsp = {
        command = "deno";
        args = [ "lsp" ];
        config = {
          deno = {
            enable = true;
            unstable = true;
            inlayHints = {
              functionLikeReturnTypes = {
                enabled = true;
              };
              parameterNames = {
                enabled = "literals";
              };
              propertyDeclarationTypes = {
                enabled = true;
              };
              #   enumMemberValues = { enabled = true; };
              #   parameterTypes = { enabled = true; };
              #   variableTypes = { enabled = true; };
            };
          };
        };
      };

      dart = {
        command = "${pkgs.flutter}/bin/dart";
        args = [
          "language-server"
          "--protocol=lsp"
        ];
      };
    };
  };
}
