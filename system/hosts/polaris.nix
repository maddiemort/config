{
  config,
  pkgs,
  pkgsUnstable,
  ...
}: {
  imports = [
    ../non-work.nix
  ];

  environment = {
    systemPackages =
      (with pkgs; [
        # jdk17
        jdk21
        pandoc
        postgresql_15
      ])
      ++ (with pkgsUnstable; [
        ffmpeg

        (python314.withPackages (pyPkgs:
          with pyPkgs; [
            beancount
            beangulp
            beanquery
            fava
            pygments
            python-lsp-black
            python-lsp-server
          ]))
      ]);

    variables = {
      JRE8 = "${pkgs.jre8}";
    };
  };

  launchd.user.agents = {
    fava = {
      path = [config.environment.systemPath];
      command = "fava $HOME/Documents/Financial/Accounts/accounts.beancount";
      serviceConfig.KeepAlive = true;
    };
  };

  homebrew = {
    casks = [
      "ableton-live-standard"
      "adobe-acrobat-reader"
      "ungoogled-chromium"
      "handbrake-app"
      "jetbrains-toolbox"
      "jubler"
      "lagrange"
      "mkvtoolnix-app"
      "obs"
      "prismlauncher"
      "radio-silence"
      "skim"
      "splice"
      "steam"
      "stolendata-mpv"
      "subler"
      "teamspeak-client"
      "transmission"
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
