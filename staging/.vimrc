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
" Highlight columns >= 80
if exists('+colorcolumn')
	set colorcolumn=80
else
	au BufWinEnter * let w:m2=matchadd('ErrorMsg', '\%>80v.\+', -1)
endif
" Don't wrap lines, just display them past the edge fo the screen
set nowrap
set sidescroll=10
" Enable folding by default
set foldenable
" Disable the arrow keys
inoremap <Up>		<NOP>
inoremap <Down>		<NOP>
inoremap <Left>		<NOP>
inoremap <Right>	<NOP>
noremap <Up>		<NOP>
noremap <Down>		<NOP>
noremap <Left>		<NOP>
noremap <Right>		<NOP>
