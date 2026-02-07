{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: let
  cfg = config.custom.lix;

  inherit (lib) mkIf;
in {
  options.custom.lix = with lib; {
    enable = mkEnableOption "Lix package manager & custom configuration";
  };

  config = mkIf cfg.enable {
    nix = {
      extraOptions = ''
        min-free = 536870912
        keep-outputs = true
        keep-derivations = true
        fallback = true
      '';

      gc.automatic = true;

      nixPath = [
        "nixpkgs=${inputs.nixpkgs}"
        "unstable=${inputs.nixpkgs-unstable}"

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

      package = pkgs.lixPackageSets.stable.lix;

      registry = {
        nixpkgs.flake = inputs.nixpkgs;
        unstable.flake = inputs.nixpkgs-unstable;
      };

      optimise.automatic = true;

      settings = {
        auto-optimise-store = true;
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
  };
}
