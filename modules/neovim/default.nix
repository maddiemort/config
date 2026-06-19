{
  lib,
  pkgs,
  pkgsUnstable,
  ...
}: let
  inherit (lib) optionals;
  inherit (lib.strings) concatStringsSep;

  concatLines = lines: concatStringsSep "\n" lines;
in {
  package = pkgsUnstable.neovim-unwrapped;

  withRuby = true;
  withPython3 = true;

  extraConfigLuaPre = concatLines (map builtins.readFile [
    ./config/telescope.lua
    ./config/illuminate.lua
  ]);

  extraConfigLua = concatLines (map builtins.readFile [
    ./config/extra.lua

    ./config/help-vsplit.lua
    ./config/jj-blame.lua
    ./config/remote.lua
    ./config/xcodebuild.lua
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
  ]);

  extraConfigVim = concatLines [
    ''
      " Use Bash whenever shell commands are run, because others are problematic
      set shell=${pkgs.bash}/bin/bash
    ''
    (builtins.readFile ./config/extra.vim)
  ];

  extraPlugins =
    (with pkgs; [
      telescope-spell-errors
      vim-beancount
      help-vsplit-nvim
    ])
    ++ (with pkgsUnstable; [
      jj-blame-nvim
      remote-nvim-nvim
      telescope-nvim
      xcodebuild-nvim

      vimPlugins.nvim-treesitter.withAllGrammars
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
      vimtex

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
    ]);

  extraPackages =
    (with pkgs; [
      glow
    ])
    ++ (with pkgsUnstable;
      [
        typstyle # For typst formatting in formatter.lua

        alejandra
        bash-language-server # Bash language server
        beancount-language-server
        lua-language-server
        nil # Nix Language server
        nixpkgs-fmt # For nil to format stuff
        prettier
        shellcheck # For Bash
        texlab # TeX language server
        tinymist # Typst language server
        typescript-language-server
        vscode-langservers-extracted
      ]
      ++ optionals stdenv.isDarwin [
        # For xcodebuild.nvim. Also requires:
        #
        # - jq (installed in system configuration)
        # - pymobiledevice3 (installed in host-specific system Python packages)
        # - ripgrep (installed in system configuration)
        # - xcode-build-server (installed via Homebrew in system configuration)
        coreutils
        xcbeautify
        xcp
      ]);
}
