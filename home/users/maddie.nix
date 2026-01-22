{
  config,
  pkgs,
  pkgsUnstable,
  ...
}: {
  home = {
    username = "maddie";
    homeDirectory = "/Users/maddie";

    stateVersion = "22.11";

    sessionPath = [
      "$HOME/.cargo/bin"
    ];

    sessionVariables = rec {
      CLICOLOR = 1;
      LANG = "en_GB.UTF-8";
      LESS = "-cR";
      BAT_PAGER = "less ${LESS}";
      # EDITOR = "hx";
    };

    file.".indentconfig.yaml".text = ''
      paths:
      - ${config.home.homeDirectory}/.indentsettings.yaml
    '';

    file.".indentsettings.yaml".text = ''
      defaultIndent: "  "
      verbatimEnvironments:
        listing: 1
        lstlisting: 1
        minted: 1
        tikzpicture: 1
        verbatim: 1
    '';
  };

  custom = {
    nvim = {
      enable = true;
      defaultEditor = true;
    };

    auth = {
      allowedSigners = [
        # My own keys
        {
          email = "me@maddie.wtf";
          key = builtins.readFile ../../keys/maddie-wtf.pub;
        }
        {
          email = "me@maddie.wtf";
          key = builtins.readFile ../../keys/maddie-wtf-c.pub;
        }
        {
          email = "me@maddie.wtf";
          key = builtins.readFile ../../keys/maddie-jj-wtf.pub;
        }
        {
          email = "maddie@ditto.live";
          key = builtins.readFile ../../keys/maddie-ditto.pub;
        }
        {
          email = "maddie@ditto.live";
          key = builtins.readFile ../../keys/maddie-ditto-c.pub;
        }
        {
          email = "maddie@ditto.live";
          key = builtins.readFile ../../keys/maddie-jj-ditto.pub;
        }
        {
          email = "maddie@ditto.com";
          key = builtins.readFile ../../keys/maddie-jj-ditto-com.pub;
        }

        # Known signers who are not me
        # { email = ""; key = ""; }
      ];
    };

    git = {
      enable = true;

      user = {
        name = "Madeleine Mortensen";
        email = "me@maddie.wtf";
      };
    };
  };

  programs = {
    home-manager.enable = true;

    direnv = {
      enable = true;
      nix-direnv.enable = true;

      stdlib = ''
        # stolen from @i077; store .direnv in cache instead of project dir
        declare -A direnv_layout_dirs
        direnv_layout_dir() {
          echo "''${direnv_layout_dirs[$PWD]:=$(
            echo -n "${config.xdg.cacheHome}"/direnv/layouts/
            echo -n "$PWD" | shasum | cut -d ' ' -f 1
          )}"
        }
      '';
    };

    zoxide = {
      enable = true;
      enableFishIntegration = true;
    };

    starship.enable = true;

    fzf = rec {
      enable = true;
      enableFishIntegration = true;

      defaultCommand = "${pkgsUnstable.fd}/bin/fd -H --type f";
      defaultOptions = ["--height 50%" "--border"];
      fileWidgetCommand = "${defaultCommand}";
      fileWidgetOptions = [
        "--preview '${pkgsUnstable.bat}/bin/bat --color=always --plain --line-range=:200 {}'"
      ];
      changeDirWidgetCommand = "${pkgsUnstable.fd}/bin/fd --type d";
      changeDirWidgetOptions = ["--preview '${pkgs.tree}/bin/tree -C {} | head -200'"];
    };

    fish = {
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
          jj bookmark list --all-remotes --quiet -T untracked_bookmark_name |\
            fzf --multi --preview='jj log --color=always -r \'::{}\' --limit $(math "floor($LINES / 2)")' |\
            xargs -r jj bookmark track
        '';
        untrack-bookmarks = ''
          jj bookmark list --tracked --quiet -T tracked_bookmark_name |\
            fzf --multi --preview='jj log --color=always -r \'::{}\' --limit $(math "floor($LINES / 2)")' |\
            xargs -r jj bookmark untrack
        '';
      };
    };

    helix = {
      enable = true;
      package = pkgsUnstable.helix;
      settings = {
        theme = "catppuccin_macchiato";

        editor = {
          scrolloff = 3;
          scroll-lines = 2;
          shell = ["fish" "-c"];
          line-number = "relative";
          cursorline = true;
          auto-completion = false;
          preview-completion-insert = false;
          auto-info = true;
          color-modes = true;
          text-width = 100;

          statusline = {
            left = [
              "mode"
              "spacer"
              "spinner"
              "spacer"
              "diagnostics"
              "file-name"
              "read-only-indicator"
              "file-modification-indicator"
            ];
            center = [];
            right = [
              "workspace-diagnostics"
              "selections"
              "register"
              "position"
              "file-encoding"
              "file-line-ending"
            ];
            separator = "│";
            mode = {
              normal = "NOR";
              insert = "INS";
              select = "SEL";
            };
          };

          lsp = {
            display-messages = true;
            display-inlay-hints = true;
          };

          file-picker = {
            hidden = false;
          };

          auto-pairs = false;

          indent-guides = {
            render = true;
          };

          cursor-shape = {
            insert = "bar";
          };

          end-of-line-diagnostics = "hint";

          inline-diagnostics = {
            cursor-line = "error";
          };
        };
      };

      languages = {
        language-server.rust-analyzer = {
          config = {
            inlayHints = {
              typeHints.enable = true;
              parameterHints.enable = true;
            };
          };
        };

        language = [
          {
            name = "nix";
            auto-format = true;
          }
        ];
      };

      extraPackages =
        (with pkgs; [
          lua-language-server
          marksman
          nil
          nixpkgs-fmt
          shellcheck
          taplo
          tinymist
          yaml-language-server
        ])
        ++ (with pkgs.nodePackages; [
          bash-language-server
          vscode-json-languageserver
        ]);
    };
  };

  xdg = {
    configFile = {
      "bottom/bottom.toml".source = (pkgs.formats.toml {}).generate "bottom.toml" {
        disk = {
          mount_filter = {
            # Whether to ignore any matches. Defaults to true.
            is_list_ignored = true;

            # A list of filters to try and match.
            list = [
              "/System/Volumes/\\w+"
              "/Library/Developer/CoreSimulator/Volumes/[^/]+"
              "/Library/Developer/CoreSimulator/Cryptex/Images/.*"
            ];

            # Whether to use regex. Defaults to false.
            regex = true;
            # Whether to be case-sensitive. Defaults to false.
            case_sensitive = true;
            # Whether to be require matching the whole word. Defaults to false.
            whole_word = true;
          };
        };
      };

      "git/ignore".source = ../../static/gitignore;

      # By default, jj wants to look in ~/Library/Application Support for this file on macOS, so in
      # order for this to work, the env var `JJ_CONFIG` has to be set to `~/.config/jj` in the
      # system config.
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
          if(remote, label("bookmark", name ++ "@" ++ remote) ++ "\n", "")
        ''''

        'untracked_bookmark_name' = ''''
          if(tracked, "", if(remote, label("bookmark", name ++ "@" ++ remote) ++ "\n", ""))
        ''''

        [revset-aliases]
        "closest_bookmark(to)" = "heads(::to & bookmarks())"
        "move_closest_target()" = "heads(closest_bookmark(@)..@ ~ empty() ~ description(exact:'''))"
        "stranded()" = "mine() ~ ::remote_bookmarks() ~ ((empty() ~ merges()) & description(exact:'''))"
        "my_bookmarks()" = "mine() & bookmarks() | tracked_remote_bookmarks()"

        [aliases]
        move-closest = ["bookmark", "move", "--from", "closest_bookmark(@)"]
        advance = ["bookmark", "move", "--from", "closest_bookmark(@)", "--to", "move_closest_target()"]
        merge = ["new", "heads(::@ ~ (empty() & description(exact:''')))"]

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

      "wezterm/wezterm.lua".text = ''
        local wezterm = require 'wezterm';

        local config = wezterm.config_builder()

        config.color_scheme = "Catppuccin Macchiato"
        config.font = wezterm.font {
          family = "Iosevka Custom",
          weight = "Light",
        }
        config.font_size = 16.0
        config.warn_about_missing_glyphs = false

        config.enable_scroll_bar = true
        config.scrollback_lines = 100000

        config.audible_bell = "Disabled"
        config.exit_behavior = "Close"
        -- config.check_for_updates = false

        config.window_decorations = "RESIZE"
        config.native_macos_fullscreen_mode = false
        config.send_composed_key_when_left_alt_is_pressed = true
        config.send_composed_key_when_right_alt_is_pressed = false

        -- The leader key (Ctrl-Space) must be pressed before any bindings with the LEADER modifier
        config.leader = { key = "Space", mods = "CTRL", timeout_milliseconds = 1000 }
        config.disable_default_key_bindings = true
        config.keys = {
          -- Reload the config file
          { key = "r", mods = "LEADER", action = "ReloadConfiguration" },

          -- Enter and exit fullscreen
          { key = "Enter", mods = "ALT", action = "ToggleFullScreen" },

          -- Create and close tabs
          { key = "c", mods = "LEADER", action = wezterm.action { SpawnCommandInNewTab = { domain = "CurrentPaneDomain", cwd = "~" } } },
          { key = "c", mods = "LEADER|SHIFT", action = wezterm.action.ShowLauncher },
          { key = "k", mods = "LEADER", action = wezterm.action { CloseCurrentTab = { confirm = true } } },

          -- Select next and previous tabs
          { key = "n", mods = "LEADER", action = wezterm.action { ActivateTabRelative = 1 } },
          { key = "p", mods = "LEADER", action = wezterm.action { ActivateTabRelative = -1 } },

          -- Move tabs
          { key = "LeftArrow", mods = "SUPER|SHIFT", action = wezterm.action.MoveTabRelative(-1) },
          { key = "RightArrow", mods = "SUPER|SHIFT", action = wezterm.action.MoveTabRelative(1) },

          -- Create horizontal or vertical splits (close by sending EOF with Ctrl-D)
          { key = "|", mods = "LEADER", action = wezterm.action { SplitHorizontal = { domain = "CurrentPaneDomain" } } },
          { key = "|", mods = "LEADER|SHIFT", action = wezterm.action { SplitHorizontal = { domain = "CurrentPaneDomain" } } },
          { key = "-", mods = "LEADER", action = wezterm.action { SplitVertical = { domain = "CurrentPaneDomain" } } },

          -- Move between splits
          { key = "h", mods = "SUPER", action = wezterm.action { ActivatePaneDirection = "Left" } },
          { key = "j", mods = "SUPER", action = wezterm.action { ActivatePaneDirection = "Down" } },
          { key = "k", mods = "SUPER", action = wezterm.action { ActivatePaneDirection = "Up" } },
          { key = "l", mods = "SUPER", action = wezterm.action { ActivatePaneDirection = "Right" } },

          -- Copy and paste text
          {
            key = "c",
            mods = "SUPER",
            action = wezterm.action.CopyTo "ClipboardAndPrimarySelection"
          },
          {
            key = "v",
            mods = "SUPER",
            action = wezterm.action.PasteFrom "Clipboard"
          },

          -- Search
          { key = "/", mods = "LEADER", action = wezterm.action.Search { Regex = "" } },

          -- Zoom in and out
          { key = "-", mods = "CTRL", action = "DecreaseFontSize" },
          { key = "+", mods = "CTRL", action = "IncreaseFontSize" },
          { key = "=", mods = "CTRL", action = "IncreaseFontSize" },
          { key = "0", mods = "CTRL", action = "ResetFontSize" },
        }

        -- Insert bindings to select each tab
        for i = 1, 9 do
          table.insert(config.keys, {
            key = tostring(i),
            mods = "LEADER",
            action = wezterm.action { ActivateTab = i - 1 },
          })
        end

        table.insert(config.keys, {
          key = "0",
          mods = "LEADER",
          action = wezterm.action { ActivateTab = 9 },
        })

        -- This function returns the suggested title for a tab.
        -- It prefers the title that was set via `tab:set_title()`
        -- or `wezterm cli set-tab-title`, but falls back to the
        -- title of the active pane in that tab.
        function tab_title(tab_info)
          local title = tab_info.tab_title
          -- if the tab title is explicitly set, take that
          if title and #title > 0 then
            return title
          end
          -- Otherwise, use the title from the active pane
          -- in that tab
          return tab_info.active_pane.title
        end

        -- Equivalent to POSIX basename(3)
        -- Given "/foo/bar" returns "bar"
        -- Given "c:\\foo\\bar" returns "bar"
        function basename(s)
          return string.gsub(s, '(.*[/\\])(.*)', '%2')
        end

        -- wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
        --   local pane = tab.active_pane
        --   local title = tab.tab_index + 1

        --   local cwd = pane.current_working_dir.file_path
        --   local cmd = pane.foreground_process_name

        --   if cwd ~= nil and cmd ~= "" then
        --     title = title .. ": " .. basename(cwd) .. " | " .. basename(cmd)
        --   else if cwd ~= nil then
        --     title = title .. ": " .. basename(cwd)
        --   else if cmd ~= "" then
        --     title = title .. ": " .. basename(cmd)
        --   end

        --   if pane.has_unseen_output then
        --     title = title .. " *"
        --   end

        --   return title
        -- end)

        wezterm.on('gui-attached', function(domain)
          -- maximize all displayed windows on startup
          local workspace = wezterm.mux.get_active_workspace()
          for _, window in ipairs(wezterm.mux.all_windows()) do
            if window:get_workspace() == workspace then
              window:gui_window():maximize()
            end
          end
        end)

        return config
      '';
    };
  };
}
