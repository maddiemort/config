{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.custom.ssh-agent;

  inherit (lib) mkIf;
in {
  options.custom.ssh-agent = with lib; {
    enable = mkEnableOption "SSH agent";
  };

  config = mkIf cfg.enable {
    environment.variables = {
      SSH_AUTH_SOCK = "/tmp/ssh-agent.sock";
    };

    launchd.user.agents = {
      ssh-agent = {
        path = [config.environment.systemPath];
        command = "${pkgs.openssh}/bin/ssh-agent -D -a /tmp/ssh-agent.sock";
        serviceConfig.KeepAlive = true;
      };
    };
  };
}
