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
"let g:solarized_termcolors=256
set background=dark
colorscheme solarized
" Whitespace configuration
set tabstop=4 shiftwidth=4
set backspace=indent,eol,start
