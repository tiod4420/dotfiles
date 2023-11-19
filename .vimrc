" Vim configuration

function! CheckAndSource(file_path)
	if filereadable(a:file_path)
		execute "source " a:file_path
	endif
endfunction

let config_path = $HOME . "/.vim/config"

" Source all the configuration files
for file in [ "global.vim", "colors.vim", "functions.vim", "filetypes.vim", "mappings.vim" ]
	call CheckAndSource(expand(config_path . "/" . file))
endfor
unlet file

" Load local configuration files that are not commited
" [!] Load after all other settings so it can override previous config
for file in split(expand(config_path . "/local/*.vim"), "\n")
	call CheckAndSource(file)
endfor

unlet config_path
delfunction CheckAndSource
