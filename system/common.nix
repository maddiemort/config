{
  pkgs,
  pkgsUnstable,
  ...
}: {
  custom = {
    fish.enable = true;
    homebrew.enable = true;
    lix.enable = true;
    ssh-agent.enable = true;
  };

  environment = {
    systemPackages =
      (with pkgs; [
        bat
        curl
        eza
        fd
        git
        gnupg
        jq
        obsidian
        openssh
        ripgrep
        sd
        unzip
        wget
        zip
      ])
      ++ (with pkgsUnstable; [
        bottom
        spotify
      ]);

    variables = {
      CURL_CA_BUNDLE = "/etc/ssl/certs/ca-certificates.crt";
    };
  };

  homebrew.casks = [
    "alt-tab"
    "linear-linear"
    "linearmouse"
    "logi-options+"
    "spotmenu"
  ];

  networking = {
    applicationFirewall = {
      enable = true;
      enableStealthMode = true;
      blockAllIncoming = true;
      allowSignedApp = true;
    };
  };

  programs = {
    _1password = {
      enable = true;
      package = pkgsUnstable._1password-cli;
    };

    _1password-gui = {
      enable = true;
      package = pkgsUnstable._1password-gui;
    };
  };

  security.pam.services.sudo_local.touchIdAuth = true;

  system = {
    defaults = {
      NSGlobalDomain = {
        # The amount of time after starting to hold down a key that it begins to repeat.
        InitialKeyRepeat = 10;
        # The amount of time betweeen repeated keypresses when holding a key.
        KeyRepeat = 2;
      };

      SoftwareUpdate = {
        # Don't automatically install macOS software updates.
        AutomaticallyInstallMacOSUpdates = false;
      };

      loginwindow = {
        # Show the login window as a name and password field instead of a list of users.
        SHOWFULLNAME = true;

        # Disable guest login.
        GuestEnabled = false;
      };
    };

    keyboard.enableKeyMapping = true;
    keyboard.remapCapsLockToControl = true;

    primaryUser = "maddie";
  };
}
