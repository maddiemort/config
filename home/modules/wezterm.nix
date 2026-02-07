{
  config,
  lib,
  pkgsUnstable,
  ...
}: let
  cfg = config.custom.wezterm;

  inherit (lib) mkIf;
in {
  options.custom.wezterm = with lib; {
    enable = mkEnableOption "custom Wezterm configuration";
  };

  config = mkIf cfg.enable {
    home = {
      sessionSearchVariables = {
        TERMINFO_DIRS = [
          "${pkgsUnstable.wezterm.terminfo}/share/terminfo"
        ];
      };

      sessionVariables = {
        TERM = "wezterm";
      };
    };

    programs.wezterm = {
      enable = true;
      package = pkgsUnstable.wezterm;

      extraConfig = ''
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

        config.mouse_bindings = {
          {
            event = { Up = { streak = 1, button = "Left" } },
            mods = 'NONE',
            action = wezterm.action.OpenLinkAtMouseCursor,
          },
          {
            event = { Up = { streak = 2, button = "Left" } },
            mods = 'NONE',
            action = wezterm.action.Nop,
          },
          {
            event = { Up = { streak = 3, button = "Left" } },
            mods = 'NONE',
            action = wezterm.action.Nop,
          },
          {
            event = { Up = { streak = 1, button = "Left" } },
            mods = 'SHIFT',
            action = wezterm.action.OpenLinkAtMouseCursor,
          },
          {
            event = { Up = { streak = 1, button = "Left" } },
            mods = 'SHIFT|ALT',
            action = wezterm.action.OpenLinkAtMouseCursor,
          },
          {
            event = { Up = { streak = 1, button = "Left" } },
            mods = 'ALT',
            action = wezterm.action.Nop,
          },
        }

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
