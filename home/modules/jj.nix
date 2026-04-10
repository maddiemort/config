{
  config,
  lib,
  ...
}: let
  cfg = config.custom.jj;

  inherit (lib) mkIf;
in {
  options.custom.jj = with lib; {
    enable = mkEnableOption "custom Jujutsu configuration";
  };

  config = mkIf cfg.enable {
    xdg.configFile = {
      "jj/conf.d/10-config.toml".text = ''
        [colors]
        "diff token" = { underline = false }

        [fix.tools.rustfmt]
        command = ["rustfmt", "--emit", "stdout"]
        patterns = ["glob:'**/*.rs'"]

        [git]
        subprocess = true
        fetch = ["glob:*"]

        [signing]
        backend = "ssh"
        backends.ssh.allowed-signers = "~/.ssh/allowed_signers"
        behavior = "own"

        [templates]
        git_push_bookmark = '"maddiemort/push-" ++ change_id.short()'

        [template-aliases]
        'format_short_signature(signature)' = ''''
        if(signature.email().domain().ends_with("users.noreply.github.com"),
          signature.name() ++ ' (GitHub)',
          signature.email(),
        )
        ''''
        'format_timestamp(timestamp)' = ''''
        if(timestamp.before("1 week ago"),
          timestamp.ago() ++ timestamp.format(" (%Y-%m-%d at %H:%M)"),
          timestamp.ago()
        )
        ''''

        'tracked_bookmark_name' = ''''
          if(remote, label("bookmark", name) ++ "\n", "")
        ''''

        'untracked_bookmark_name' = ''''
          if(tracked, "", if(remote, label("bookmark", name) ++ "\n", ""))
        ''''

        [revsets]
        "bookmark-advance-from" = "closest_local_bookmark(@)"
        "bookmark-advance-to" = "move_closest_target(@)"

        [revset-aliases]
        # Revisions that are ancestors of bookmarks.
        "bookmarked()" = "::(bookmarks() | untracked_remote_bookmarks())"

        # The closest ancestor of `x` that is an ancestor of any bookmark.
        "closest_bookmarked_ancestor(x)" = "heads(::x & bookmarked())"

        # The "current bookmark", as I'm defining it, which is the nearest bookmark found pointing
        # to any of the descendants of our closest bookmarked ancestor. We'll start by trying to
        # find local bookmarks in that set, but if we don't find any, look for tracked remote
        # bookmarks and then untracked remote bookmarks (we might have checked out the remote
        # bookmark for a PR without tracking it, for example).
        "current_bookmark(x)" = ''''
          roots(
            coalesce(
              closest_bookmarked_ancestor(x):: & bookmarks(),
              closest_bookmarked_ancestor(x):: & tracked_remote_bookmarks(),
              closest_bookmarked_ancestor(x):: & untracked_remote_bookmarks(),
            )
          )
        ''''

        # Unlike `closest_bookmarked_ancestor()`, this is the first *bookmark* we find in `x`'s
        # ancestors, not just the first *bookmarked* revision.
        "closest_local_bookmark(x)" = "heads(::x & bookmarks())"

        # The closest revision along the path of nonempty and described revisions between the
        # closest local bookmark to `x` and `x` itself.
        "move_closest_target(x)" = ''''
          exactly(
            heads(
              reachable(
                closest_local_bookmark(x),
                closest_local_bookmark(x)::x ~ empty() ~ description("")
              )
            ),
            1
          )
        ''''

        "stranded()" = "mine() ~ ::remote_bookmarks() ~ ((empty() ~ merges()) & description(exact:'''))"
        "my_bookmarks()" = "mine() & bookmarks() | tracked_remote_bookmarks()"

        [aliases]
        advance = ["bookmark", "advance"]
        merge = ["new", "heads(::@ ~ (empty() & description(exact:''')))"]
        tip = ["new", "current_bookmark(@)"]

        track-bookmarks = ["util", "exec", "--", "bash", "-c", """
          set -euo pipefail
          jj bookmark list --all-remotes --quiet -T untracked_bookmark_name --sort committer-date- |\\
            fzf --no-sort --multi --preview='jj log --color=always -r ::{} --limit $(math "floor($LINES / 2)")' |\\
            xargs -r jj bookmark track
        """, ""]

        untrack-bookmarks = ["util", "exec", "--", "bash", "-c", """
          set -euo pipefail
          jj bookmark list --tracked --quiet -T tracked_bookmark_name --sort committer-date- |\\
            fzf --no-sort --multi --preview='jj log --color=always -r ::{} --limit $(math "floor($LINES / 2)")' |\\
            xargs -r jj bookmark untrack
        """, ""]

        [ui]
        default-command = [
          "log",
          "-r",
          "reachable(closest_bookmarked_ancestor(@), mutable() | mutable()- | closest_bookmarked_ancestor(@)::current_bookmark(@))",
        ]
        diff-editor = ":builtin"
        movement.edit = true
        show-cryptographic-signatures = false

        [remotes.origin]
        auto-track-created-bookmarks = "*"

        [user]
        name = "Madeleine Mortensen"
        email = "me@maddie.wtf"

        [[--scope]]
        --when.commands = ["status"]

        [--scope.ui]
        paginate = "never"
      '';
    };
  };
}
