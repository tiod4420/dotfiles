" Global settings

" Works only for Vim
set nocompatible
" Disable modeline
set nomodeline
" UTF8 encoding, without BOMB
set encoding=utf-8 nobomb

" Enable screen interaction
if has("mouse") | set mouse=a | endif
" Enable title changes
if has ("title") | set title | endif

" Set auto indentation
set autoindent
" Backspace behaviour
set backspace=indent,eol,start
" Set column space
set colorcolumn=80,100
" Show line number
set number
" Search path for find and related
set path+=**
" Show ruler at the bottom right
set ruler
" Scrolls some lines before the bottom
set scrolloff=2
" Show current typed command
set showcmd
" Show current mode
set showmode

" Case insensitive search
set ignorecase
" Unless the search pattern has uppercase
set smartcase
" Highlight the matches
set hlsearch
" Highlight while typing the pattern
set incsearch

" Show ribbon for available options in command mode
set wildmenu
" Autocomplete menu in insert mode
set completeopt=longest,menuone

" No backup files
set nobackup
" No undo files
set noundofile
" Command mode history
set history=4096
" In-memory undo levels
set undolevels=4096
