" Global settings

" Disable Vi compatibility
set nocompatible
" Set encoding to UTF-8
set encoding=utf-8

" Use XDG directories for viminfo
runtime xdg.vim

" Enable mouse support
if has("mouse") | set mouse=a | endif
" Enable SGR mouse events (to work with columns after 233)
if has("mouse_sgr") | set ttymouse=sgr | endif
" Set terminal window title
if has ("title") | set title | endif

" Disable backup files
set nobackup
" Disable modelines (commands in top of file)
set nomodeline
" Disable undo files
set noundofile
" Set undo levels
set undolevels=5000

" Highlight search matches
set hlsearch
" Highlight matches while typing
if has("reltime") | set incsearch | endif

" Search ignores case
set ignorecase
" Search ignores case only if lowecase letters only
set smartcase

" Enable auto-indentation
set autoindent
" Enable backspacing over everything (insert mode)
set backspace=indent,eol,start

" Numbers are negative only if preceding whitespace
set nrformats+=blank
" Numbers are never octal
set nrformats-=octal
