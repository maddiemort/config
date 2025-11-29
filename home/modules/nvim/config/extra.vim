" =============
" INITIAL SETUP
" =============

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

" --------
" markdown
" --------

augroup markdown | au!
    au Filetype markdown setlocal wrap
    au Filetype markdown nnoremap <buffer> j gj
    au Filetype markdown nnoremap <buffer> k gk
    au Filetype markdown nnoremap <buffer> $ g$
    au Filetype markdown nnoremap <buffer> 0 g0
    au Filetype markdown vnoremap <buffer> j gj
    au Filetype markdown vnoremap <buffer> k gk
    au Filetype markdown vnoremap <buffer> $ g$
    au Filetype markdown vnoremap <buffer> 0 g0
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
    au BufRead,BufNewFile *.html,*.yaml setlocal shiftwidth=2 softtabstop=2
    " Same for other JS-adjacent file types
    au BufRead,BufNewFile *.graphql,*.json setlocal shiftwidth=2 softtabstop=2
    " But I want Markdown to use 4
    au BufRead,BufNewFile *.md setlocal shiftwidth=4 softtabstop=4
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

" ------
" Unison
" ------

augroup unison | au!
    " Set the indentation width to 2 spaces for Unison
    au Filetype unison setlocal shiftwidth=2 softtabstop=2
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

" Highlight yanked text
augroup highlight_yank
    autocmd!
    au TextYankPost * silent! lua vim.highlight.on_yank { higroup = 'IncSearch', timeout = 500 }
augroup END

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

" Wrap to 100 characters
set textwidth=100

" Format options
set fo=cro/qnlj

" Enable mouse usage (all modes) in terminals
set mouse=a
set mousescroll=ver:1,hor:6

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

augroup quickfix | au!
    " Rebind p to "preview" command in quickfix window
    au FileType qf nnoremap <buffer> p <CR><C-w>p
augroup END

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

" -----
" Typst
" -----

augroup typst | au!
    au BufRead,BufNewFile *.typ setlocal textwidth=100 spell spelllang=en_gb spellcapcheck=

    function! g:FindGlob(pattern, path)
      let fullpattern = a:path . "/" . a:pattern
      if strlen(glob(fullpattern))
        return fullpattern
      else
        let parts = split(a:path, "/")
        if len(parts)
          let newpath = "/" . join(parts[0:-2], "/")
          return FindGlob(a:pattern, newpath)
        else
          return v:null
        endif
      endif
    endfunction

    let b:spellfile = FindGlob('.vimspell.utf-8.add', expand('%:p:h'))
    if b:spellfile isnot v:null && filereadable(b:spellfile)
        let &l:spellfile = b:spellfile . ',' . stdpath('data') . '/site/spell/en.utf-8.add'
    else
        setlocal spellfile=
    endif
augroup END

" ==================
" KEYBOARD SHORTCUTS
" ==================

" Write buffer through sudo
cnoreabbrev w!! w !sudo tee % >/dev/null
