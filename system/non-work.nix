{pkgsUnstable, ...}: {
  environment.systemPackages = with pkgsUnstable; [
    spotify
    yt-dlp
  ];

  homebrew = {
    brews = [
      "xcode-build-server" # For xcodebuild.nvim
    ];
    casks = [
      "alt-tab"
      "calibre"
      "discord"
      "linear"
      # "logi-options+"
      "mullvad-vpn"
      "signal"
      "ungoogled-chromium"
      "whatsapp"
      "zulip"
    ];
  };

  networking = {
    applicationFirewall = {
      enable = true;
      enableStealthMode = true;
      blockAllIncoming = true;
      allowSignedApp = true;
    };
  };
}
