" Global settings

" Works only for Vim
set nocompatible
" UTF8 encoding, without BOMB
set encoding=utf-8 nobomb

" Set auto indentation
set autoindent
" Set column space
set colorcolumn=80,100
" Show line number
set number
" Show ruler at the bottom right
set ruler
" Show current typed command
set showcmd
" Show current mode
set showmode
" Change window's title
set title

" Enable screen interaction
if has("mouse") | set mouse=a | endif
" Backspace behaviour
set backspace=indent,eol,start
" Scrolls some lines before the bottom
set scrolloff=2

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
set completeopt=menuone,longest

" No backup files
set nobackup
" No undo files
set noundofile
" Command mode history
set history=256
" In-memory undo levels
set undolevels=256
