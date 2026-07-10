{ pkgs, ... }: {
  home.packages = with pkgs; [
    awscli2
    d4s
    devcontainer
    docker
    docker-credential-helpers
    glab
    gnumake
    jujutsu-lfs
    lazydocker
    terraform
    watch
  ];

  custom.nixvim = {
    beancount = false;
    latex = false;
    remote = true;
    swift = false;
    extras = false;
  };

  programs.fish.shellAbbrs = {
    lclean = "make dev/luna.clean";
    lcheck = "make dev/luna.check";
    lbuild = "make dev/luna.build";
    lrun = "make dev/luna.run";
    lrel = "make dev/luna.run-release";
    lwatch = "make dev/luna.watch";

    godo = "glab todo list";
  };

  services = {
    colima = {
      enable = true;
      profiles = {
        default = {
          isActive = true;
          isService = true;
          setDockerHost = true;
          settings = {
            cpu = 8;
            disk = 500;
            memory = 24;
            arch = "host";
            runtime = "docker";
            modelRunner = "docker";
            hostname = null;
            kubernetes = {
              enabled = false;
              version = "v1.35.0+k3s1";
              k3sArgs = [ "--disable=traefik" ];
              port = 0;
            };
            autoActivate = true;
            network = {
              address = false;
              mode = "shared";
              interface = "en0";
              preferredRoute = false;
              dns = [ ];
              dnsHosts = {
                "host.docker.internal" = "host.lima.internal";
              };
              hostAddresses = false;
              gatewayAddress = "192.168.5.2";
            };
            forwardAgent = false;
            docker = { };
            vmType = "vz";
            portForwarder = "ssh";
            rosetta = true;
            binfmt = true;
            nestedVirtualization = true;
            mountType = "virtiofs";
            mountInotify = true;
            cpuType = "host";
            provision = [ ];
            sshConfig = false;
            sshPort = 0;
            mounts = [ ];
            diskImage = "";
            rootDisk = 20;
            env = { };
          };
        };
      };
    };
  };

  xdg.configFile."d4s/config.yaml".text = ''
    d4s:
      ui:
        skin: "default"
  '';

  xdg.configFile."jj/conf.d/40-work.toml".text = ''
    [[--scope]]
    --when.repositories = ["~/src/gitlab.com/retinai_master"]

    [--scope.remotes.origin]
    auto-track-bookmarks = 'regex:"^mm/" ~ regex:"^mm/megamerge"'

    [--scope.templates]
    git_push_bookmark = '"mm/push-" ++ change_id.short()'

    [--scope.user]
    email = "madeleine.mortensen@ikerian.com"
  '';
}
