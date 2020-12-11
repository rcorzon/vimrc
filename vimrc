
set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

" The following are examples of different formats supported.
" Keep Plugin commands between vundle#begin/end.
" plugin on GitHub repo
" Plugin 'tpope/vim-fugitive'
" plugin from http://vim-scripts.org/vim/scripts.html
" Plugin 'L9'
" Git plugin not hosted on GitHub
" Plugin 'git://git.wincent.com/command-t.git'
" The sparkup vim script is in a subdirectory of this repo called vim.
" Pass the path to set the runtimepath properly.
" Plugin 'rstacruz/sparkup', {'rtp': 'vim/'}
" Install L9 and avoid a Naming conflict if you've already installed a
" different version somewhere else.
" Plugin 'ascenator/L9', {'name': 'newL9'}

" In order to show the '>' characters in the Vim bar, the package
" powerline-fonts is required, so, you will have to install it following the
" instructions of this link:
"
" https://github.com/powerline/fonts
"


" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required
" To ignore plugin indent changes, instead use:
"filetype plugin on
"
" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
"
" see :h vundle for more details or wiki for FAQ
" Put your non-Plugin stuff after this line



" Personal settings
" -----------------

Plugin 'mhinz/vim-startify'	"Custom start buffer
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
"In Linux we can try this ones
"let g:airline#extensions#tabline#enabled = 1
"let g:airline_powerline_fonts = 1

let g:airline_theme='badwolf'

set relativenumber
set number
syntax on

"More comfy for spanish layouts
nmap ñ :
nmap Ñ :

if has('win32') || has('win64')
	" Set powershell as default shell for ! commands and terminal mode
	" instead of CMD
	set shell=powershell shellquote= shellpipe=\| shellxquote=
	set shellcmdflag=-NoLogo\ -NoProfile\ -ExecutionPolicy\ RemoteSigned\ -Command
	set shellredir=\|\ Out-File\ -Encoding\ UTF8

	" Check if the listed plugins are installed. If not, 
	" runs Plugin install
	" NOTE: Use $HOME to get the user path. 
	
	let checkGitWinFunction = 'function Is-Git-Available(){ $output = powershell -command git | Out-String; if($output -like ''*usage:*'') { clear; return 0;} else { return }; }; Is-Git-Available'

	let isGitInstalled = system(checkGitWinFunction)

	if strlen(isGitInstalled) > 2
		"echo "Git is not available in your sistem."
	else







	endif


endif


