
" Use Lex as a file explorer instead of e
" to open directories.
function OpenFileOrLex(path)
	if -f a:path
		e a:path
	else
		Lex a:path
	endif
endfunction


" https://unix.stackexchange.com/a/8296
" Returns the output of an exec command
funct! GetExecOutput(command)
    redir =>output
    silent exec a:command
    redir END
    return output
endfunct!


function WriteToVimConfigFile(codeString)
	call writefile([a:codeString], $VIMADDCONFIG, "a")
endfunction


function GetOSSlash()
	if has('win32') || has('win64')
		return "\\"
	endif
		return "/"
endfunction


" Loads or creates a file to store variables used in dialogs 
" or functions from this file. If none of these things can 
" be done, g:NOVIMADDCONFIG is set to 1. 
" ==========================================================

let g:OSSlash = GetOSSlash()

let g:vimrcPath = split($MYVIMRC, g:OSSlash)
let g:vimrcPath = vimrcPath[0:-2]
let g:vimrcPath = join(vimrcPath, g:OSSlash) 

let $VIMADDCONFIG = g:vimrcPath . g:OSSlash . '.auto.vim'
let g:NOVIMADDCONFIG = 0

unlet g:vimrcPath

try
	source $VIMADDCONFIG
catch
	try
		call writefile(['"Deleting this file will cause the auto installation process to start again'], $VIMADDCONFIG)
	catch
		let g:NOVIMADDCONFIG = 1
	endtry
endtry











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

" Configures VIM based on the OS which is running in.
function ConfigureVim()

	let gitAvailable = 0
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

		if strlen(isGitInstalled) <= 2
			let gitAvailable = 1
		endif
	endif

	if has('unix')	
		" TODO: Configure VIM for Linux and Mac
	endif

	
	if g:NOVIMADDCONFIG == 0 && !exists("g:DisableConfigurationDialog")
   		let choice = confirm("Do you want to download and install the plugins?", "&Yes\n&No\n&O No, and don't ask again.", 2)
		if choice == 1
			if gitAvailable == 1
				call CheckIfPluginsAreInstalled()
				call WriteToVimConfigFile("let DisableConfigurationDialog = 1")
			else
				echo "Git is not available in your system. Please, install it and try again."
				return
			endif
		endif
		if choice == 2
			return
		endif
		if choice == 3
			call WriteToVimConfigFile("let DisableConfigurationDialog = 1")
		endif
	endif
endfunction

function CheckIfPluginsAreInstalled()
	let slash = g:OSSlash

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








call ConfigureVim()

