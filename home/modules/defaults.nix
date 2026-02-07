{...}: {
  targets.darwin.currentHostDefaults = {
    "com.apple.AppleMultitouchTrackpad" = {
      # Enable tap-to-click on the trackpad
      Clicking = true;
    };

    "com.apple.dock" = {
      autohide = true;
      orientation = "bottom";
      show-recents = false;
      static-only = false;
      tilesize = 50;
    };

    "com.apple.finder" = {
      # Don't show icons on the desktop.
      CreateDesktop = false;

      FXEnableExtensionChangeWarning = false;

      # Use list view by default
      FXPreferredViewStyle = "Nlsv";

      ShowPathbar = true;
      _FXSortFoldersFirst = false;
      _FXSortFoldersFirstOnDesktop = false;
    };

    "com.apple.HIToolbox" = {
      # Pressing the Fn key opens the Emoji & Symbols menu
      AppleFnUsageType = 2;
    };

    "com.apple.LaunchServices" = {
      # Disable quarantine for downloaded applications (may not work anymore)
      LSQuarantine = false;
    };

    "com.apple.iphonesimulator" = {
      ScreenShotSaveLocation = "~/Desktop/Screenshots/Simulator";
    };

    "com.apple.screencapture" = {
      location = "~/Desktop/Screenshots";
    };

    "com.apple.TextEdit" = {
      RichText = false;
      SmartQuotes = false;
    };

    "com.apple.TimeMachine" = {
      DoNotOfferNewDisksForBackup = true;
    };

    "com.apple.universalaccess" = {
      showWindowTitlebarIcons = true;
    };

    NSGlobalDomain = {
      AppleFontSmoothing = 0;

      # Allow Tab to control all UI elements
      AppleKeyboardUIMode = 2;

      # Use the expanded save dialog by default. Why are there two??
      NSNavPanelExpandedStateForSaveMode = true;
      NSNavPanelExpandedStateForSaveMode2 = true;

      # Disable press-and-hold for entering special characters
      ApplePressAndHoldEnabled = false;

      AppleShowAllExtensions = false;
      AppleShowAllFiles = true;
      AppleShowScrollBars = "WhenScrolling";

      # Fn keys perform the printed special features when pressed
      "com.apple.keyboard.fnState" = false;

      # Turn off all the automatic correction shit
      NSAutomaticCapitalizationEnabled = false;
      NSAutomaticDashSubstitutionEnabled = false;
      NSAutomaticPeriodSubstitutionEnabled = false;
      NSAutomaticQuoteSubstitutionEnabled = false;
      NSAutomaticSpellingCorrectionEnabled = false;

      # Open the home directory instead of iCloud Documents by default when prompting for file save
      # location
      NSDocumentSaveNewDocumentsToCloud = false;

      NSQuitAlwaysKeepsWindow = false;

      # Use medium size Finder sidebar icons.
      NSTableViewDefaultSizeMode = 2;
    };

    ".GlobalPreferences" = {
      "com.apple.sound.beep.sound" = "Pong";
    };
  };
}
