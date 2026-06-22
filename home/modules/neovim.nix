{
  config,
  lib,
  pkgs,
  pkgsUnstable,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.modules) importApply;

  cfg = config.custom.neovim;
in {
  options.custom.neovim = with lib; {
    enable = mkOption rec {
      description = "Whether to enable neovim";
      type = types.bool;
      default = true;
      example = !default;
    };

    defaultEditor = mkOption rec {
      description = "Whether to make neovim the default editor using the EDITOR environment variable";
      type = types.bool;
      default = true;
      example = !default;
    };
  };

  config = mkIf cfg.enable {
    home.sessionVariables = mkIf cfg.defaultEditor {
      EDITOR = "nvim";
    };

    programs.nixvim = {
      inherit (cfg) enable;
      imports = [
        (importApply ../../modules/neovim {
          inherit lib pkgs pkgsUnstable;
        })
      ];
    };
  };
}
