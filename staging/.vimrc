" Enable Vundle
filetype off
set rtp +=~/.vim/bundle/vundle/
call vundle#rc()

set nocompatible

" Manage Vundle with Vundle
Bundle 'gmarix/vundle'

""" Bundle vim plugins
Bundle 'tpope/vim-fugitive'
Bundle 'Rip-Rip/clang_complete'
Bundle 'ervandew/supertab'
Bundle 'paxswill/vim-opencl'
Bundle 'tangledhelix/vim-octopress'
Bundle 'altercation/vim-colors-solarized'
Bundle 'smerrill/vagrant-vim'
Bundle 'tpope/vim-surround'
Bundle 'jmcantrell/vim-virtualenv'
Bundle 'nginx.vim'
Bundle 'uggedal/jinja-vim'
if has('python')
	Bundle 'davidhalter/jedi-vim'
endif

" Show incomplete commands
set showcmd

""" Language Settings
syntax enable	" Enable Syntax highlighting
filetype plugin indent on	" Enable format based highlighting and indenting
" Set up some sort of completion
set completeopt=menu,preview
set ofu=syntaxcomplete#Complete
" Set up clang_completion
" Do not show the pop up automatically
let g:clang_complete_auto = 0
" Show quickfix for errors
let g:clang_complete_copen = 1
" Highlight errors and warnings
let g:clang_hl_errors = 1
" Complete Macros
let g:clang_complete_macros = 1
" Complete loops and stuff
let g:clang_complete_patterns = 1
" Use the clang shared library
"let g:clang_use_library = 1
"Set up SuperTab
" Detect the context for completion
let g:SuperTabDefaultCompletionType = "context"
let g:SuperTabContextDefaultCompletionType = "<c-p>"

""" Configure the colors (and fonts)
set background=dark
let g:solarized_visibility='low'	" Desaturate special characters
colorscheme solarized

""" Load the manpage plugin for :Man
runtime ftplugin/man.vim

""" Whitespace
" Tabs are four spaces
set tabstop=4
set shiftwidth=4
" Insert tab characters by default
set noexpandtab
" Back up over anything (beepbeep!)
set backspace=indent,eol,start

""" Status line, and other line related settings
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
" Soft-wrap lines by default
set wrap
"Force line wrapping at 80 characters
set textwidth=79
" Enable folding by default
set foldenable
" Line numbers in the gutter
set number

""" Disable the arrow keys
inoremap <Up>     <NOP>
inoremap <Down>   <NOP>
inoremap <Left>   <NOP>
inoremap <Right>  <NOP>
noremap  <Up>     <NOP>
noremap  <Down>   <NOP>
noremap  <Left>   <NOP>
noremap  <Right>  <NOP>

""" Simplify split navigation
noremap <C-h> <C-w>h
noremap <C-j> <C-w>j
noremap <C-k> <C-w>k
noremap <C-l> <C-w>l

""" Search setup
" Ignore case while searching, unless the needle is mixed case
set ignorecase
set smartcase
" Search while typing
set incsearch

""" Misc
" Show unprintable characters like TextMate
set listchars=tab:▸\ ,eol:¬,extends:»,precedes:«
set list
" Automatically externally read changed files in
set autoread
" Allow hidden buffers to not complain
set hidden
" ~ (tilde) acts as an operator
set tildeop
" Default to Bash for shell scripts
let g:is_bash = 1

""" GUI Customizations
if has("gui_running")
	" Bunch of guioptions flags here
	set guioptions-=R
	set guioptions-=l
	set guioptions-=b
	set guioptions-=t
	" Always show tabs in the GUI
	set showtabline=2
	" Set the font
	if has("mac")
		set guifont=Source\ Code\ Pro\ Light:h11,Menlo\ Regular:h11
	endif
endif

" Reenable filetype stuff that Vundle needed turned off
filetype plugin indent on
