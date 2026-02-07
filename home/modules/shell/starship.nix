{
  config,
  lib,
  ...
}: let
  cfg = config.custom.shell;

  inherit (lib) mkIf;
in {
  config = mkIf cfg.enable {
    programs.starship = {
      enable = true;

      settings = {
        add_newline = true;

        format = "$username$hostname$localip$shlvl$singularity$kubernetes$directory\${custom.jujutsu}$all";
        # \${custom.jujutsu-closest-bookmarks}

        aws.symbol = "  ";
        conda.symbol = "  ";
        docker_context.symbol = "  ";
        elixir.symbol = "  ";
        elm.symbol = "  ";
        golang.symbol = "  ";
        haskell.symbol = "  ";
        hg_branch.symbol = "  ";
        java.symbol = "  ";
        julia.symbol = "  ";
        nim.symbol = " ";
        nodejs.symbol = "  ";
        package.symbol = "📦 ";
        php.symbol = "  ";
        python.symbol = "  ";
        ruby.symbol = "  ";
        rust.symbol = "  ";

        battery = {
          disabled = true;
          full_symbol = "";
          charging_symbol = "";
          discharging_symbol = "";
        };

        directory = {
          style = "cyan";
          read_only = " 🔒";
        };

        direnv = {
          disabled = true;
          format = "[$symbol($loaded)(/$allowed)]($style) ";
          symbol = "◉ ";
          allowed_msg = "";
        };

        dotnet.disabled = true;

        git_branch = {
          disabled = false;
          style = "purple";
          format = "on [[$symbol](bold $style)$branch(:$remote_branch)]($style) ";
          only_attached = true;
        };

        git_commit = {
          disabled = true;
          style = "purple";
          format = "on [[](bold $style) $hash$tag]($style) ";
          only_detached = true;
        };

        git_state.disabled = false;
        git_status.disabled = true;

        kubernetes.disabled = false;

        memory_usage = {
          symbol = " ";
          disabled = true;
        };

        nix_shell = {
          format = "in [$symbol($name )]($style)";
          symbol = "  ";
        };

        status = {
          symbol = "×";
          not_executable_symbol = "∅";
          not_found_symbol = "∉";
          sigint_symbol = "⊥";
          signal_symbol = "⋕";
          disabled = true;
        };

        sudo = {
          symbol = "⚝  ";
          disabled = false;
        };

        custom = {
          jujutsu = {
            symbol = "[@](green)";
            format = "$symbol( $output) ";
            detect_folders = [".jj"];
            when = "jj workspace root --ignore-working-copy --quiet";
            command = ''
              jj \
                log \
                -r@ \
                -n1 \
                --ignore-working-copy \
                --no-graph \
                --no-pager \
                --color always \
                -T 'separate(" ",
                  label(
                    "working_copy mutable change_id",
                    format_short_change_id_with_change_offset(self)
                      ++ if(self.contained_in("::bookmarks() ~ ::remote_bookmarks()"), "*"),
                  ),
                  if(conflict, label("conflict", "conflict")),
                  if(immutable, label("warning", "immutable")),
                  bookmarks,
                  tags,
                  if(
                    !(author.email() == config("user.email").as_string()
                      || author.name().replace("​", "") == config("user.name").as_string()),
                    "by " ++ author.name(),
                  ),
                  if(
                    !(author.name() == committer.name()
                      || (committer.name() == "GitHub" && committer.email() == "noreply@github.com")),
                    "via " ++ committer.name(),
                  ),
                )'
            '';
          };

          # jujutsu-closest-bookmarks = {
          #   symbol = "[](green)";
          #   format = "($symbol $output )";
          #   detect_folders = [".jj"];
          #   when = "jj workspace root --ignore-working-copy --quiet";
          #   command = ''
          #     jj \
          #       log \
          #       -r 'closest_bookmark(@)' \
          #       --ignore-working-copy \
          #       --no-graph \
          #       --no-pager \
          #       --color always \
          #       -T 'bookmarks.join(" ") ++ " "'
          #   '';
          # };
        };
      };
    };
  };
}
