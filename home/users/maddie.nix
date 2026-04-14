{
  config,
  pkgs,
  pkgsUnstable,
  ...
}: {
  home = {
    username = "maddie";
    homeDirectory = "/Users/maddie";

    packages =
      (with pkgs; [
        asciiquarium-transparent
        catgirl
        convco
        dig
        erdtree
        fzf
        gh
        ghostscript
        glow
        go
        gopls
        hl-log-viewer
        hyperfine
        imagemagick
        iosevka-custom
        lora
        monodraw
        pandoc
        samply
        tectonic
        tokei
      ])
      ++ (with pkgsUnstable; [
        cargo-expand
        cargo-generate
        cargo-modules
        cargo-nextest
        cargo-update
        exercism
        ice-bar
        jujutsu-0-40-0-mailmap
        # rust-analyzer
        rustup
        swiftlint
        tailscale
        thunderbird
        typst
        typstyle
        yubikey-manager
        yubikey-personalization
      ]);

    stateVersion = "22.11";

    sessionPath = [
      "$HOME/.cargo/bin"
    ];

    sessionVariables = rec {
      CLICOLOR = 1;
      LANG = "en_GB.UTF-8";
      LESS = "-cR";
      BAT_PAGER = "less ${LESS}";
    };

    file.".indentconfig.yaml".text = ''
      paths:
      - ${config.home.homeDirectory}/.indentsettings.yaml
    '';

    file.".indentsettings.yaml".text = ''
      defaultIndent: "  "
      verbatimEnvironments:
        listing: 1
        lstlisting: 1
        minted: 1
        tikzpicture: 1
        verbatim: 1
    '';
  };

  custom = {
    auth = {
      allowedSigners = [
        # My own keys
        {
          email = "me@maddie.wtf";
          key = builtins.readFile ../../keys/maddie-wtf.pub;
        }
        {
          email = "me@maddie.wtf";
          key = builtins.readFile ../../keys/maddie-wtf-c.pub;
        }
        {
          email = "me@maddie.wtf";
          key = builtins.readFile ../../keys/maddie-jj-wtf.pub;
        }
        {
          email = "maddie@ditto.live";
          key = builtins.readFile ../../keys/maddie-ditto.pub;
        }
        {
          email = "maddie@ditto.live";
          key = builtins.readFile ../../keys/maddie-ditto-c.pub;
        }
        {
          email = "maddie@ditto.live";
          key = builtins.readFile ../../keys/maddie-jj-ditto.pub;
        }
        {
          email = "maddie@ditto.com";
          key = builtins.readFile ../../keys/maddie-jj-ditto-com.pub;
        }

        # Known signers who are not me
        # { email = ""; key = ""; }
      ];
    };

    git = {
      enable = true;

      user = {
        name = "Madeleine Mortensen";
        email = "me@maddie.wtf";
      };
    };

    jj.enable = true;

    nvim = {
      enable = true;
      defaultEditor = true;
    };

    shell.enable = true;
    wezterm.enable = true;
    zed.enable = true;
  };

  programs = {
    home-manager.enable = true;
  };

  services = {
    home-manager.autoExpire.enable = true;
  };

  targets = {
    darwin = {
      copyApps.enable = true;
      linkApps.enable = false;
    };
  };

  xdg = {
    configFile = {
      "bottom/bottom.toml".source = (pkgs.formats.toml {}).generate "bottom.toml" {
        disk = {
          mount_filter = {
            # Whether to ignore any matches. Defaults to true.
            is_list_ignored = true;

            # A list of filters to try and match.
            list = [
              "/System/Volumes/\\w+"
              "/Library/Developer/CoreSimulator/Volumes/[^/]+"
              "/Library/Developer/CoreSimulator/Cryptex/Images/.*"
            ];

            # Whether to use regex. Defaults to false.
            regex = true;
            # Whether to be case-sensitive. Defaults to false.
            case_sensitive = true;
            # Whether to be require matching the whole word. Defaults to false.
            whole_word = true;
          };
        };
      };
    };
  };
}
