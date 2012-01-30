" Enable Pathogen
call pathogen#infect()
set nocompatible
" Show incomplete commands
set showcmd

" Syntax highlighting and autocompletion
syntax enable
filetype plugin indent on
set ofu=syntaxcomplete#Complete
" Turn on Solarized
set background=dark
colorscheme solarized
" Whitespace configuration
set tabstop=4 shiftwidth=4
set backspace=indent,eol,start
" Status line configuration
set ls=2
if has('statusline')
	let &stl="%f\ %([%R%M]%)%=%l-%c\ \ \ \ "
endif
