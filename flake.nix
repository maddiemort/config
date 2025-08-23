{
  description = "System and home configurations for my Darwin workstations";

  nixConfig.extra-experimental-features = "nix-command flakes";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils/main";

    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-24.11-darwin";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    nix-darwin.url = "github:LnL7/nix-darwin/nix-darwin-24.11";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager/release-24.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    agenix.url = "github:ryantm/agenix/main";
    agenix.inputs.nixpkgs.follows = "nixpkgs";
    agenix.inputs.darwin.follows = "nixpkgs";
    agenix.inputs.home-manager.follows = "home-manager";

    jj.url = "github:maddiemort/jj/updated-mailmap";
    jj.inputs.flake-utils.follows = "flake-utils";

    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay/master";
    neovim-nightly-overlay.inputs.nixpkgs.follows = "nixpkgs-unstable";

    yknotify-rs.url = "github:reo101/yknotify-rs/master";
    yknotify-rs.inputs.nixpkgs.follows = "nixpkgs-unstable";

    unison-lang.url = "github:ceedubs/unison-nix";
    unison-lang.inputs.nixpkgs.follows = "nixpkgs-unstable";
  };

  outputs = {
    self,
    flake-utils,
    nixpkgs,
    nixpkgs-unstable,
    nix-darwin,
    ...
  } @ inputs: let
    inherit (flake-utils.lib) eachSystem;
    inherit (flake-utils.lib.system) aarch64-darwin x86_64-darwin;
    inherit (inputs.home-manager.lib) homeManagerConfiguration;
    inherit (nix-darwin.lib) darwinSystem;
    inherit (nixpkgs.lib) optional;

    supportedSystems = [aarch64-darwin x86_64-darwin];

    mkOverlays = system: [
      inputs.agenix.overlays.default
      inputs.jj.overlays.default
      inputs.unison-lang.overlay

      (_: _: {
        inherit (inputs.home-manager.packages.${system}) home-manager;
      })

      (final: prev: {
        yt-dlp = prev.yt-dlp.overrideAttrs (_: {
          version = "fix-youtube-translation";

          src = final.fetchFromGitHub {
            owner = "kclauhk";
            repo = "yt-dlp";
            rev = "fix/youtube-translation";
            hash = "sha256-mDOgmGu+4VrJfPEn+29TKQov9HEGE8G2LkPxM5cfIGM=";
          };
        });
      })

      (final: prev: {
        key-menu-nvim = final.callPackage ./pkgs/key-menu-nvim.nix {};
        tla-nvim = final.callPackage ./pkgs/tla-nvim.nix {};
      })

      self.overlays.iosevka-custom
    ];

    mkUnstableOverlays = system:
      [
        inputs.neovim-nightly-overlay.overlays.default
      ]
      ++ mkOverlays system;

    pkgsFor = system: channel: overlays:
      import channel {
        inherit system overlays;
        config.allowUnfree = true;
      };

    stableFor = system: pkgsFor system nixpkgs (mkOverlays system);
    unstableFor = system: pkgsFor system nixpkgs-unstable (mkUnstableOverlays system);

    mkDarwin = {
      system,
      hostname,
    }: let
      pkgs = stableFor system;
      pkgsUnstable = unstableFor system;
    in
      darwinSystem {
        inherit system pkgs;
        modules = [
          inputs.agenix.darwinModules.age
          inputs.yknotify-rs.darwinModules.default
          ./system/common.nix
          ./system/hosts/${hostname}.nix
        ];
        specialArgs = {
          inherit pkgsUnstable;
        };
      };

    mkHome = {
      system,
      username,
      override ? null,
    }: let
      pkgs = stableFor system;
      pkgsUnstable = unstableFor system;
    in
      homeManagerConfiguration {
        inherit pkgs;
        modules =
          [
            inputs.agenix.homeManagerModules.age
            ./home/modules
            ./home/users/${username}.nix
          ]
          ++ optional (override != null) ./home/overrides/${override}.nix;
        extraSpecialArgs = {
          inherit pkgsUnstable;
        };
      };
  in
    (eachSystem supportedSystems (system: let
      pkgs = stableFor system;
      pkgsUnstable = unstableFor system;
    in {
      devShells.default = pkgs.mkShell {
        name = "maddiemort/config";
        packages =
          (with pkgs; [
            agenix
            home-manager
          ])
          ++ (with pkgsUnstable; [
            age-plugin-yubikey
          ]);
      };

      formatter = pkgsUnstable.alejandra;

      legacyPackages = {
        homeConfigurations = {
          maddie-betelgeuse = mkHome {
            inherit system;
            username = "maddie";
            override = "betelgeuse";
          };
          maddie-nashira = mkHome {
            inherit system;
            username = "maddie";
            override = "nashira";
          };
          maddie-natasha = mkHome {
            inherit system;
            username = "maddie";
            override = "natasha";
          };
          maddie-polaris = mkHome {
            inherit system;
            username = "maddie";
            override = "polaris";
          };
          maddie-rigel = mkHome {
            inherit system;
            username = "maddie";
            override = "rigel";
          };
        };
      };

      packages = {
        neovim = let
          maddie = mkHome {
            inherit system;
            username = "maddie";
          };
        in
          maddie.config.programs.neovim.finalPackage;
      };
    }))
    // {
      darwinConfigurations = {
        betelgeuse = mkDarwin {
          system = aarch64-darwin;
          hostname = "betelgeuse";
        };
        nashira = mkDarwin {
          system = aarch64-darwin;
          hostname = "nashira";
        };
        natasha = mkDarwin {
          system = aarch64-darwin;
          hostname = "natasha";
        };
        polaris = mkDarwin {
          system = aarch64-darwin;
          hostname = "polaris";
        };
        rigel = mkDarwin {
          system = x86_64-darwin;
          hostname = "rigel";
        };
      };

      overlays = {
        iosevka-custom = import ./overlays/iosevka-custom.nix;
      };
    };
}
