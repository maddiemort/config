{
  config,
  lib,
  pkgs,
  pkgsUnstable,
  ...
}: let
  cfg = config.custom.helix;

  inherit (lib) mkIf;
in {
  options.custom.helix = with lib; {
    enable = mkEnableOption "custom Helix configuration";
  };

  config = mkIf cfg.enable {
    programs.helix = {
      enable = true;
      package = pkgsUnstable.helix;
      settings = {
        theme = "catppuccin_macchiato";

        editor = {
          scrolloff = 3;
          scroll-lines = 2;
          shell = ["fish" "-c"];
          line-number = "relative";
          cursorline = true;
          auto-completion = false;
          preview-completion-insert = false;
          auto-info = true;
          color-modes = true;
          text-width = 100;

          statusline = {
            left = [
              "mode"
              "spacer"
              "spinner"
              "spacer"
              "diagnostics"
              "file-name"
              "read-only-indicator"
              "file-modification-indicator"
            ];
            center = [];
            right = [
              "workspace-diagnostics"
              "selections"
              "register"
              "position"
              "file-encoding"
              "file-line-ending"
            ];
            separator = "│";
            mode = {
              normal = "NOR";
              insert = "INS";
              select = "SEL";
            };
          };

          lsp = {
            display-messages = true;
            display-inlay-hints = true;
          };

          file-picker = {
            hidden = false;
          };

          auto-pairs = false;

          indent-guides = {
            render = true;
          };

          cursor-shape = {
            insert = "bar";
          };

          end-of-line-diagnostics = "hint";

          inline-diagnostics = {
            cursor-line = "error";
          };
        };
      };

      languages = {
        language-server.rust-analyzer = {
          config = {
            inlayHints = {
              typeHints.enable = true;
              parameterHints.enable = true;
            };
          };
        };

        language = [
          {
            name = "nix";
            auto-format = true;
          }
        ];
      };

      extraPackages = with pkgs; [
        bash-language-server
        lua-language-server
        marksman
        nil
        nixpkgs-fmt
        shellcheck
        taplo
        tinymist
        vscode-json-languageserver
        yaml-language-server
      ];
    };
  };
}
