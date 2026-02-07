{pkgs, ...}: {
  environment = {
    systemPackages = with pkgs; [
      mpv
    ];
  };

  homebrew.casks = [
    # This really does have to be installed through Homebrew, or 1Password will refuse to
    # integrate with it.
    "firefox"

    "ableton-live-standard"
    "adobe-acrobat-reader"
    "calibre"
    "ungoogled-chromium"
    "discord"
    "handbrake-app"
    "mullvad-vpn"
    "obs"
    "radio-silence"
    "skim"
    "signal"
    "splice"
    "steam"
    "teamspeak-client"
    "transmission"
    "whatsapp"
    "zulip"
  ];

  system.stateVersion = 5;
}
