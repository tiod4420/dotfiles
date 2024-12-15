" Theme settings

" Show column markers at 80 and 100
set colorcolumn=80,100
" Show current line indicator
set cursorline
" Show line numbers in left margin
set number
" Show cursor position in the status line
set ruler
" Show a few lines of context around the cursor
set scrolloff=2
" Show incomplete commands in the status line
set showcmd
" Show current mode in the status line
set showmode

" Enable dark background colors (before syntax)
set background=dark
" Enable syntax highlight
if &t_Co > 2 | syntax on | endif

" Set color scheme
try | colorscheme gruvbox | catch | colorscheme desert | endtry

" Highlight white space errors
highlight link WhiteSpaceError ErrorMsg
