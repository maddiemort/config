{ pkgs, ... }: {
  imports = [
    ../non-work.nix
  ];

  environment = {
    systemPackages = with pkgs; [
      mpv
    ];
  };

  homebrew.casks = [
    "ableton-live-standard"
    "adobe-acrobat-reader"
    "handbrake-app"
    "obs"
    "radio-silence"
    "skim"
    "splice"
    "steam"
    "teamspeak-client"
    "transmission"
    "vivid-app"
  ];

  system.stateVersion = 5;
}
