{
  config,
  pkgs,
  pkgsUnstable,
  ...
}: {
  age.secrets.ditto-license = {
    file = ../../secrets/ditto-license.age;
    owner = "maddie";
  };
  age.secrets.quay-email-ditto = {
    file = ../../secrets/quay-email-ditto.age;
    owner = "maddie";
  };
  age.secrets.quay-token-ditto = {
    file = ../../secrets/quay-token-ditto.age;
    owner = "maddie";
  };
  age.secrets.quay-user-ditto = {
    file = ../../secrets/quay-user-ditto.age;
    owner = "maddie";
  };

  environment = {
    extraInit = ''
      export DITTO_LICENSE="$(cat ${config.age.secrets.ditto-license.path})"
      export QUAY_EMAIL="$(cat ${config.age.secrets.quay-email-ditto.path})"
      export QUAY_TOKEN="$(cat ${config.age.secrets.quay-token-ditto.path})"
      export QUAY_USER="$(cat ${config.age.secrets.quay-user-ditto.path})"

      ulimit -n unlimited
    '';

    systemPackages =
      (with pkgs; [
        # ninja
        # swig
        tlaplus18
      ])
      ++ (with pkgsUnstable; [
        cachix
        colima
        docker
        docker-buildx
        jujutsu-0-40-0-mailmap
        k3d
        kubectl
        stern

        (python314.withPackages (pyPkgs:
          with pyPkgs; [
            python-lsp-black
            python-lsp-server
          ]))
      ]);

    systemPath = [
      "/opt/jetbrains-toolbox"
    ];
  };

  homebrew = {
    brews = [
      # "ios-deploy"
      # "libimobiledevice"
      "sourcekitten"
      "swiftlint"
    ];

    casks = [
      "cool-retro-term"
      "docker-desktop"
      "firefox@developer-edition"
      "flutter"
      # "insomnia"
      "jetbrains-toolbox"
      "loom"
      "notion"
      "obs"
      # "slack" # installed automatically by Pixel
      "stats"
      "tla+-toolbox"
      "visual-studio-code"
      "zed@preview"
      # "zoom" # installed automatically by Pixel
      "zulip"
    ];
  };

  services = {
    yknotify-rs = {
      enable = true;
      requestSound = "Funk";
      dismissedSound = "Hero";
    };
  };

  system.stateVersion = 5;
}
