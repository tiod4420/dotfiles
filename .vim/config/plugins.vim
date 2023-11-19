" Plugins settings

" Clear snipMate options
let g:snipMate = {}
" Set snipMate parser version
let g:snipMate.snippet_version = 1
" Overriding snippets is enabled
let g:snipMate.override = 1
let g:snipMate.always_choose_first = 1

" Loading order for snippets
packadd own-snippets
packadd vim-snippets
