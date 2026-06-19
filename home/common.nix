{
  config,
  pkgs,
  pkgsUnstable,
  lib,
  ...
}: let
  age-with-yubikey = let
    wrapped = pkgs.age.withPlugins (ps: [ps.age-plugin-yubikey]);
  in
    wrapped.overrideAttrs (old: {
      meta =
        (old.meta or {})
        // {
          mainProgram = "age";
        };
    });

  common = {
    age.package = age-with-yubikey;

    launchd.agents.activate-agenix.config.KeepAlive.Crashed = lib.mkForce null;

    home = {
      homeDirectory = "/Users/${config.home.username}";

      packages =
        [age-with-yubikey]
        ++ (with pkgs; [
          age-plugin-yubikey
          asciiquarium-transparent
          dig
          erdtree
          fzf
          gh
          glow
          hl-log-viewer
          hyperfine
          imagemagick
          iosevka-custom
          lora
          monodraw
          samply
          tokei
        ])
        ++ (with pkgsUnstable; [
          cargo-expand
          cargo-generate
          cargo-modules
          cargo-nextest
          cargo-update
          devpod
          ice-bar
          swiftlint
          thunderbird
          typst
          typstyle
        ]);

      sessionPath = [
        "$HOME/.cargo/bin"
        "$HOME/.local/bin"
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

    catppuccin = {
      accent = "lavender";
      flavor = "macchiato";

      bat.enable = true;
      bottom.enable = true;
      btop.enable = true;
      eza.enable = true;
    };

    custom = {
      auth = {
        allowedSigners = [
          # My own keys
          {
            email = "me@maddie.wtf";
            key = builtins.readFile ../keys/maddie-wtf.pub;
          }
          {
            email = "me@maddie.wtf";
            key = builtins.readFile ../keys/maddie-wtf-c.pub;
          }
          {
            email = "me@maddie.wtf";
            key = builtins.readFile ../keys/maddie-jj-wtf.pub;
          }
          {
            email = "maddie@ditto.live";
            key = builtins.readFile ../keys/maddie-ditto.pub;
          }
          {
            email = "maddie@ditto.live";
            key = builtins.readFile ../keys/maddie-ditto-c.pub;
          }
          {
            email = "maddie@ditto.live";
            key = builtins.readFile ../keys/maddie-jj-ditto.pub;
          }
          {
            email = "maddie@ditto.com";
            key = builtins.readFile ../keys/maddie-jj-ditto-com.pub;
          }
          {
            email = "madeleine.mortensen@ikerian.com";
            key = builtins.readFile ../keys/maddie-ikerian.pub;
          }
          {
            email = "madeleine.mortensen@ikerian.com";
            key = builtins.readFile ../keys/maddie-ikerian-c.pub;
          }
          {
            email = "madeleine.mortensen@ikerian.com";
            key = builtins.readFile ../keys/maddie-jj-ikerian.pub;
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

      neovim = {
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
  };

  darwin = {
    targets.darwin = {
      copyApps.enable = true;
      linkApps.enable = false;
    };
  };
in
  lib.mkMerge
  [
    common
    (lib.mkIf pkgs.stdenv.isDarwin darwin)
  ]
