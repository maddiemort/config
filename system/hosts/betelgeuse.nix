{
  pkgs,
  pkgsUnstable,
  ...
}: {
  environment = {
    systemPackages =
      (with pkgs; [
        jdk17
        pandoc
      ])
      ++ (with pkgsUnstable; [
        catgirl
        jujutsu-0-40-0-mailmap
        tectonic

        (python313.withPackages (pyPkgs:
          with pyPkgs; [
            beancount
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

  homebrew = {
    casks = [
      "ableton-live-standard"
      "adobe-acrobat-reader"
      "calibre"
      "chromium"
      "discord"
      "firefox"
      "handbrake-app"
      "jetbrains-toolbox"
      "lagrange"
      "mullvad-vpn"
      "obs"
      "prismlauncher"
      "radio-silence"
      "signal"
      "skim"
      "splice"
      "steam"
      "stolendata-mpv"
      "teamspeak-client"
      "thorium"
      "transmission"
      "whatsapp"
      "zulip"
    ];
  };

  system.stateVersion = 5;
}
