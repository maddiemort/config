{
  config,
  lib,
  pkgs,
  pkgsUnstable,
  ...
}: {
  environment = {
    extraInit = let
      starship-toml =
        pkgs.writeText
        "starship.toml"
        (lib.fileContents ../static/starship.toml);
    in ''
      export SSH_AUTH_SOCK="/tmp/ssh-agent.sock"
      export STARSHIP_CONFIG=${starship-toml}
      export JJ_CONFIG="$HOME/.config/jj:$HOME/.config/jj/conf.d"
    '';

    pathsToLink = [
      "/Applications"
    ];

    shells = with pkgs; [
      fish
    ];

    systemPackages =
      (with pkgs; [
        asciiquarium-transparent
        cargo-expand
        cargo-generate
        cargo-modules
        cargo-nextest
        cargo-update
        convco
        curl
        dig
        erdtree
        fzf
        gh
        ghostscript
        glow
        go
        gopls
        hyperfine
        imagemagick
        jq
        python3
        tokei
        unzip
        wget
        zip
      ])
      ++ (with pkgsUnstable; [
        bat
        btop
        direnv
        exercism
        eza
        fd
        git
        gnupg
        hl-log-viewer
        jujutsu
        openssh
        ripgrep
        rust-analyzer
        rustup
        sd
        tailscale
        typst
        typstyle
        unison-ucm
        yubikey-manager
        yubikey-personalization
      ]);

    systemPath = [
      "/opt/homebrew/bin"
    ];

    variables = {
      CURL_CA_BUNDLE = "/etc/ssl/certs/ca-certificates.crt";

      TERMINFO_DIRS = [
        "${pkgsUnstable.wezterm.terminfo}/share/terminfo"
      ];
    };
  };

  fonts.packages = with pkgs; [
    iosevka-custom
    lora
  ];

  homebrew = {
    enable = true;

    casks = [
      "1password"
      "alt-tab"
      "jordanbaird-ice"
      "linear-linear"
      "linearmouse"
      "logi-options+"
      "monodraw"
      "obsidian"
      "scroll-reverser"
      "spotify"
      "thunderbird"
      "wezterm@nightly"
    ];

    global.brewfile = true;
    # onActivation.autoUpdate = true;
    # onActivation.upgrade = true;
  };

  launchd.user.agents = {
    ssh-agent = {
      path = [config.environment.systemPath];
      command = "${pkgs.openssh}/bin/ssh-agent -D -a /tmp/ssh-agent.sock";
      serviceConfig.KeepAlive = true;
    };
  };

  nix = {
    extraOptions = ''
      min-free = 536870912
      keep-outputs = true
      keep-derivations = true
      fallback = true
    '';

    gc.automatic = true;

    nixPath = [
      # TODO: This entry should be added automatically via FUP's
      # `nix.linkInputs` and `nix.generateNixPathFromInputs` options, but
      # currently that doesn't work because nix-darwin doesn't export packages,
      # which FUP expects.
      #
      # This entry should be removed once the upstream issues are fixed.
      #
      # https://github.com/LnL7/nix-darwin/issues/277
      # https://github.com/gytis-ivaskevicius/flake-utils-plus/issues/107
      #
      # NOTE: FUP isn't being used in this flake anymore......
      "darwin=/etc/nix/inputs/darwin"
    ];

    optimise.automatic = true;

    settings = {
      extra-experimental-features = "nix-command flakes";

      substituters = [
        "https://cache.nixos.org/"
        "https://nix-community.cachix.org"
      ];

      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];

      trusted-users = [
        "root"
        "@wheel"

        # Administrative users on Darwin are part of the @admin group.
        "@admin"
      ];
    };
  };

  programs = {
    fish = {
      enable = true;

      loginShellInit = let
        # Fix for incorrect order of items in $PATH, from:
        # https://github.com/LnL7/nix-darwin/issues/122#issuecomment-1659465635
        #
        # This naive quoting is good enough in this case. There shouldn't be any
        # double quotes in the input string, and it needs to be double quoted in case
        # it contains a space (which is unlikely!)
        dquote = str: "\"" + str + "\"";

        makeBinPathList = map (path: path + "/bin");
      in ''
        fish_add_path --move --prepend --path ${lib.concatMapStringsSep " " dquote (makeBinPathList config.environment.profiles)}
        set fish_user_paths $fish_user_paths
      '';
    };

    zsh.interactiveShellInit = ''
      source /Applications/WezTerm.app/Contents/Resources/wezterm.sh
      export TERM=wezterm
    '';
  };

  system = {
    defaults = {
      LaunchServices = {
        # Disable quarantine for downloaded applications.
        LSQuarantine = false;
      };

      ".GlobalPreferences" = {
        "com.apple.sound.beep.sound" = /System/Library/Sounds/Morse.aiff;
      };

      NSGlobalDomain = {
        # Turn off "font smoothing", because it looks terrible on HiDPI displays that aren't Retina.
        AppleFontSmoothing = 0;

        # Allow Tab to control all UI elements.
        AppleKeyboardUIMode = 3;

        # Disable press-and-hold for entering special characters.
        ApplePressAndHoldEnabled = false;

        # Hide scrollbars except when actively scrolling, regardless of input device.
        AppleShowScrollBars = "WhenScrolling";

        # Turn off all the automatic correction shit.
        NSAutomaticCapitalizationEnabled = false;
        NSAutomaticDashSubstitutionEnabled = false;
        NSAutomaticPeriodSubstitutionEnabled = false;
        NSAutomaticQuoteSubstitutionEnabled = false;
        NSAutomaticSpellingCorrectionEnabled = false;

        # Don't save things to iCloud automatically.
        NSDocumentSaveNewDocumentsToCloud = false;

        # Use the expanded save dialog by default. Why are there two??
        NSNavPanelExpandedStateForSaveMode = true;
        NSNavPanelExpandedStateForSaveMode2 = true;

        # Use medium size Finder sidebar icons.
        NSTableViewDefaultSizeMode = 2;

        # The amount of time after starting to hold down a key that it begins to repeat.
        InitialKeyRepeat = 10;
        # The amount of time betweeen repeated keypresses when holding a key.
        KeyRepeat = 2;
      };

      SoftwareUpdate = {
        # Don't automatically install macOS software updates.
        AutomaticallyInstallMacOSUpdates = false;
      };

      # Firewall settings.
      alf = {
        # Enable the firewall.
        globalstate = 1;

        # Allow any downloaded app that's been signed to accept incoming requests.
        allowdownloadsignedenabled = 1;

        # Enable stealth mode (drops incoming requests via ICMP such as ping requests).
        stealthenabled = 1;
      };

      dock = {
        # Auto-hide the dock.
        autohide = true;

        # Don't show recent apps in the dock.
        show-recents = false;

        # Don't only show open apps in the dock.
        static-only = false;

        # Set the icon size in the dock to smaller than default.
        tilesize = 50;
      };

      finder = {
        # Don't show icons on the desktop.
        CreateDesktop = false;

        # Don't warn when changing the extension of items.
        FXEnableExtensionChangeWarning = false;
      };

      loginwindow = {
        # Show the login window as a name and password field instead of a list of users.
        SHOWFULLNAME = true;

        # Disable guest login.
        GuestEnabled = false;
      };

      screencapture = {
        location = "~/Pictures/Screenshots";
      };

      trackpad = {
        # Enable tap-to-click on the trackpad.
        Clicking = true;
      };
    };

    keyboard.enableKeyMapping = true;
    keyboard.remapCapsLockToControl = true;
  };

  # TODO: Figure out if there's a way to default this rather than setting it for
  # individual users.
  users.users.maddie.shell = pkgs.fish;
}
