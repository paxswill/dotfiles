" Enable Vundle
set nocompatible
filetype off
set rtp +=~/.vim/bundle/Vundle.vim
call vundle#begin()
" Manage Vundle with Vundle
Plugin 'VundleVim/Vundle.vim'

" Git plugin
Plugin 'tpope/vim-fugitive'
" GitHub integration with fugitive
Plugin 'tpope/vim-rhubarb'
" Easy Session updating
Plugin 'tpope/vim-obsession'
" Nicer swapfile recovery
Plugin 'chrisbra/Recover.vim'
" C/C++/Obj-C completion with clang
Plugin 'Rip-Rip/clang_complete'
" use tab for completions
Plugin 'ervandew/supertab'
" OpenCL syntax
Plugin 'paxswill/vim-opencl'
" Solarized colorscheme
Plugin 'icymind/NeoSolarized'
" Vagrantfile syntax
Plugin 'smerrill/vagrant-vim'
" Helpers for editing HTML and other opening/closing tags
Plugin 'tpope/vim-surround'
" nginx config file syntax
Plugin 'chr4/nginx.vim'
" Jinja template syntax
Plugin 'lepture/vim-jinja'
" automatically add end tokens in some languages
Plugin 'tpope/vim-endwise'
" Syntax for LESS (CSS metalanguage)
Plugin 'groenewege/vim-less'
" Better Python indenting
Plugin 'hynek/vim-python-pep8-indent'
" jedi-vim requires python support in vim
if has('python') || has('python3')
    " Python completion with Jedi
    Plugin 'davidhalter/jedi-vim'
endif
" Use Vim syntax files included with Go, oterwise use Vundle
if empty($GOROOT)
    " Repackaged Go syntax files
    Plugin 'jnwhiteh/vim-golang'
else
    set rtp+=$GOROOT/misc/vim
endif
" Syntax for Rust lang
Plugin 'rust-lang/rust.vim'
" Syntax for TOML files
Plugin 'cespare/vim-toml'
" Syntax and other goodies for CoffeeScript
Plugin 'kchmck/vim-coffee-script'
" Syntax for Handlebars and Mustache
Plugin 'mustache/vim-mustache-handlebars'
" Dash integration
Plugin 'rizzatti/dash.vim'
" Swift syntax
Plugin 'kballard/vim-swift'
call vundle#end()

" Show incomplete commands
set showcmd

""" Language Settings
syntax enable	" Enable Syntax highlighting
filetype plugin indent on	" Enable format based highlighting and indenting
" Set up some sort of completion
set completeopt=menu,preview
set ofu=syntaxcomplete#Complete

""" clang-completion
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

""" SuperTab
" Detect the context for completion
let g:SuperTabDefaultCompletionType = "context"
let g:SuperTabContextDefaultCompletionType = "<c-p>"
"
""" Jedi-Vim
" Don't autocomplete on dot
let g:jedi#popup_on_dot = 0
" Don't show the function definition
let g:jedi#show_call_signatures = 0
" Don't add the 'import ' when typing 'from foo '
let g:jedi#smart_auto_mappings = 0

""" Configure the colors (and fonts)
set termguicolors
set background=dark
try
	let g:neosolarized_visibility='low'	" Desaturate special characters
	colorscheme NeoSolarized
catch /^Vim\%((\a\+)\)\=:E185/
	colorscheme desert
endtry

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
	let &stl="%f\ %([%R%M]%)%=%l-%c\ %{ObsessionStatus()}\ \ \ \ "
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
" Use the system clipboard
set clipboard=unnamed
" Keep some context for lines at the edge of the screen
set scrolloff=3
" Customize which things are saved in a session
set sessionoptions="blank,buffers,curdir,folds,globals,localoptions,options,resize,tabpages,winpos,winsize"

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
	elseif has("gui_gtk2")
		set guifont=Source\ Code\ Variable\ 10
	endif
endif

" Reenable filetype stuff that Vundle needed turned off
filetype plugin indent on
