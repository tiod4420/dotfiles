" Vim configuration

function! CheckAndSource(file_path)
	if filereadable(a:file_path)
		execute "source " a:file_path
	endif
endfunction

let config_path = $HOME . "/.vim/config.d"

" Source all the configuration files
for file in [ "global.vim", "colors.vim", "functions.vim", "filetypes.vim", "mappings.vim" ]
	call CheckAndSource(expand(config_path . "/" . file))
endfor
unlet file

unlet config_path
delfunction CheckAndSource
