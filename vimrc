
" https://unix.stackexchange.com/a/8296
" Returns the output of an exec command
function GetExecOutput(command)
    redir =>output
    silent exec a:command
    redir END
    return output
endfunction


function WriteToVimConfigFile(codeString)
	call writefile([a:codeString], $VIMAUTOCOOKIES, "a")
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
	elseif has ('unix')
		let checkGitBashFunction = "hash git &> /dev/null && echo '0' || echo '1'"
		silent let isGitInstalled = system(checkGitBashFunction)
		let isGitInstalled = isGitInstalled[0:0]

		if isGitInstalled == 0
			let gitAvailable = 1
		else
			let gitAvailable = 0
		endif
	endif
	return gitAvailable
endfunction

" Configures VIM based on the OS which is running in.
function ConfigureVim()

	" We set the user folder as the initial directory.
	cd $HOME

	let g:airline_theme='badwolf'

	set relativenumber
	set number
	syntax on

	" Mapping keys
	nmap ñ :
	nmap Ñ :
	nmap <C-Tab> gt


	if has('win32') || has('win64')
		
		" Set powershell as the default shell for 
		" ! commands and terminal mode instead of CMD
		set shell=powershell shellquote= shellpipe=\| shellxquote=
		set shellcmdflag=-NoLogo\ -NoProfile\ -ExecutionPolicy\ RemoteSigned\ -Command
		set shellredir=\|\ Out-File\ -Encoding\ UTF8
	endif

	if has('unix')	
		" TODO: Configure VIM for Linux and Mac
		
		" In order to show the '>' characters in the Vim bar, the package
		" powerline-fonts is required, so, you will have to install it following the
		" instructions of this link:
		"
		" https://github.com/powerline/fonts
		"

		let g:airline#extensions#tabline#enabled = 1
		let g:airline_powerline_fonts = 1
	endif
endfunction

" Loads or creates a file to store variables used in dialogs 
" or functions from this file. 
function SetConfigFile()
	try
		source $VIMAUTOCOOKIES
		let g:NOVIMAUTOCOOKIES = 1
	catch
		try
			call writefile(['"Deleting this file will cause the auto installation process to start again'], $VIMAUTOCOOKIES)
			let g:NOVIMAUTOCOOKIES = 1
		catch
			let g:NOVIMAUTOCOOKIES = 0
		endtry
	endtry
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
		return 1
	endif
	return 0
endfunction

function DownloadOrUpdatePlugins()
	if exists('g:NOVIMAUTOCOOKIES') && g:NOVIMAUTOCOOKIES != 0
   		let choice = confirm("Do you want to download and install the plugins?", "&Yes\n&No\n&O No, and don't ask again.", 2)
		if choice == 1
			exec 'PluginInstall'
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
	let pluginsPath = $HOME . g:OSSlash . ".vim" . g:OSSlash . "bundle"

	let pendingPlugins = 0

	for plugin in g:pluginList

		let pluginFolder = split(plugin, "/")
		let pluginPath = pluginsPath . g:OSSlash . pluginFolder[1]

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
	if !exists("g:NOVIMAUTOCOOKIES") || (exists("g:DisableConfigurationDialog") && g:DisableConfigurationDialog == 1)
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


let g:OSSlash = GetOSSlash()

let g:vimrcPath = split($MYVIMRC, g:OSSlash)
let g:vimrcPath = vimrcPath[0:-2]
let g:vimrcPath = join(vimrcPath, g:OSSlash) 

if has('unix')
	let g:vimrcPath = g:OSSlash . g:vimrcPath
endif

let $VIMAUTOCOOKIES = g:vimrcPath . g:OSSlash . '.autoCookies.vim'
let $VUNDLEPATH = g:vimrcPath . g:OSSlash . 'bundle' . g:OSSlash . 'Vundle.vim'

let g:NOVIMAUTOCOOKIES = 0

call SetConfigFile()

unlet g:vimrcPath

if isdirectory($VUNDLEPATH)
	set nocompatible              " be iMproved, required
	filetype off                  " required

	" set the runtime path to include Vundle and initialize
	set rtp+=$VUNDLEPATH
	call vundle#begin($VUNDLEPATH . g:OSSlash . 'plugins')

	" let Vundle manage Vundle, required
	Plugin 'VundleVim/Vundle.vim'


	" Put all the plugins that you want to use
	" inside this array to automatize the process.
	let g:pluginList = [
	  \"mhinz/vim-startify",
	  \"vim-airline/vim-airline",
	  \"vim-airline/vim-airline-themes",
	  \"aserebryakov/vim-todo-liststhemes",
	  \]

	for plugin in g:pluginList
		exec "Plugin \'" . plugin . "\'"
	endfor

	" All of your Plugins must be added before the following line
	call vundle#end()            " required
	filetype plugin indent on    " required
endif

call ConfigureVim()
call StartInstallationWizard()

