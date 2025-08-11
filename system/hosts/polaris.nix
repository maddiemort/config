{
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
        tectonic
        typst
        yt-dlp
      ]);

    variables = {
      JRE8 = "${pkgs.jre8}";
    };
  };

  homebrew = {
    casks = [
      "ableton-live-standard"
      "calibre"
      "chromium"
      "discord"
      "gnucash"
      "handbrake-app"
      "jetbrains-toolbox"
      "jubler"
      "lagrange"
      "mkvtoolnix-app"
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

  system.stateVersion = 5;
}
