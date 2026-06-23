{pkgs, ...}: {
  age.identityPaths = [
    ../identities/maddie-ikerian.txt
    ../identities/maddie-ikerian-c.txt
  ];

  home.packages = with pkgs; [
    devcontainer
    docker
    docker-credential-helpers
    jujutsu-lfs
    lazydocker
  ];

  custom.nixvim = {
    beancount = false;
    latex = false;
    remote = true;
    swift = false;
    extras = false;
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
            memory = 16;

            disk = 100;
            arch = "host";
            runtime = "docker";
            modelRunner = "docker";
            hostname = "";
            kubernetes = {
              enabled = false;
              version = "v1.35.0+k3s1";
              k3sArgs = ["--disable=traefik"];
              port = 0;
            };
            autoActivate = true;
            network = {
              address = false;
              mode = "shared";
              interface = "en0";
              preferredRoute = false;
              dns = [];
              dnsHosts = {
                "host.docker.internal" = "host.lima.internal";
              };
              hostAddresses = false;
              gatewayAddress = "192.168.5.2";
            };
            forwardAgent = false;
            docker = {};
            vmType = "qemu";
            portForwarder = "ssh";
            rosetta = false;
            binfmt = true;
            nestedVirtualization = false;
            mountType = "sshfs";
            mountInotify = false;
            cpuType = "host";
            provision = [];
            sshConfig = true;
            sshPort = 0;
            mounts = [];
            diskImage = "";
            rootDisk = 20;
            env = {};
          };
        };
      };
    };
  };

  xdg.configFile."jj/conf.d/40-work.toml".text = ''
    [[--scope]]
    --when.repositories = ["~/src/gitlab.com/retinai_master"]

    [--scope.remotes.origin]
    auto-track-bookmarks = "mm/*"

    [--scope.templates]
    git_push_bookmark = '"mm/push-" ++ change_id.short()'

    [--scope.user]
    email = "madeleine.mortensen@ikerian.com"
  '';
}
