{ config
, lib
, ...
}:

with lib;
let
  cfg = config.custom.git;
in
{
  options.custom.git = with types; {
    enable = mkEnableOption "git configuration";

    user = mkOption {
      description = "User details";
      type = submodule {
        options = {
          name = mkOption {
            description = "Full name";
            type = str;
            example = "Firstname Lastname";
          };

          email = mkOption {
            description = "Email";
            type = str;
            example = "name@example.com";
          };

          key = mkOption {
            description = "Path to an SSH key to use to sign commits";
            type = str;
          };
        };
      };
    };

    includes = mkOption {
      description = "List of extra config files to include based on a condition";
      type = listOf (submodule {
        options = {
          condition = mkOption {
            description = "The condition to include the extra config based on";
            type = str;
            example = "gitdir:~/src/work/";
          };

          path = mkOption {
            description = "Path to the config file";
            type = path;
          };
        };
      });
      default = [ ];
    };
  };

  config = mkIf cfg.enable {
    programs.git = {
      inherit (cfg) enable;
      # lfs.enable = true;

      userName = cfg.user.name;
      userEmail = cfg.user.email;

      aliases = {
        hist = "log --graph --pretty=format:'%C(magenta)%h%Creset - %G?%C(red)%d%Creset %s %C(dim green)(%cr) %C(cyan)<%aN>%Creset' --abbrev-commit";
        conflicted = "diff --name-only --diff-filter=U";
        unstage = "reset HEAD --";
        nuke = "checkout --";
        forcepush = "push --force-with-lease";

        ignore = "!gi() { curl -sL https://www.toptal.com/developers/gitignore/api/$@ ;}; gi";

        a = "add";
        ap = "add -p";
        bd = "branch -d";
        br = "branch";
        ci = "commit";
        cia = "commit --amend";
        cim = "commit -m";
        co = "checkout";
        cob = "checkout -b";
        di = "diff";
        dic = "diff --cached";
        f = "fetch --all --prune";
        pf = "push --force-with-lease";
        pu = "push -u";
        puo = "push -u origin";
        r = "rebase";
        ri = "rebase -i";
        rio = "rebase -i --onto";
        ro = "rebase --onto";
        st = "status";
      };

      extraConfig = {
        pull.rebase = true;
        pager.branch = false;
        rerere.enabled = true;
        init.defaultBranch = "main";
        core.excludesFile = "/etc/gitignore";

        merge.conflictStyle = "zdiff3";

        # Set the SSH key to sign with.
        user.signingKey = cfg.user.key;

        # Turn on commit signing. This isn't actually going to use GPG, because we're about to set it 
        # to use SSH instead.
        commit.gpgSign = true;

        gpg = {
          # Set commit signing to use SSH instead of GPG.
          format = "ssh";
          ssh.allowedSignersFile = "~/.ssh/allowed_signers";
        };
      };

      includes = map
        (include: {
          inherit (include) condition;
          path = "${include.path}";
        })
        cfg.includes;
    };
  };
}
