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
      inherit (flake-utils.lib.system) aarch64-darwin;
      inherit (inputs.home-manager.lib) homeManagerConfiguration;
      inherit (nix-darwin.lib) darwinSystem;

      supportedSystems = [ aarch64-darwin ];

      mkOverlays = system: [
        inputs.agenix.overlays.default
        inputs.jj.overlays.default

        (_: _: {
          inherit (inputs.home-manager.packages.${system}) home-manager;
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

      mkDarwin = hostname:
        let
          system = aarch64-darwin;
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

      mkHome = username:
        let
          system = aarch64-darwin;
          pkgs = stableFor system;
          pkgsUnstable = unstableFor system;
        in
        homeManagerConfiguration {
          inherit pkgs;
          modules = [
            inputs.agenix.homeManagerModules.age
            ./home/modules
            ./home/users/${username}.nix
          ];
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
          maddie = mkHome "maddie";
        };
      };

      packages = {
        neovim = self.legacyPackages.${system}.homeConfigurations.maddie.config.programs.neovim.finalPackage;
      };
    })) // {
      darwinConfigurations = {
        nashira = mkDarwin "nashira";
      };
      overlays = {
        iosevka-custom = (import ./overlays/iosevka-custom.nix);
      };
    };
}
