{
  description = "System and home configurations for my Darwin workstations";

  nixConfig.extra-experimental-features = "nix-command flakes";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils/main";

    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-26.05-darwin";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    nix-darwin.url = "github:LnL7/nix-darwin/nix-darwin-26.05";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    agenix.url = "github:ryantm/agenix/main";
    agenix.inputs.nixpkgs.follows = "nixpkgs";
    agenix.inputs.darwin.follows = "nix-darwin";
    agenix.inputs.home-manager.follows = "home-manager";

    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay/master";
    neovim-nightly-overlay.inputs.nixpkgs.follows = "nixpkgs-unstable";

    nixvim.url = "github:nix-community/nixvim/nixos-26.05";

    jj-blame-nvim.url = "github:maddiemort/jj-blame.nvim/main";
    jj-blame-nvim.inputs.nixpkgs.follows = "nixpkgs-unstable";
    jj-blame-nvim.inputs.flake-utils.follows = "flake-utils";

    yknotify-rs.url = "github:reo101/yknotify-rs/master";
    yknotify-rs.inputs.nixpkgs.follows = "nixpkgs-unstable";

    catppuccin.url = "github:catppuccin/nix/release-26.05";
    catppuccin.inputs.nixpkgs.follows = "nixpkgs";

    jj-lfs.url = "github:jj-vcs/jj/sbarfurth/push-uulvmqxnpmzk";
    jj-lfs.inputs.nixpkgs.follows = "nixpkgs-unstable";
    jj-lfs.inputs.flake-utils.follows = "flake-utils";
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
    inherit (flake-utils.lib.system) aarch64-darwin aarch64-linux;
    inherit (inputs.home-manager.lib) homeManagerConfiguration;
    inherit (nix-darwin.lib) darwinSystem;

    supportedSystems = [aarch64-darwin aarch64-linux];

    vimPluginsOverlay = final: prev: {
      help-vsplit-nvim = final.vimUtils.buildVimPlugin rec {
        pname = "help-vsplit.nvim";
        version = "1268670";
        src = final.fetchFromGitHub {
          owner = "anuvyklack";
          repo = pname;
          rev = "1268670db1bde2276fbfbadb9b12ec0c984ef229";
          hash = "sha256-X4PF1L06ShhzlsT8HiMCxXLc9hK0gNwzIwYIYwWwwto=";
        };
        meta.homepage = "https://github.com/anuvyklack/${pname}";
      };

      remote-nvim-nvim = let
        pname = "remote-nvim.nvim";
        version = "b269711";
        owner = "maddiemort";
      in
        final.vimUtils.buildVimPlugin rec {
          inherit pname version;
          src = final.fetchFromGitHub {
            inherit owner;
            repo = pname;
            rev = version;
            hash = "sha256-PuS5Ve1/LGNLtaNHTwwzdDYGUJi3AEXDjDMDaoY9I8g=";
          };
          doCheck = false;
          meta.homepage = "https://github.com/${owner}/${pname}";
        };

      # Attempt to fix folding in beancount files on first load. See comment in
      # `home/modules/nvim/config/extra.lua`.
      telescope-nvim = final.vimPlugins.telescope-nvim.overrideAttrs {
        src = final.fetchFromGitHub {
          owner = "nvim-telescope";
          repo = "telescope.nvim";
          rev = "bea6665a8f14f31e11a3093a3b4a92be313bf4be";
          hash = "sha256-YQdVPfWtbvoPScq27r+KRyvM0v6XzuRgzEEIn1qWFWg=";
        };
      };

      telescope-spell-errors = final.vimUtils.buildVimPlugin {
        pname = "telescope-spell-errors";
        version = "2025-11-28";
        src = final.fetchFromGitHub {
          owner = "matkrin";
          repo = "telescope-spell-errors.nvim";
          rev = "1567a8bf0998fe65ef6cb8c40f62a0eec0b7d774";
          hash = "sha256-AlgMr9sGDYJMCFsUPiRJz1mWr87eqF+qrpTMIGGHXoY=";
        };
        meta.homepage = "https://github.com/matkrin/telescope-spell-errors.nvim";
      };

      vim-beancount = final.vimUtils.buildVimPlugin {
        pname = "vim-beancount";
        version = "dd2f56a";
        src = final.fetchFromGitHub {
          owner = "nathangrigg";
          repo = "vim-beancount";
          rev = "dd2f56a122b698454af582cbe7eae471dbdc48f8";
          hash = "sha256-cZsmFCzF4X9sw0S3V/RR6HCX2H6ksoEY/DIL8PjAjAM=";
        };
        meta.homepage = "https://github.com/nathangrigg/vim-beancount/";
      };

      xcodebuild-nvim = final.vimUtils.buildVimPlugin rec {
        pname = "xcodebuild.nvim";
        version = "6ee81bc";
        src = final.fetchFromGitHub {
          owner = "wojciech-kulik";
          repo = pname;
          rev = "6ee81bcf0334eac180111ac7ac2435d421d1508d";
          hash = "sha256-e1/QTC3XJvib+LVdMJnaPXgq4HJ9JlczHrdTD0/poF0=";
        };
        dependencies = with prev.vimPlugins; [
          fzf-lua
          nui-nvim
          plenary-nvim
          snacks-nvim
          telescope-nvim
        ];
        meta.homepage = "https://github.com/wojciech-kulik/${pname}";
      };
    };

    mkOverlays = system: [
      (final: prev: {
        inherit
          (prev.lixPackageSets.stable)
          nixpkgs-review
          nix-eval-jobs
          nix-fast-build
          colmena
          ;
      })

      inputs.agenix.overlays.default

      (_: _: {
        inherit (inputs.home-manager.packages.${system}) home-manager;
        inherit (inputs.jj-blame-nvim.packages.${system}) jj-blame-nvim;

        jujutsu-lfs = inputs.jj-lfs.packages.${system}.jujutsu;
      })

      (final: prev: {
        nodejs = final.nodejs_latest;
        nodejs-slim = final.nodejs-slim_latest;

        devcontainer = prev.devcontainer.override {
          nodejs = final.nodejs_24;
          node-gyp = final.node-gyp.override {nodejs = final.nodejs_24;};
        };
      })

      vimPluginsOverlay

      (final: prev: {
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

    hosts = [
      "betelgeuse"
      "EQ-0265"
      "merope"
      "polaris"
    ];
  in
    (eachSystem supportedSystems (system: let
      pkgs = stableFor system;
      pkgsUnstable = unstableFor system;

      mkHome = {
        hostname,
        system,
      }: let
        pkgs = stableFor system;
        pkgsUnstable = unstableFor system;
      in
        homeManagerConfiguration {
          inherit pkgs;
          modules = [
            inputs.agenix.homeManagerModules.age
            inputs.catppuccin.homeModules.catppuccin
            inputs.nixvim.homeModules.nixvim
            ./home/modules
            ./home/common.nix
            ./home/hosts/${hostname}.nix
          ];
          extraSpecialArgs = {
            inherit inputs pkgsUnstable;
          };
        };

      homeConfigurations = builtins.listToAttrs (
        map (hostname: {
          name = hostname;
          value = mkHome {
            inherit hostname system;
          };
        })
        hosts
      );
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

      formatter = pkgs.nixfmt-tree;

      legacyPackages = {
        inherit homeConfigurations;
      };

      packages = {
        neovim =
          (inputs.nixvim.lib.evalNixvim {
            inherit system;
            modules = [self.nixosModules.nixvim];
            extraSpecialArgs = {
              inherit pkgs pkgsUnstable;
            };
          }).config.build.package;
      };
    }))
    // {
      darwinConfigurations = let
        mkDarwin = {
          hostname,
          system,
        }: let
          pkgs = stableFor system;
          pkgsUnstable = unstableFor system;
        in
          darwinSystem {
            inherit system pkgs;
            modules = [
              inputs.agenix.darwinModules.age
              inputs.yknotify-rs.darwinModules.default
              ./system/modules
              ./system/common.nix
              ./system/hosts/${hostname}.nix
            ];
            specialArgs = {
              inherit inputs pkgsUnstable;
            };
          };
      in
        builtins.listToAttrs (
          map (hostname: {
            name = hostname;
            value = mkDarwin {
              inherit hostname;
              system = aarch64-darwin;
            };
          })
          hosts
        );

      nixosModules = {
        nixvim = ./modules/nixvim;
      };

      overlays = {
        iosevka-custom = import ./overlays/iosevka-custom.nix;
        vim-plugins = vimPluginsOverlay;
      };
    };
}
