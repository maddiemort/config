{pkgs, ...}: {
  imports = [
    ../non-work.nix
  ];

  homebrew.casks = [
    # "ableton-live-standard"
    # "adobe-acrobat-reader"
    # "ungoogled-chromium"
    # "handbrake-app"
    # "obs"
    # "radio-silence"
    # "skim"
    # "splice"
    # "steam"
    # "teamspeak-client"
    # "transmission"
  ];

  system.stateVersion = 6;
}
