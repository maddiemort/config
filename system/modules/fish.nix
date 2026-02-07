{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.custom.fish;

  inherit (lib) mkIf;
in {
  options.custom.fish = with lib; {
    enable = mkEnableOption "Fish shell";
  };

  config = mkIf cfg.enable {
    environment.shells = [pkgs.fish];
    programs.fish.enable = true;
    users.users.maddie.shell = pkgs.fish;
  };
}
