" Global settings

" Disable Vi compatibility
set nocompatible
" Disable modelines (commands in top of file)
set nomodeline
" Set encoding to UTF-8
set encoding=utf-8

" Enable mouse support
if has("mouse") | set mouse=a | endif
" Enable SGR mouse events (to work with columns after 233)
if has("mouse_sgr") | set ttymouse=sgr | endif
" Set terminal window title
if has ("title") | set title | endif

" Disable backup files
set nobackup
" Disable undo files
set noundofile
" Set undo levels
set undolevels=5000

" Highlight search matches
set hlsearch
" Highlight matches while typing
if has("reltime") | set incsearch | endif

" Enable auto-indentation
set autoindent
" Enable backspacing over everything (insert mode)
set backspace=indent,eol,start
" Set completion options
set completeopt=menuone,preview,longest
" Disable octal number recognition
set nrformats-=octal
