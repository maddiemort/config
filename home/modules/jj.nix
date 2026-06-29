{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.custom.jj;

  inherit (lib) mkIf;
in
{
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
        private-commits = 'description(regex:"^megamerge") | bookmarks(regex:"^(mm/)?megamerge")'

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
          if(tracked, "", if(remote, label("bookmark", name ++ "@" ++ remote) ++ "\n", ""))
        ''''

        'jjblame_template' = ''''
          "⬥ " ++ separate(" ⬦ ",
            commit.author().name().replace("​", ""),
            "authored " ++ commit.author().timestamp().ago(),
            "committed " ++ commit.committer().timestamp().ago(),
            commit.change_id().short(7),
            coalesce(commit.description().first_line(), ""),
          )
        ''''

        [revsets]
        "bookmark-advance-from(to)" = "closest_local_bookmark(to)"
        "bookmark-advance-to" = "move_closest_target(@)"

        [revset-aliases]
        # Revisions that are ancestors of bookmarks.
        "bookmarked()" = "::(bookmarks() | untracked_remote_bookmarks())"

        # The closest first-parent ancestor of `x` that is an ancestor of any bookmark.
        "closest_bookmarked_ancestor(x)" = "heads(first_ancestors(x) & bookmarked())"

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

        # The closest revision along the path of described revisions between the closest local
        # bookmark to `x` and `x` itself.
        "move_closest_target(x)" = ''''
          exactly(
            heads(
              reachable(
                closest_local_bookmark(x),
                closest_local_bookmark(x)::x ~ description(exact:"")
              )
            ),
            1
          )
        ''''

        # Find all revisions that are reachable from a remote bookmark on the provided remote, but
        # without including any revisions that are on a remote bookmark on another remote.
        "unique_to_remote(remote)" = ''''
          reachable(
            remote_bookmarks(remote=exact:remote),
            (remote_bookmarks() ~ remote_bookmarks(remote=exact:remote))..
          )
        ''''

        # Similar to `unique_to_remote()`, but shows the parents of the revset as well to help
        # provide context.
        "remote_overview(remote)" = ''''
          unique_to_remote(remote) | unique_to_remote(remote)-
        ''''

        "stranded()" = "mine() ~ ::remote_bookmarks() ~ ((empty() ~ merges()) & description(exact:'''))"
        "my_bookmarks()" = "mine() & bookmarks() | tracked_remote_bookmarks()"

        # Megamerges. These might not actually be merge revisions, as long as they have a megamerge
        # branch pointing to them or a description that says they're megamerges - this is because
        # sometimes simplifying parents causes a megamerge to only have one parent.
        "megamerges()" = 'bookmarks("mm/megamerge/*") | bookmarks("megamerge/*") | description("megamerge*")'

        # Returns the closest megamerge in the parents of `to`.
        #
        # It might not actually be a merge revision, as long as it has a megamerge branch pointing
        # to it or a description that says it's a megamerge - this is because sometimes simplifying
        # parents causes a megamerge to only have one parent.
        "closest_megamerge(to)" = "heads(reachable(to, ::to & mutable()) & megamerges())"

        [aliases]
        advance = ["bookmark", "advance"]
        merge = ["new", "heads(::@ ~ (empty() & description(exact:''')))"]
        tip = ["new", "current_bookmark(@)"]

        # Inserts the given revset as a new branch under the megamerge.
        stack = ["rebase", "--simplify-parents", "--after", "trunk()", "--before", "closest_megamerge(@)"]

        # Interactively squashes some changes from the current revision (or the provided revision)
        # into a new branch under the megamerge.
        squeeze = ["squash", "--interactive", "--after", "trunk()", "--before", "closest_megamerge(@)"]

        # Stacks *all* the revsets after the megamerge together on one branch under the megamerge
        stage = ["stack", "--revision", "closest_megamerge(@)+:: ~ empty()"]

        # Like `stage`, but inserts the revsets after the megamerge as children of the provided
        # bookmark (as long as the bookmark is a parent of the megamerge) and advances the bookmark.
        insert = ["util", "exec", "--", "bash", "-c", """
          set -euo pipefail
          operation=$(jj op log --limit 1 --no-graph --no-pager -T 'id.short()')
          jj rebase \\
            --simplify-parents \\
            --revision "closest_megamerge(@)+:: ~ empty()" \\
            --after "exactly(heads(reachable($1, $1::(closest_megamerge(@)-))), 1)" \\
            && jj bookmark move "$1" --to "exactly(heads(reachable($1, $1::(closest_megamerge(@)-))), 1)" \\
            || jj op restore "$operation"
        """, ""]

        # Rebase all the member branches of the megamerge that we're allowed to modify onto the
        # trunk, simplifying parents afterwards.
        retrunk = [
          "rebase",
          "--simplify-parents",
          "--source", "roots(reachable(closest_megamerge(@), trunk()..closest_megamerge(@) & mutable()))",
          "--onto", "trunk()",
        ]

        # Pull the given revset into the megamerge (specifically, the new last parent) of the megamerge.
        include = ["util", "exec", "--", "bash", "-c", """
          set -euo pipefail
          jj rebase \\
            --simplify-parents \\
            --source "closest_megamerge(@)" \\
            --onto "parents(closest_megamerge(@))" \\
            --onto "$1"
        """, ""]

        # "Promote" the given revset to the first parent of the megamerge. This will include it if
        # it's not already in the merge.
        promote = ["util", "exec", "--", "bash", "-c", """
          set -euo pipefail
          jj rebase \\
            --simplify-parents \\
            --source "closest_megamerge(@)" \\
            --onto "$1" \\
            --onto "parents(closest_megamerge(@))"
        """, ""]

        # Remove the given revset from the parents of the megamerge.
        exclude = ["util", "exec", "--", "bash", "-c", """
          set -euo pipefail
          jj rebase \\
            --simplify-parents \\
            --source "closest_megamerge(@)" \\
            --onto "parents(closest_megamerge(@)) ~ ($1)"
        """, ""]

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

        watch = ["util", "exec", "--", "bash", "-c", """
          ${pkgs.watchexec}/bin/watchexec -d 350ms --workdir "$(jj workspace root)" -c --watch .jj --no-vcs-ignore -- \\
            jj --ignore-working-copy --at-op @ --no-pager --limit $(($(tput lines) / 2 - 2))
        """, ""]

        [ui]
        default-command = [
          "log",
          "-r",
          "reachable(closest_bookmarked_ancestor(@), mutable() | mutable()- | closest_bookmarked_ancestor(@)::current_bookmark(@))",
        ]
        diff-editor = ":builtin"
        movement.edit = true
        pager = "less"
        show-cryptographic-signatures = false

        [remotes.origin]
        auto-track-created-bookmarks = '~regex:"^(mm/)?megamerge"'

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
