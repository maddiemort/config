{ pkgs
, pkgsUnstable
, ...
}:

{
  environment = {
    systemPackages = (with pkgs; [
      # jdk17
      jdk21
      pandoc
      python39Packages.pygments
    ]) ++ (with pkgsUnstable; [
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
      "discord@ptb"
      "gnucash"
      "handbrake"
      "jetbrains-toolbox"
      "lagrange"
      "mkvtoolnix"
      "obs"
      "prismlauncher"
      "skim"
      "splice"
      "steam"
      "stolendata-mpv"
      "subler"
      "teamspeak-client"
      "transmission"
      "zulip"
    ];
  };
}