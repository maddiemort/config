{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.custom.shell;

  inherit (lib) mkIf;
in {
  config = mkIf cfg.enable {
    programs.fish = {
      enable = true;

      interactiveShellInit = ''
        export TERM=wezterm
        set -g fish_key_bindings fish_vi_key_bindings

        COMPLETE=fish jj | source

        function fish_greeting
          # ${pkgs.fastfetch}/bin/fastfetch
        end

        function git
          # Check if 'clean' appears as a subcommand and look for dangerous flags
          set -l has_clean false
          set -l has_x false
          set -l has_n false
          set -l has_i false

          for arg in $argv
            # Stop processing after -- (everything after is paths/filenames)
            if test "$arg" = "--"
              break
            end

            # Check if 'clean' appears as a complete argument. This means it's probably a subcommand,
            # and although there's the potential for some false positives by not taking the position of
            # the arg into account to determine whether it's a subcommand, this lets us avoid complex
            # logic to detect cases like `git -C foo clean` (where `clean` is the subcommand, but most
            # naïve approaches would think the subcommand is `foo`).
            if test "$arg" = "clean"
              set has_clean true
            end

            # Check for flags
            if string match -qr -- '^-[a-zA-Z]*[xX]' $arg
              set has_x true
            end
            if string match -qr -- '^-[a-zA-Z]*n' $arg
              set has_n true
            end
            if string match -qr -- '^-[a-zA-Z]*i' $arg
              set has_i true
            end
          end

          # Only prompt if this is 'clean' with -x/-X and without -n or -i
          if test "$has_clean" = true -a "$has_x" = true -a "$has_n" = false -a "$has_i" = false
            echo "warning: this might remove all ignored and untracked files (such as `.jj/`)"
            echo "warning: you can dry-run a `git clean` command by adding `-n` to its flags"
            read -l -P "Proceed? (y/n): " confirm
            if test "$confirm" != "y"
              echo "Aborting."
              return 1
            end
          end

          command git $argv
        end

        # catppuccin macchiato theme
        set -l red ed8796 #ed8796
        set -l green a6da95 #a6da95
        set -l yellow eed49f #eed49f
        set -l blue 8aadf4 #8aadf4
        set -l purple c6a0f6 #c6a0f6
        set -l cyan 8bd5ca #8bd5ca
        set -l black 1e2030 #1e2030
        set -l grey 5b6078 #5b6078
        set -l white cad3f5 #cad3f5
        set -g fish_color_normal $white
        set -g fish_color_command $purple
        set -g fish_color_keyword $yellow
        set -g fish_color_quote $green
        set -g fish_color_redirection $white
        set -g fish_color_error $red
        set -g fish_color_param $blue
        set -g fish_color_comment $grey
        set -g fish_color_selection --background=$grey
        set -g fish_color_search_match --background=$grey
        set -g fish_color_operator $green
        set -g fish_color_escape $cyan
        set -g fish_color_autosuggestion $grey
        set -g fish_color_cancel --background=$grey

        # Completion Pager Colors
        set -g fish_pager_color_progress $grey
        set -g fish_pager_color_prefix $cyan
        set -g fish_pager_color_completion $white
        set -g fish_pager_color_description $grey
        set -g fish_pager_color_selected_background --background=$grey
      '';

      shellAbbrs = {
        lsl = "eza -al";
        lst = "eza -alT -I '.git|.jj|target|node_modules'";
        lsta = "eza -alT";

        # Status/info
        ghg = "git status";
        ghf = "git hist";
        ghd = "git diff --color-moved";
        ghs = "git diff --color-moved --cached";
        gha = "git stash list";

        jsj = "jj status";

        jfj = "jj log";
        jfl = "jj log --limit";

        # Changes
        gjg = "git add";
        gjf = "git checkout --";
        gjd = "git add -p";
        gjs = "git reset HEAD --";
        gja = "git reset -p";

        # Commit
        gkg = "git commit";
        gkf = "git commit --amend";
        gkd = "git commit -m";

        # Push/pull
        glg = "git push";
        glf = "git push --force-with-lease";
        gld = "git push -u";
        gls = "git pull";
        gla = "git fetch -p --all";

        # Rebase
        gug = "git rebase";
        guf = "git rebase --onto";
        gud = "git rebase -i";
        gus = "git rebase --continue";
        gua = "git rebase --abort";

        # Branch/checkout
        gig = "git checkout";
        gif = "git branch -d";
        giF = "git branch -D";
        gid = "git checkout -b";
        gis = "git branch";
        gia = "git branch -r";

        # Stash
        gog = "git stash push";
        gof = "git stash drop";
        god = "git stash push --keep-index";
        gos = "git stash pop";
        goa = "git stash apply";

        # Bisect
        gyg = "git bisect start";
        gyf = "git bisect reset";
        gyd = "git bisect good";
        gys = "git bisect bad";
        gya = "git bisect run";

        # Merge
        gmg = "git merge";
        gmf = "git merge --squash";
        gmd = "git merge --signoff";
        gms = "git merge --continue";
        gma = "git merge --abort";

        gnd = "git clone";

        # Kubernetes
        k = "kubectl";
        kn = "kubectl -n $QUAY_USER";

        # Select which folders called target/ inside ~/src to delete
        delete-targets = "fd -It d '^target$' ~/src | fzf --multi --preview='eza -al {}/..' | xargs -r rm -r";

        # Select git branches to delete
        delete-branches = "git branch | rg -v '\*' | cut -c 3- | fzf --multi --preview='git hist {}' | xargs -r git branch --delete --force";

        # Select jj bookmarks to track/untrack
        track-bookmarks = ''
          jj bookmark list --all-remotes --quiet -T untracked_bookmark_name --sort committer-date- |\
            fzf --no-sort --multi --preview='jj log --color=always -r \'::{}\' --limit $(math "floor($LINES / 2)")' |\
            xargs -r jj bookmark track
        '';
        untrack-bookmarks = ''
          jj bookmark list --tracked --quiet -T tracked_bookmark_name --sort committer-date- |\
            fzf --no-sort --multi --preview='jj log --color=always -r \'::{}\' --limit $(math "floor($LINES / 2)")' |\
            xargs -r jj bookmark untrack
        '';
      };
    };
  };
}
