{ config
, lib
, pkgs
, ...
}:

let
  cfg = config.custom.auth;

  inherit (lib) concatMapStrings mkIf mkMerge;
  inherit (pkgs.stdenv.hostPlatform) isDarwin;
in
{
  options.custom.auth = with lib; {
    publicKeys = mkOption rec {
      description = ''
        A list of the user's SSH public key(s), optionally paired with an SSH 
        host match declaration to use for each key.
      '';
      type = types.listOf (types.submodule {
        options = {
          path = mkOption {
            description = "Path to the key";
            type = types.str;
          };

          host = mkOption {
            description = "SSH host match declaration to use for this key.";
            type = types.str;
            default = "*";
            example = "github.com";
          };
        };
      });
      default = [ ];
    };

    allowedSigners = mkOption rec {
      description = ''
        List of SSH keys that should be considered as valid when used to sign 
        Git commits.
      '';
      type = types.listOf (types.submodule {
        options = {
          email = mkOption {
            description = ''
              The email address of the owner of the SSH key. If unset, this will 
              default to "*", which is a wildcard that allows any email address 
              for commits signed with this key.
            '';
            type = types.str;
            default = "*";
            example = "user@example.com";
          };
          key = mkOption {
            description = ''
              The SSH key.
            '';
            type = types.str;
          };
        };
      });
      default = [ ];
    };
  };

  config = {
    programs.ssh.enable = true;
    home.file.".ssh/allowed_signers".text = concatMapStrings (key: "${key.email} ${key.key}") cfg.allowedSigners;

    programs.ssh.matchBlocks = mkMerge [
      (builtins.listToAttrs (map
        ({ path, host }: {
          name = host;
          value = {
            identityFile = path;
          };
        })
        cfg.publicKeys
      ))

      (mkIf isDarwin {
        "*" = {
          identitiesOnly = true;
          serverAliveInterval = 15;

          extraOptions = {
            PreferredAuthentications = "publickey";
          };
        };
      })
    ];
  };
}
