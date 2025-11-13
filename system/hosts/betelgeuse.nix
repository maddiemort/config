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
        postgresql_15
        python39Packages.pygments
      ])
      ++ (with pkgsUnstable; [
        catgirl
        tectonic
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
      "gnucash"
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
      "transmission"
      "whatsapp"
      "zulip"
    ];
  };

  system.stateVersion = 5;
}
