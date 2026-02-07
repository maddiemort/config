{
  config,
  lib,
  ...
}: let
  cfg = config.custom.homebrew;

  inherit (lib) mkIf;
in {
  options.custom.homebrew = with lib; {
    enable = mkEnableOption "Homebrew package manager";
  };

  config = mkIf cfg.enable {
    environment.systemPath = ["/opt/homebrew/bin"];

    homebrew = {
      enable = true;
      global.brewfile = true;

      onActivation = {
        # autoUpdate = true;
        cleanup = "uninstall";
        # upgrade = true;
      };
    };
  };
}
