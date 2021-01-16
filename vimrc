
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
function GetExecOutput(command)
    redir =>output
    silent exec a:command
    redir END
    return output
endfunction


function WriteToVimConfigFile(codeString)
	call writefile([a:codeString], $VIMADDCONFIG, "a")
endfunction


function GetOSSlash()
	if has('win32') || has('win64')
		return "\\"
	endif
		return "/"
endfunction

function IsGitAvailable()
	let gitAvailable = 0
	if has('win32') || has('win64')
		let checkGitWinFunction = 'function Is-Git-Available(){ $output = powershell -command git | Out-String; if($output -like ''*usage:*'') { clear; return 0;} else { return }; }; Is-Git-Available'

		let isGitInstalled = system(checkGitWinFunction)

		" Kinda sloppy - We are measuring the string length, if it is longer
		" than 2, it returned an error -.

		if strlen(isGitInstalled) <= 2
			let gitAvailable = 1
		endif
	endif
	return gitAvailable
endfunction

" Configures VIM based on the OS which is running in.
function ConfigureVim()

	let gitAvailable = 0
	if has('win32') || has('win64')
		
		" Set powershell as the default shell for 
		" ! commands and terminal mode instead of CMD
		set shell=powershell shellquote= shellpipe=\| shellxquote=
		set shellcmdflag=-NoLogo\ -NoProfile\ -ExecutionPolicy\ RemoteSigned\ -Command
		set shellredir=\|\ Out-File\ -Encoding\ UTF8
	endif

	if has('unix')	
		" TODO: Configure VIM for Linux and Mac
	endif
endfunction

function IsVundleInstalled()
	if exists("$VUNDLEPATH")
		try
			let test = isdirectory($VUNDLEPATH)
			return test
		catch
			return 0
		endtry
	endif
	return 0
endfunction

function InstallVundle()
	if exists("g:isGitInstalled") && g:isGitInstalled == 1 && exists("$VUNDLEPATH")
		silent exe "! git clone https://github.com/VundleVim/Vundle.vim " . $VUNDLEPATH
		let success = IsVundleInstalled()
		return success
	endif
	return 0
endfunction

function DownloadOrUpdatePlugins()
	if !exists('g:NOVIMADDCONFIG')
   		let choice = confirm("Do you want to download and install the plugins?", "&Yes\n&No\n&O No, and don't ask again.", 2)
		if choice == 1
				call CheckIfPluginsAreInstalled()
				call WriteToVimConfigFile("let DisableConfigurationDialog = 1")
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



function StartInstallationWizard()
	if !exists("g:NOVIMADDCONFIG") || (exists("g:DisableConfigurationDialog") && g:DisableConfigurationDialog == 1)
		return
	endif

	let g:isGitInstalled = IsGitAvailable()
	if g:isGitInstalled == 0
		if !exists("g:userAlreadyWarnedAboutGit")
			echo "You need to install Git in your operative system in order to be able to auto configure Vim."
			call WriteToVimConfigFile("let g:userAlreadyWarnedAboutGit = 1")
		endif
		return
	endif

	let g:isVundleInstalled = IsVundleInstalled()
	if g:isVundleInstalled == 0
   		let choice = confirm("You must install Vundle in order to continue. Do you want to proceed?", "&Yes\n&No\n&O No, and don't ask again.", 2)
		if choice == 1
			echo "Downloading and installing Vundle. Please wait..."
			call InstallVundle()
			let g:isVundleInstalled = IsVundleInstalled()
			if g:isVundleInstalled == 0
				echo "There has been an error while installing Vundle. The path was " . $VUNDLEPATH 
				echo "Delete the folder and try again."
				return
			else
				echo "Vundle has been installed in " . $VUNDLEPATH . "."
				echo "Restart Vim to continue with the installation process."
				return
			endif
		elseif choice == 2
			return
		elseif choice == 3 
			call WriteToVimConfigFile("let DisableConfigurationDialog = 1")
			return
		endif
	endif

	call DownloadOrUpdatePlugins()

endfunction








" ============================================================
" ============================================================
" ============================================================
" ============================================================


" Loads or creates a file to store variables used in dialogs 
" or functions from this file. If none of these things can 
" be done, g:NOVIMADDCONFIG is set to 1. 
" ==========================================================

let g:OSSlash = GetOSSlash()

let g:vimrcPath = split($MYVIMRC, g:OSSlash)
let g:vimrcPath = vimrcPath[0:-2]
let g:vimrcPath = join(vimrcPath, g:OSSlash) 

let $VIMADDCONFIG = g:vimrcPath . g:OSSlash . '.auto.vim'
let $VUNDLEPATH = g:vimrcPath . g:OSSlash . 'bundle' . g:OSSlash . 'Vundle.vim'

let g:NOVIMADDCONFIG = 0

try
	source $VIMADDCONFIG
catch
	try
		call writefile(['"Deleting this file will cause the auto installation process to start again'], $VIMADDCONFIG)
	catch
		let g:NOVIMADDCONFIG = 1
	endtry
endtry

unlet g:vimrcPath

set nocompatible              " be iMproved, required
filetype off                  " required

if isdirectory($VUNDLEPATH)
	" set the runtime path to include Vundle and initialize
	set rtp+=$VUNDLEPATH
	call vundle#begin($VUNDLEPATH . g:OSSlash . 'plugins')

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
endif


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


" Starts Vim auto configuration
call ConfigureVim()
call StartInstallationWizard()

