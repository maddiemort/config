{
  config,
  lib,
  pkgsUnstable,
  ...
}: let
  cfg = config.custom.zed;

  inherit (lib) mkIf;
in {
  options.custom.zed = with lib; {
    enable = mkEnableOption "custom Zed configuration";
  };

  config = mkIf cfg.enable {
    programs.zed-editor = {
      enable = true;
      package = pkgsUnstable.zed-editor;

      extraPackages = with pkgsUnstable; [
        alejandra
        beancount-language-server
        lua-language-server
        nil # Nix Language server
        nixpkgs-fmt # For nil to format stuff
        nodePackages.bash-language-server # Bash language server
        nodePackages.prettier
        shellcheck # For Bash
        texlab # TeX language server
        tinymist # Typst language server
        typescript-language-server
        vscode-langservers-extracted
      ];

      extensions = [
        "catppuccin"
        "catppuccin-icons"
        "nix"
        "rust"
        "toml"
      ];

      userSettings = {
        # TODO: Decide
        # active_pane_modifiers
        # base_keymap
        # close_on_file_delete
        # diagnostics_max_severity
        # double_click_in_multibuffer
        # minimap
        # tab_bar
        # status_bar
        # global_lsp_settings

        # Appearance
        theme = {
          mode = "system";
          dark = "Catppuccin Macchiato";
          light = "Catppuccin Latte";
        };
        icon_theme = {
          mode = "system";
          dark = "Catppuccin Macchiato";
          light = "Catppuccin Latte";
        };
        cursor_blink = false;
        scrollbar = {
          diagnostics = "warning";
          axes = {
            horizontal = false;
          };
        };
        use_system_window_tabs = true;
        relative_line_numbers = "enabled";
        show_wrap_guides = true;
        wrap_guides = [100];
        colorize_brackets = true;

        # Fonts
        buffer_font_family = "Iosevka Custom";
        buffer_font_size = 16.0;
        buffer_font_weight = 300;
        buffer_line_height = "standard";
        terminal.font_family = "Iosevka Custom";
        terminal.font_size = 16.0;
        terminal.line_height = "standard";

        # Editing
        vim_mode = true;
        auto_signature_help = true;
        format_on_save = "on";
        use_autoclose = false;
        snippet_sort_order = "none";
        file_types = {
          "JSONC" = [
            "**/.zed/**/*.json"
            "**/zed/**/*.json"
            "**/Zed/**/*.json"
            "**/.vscode/**/*.json"
          ];
          "Shell Script" = [
            ".env"
            ".env.*"
          ];
          "TeX" = [
            "*.cls"
          ];
          "Ruby" = [
            "Podfile"
          ];
        };
        diagnostics = {
          inline = {
            enabled = true;
          };
        };
        indent_guides = {
          enabled = true;
          coloring = "indent_aware";
        };
        hover_popover_enabled = false;
        inlay_hints.enabled = true;
        pane_split_direction_horizontal = "down";
        pane_split_direction_vertical = "right";
        preferred_line_length = 100;
        show_completions_on_input = false;
        show_edit_predictions = false;
        soft_wrap = "none";
        tab_size = 4;

        # Features
        auto_update = false;
        disable_ai = true;
        load_direnv = "direct";
        journal = {
          hour_format = "hour24";
        };
        restore_on_startup = "launchpad";
        search = {
          regex = true;
          center_on_match = true;
          seed_search_query_from_cursor = "never";
        };
        semantic_tokens = "combined";
        use_smartcase_search = true;
        use_system_path_prompts = false;
        use_system_prompts = false;
        project_panel = {
          sort_mode = "mixed";
        };
        calls = {
          mute_on_join = true;
        };

        # Languages & LSP
        languages = {
          Nix = {
            language_servers = ["nil" "!nixd"];
          };
        };

        lsp = {
          rust-analyzer = {
            binary = {
              # path = lib.getExe pkgs.rust-analyzer;
              path_lookup = true;
            };
            initialization_options = {
              assist = {
                preferSelf = true;
              };
              cargo = {
                # allFeatures = true,
                extraArgs = [
                  "--profile"
                  "rust-analyzer"
                ];
                extraEnv = {
                  CARGO_PROFILE_RUST_ANALYZER_INHERITS = "dev";
                };
              };
              check = {
                command = "clippy";
                # extraArgs = [
                #     "--profile"
                #     "rust-analyzer"
                # ];
              };
              completion = {
                postfix = {
                  enable = false;
                };
              };
              diagnostics = {
                disabled = [
                  "unresolved-proc-macro"
                ];
              };
              gotoImplementations = {
                filterAdjacentDerives = true;
              };
              hover = {
                links = {
                  # It's ugly when rust-analyzer tries to display docs.rs links for links in
                  # markdown docs.
                  enable = false;
                };
              };
              imports = {
                granularity = {
                  # Not sure what I want this set to yet
                  enforce = false;
                };
              };
              inlayHints = {
                bindingModeHints.enable = false;
                chainingHints.enable = true;
                closingBraceHints = {
                  enable = true;
                  minLines = 25;
                };
                closureCaptureHints.enable = true;
                closureReturnTypeHints.enable = "never";
                closureStyle = "impl_fn";
                discriminantHints.enable = "never";
                expressionAdjustmentHints = {
                  disableReborrows = true;
                  enable = "always";
                  hideOutsideUnsafe = true;
                  mode = "prefix";
                };
                genericParameterHints = {
                  const.enable = true;
                  lifetime.enable = false;
                  type.enable = false;
                };
                implicitDrops.enable = false;
                implicitSizedBoundHints.enable = false;
                lifetimeElisionHints = {
                  enable = "never";
                  useParameterNames = false;
                };
                maxLength = 25;
                parameterHints.enable = true;
                rangeExclusiveHints.enable = false;
                renderColons = true;
                typeHints = {
                  enable = false;
                  hideClosureInitialization = false;
                  hideClosureParameter = false;
                  hideNamedConstructor = false;
                };
              };
              server = {
                extraEnv = {
                  CARGO_PROFILE_RUST_ANALYZER_INHERITS = "dev";
                };
              };
            };
          };

          nil = {
            binary = {
              path = "${pkgsUnstable.nil}/bin/nil";
            };
            initialization_options = {
              formatting = {
                command = [
                  "${pkgsUnstable.alejandra}/bin/alejandra"
                  "--quiet"
                  "--"
                ];
              };
            };
          };
        };

        profiles = {
          "Non-Vim" = {
            cursor_blink = true;
            relative_line_numbers = "disabled";
            vim_mode = false;
            base_keymap = "VSCode";
            use_autoclose = true;
            snippet_sort_order = "inline";
            hover_popover_enabled = true;
            show_completions_on_input = true;
          };
        };
      };

      userKeymaps = {
      };

      userTasks = {
      };

      userDebug = {
      };

      mutableUserSettings = false;
      mutableUserKeymaps = false;
      mutableUserTasks = false;
      mutableUserDebug = false;
    };
  };
}
