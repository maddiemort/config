{
  config,
  lib,
  pkgs,
  pkgsUnstable,
  ...
}: let
  cfg = config.custom.shell;

  inherit (lib) mkIf;
in {
  imports = [
    ./fish.nix
    ./starship.nix
  ];

  options.custom.shell = with lib; {
    enable = mkEnableOption "custom shell configuration";
  };

  config = mkIf cfg.enable {
    programs = {
      atuin = {
        enable = true;
        package = pkgsUnstable.atuin;

        forceOverwriteSettings = true;

        flags = [
          "--disable-up-arrow"
        ];

        settings = {
          command_chaining = false; # try this
          dialect = "uk";
          enter_accept = true;
          inline_height = 20;
          invert = false;
          keymap_mode = "vim-insert";
          show_help = false;
          style = "auto";

          search = {
            filters = [
              "global"
              "directory"
              "session-preload"
              "session"
            ];
          };

          stats = {
            common_subcommands = [
              "apt"
              "cargo"
              "composer"
              "dnf"
              "docker"
              "git"
              "go"
              "ip"
              "jj"
              "kubectl"
              "nix"
              "nmcli"
              "npm"
              "pecl"
              "pnpm"
              "podman"
              "port"
              "systemctl"
              "tmux"
              "yarn"

              "rustup"
              "home-manager"
              "darwin-rebuild"
              "convco"
              "typst"
              "brew"
            ];
          };

          ui = {
            columns = [
              "exit"
              {
                type = "command";
                expand = true;
              }
              "time"
              "directory"
            ];
          };
        };
      };

      clock-rs.enable = true;

      direnv = {
        enable = true;
        package = pkgsUnstable.direnv;

        nix-direnv = {
          enable = true;
          package = pkgsUnstable.nix-direnv;
        };

        stdlib = ''
          # stolen from @i077; store .direnv in cache instead of project dir
          declare -A direnv_layout_dirs
          direnv_layout_dir() {
            echo "''${direnv_layout_dirs[$PWD]:=$(
              echo -n "${config.xdg.cacheHome}"/direnv/layouts/
              echo -n "$PWD" | shasum | cut -d ' ' -f 1
            )}"
          }
        '';
      };

      fzf = rec {
        enable = true;
        enableFishIntegration = true;

        defaultCommand = "${pkgsUnstable.fd}/bin/fd -H --type f -E '**/.git/*' -E '**/.jj/*'";
        defaultOptions = ["--height 50%" "--border"];
        fileWidgetCommand = "${defaultCommand}";
        fileWidgetOptions = [
          "--preview '${pkgsUnstable.bat}/bin/bat --color=always --plain --line-range=:200 {}'"
        ];
        changeDirWidgetCommand = "${pkgsUnstable.fd}/bin/fd --type d";
        changeDirWidgetOptions = ["--preview '${pkgs.tree}/bin/tree -C {} | head -200'"];
      };

      jqp.enable = true;

      zoxide = {
        enable = true;
        enableFishIntegration = true;
      };
    };
  };
}
