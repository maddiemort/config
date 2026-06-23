{
  lib,
  pkgsUnstable,
  ...
}: let
  inherit (lib) mkEnableOption mkOption;
in {
  options.custom.nixvim = with lib.types; {
    package = mkOption {
      type = package;
      default = pkgsUnstable.neovim-unwrapped;
    };

    beancount = mkEnableOption "plugins and config for working with Beancount";
    latex = mkEnableOption "plugins and config for working with LaTeX";
    remote = mkEnableOption "plugins and config for remote development";
    swift = mkEnableOption "plugins and config for Swift/Xcode development";

    extras = mkEnableOption "extra miscellaneous plugins and config";
  };
}
