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

        [revset-aliases]
        "closest_local_bookmark(to)" = "heads(::to & bookmarks())"
        "closest_bookmark(to)" = "heads(::to & (bookmarks() | untracked_remote_bookmarks()))"
        "move_closest_target()" = "heads(closest_local_bookmark(@)..@ ~ empty() ~ description(exact:'''))"
        "stranded()" = "mine() ~ ::remote_bookmarks() ~ ((empty() ~ merges()) & description(exact:'''))"
        "my_bookmarks()" = "mine() & bookmarks() | tracked_remote_bookmarks()"

        [aliases]
        move-closest = ["bookmark", "move", "--from", "closest_local_bookmark(@)"]
        advance = ["move-closest", "--to", "move_closest_target()"]
        merge = ["new", "heads(::@ ~ (empty() & description(exact:''')))"]
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
        default-command = "log"
        diff-editor = ":builtin"
        movement.edit = true
        show-cryptographic-signatures = false

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
