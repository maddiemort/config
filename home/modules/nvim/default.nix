{
  config,
  lib,
  pkgs,
  pkgsUnstable,
  ...
}: let
  cfg = config.custom.nvim;

  luaPlugin = plugin: configPath: {
    inherit plugin;
    type = "lua";
    config = builtins.readFile configPath;
  };

  inherit (lib) mkIf;
in {
  imports = [
    ./lsp.nix
  ];

  options.custom.nvim = with lib; {
    enable = mkOption rec {
      description = "Whether to enable neovim";
      type = types.bool;
      default = true;
      example = !default;
    };

    defaultEditor = mkOption rec {
      description = "Whether to make neovim the default editor using the EDITOR environment variable";
      type = types.bool;
      default = true;
      example = !default;
    };
  };

  config = mkIf cfg.enable {
    home.sessionVariables = mkIf cfg.defaultEditor {
      EDITOR = "nvim";
    };

    programs.neovim = {
      inherit (cfg) enable;
      package = pkgsUnstable.neovim-unwrapped;

      extraLuaConfig = builtins.readFile ./config/extra.lua;

      extraConfig =
        ''
          " Use Bash whenever shell commands are run, because others are problematic
          set shell=${pkgs.bash}/bin/bash
        ''
        + builtins.readFile ./config/extra.vim;

      plugins =
        (with pkgs; [
          telescope-spell-errors
          vim-beancount

          (luaPlugin help-vsplit-nvim ./config/help-vsplit.lua)
          (luaPlugin vimPlugins.nvim-treesitter.withAllGrammars ./config/treesitter.lua)
        ])
        ++ (with pkgsUnstable; [
          (luaPlugin jj-blame-nvim ./config/jj-blame.lua)
          (luaPlugin telescope-nvim ./config/telescope.lua)
        ])
        ++ (with pkgsUnstable.vimPlugins; [
          haskell-vim
          kotlin-vim
          plenary-nvim
          swift-vim
          telescope-file-browser-nvim
          telescope-fzf-native-nvim
          telescope-ui-select-nvim
          typst-vim
          vim-beancount
          vim-glsl
          vim-graphql
          vim-helm
          vim-javascript
          vim-jjdescription
          vim-jsonnet
          vim-jsx-pretty
          vim-mustache-handlebars
          vim-nix
          vim-numbertoggle
          vim-toml
          vim-unison
          vimtex

          (luaPlugin vim-signify ./config/signify.lua)

          (luaPlugin catppuccin-nvim ./config/catppuccin.lua)
          (luaPlugin formatter-nvim ./config/formatter.lua)
          (luaPlugin indent-blankline-nvim ./config/indent-blankline.lua)
          (luaPlugin lualine-nvim ./config/lualine.lua)
          # (luaPlugin nvim-highlight-colors ./config/highlight-colors.lua)
          (luaPlugin rust-vim ./config/rust.lua)
          (luaPlugin snacks-nvim ./config/snacks.lua)
          (luaPlugin vim-rooter ./config/rooter.lua)
        ]);

      extraPackages =
        (with pkgs; [
          glow
        ])
        ++ (with pkgsUnstable; [
          typstyle # For typst formatting in formatter.lua
        ]);
    };
  };
}
