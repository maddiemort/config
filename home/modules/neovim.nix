{
  config,
  lib,
  pkgs,
  pkgsUnstable,
  ...
}:
let
  inherit (lib) mkIf;
  inherit (lib.modules) importApply;

  cfg = config.custom.neovim;
in
{
  imports = [
    ../../modules/nixvim/options.nix
  ];

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
        (importApply ../../modules/nixvim {
          inherit
            config
            lib
            pkgs
            pkgsUnstable
            ;
        })
      ];
    };
  };
}
