{lib, ...}: {
  homebrew.casks = [
    "skim"
    "zulip"
  ];

  nix.linux-builder.enable = true;

  services = {
    yknotify-rs = {
      enable = true;
      requestSound = "Funk";
      dismissedSound = "Hero";
    };
  };

  system.stateVersion = 6;
  system.primaryUser = lib.mkForce "madeleine.mortensen";
}
