" Color settings

" Dark theme
set background=dark
" Syntax highlighting
syntax on

" Color scheme style
try
	let g:gruvbox_contrast_dark="hard"
	colorscheme gruvbox
catch
	colorscheme desert

	" Color of max column size indicator
	highlight ColorColumn ctermfg=15 ctermbg=1
	" Color in visual selection
	highlight Visual ctermfg=12 ctermbg=0
	" Color of search matches while typing
	highlight IncSearch ctermfg=15 ctermbg=1
	" Color of search matches
	highlight Search ctermfg=15 ctermbg=2
endtry

" Color of extra whitespaces
highlight link ExtraWhitespace IncSearch
