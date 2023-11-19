" Color settings

" Dark theme
set background=dark
" Syntax highlighting
syntax on

" Color scheme style
try
	colorscheme gruvbox
catch
	colorscheme desert

	" Color of max column size indicator
	highlight ColorColumn ctermbg=DarkGray
	" Color of search matches while typing
	highlight IncSearch ctermfg=White ctermbg=DarkBlue
	" Color of search matches
	highlight Search ctermfg=White ctermbg=DarkGreen
endtry

" Color of extra whitespaces
highlight link ExtraWhiteSpace ErrorMsg
