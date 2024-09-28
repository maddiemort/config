{ config
, lib
, pkgs
, pkgsUnstable
, ...
}:

let
  cfg = config.custom.nvim;

  luaPluginInline = plugin: config: {
    inherit plugin config;
    type = "lua";
  };

  luaPlugin = plugin: configPath: {
    inherit plugin;
    type = "lua";
    config = builtins.readFile configPath;
  };

  inherit (lib) mkIf;
in
{
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
    home.sessionVariables = (mkIf cfg.defaultEditor {
      # Required for TLA+
      JAVA_HOME = "${pkgs.jre_minimal}";

      EDITOR = "nvim";
    });

    programs.neovim = {
      inherit (cfg) enable;

      plugins = (with pkgs.vimPlugins; [
        haskell-vim
        kotlin-vim
        nvim-notify
        plenary-nvim
        swift-vim
        telescope-file-browser-nvim
        telescope-fzf-native-nvim
        vim-glsl
        vim-highlightedyank
        vim-javascript
        vim-jsonnet
        vim-jsx-pretty
        vim-nix
        vim-numbertoggle
        vim-toml
        vimtex

        (luaPlugin dressing-nvim ./config/dressing.lua)
        (luaPlugin formatter-nvim ./config/formatter.lua)
        (luaPlugin git-blame-nvim ./config/git-blame.lua)
        (luaPlugin indent-blankline-nvim ./config/indent-blankline.lua)
        (luaPlugin lualine-nvim ./config/lualine.lua)
        (luaPlugin nvim-treesitter ./config/treesitter.lua)
        (luaPlugin onedark-vim ./config/onedark.lua)
        (luaPlugin rust-vim ./config/rust.lua)
        (luaPlugin telescope-nvim ./config/telescope.lua)
        (luaPlugin vim-gitgutter ./config/gitgutter.lua)
        (luaPlugin vim-rooter ./config/rooter.lua)
        (luaPluginInline comment-nvim "require'Comment'.setup {}")
        (luaPluginInline nvim-colorizer-lua "require'colorizer'.setup {}")

      ]) ++ (with pkgsUnstable.vimPlugins; [
      ]) ++ (with pkgsUnstable; [
        (luaPlugin key-menu-nvim ./config/key-menu.lua)

        (luaPluginInline tla-nvim ''
          require"tla".setup {
            --java_executable = "${pkgs.jre_minimal}",
            java_opts = { "-XX:+UseParallelGC" },
            tla2tools = "${pkgs.tlaplus18}/share/java/tla2tools.jar",
          }

          local tla_group = vim.api.nvim_create_augroup('tla', {})
          vim.api.nvim_create_autocmd({ 'BufNewFile', 'BufRead' }, {
              group = id,
              pattern = '*.tla',
              callback = function()
                  vim.keymap.set('n', 'M', "<cmd>TlaCheck<cr>", { desc = 'Model-check TLA+ code in the current buffer', buffer = true })
              end,
          })
        '')
      ]) ++ (with pkgs.vimPlugins.nvim-treesitter-parsers; [
        bash
        c
        c_sharp
        cmake
        cpp
        css
        dart
        dockerfile
        java
        javascript
        json
        jsonnet
        kotlin
        lua
        make
        markdown
        markdown_inline
        nix
        objc
        python
        query
        ruby
        rust
        tlaplus
        toml
        tsx
        typescript
        vim
        vimdoc
        xml
        yaml
      ]);

      extraPackages = with pkgs; [
        glow
      ];

      extraConfig = ''
        " =============
        " INITIAL SETUP
        " =============

        " Use Bash whenever shell commands are run, because others are problematic
        set shell=${pkgs.bash}/bin/bash

        " Set the leader key to space
        let mapleader = "\<Space>"

        " Use truecolor support, so we can display more than just 256 colours.
        set termguicolors

        " ===============
        " PLUGIN SETTINGS
        " ===============

        " ------
        " vimtex
        " ------

        " Explicitly specify that TeX is always really LaTeX
        let g:tex_flavor = 'latex'
        " Set the compiler method to tectonic
        let g:vimtex_compiler_method = 'tectonic'
        " Turn on shell-escape for tectonic
        let g:vimtex_compiler_tectonic = {
          \   'options': [
          \     '-Z',
          \     'shell-escape'
          \   ],
          \ }
        " Set the leader key for insert-mode bindings
        let g:vimtex_imaps_leader = ';'

        " =================
        " LANGUAGE SETTINGS
        " =================

        " --
        " Go
        " --

        " Some things here from https://www.getman.io/posts/programming-go-in-neovim
        augroup go | au!
            " Set the indentation to use tabs
            au FileType go setlocal tabstop=8 softtabstop=8 shiftwidth=8 noexpandtab
        augroup END

        " -----
        " marsh
        " -----

        augroup marsh | au!
            au BufNewFile,BufRead *.marsh set filetype=marsh
        augroup END

        " ---
        " C++
        " ---

        augroup cpp | au!
            au Filetype cpp setlocal shiftwidth=2 softtabstop=2
        augroup END

        " -----
        " LaTeX
        " -----

        augroup latex | au!
            " Set filetype correctly for .cls files
            au BufNewFile,BufRead *.cls setlocal syntax=tex

            " Set indentation levels for LaTeX files
            au Filetype tex setlocal shiftwidth=2 softtabstop=2

            " In LaTeX files, we want to wrap both "normal text" and comments.
            au Filetype tex setlocal fo-=c
            au Filetype tex setlocal fo+=tc

            " Build TeX files with ninja, not make, when running a make keybinding
            au Filetype tex noremap M :VimtexCompile<cr>
        augroup END

        " ----------------------------
        " JavaScript and Web Languages
        " ----------------------------

        augroup web | au!
            " Set an indentation level of 2 spaces for JavaScript and TypeScript files
            au BufRead,BufNewFile *.js,*.jsx,*.mjs,*.ts,*.tsx setlocal shiftwidth=2 softtabstop=2
            " Same for CSS-family files
            au BufRead,BufNewFile *.css,*.less,*.scss,*.sass setlocal shiftwidth=2 softtabstop=2
            " Same for markup languages
            au BufRead,BufNewFile *.html,*.md,*.yaml setlocal shiftwidth=2 softtabstop=2
            " Same for other JS-adjacent file types
            au BufRead,BufNewFile *.graphql,*.json setlocal shiftwidth=2 softtabstop=2
        augroup END

        " ----
        " Ruby
        " ----

        augroup rb | au!
            " Set filetype correctly for Podfiles
            au BufNewFile,BufRead Podfile setlocal syntax=ruby
        augroup END

        " -----
        " Email
        " -----

        augroup eml | au!
            " Set the textwidth to the smaller standard 72 chars for emails
            au BufRead,BufNewFile *.eml setlocal textwidth=72
        augroup END

        " ----
        " YAML
        " ----

        augroup yaml | au!
            " Set the indentation width to 2 spaces for YAML
            au Filetype yaml setlocal shiftwidth=2 softtabstop=2
        augroup END

        " ------
        " Gemini
        " ------

        augroup gemini | au!
            au BufRead,BufNewFile *.gmi setlocal wrap linebreak textwidth=0 wrapmargin=0
        augroup END

        " -------
        " Haskell
        " -------

        augroup hs | au!
            " Set the indentation width to 2 spaces for Haskell
            au Filetype haskell setlocal shiftwidth=2 softtabstop=2
        augroup END

        " ===============
        " EDITOR SETTINGS
        " ===============

        " ----------
        " Appearance
        " ----------

        " Lighten comments and special (doc) comments, make special comments italic
        autocmd ColorScheme * hi Comment guifg=#7c828c gui=NONE
        autocmd ColorScheme * hi SpecialComment guifg=#7c828c gui=italic

        " Display a background on the line with the cursor on it
        set cursorline
        " Always show the signcolumn
        set signcolumn=yes

        " ------------
        " Text Editing
        " ------------

        " Turn on filetype detection and plugin/indent info loading
        filetype plugin indent on

        " Use 4-space indentation
        set shiftwidth=4
        set softtabstop=4
        set expandtab

        " Auto-indent on new lines
        set autoindent

        " Don't insert two spaces after certain characters when using a join command
        set nojoinspaces

        " Wrap to 80 characters
        set textwidth=80

        " Format options (default fo=jcroql)
        " set fo=ca " Auto-wrap comments to textwidth
        " set fo+=r " Auto-insert the current comment leader when pressing enter in insert mode
        " set fo+=o " Auto-insert the current comment leader when entering new lines with o
        " set fo+=q " Allow `gq` to format comments
        " set fo+=n " Format numbered lists as well
        " set fo+=j " Auto-remove comment characters when joining lines

        " Enable mouse usage (all modes) in terminals
        set mouse=a

        " ------------
        " Text Display
        " ------------

        " Display tab characters with a width of 4 spaces
        set tabstop=4

        " Set the number of lines to keep visible above and below the cursor at the top and bottom of the
        " screen
        set scrolloff=2

        " Don't soft-wrap long lines to display them in the buffer
        set nowrap

        " Display line numbers in the sidebar
        set number

        " Display line numbers for every line but the current one as an offset
        set relativenumber

        " ---------
        " Searching
        " ---------

        " Jump to search results as the search pattern is typed
        set incsearch

        " Ignore case in search results by default
        set ignorecase

        " Don't ignore case if the search pattern contains uppercase characters
        set smartcase

        " Vertically centre search results in the buffer when jumping to them
        nnoremap <silent> n nzz
        nnoremap <silent> N Nzz
        nnoremap <silent> * *zz
        nnoremap <silent> # #zz
        nnoremap <silent> g* g*zz

        " Turn on magic options for searching by default
        " nnoremap ? ?\v
        " nnoremap / /\v
        " cnoremap %s/ %sm/

        " Set the grep program to rg if available
        if executable('rg')
          set grepprg=rg\ --no-heading\ --vimgrep
          set grepformat=%f:%l:%c:%m
        endif

        " -------
        " Utility
        " -------

        " Allow project-local configuration using (dangerous) exrc
        set exrc

        " Use undo files for permanent undo history
        set undodir=~/.local/share/nvim/did
        set undofile

        " Hide buffers when they're abandoned rather than unloading them
        set hidden

        " Set up wildmenu for decent completions
        set wildmenu
        set wildmode=full
        set wildignore=.hg,.svn,*~,*.png,*.jpg,*.gif,*.settings,Thumbs.db,*.min.js,*.swp,publish/*,intermediate/*,*.o,*.hi,Zend,vendor

        " Remap the § key to escape, for the sake of my experience on iPad
        nnoremap § <Esc>
        inoremap § <Esc>
        vnoremap § <Esc>
        cnoremap § <Esc>

        " And also let me type # on iPad
        inoremap <M-3> #

        " Count words in the current TeX file
        function! WC()
            let filename = expand("%")
            let cmd = "detex " . filename . " | wc -w | tr -d '[:space:]'"
            let result = system(cmd)
            echo result . " words"
        endfunction
        command WC call WC()

        " Just call detex on the current file, to check
        function! DT()
            let filename = expand("%")
            let cmd = "detex " . filename
            let result = system(cmd)
            echo result
        endfunction
        command DT call DT()

        " Lower updatetime to make CursorHold more responsive
        set updatetime=500

        " ---------------
        " Annoyance Fixes
        " ---------------

        " Split in sane directions by default
        set splitright
        set splitbelow

        " Reduce the time before vim executes a command
        set timeoutlen=300

        " -----------------
        " Platform Specific
        " -----------------

        " Find out what OS we're on
        let OS=substitute(system('uname -s'),"\n","","")

        if (OS == "Darwin")
            " macOS Specific Settings
        elseif ( OS == 'Linux' )
            " Linux Specific Settings
        endif

        " ==================
        " KEYBOARD SHORTCUTS
        " ==================

        lua<<EOF
          -- Quick-save with <leader>w
          vim.keymap.set('n', '<leader>w', '<cmd>w<cr>', { desc = 'Write' })

          -- Suspend nvim
          vim.keymap.set('n', '<leader>z', '<cmd>sus<cr>', { desc = 'Suspend' })

          -- Copy and paste to/from system clipboard
          vim.keymap.set({ 'n', 'v' }, '<leader>y', '"+y', { desc = 'Yank to System' })
          vim.keymap.set('n', '<leader>p', '"+p', { desc = 'Paste from System' })
          vim.keymap.set('n', '<leader>P', '"+P', { desc = 'Paste Above from System' })

          -- Quick switch between the last two buffers using <leader><leader>
          vim.keymap.set('n', '<leader><leader>', '<c-^>', { desc = 'Quick Switch Buffers' })

          -- Clear search highlighting
          vim.keymap.set('n', '<leader>/', '<cmd>noh<cr>', { desc = 'Clear Search Highlighting' })

          -- Create splits with <leader>s and a direction
          require'key-menu'.set('n', '<leader>s', { desc = 'Split' })
          vim.keymap.set('n', '<leader>sh', '<cmd>leftabove vnew<cr>', { desc = 'Split Left' })
          vim.keymap.set('n', '<leader>sj', '<cmd>rightbelow new<cr>', { desc = 'Split Below' })
          vim.keymap.set('n', '<leader>sk', '<cmd>leftabove new<cr>', { desc = 'Split Above' })
          vim.keymap.set('n', '<leader>sl', '<cmd>rightbelow vnew<cr>', { desc = 'Split Right' })

          -- Move between splits with C and a direction
          vim.keymap.set('n', '<C-H>', '<C-W><C-H>', { desc = 'Move to Split Left' })
          vim.keymap.set('n', '<C-J>', '<C-W><C-J>', { desc = 'Move to Split Below' })
          vim.keymap.set('n', '<C-K>', '<C-W><C-K>', { desc = 'Move to Split Above' })
          vim.keymap.set('n', '<C-L>', '<C-W><C-L>', { desc = 'Move to Split Right' })

          -- Run make from the current directory
          vim.keymap.set('n', 'M', '<cmd>make<cr>', { desc = 'Run `make`' })

          -- Go to next/previous diagnostic
          vim.keymap.set('n', 'g>', function() vim.diagnostic.goto_next({ float = false }) end, { desc = 'Next Diagnostic' })
          vim.keymap.set('n', 'g<', function() vim.diagnostic.goto_prev({ float = false }) end, { desc = 'Previous Diagnostic' })
        EOF

        " Write buffer through sudo
        cnoreabbrev w!! w !sudo tee % >/dev/null
      '';
    };
  };
}
