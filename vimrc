

" --------------------------------------------------------------
" all the variables used in interactive dialogs are stored above



set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

" In order to show the '>' characters in the Vim bar, the package
" powerline-fonts is required, so, you will have to install it following the
" instructions of this link:
"
" https://github.com/powerline/fonts
"

" Put all the plugins that you want to use
" inside this array to automatize the process.
let g:pluginList = [
  \"mhinz/vim-startify",
  \"vim-airline/vim-airline",
  \"vim-airline/vim-airline-themes",
  \"vim-airline/vim-airline-asdfasdf",
  \]

for plugin in g:pluginList
	exec "Plugin \'" . plugin . "\'"
endfor

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required


" Personal settings
" -----------------

" We set the user folder as the initial directory.
cd $HOME

"In Linux we can try this ones
"let g:airline#extensions#tabline#enabled = 1
"let g:airline_powerline_fonts = 1

let g:airline_theme='badwolf'

set relativenumber
set number
syntax on

" Mapping keys
nmap ñ :
nmap Ñ :
nmap <C-Tab> gt


" Run this function at the bottom of the file to allow all the called 
" functions to load before.
function ConfigureVim()

	if has('win32') || has('win64')
		" Set powershell as the default shell for 
		" ! commands and terminal mode instead of CMD
		set shell=powershell shellquote= shellpipe=\| shellxquote=
		set shellcmdflag=-NoLogo\ -NoProfile\ -ExecutionPolicy\ RemoteSigned\ -Command
		set shellredir=\|\ Out-File\ -Encoding\ UTF8

		let checkGitWinFunction = 'function Is-Git-Available(){ $output = powershell -command git | Out-String; if($output -like ''*usage:*'') { clear; return 0;} else { return }; }; Is-Git-Available'

		let isGitInstalled = system(checkGitWinFunction)

		" Kinda sloppy - We are measuring the string length, if it is longer
		" than 2, it returned an error -.

		if strlen(isGitInstalled) > 2
			"echo "Git is not available in your system."
		else
			"call CheckIfPluginsAreInstalled()
		endif

	endif
endfunction

function CheckAndInstallPlugins()

endfunction



function CheckIfPluginsAreInstalled()
	let slash = GetOSSlash()

	let pluginsPath = $HOME . slash . ".vim" . slash . "bundle"

	let pendingPlugins = 0

	for plugin in g:pluginList

		let pluginFolder = split(plugin, "/")
		let pluginPath = pluginsPath . slash . pluginFolder[1]

		if isdirectory(pluginPath) == 0
			let pendingPlugins = 1
			continue
		endif
	endfor

	if pendingPlugins == 1
		echo "There are missing plugins. Attempting to install them..."
		exec 'PluginInstall'
	endif

endfunction

function GetOSSlash()
	if has('win32') || has('win64')
		return "\\"
	endif
		return "/"
endfunction


" Use Lex as a file explorer instead of e
" to open directories.
function OpenFileOrLex(path)
	if -f a:path
		e a:path
	else
		Lex a:path
	endif
endfunction



"https://unix.stackexchange.com/a/8296
funct! GetExecOutput(command)
    redir =>output
    silent exec a:command
    redir END
    return output
endfunct!

function AskVim()
   let choice = confirm("Do you want to download and install the plugins?", "&Yes\n&No\n&O No, and don't ask again", 2)
   echo choice
endfunction

function WriteToTopVimrc(codeString)
	let vimrc = readfile($MYVIMRC)
	call writefile([a:codeString], $MYVIMRC, "b")
	call writefile(vimrc, $MYVIMRC, "a")
endfunction

call ConfigureVim()

