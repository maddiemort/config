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
        ])
        ++ (with pkgsUnstable.vimPlugins; [
          haskell-vim
          kotlin-vim
          nvim-treesitter.withAllGrammars
          plenary-nvim
          swift-vim
          telescope-file-browser-nvim
          telescope-fzf-native-nvim
          typst-vim
          vim-glsl
          vim-graphql
          vim-helm
          vim-javascript
          vim-jsonnet
          vim-jsx-pretty
          vim-mustache-handlebars
          vim-nix
          vim-numbertoggle
          vim-toml
          vim-unison
          vimtex

          (luaPlugin catppuccin-vim ./config/catppuccin.lua)
          (luaPlugin formatter-nvim ./config/formatter.lua)
          (luaPlugin git-blame-nvim ./config/git-blame.lua)
          (luaPlugin indent-blankline-nvim ./config/indent-blankline.lua)
          (luaPlugin lualine-nvim ./config/lualine.lua)
          (luaPlugin nvim-highlight-colors ./config/highlight-colors.lua)
          (luaPlugin rust-vim ./config/rust.lua)
          (luaPlugin snacks-nvim ./config/snacks.lua)
          (luaPlugin telescope-nvim ./config/telescope.lua)
          (luaPlugin vim-gitgutter ./config/gitgutter.lua)
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
