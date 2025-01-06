{
  description = "System and home configurations for my Darwin workstations";

  nixConfig.extra-experimental-features = "nix-command flakes";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils/main";

    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-24.05-darwin";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    nix-darwin.url = "github:LnL7/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager/release-24.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    agenix.url = "github:ryantm/agenix/main";
    agenix.inputs.nixpkgs.follows = "nixpkgs";
    agenix.inputs.darwin.follows = "nixpkgs";
    agenix.inputs.home-manager.follows = "home-manager";

    jj.url = "github:maddiemort/jj/openssh-and-mailmap";
    jj.inputs.flake-utils.follows = "flake-utils";
    jj.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    { self
    , flake-utils
    , nixpkgs
    , nixpkgs-unstable
    , nix-darwin
    , ...
    } @ inputs:
    let
      inherit (flake-utils.lib) eachSystem;
      inherit (flake-utils.lib.system) aarch64-darwin x86_64-darwin;
      inherit (inputs.home-manager.lib) homeManagerConfiguration;
      inherit (nix-darwin.lib) darwinSystem;
      inherit (nixpkgs.lib) optional;

      supportedSystems = [ aarch64-darwin x86_64-darwin ];

      mkOverlays = system: [
        inputs.agenix.overlays.default
        inputs.jj.overlays.default

        (_: _: {
          inherit (inputs.home-manager.packages.${system}) home-manager;
        })

        (final: prev: {
          # Switches to the version from this PR, which adds support for
          # displaying jujutsu repo details:
          #
          # https://github.com/starship/starship/pull/6089
          starship = (prev.starship.overrideAttrs (old: rec {
            src = final.fetchFromGitHub {
              owner = "idursun";
              repo = "starship";
              rev = "7226aaedf2dd0dd34a7373859d25da45c7cd3eaa";
              hash = "sha256-m0eA4Kv5RikMcnYqRlGnyHV1bQS3kDgHhGYGqTvbZBE=";
            };

            cargoDeps = old.cargoDeps.overrideAttrs {
              inherit src;
              outputHash = "sha256-d6i9+gnkt4wXzqB8+eLofX4enejG/YYiJAtg7KimA6M=";
            };

            doCheck = false;
          }));
        })

        (final: prev: {
          key-menu-nvim = final.callPackage ./pkgs/key-menu-nvim.nix { };
          tla-nvim = final.callPackage ./pkgs/tla-nvim.nix { };
        })

        self.overlays.iosevka-custom
      ];

      pkgsFor = system: channel: overlays: import channel {
        inherit system overlays;
        config.allowUnfree = true;
      };

      stableFor = system: pkgsFor system nixpkgs (mkOverlays system);
      unstableFor = system: pkgsFor system nixpkgs-unstable (mkOverlays system);

      mkDarwin = { system, hostname }:
        let
          pkgs = stableFor system;
          pkgsUnstable = unstableFor system;
        in
        darwinSystem {
          inherit system pkgs;
          modules = [
            inputs.agenix.darwinModules.age
            ./system/common.nix
            ./system/hosts/${hostname}.nix
          ];
          specialArgs = {
            inherit pkgsUnstable;
          };
        };

      mkHome = { system, username, override ? null }:
        let
          pkgs = stableFor system;
          pkgsUnstable = unstableFor system;
        in
        homeManagerConfiguration {
          inherit pkgs;
          modules = [
            inputs.agenix.homeManagerModules.age
            ./home/modules
            ./home/users/${username}.nix
          ] ++ optional (override != null) ./home/overrides/${override}.nix;
          extraSpecialArgs = {
            inherit pkgsUnstable;
          };
        };
    in
    (eachSystem supportedSystems (system:
    let
      pkgs = stableFor system;
      pkgsUnstable = unstableFor system;
    in
    {
      devShells.default = pkgs.mkShell {
        name = "maddiemort/config";
        packages = (with pkgs; [
          agenix
          home-manager
        ]) ++ (with pkgsUnstable; [
          age-plugin-yubikey
        ]);
      };

      formatter = pkgs.nixpkgs-fmt;

      legacyPackages = {
        homeConfigurations = {
          maddie-betelgeuse = mkHome { inherit system; username = "maddie"; override = "betelgeuse"; };
          maddie-nashira = mkHome { inherit system; username = "maddie"; override = "nashira"; };
          maddie-polaris = mkHome { inherit system; username = "maddie"; override = "polaris"; };
          maddie-rigel = mkHome { inherit system; username = "maddie"; override = "rigel"; };
        };
      };

      packages = {
        neovim =
          let maddie = mkHome { inherit system; username = "maddie"; };
          in maddie.config.programs.neovim.finalPackage;
      };
    })) // {
      darwinConfigurations = {
        betelgeuse = mkDarwin { system = aarch64-darwin; hostname = "betelgeuse"; };
        nashira = mkDarwin { system = aarch64-darwin; hostname = "nashira"; };
        polaris = mkDarwin { system = aarch64-darwin; hostname = "polaris"; };
        rigel = mkDarwin { system = x86_64-darwin; hostname = "rigel"; };
      };

      overlays = {
        iosevka-custom = (import ./overlays/iosevka-custom.nix);
      };
    };
}
