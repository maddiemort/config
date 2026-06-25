{
  config,
  lib,
  pkgs,
  pkgsUnstable,
  ...
}:
let
  inherit (lib) optionals;
  inherit (lib.strings) concatStringsSep;

  concatLines = lines: concatStringsSep "\n" lines;

  cfg = config.custom.nixvim;
in
{
  imports = [
    ./options.nix
  ];

  config = {
    inherit (cfg) package;

    withRuby = true;
    withPython3 = true;

    extraConfigLuaPre =
      let
        files = [
          ./config/illuminate.lua
        ];
      in
      concatLines (map builtins.readFile files);

    extraConfigLua =
      let
        files = [
          ./config/help-vsplit.lua
          ./config/jj-blame.lua
          ./config/treesitter.lua

          ./config/signify.lua

          ./config/catppuccin.lua
          ./config/formatter.lua
          ./config/indent-blankline.lua
          ./config/lualine.lua
          ./config/marks.lua
          # ./config/highlight-colors.lua
          ./config/nvim-lint.lua
          ./config/rust.lua
          ./config/snacks.lua
          ./config/rooter.lua

          ./config/fidget.lua
          ./config/nvim-cmp.lua
          ./config/lspconfig.lua
        ]
        ++ optionals cfg.remote [
          ./config/remote.lua
        ]
        ++ optionals cfg.swift [
          ./config/xcodebuild.lua
        ];
      in
      concatLines (map builtins.readFile files);

    extraConfigLuaPost =
      let
        files = [
          ./config/telescope.lua
          ./config/extra.lua
        ];
      in
      concatLines (map builtins.readFile files);

    extraConfigVim = concatLines [
      ''
        " Use Bash whenever shell commands are run, because others are problematic
        set shell=${pkgs.bash}/bin/bash
      ''
      (builtins.readFile ./config/extra.vim)
    ];

    extraPlugins =
      (
        with pkgs;
        [
          telescope-spell-errors
          help-vsplit-nvim
        ]
        ++ optionals cfg.beancount [
          vim-beancount
        ]
      )
      ++ (
        with pkgsUnstable;
        [
          jj-blame-nvim
          telescope-nvim

          vimPlugins.nvim-treesitter.withAllGrammars
        ]
        ++ optionals cfg.remote [
          remote-nvim-nvim
        ]
        ++ optionals cfg.swift [
          xcodebuild-nvim
        ]
      )
      ++ (
        with pkgsUnstable.vimPlugins;
        [
          plenary-nvim
          telescope-file-browser-nvim
          telescope-fzf-native-nvim
          telescope-ui-select-nvim
          vim-graphql
          vim-javascript
          vim-jjdescription
          vim-jsx-pretty
          vim-nix
          vim-numbertoggle
          vim-toml

          vim-signify

          catppuccin-nvim
          formatter-nvim
          indent-blankline-nvim
          lualine-nvim
          marks-nvim
          # nvim-highlight-colors
          nvim-lint
          rust-vim
          snacks-nvim
          vim-rooter

          cmp-cmdline
          cmp-fuzzy-path
          cmp-nvim-lsp
          cmp_luasnip
          fuzzy-nvim
          lspkind-nvim
          luasnip

          fidget-nvim
          nvim-cmp
          nvim-lspconfig
          vim-illuminate
        ]
        ++ optionals cfg.latex [
          vimtex
        ]
        ++ optionals cfg.swift [
          swift-vim
        ]
        ++ optionals cfg.extras [
          haskell-vim
          kotlin-vim
          typst-vim
          vim-glsl
          vim-helm
          vim-jsonnet
          vim-mustache-handlebars
        ]
      );

    extraPackages =
      (with pkgs; [
        glow
      ])
      ++ (
        with pkgsUnstable;
        [
          typstyle # For typst formatting in formatter.lua

          bash-language-server # Bash language server
          lua-language-server
          nil # Nix Language server
          nixfmt # For nil to format stuff
          prettier
          shellcheck # For Bash
          tinymist # Typst language server
          tree-sitter
          typescript-language-server
          vscode-langservers-extracted
        ]
        ++ optionals cfg.beancount [
          beancount-language-server
        ]
        ++ optionals cfg.latex [
          texlab # TeX language server
        ]
        ++ optionals (stdenv.isDarwin && cfg.swift) [
          # For xcodebuild.nvim. Also requires:
          #
          # - jq (installed in system configuration)
          # - pymobiledevice3 (installed in host-specific system Python packages)
          # - ripgrep (installed in system configuration)
          # - xcode-build-server (installed via Homebrew in system configuration)
          coreutils
          xcbeautify
          xcp
        ]
      );
  };
}
