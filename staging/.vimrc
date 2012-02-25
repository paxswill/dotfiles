" Enable Pathogen
runtime bundle/vim-pathogen/autoload/pathogen.vim
call pathogen#infect()
set nocompatible
" Show incomplete commands
set showcmd

" Syntax highlighting and autocompletion
syntax enable
filetype plugin indent on
" Set up some sort of completion
set completeopt=menu,preview
set ofu=syntaxcomplete#Complete
" Turn on Solarized
set background=dark
colorscheme solarized
" Whitespace configuration
set tabstop=4 shiftwidth=4
set backspace=indent,eol,start
" Always show the status line
set laststatus=2
" Make that status line pretty (line, col nums, file name)
if has('statusline')
	let &stl="%f\ %([%R%M]%)%=%l-%c\ \ \ \ "
endif
" Highlight lines past 80 some way
if exists('+colorcolumn')
	" Highlights just the 80th column
	set colorcolumn=80
else
	" Have all text past column 80 be marked as an error message (red)
	au BufWinEnter * let w:m2=matchadd('ErrorMsg', '\%>80v.\+', -1)
endif
" Don't wrap lines, just display them past the edge fo the screen
set nowrap
set sidescroll=20
" Enable folding by default
set foldenable
" Disable the arrow keys
inoremap <Up>     <NOP>
inoremap <Down>   <NOP>
inoremap <Left>   <NOP>
inoremap <Right>  <NOP>
noremap  <Up>     <NOP>
noremap  <Down>   <NOP>
noremap  <Left>   <NOP>
noremap  <Right>  <NOP>
" Show unprintable characters like TextMate
set listchars=tab:▸\ ,eol:¬,extends:»,precedes:«
set list
" Automatically externally read changed files in
set autoread
" Always show tabs in the GUI
if has("gui_running")
	set showtabline=2
endif
" Ignore case while searching, unless the needle is mixed case
set ignorecase
set smartcase
" Search while typing
set incsearch
