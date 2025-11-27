{
  config,
  pkgs,
  pkgsUnstable,
  ...
}: {
  environment = {
    systemPackages =
      (with pkgs; [
        # jdk17
        jdk21
        pandoc
        postgresql_15
        python39Packages.pygments
      ])
      ++ (with pkgsUnstable; [
        catgirl
        ffmpeg
        jujutsu
        tectonic
        yt-dlp

        (python313.withPackages (pyPkgs:
          with pyPkgs; [
            beancount
            beangulp
            beanquery
            fava
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
      "calibre"
      "chromium"
      "discord"
      "firefox"
      "gnucash"
      "handbrake-app"
      "jetbrains-toolbox"
      "jubler"
      "lagrange"
      "mkvtoolnix-app"
      "mullvad-vpn"
      "obs"
      "prismlauncher"
      "radio-silence"
      "signal"
      "skim"
      "splice"
      "steam"
      "stolendata-mpv"
      "subler"
      "teamspeak-client"
      "transmission"
      "whatsapp"
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
