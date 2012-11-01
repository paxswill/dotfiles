source $HOME/.dotfiles/util/common.sh

_configure_android() {
	# Android SDK (non-OS X)
	if [ -d /opt/android-sdk ]; then
		export ANDROID_SDK_ROOT="/opt/android-sdk"
		__append_to_path "${ANDROID_SDK_ROOT}/tools"
		__append_to_path "${ANDROID_SDK_ROOT}/platform-tools"
	fi
}

_configure_bash() {
	# don't put duplicate lines in the history. See bash(1) for more options
	# ... or force ignoredups and ignorespace
	HISTCONTROL=ignoreboth
	# append to the history file, don't overwrite it
	shopt -s histappend
	# All shells share a history
	PROMPT_COMMAND='history -a'
	# Multi-line commands in the same history entry
	shopt -s cmdhist
	shopt -s lithist
	# Files beginning with '.' are included in globbing
	shopt -s dotglob
	# Autocomplete for hostnames
	shopt -s hostcomplete
	# check the window size after each command and, if necessary,
	# update the values of LINES and COLUMNS.
	shopt -s checkwinsize
	# Bash-related configuration
	_configure_bash_completion
	unset _configure_bash_completion
	_configure_bash_PS1
	unset _configure_bash_PS1
}

_configure_bash_completion() {
	# Enable programmable shell completion features
	if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
		# Normal, sane systems
		. /etc/bash_completion
	elif [ -f $HOME/local/common/share/bash-completion/bash_completion ] && shopt -oq posix; then
		# Systems that need customized help (fast.cs.odu.edu Solaris machines)
		. $HOME/local/common/share/bash-completion/bash_completion
	elif [ "$SYSTYPE" == "Darwin" ] && which brew 2>&1 > /dev/null && [ -f $(brew --prefix)/etc/bash_completion ]; then
		# Homebrew
		. $(brew --prefix)/etc/bash_completion
	elif [ -f /opt/local/etc/bash_completion ]; then
		# Macports
		. /opt/local/etc/bash_completion
	fi
}

_configure_bash_PS1() {
	# Set PS1 (prompt)
	# If we have git PS1 magic
	if type __git_ps1 >/dev/null 2>&1; then
		# [user@host:dir(git branch)] $
		GIT_PS1_SHOWUPSTREAM="auto"
		git_branch='$(__git_ps1 " (%s)")'
	fi
	PS1="[\u@${HOST_COLOR}\h${COLOR_RESET}:\W${git_branch}]\$ "
	unset git_branch
}

_configure_ccache() {
	# Enable ccache in Android if we have it, and set it up
	if which ccache >/dev/null; then
		if [ ! -z "$CCACHE_DIR" -a ! -d "$CCACHE_DIR" ]; then
			mkdir "$CCACHE_DIR"
		fi
		if [ ! -w "$CCACHE_DIR" ]; then
			unset CCACHE_DIR
		else
			export USE_CCACHE=1
			ccache -M 50G > /dev/null
		fi
	fi
}

_configure_cmf_krb5() {
	if [ -d /usr/krb5 ]; then
		__prepend_to_path "/usr/krb5/bin"
		__prepend_to_path "/usr/krb5/sbin"
	elif [ -d /usr/local/krb5 ]; then
		__prepend_to_path "/usr/local/krb5/bin"
		__prepend_to_path "/usr/local/krb5/sbin"
	fi
}

_configure_ec2() {
	# Set up Amazon EC2 keys
	if [ -d "$HOME/.ec2" ] && which ec2-cmd >/dev/null; then
		# EC2_HOME needs the jars directory. Right now I'm just using Homebrew, so
		# I'll need to add special handling if I use other platforms in the future.
		if which brew >/dev/null; then
			export EC2_HOME="$(brew --prefix ec2-api-tools)/jars"
		else
			echo "WARNING: ec2-cmd detected but no Homebrew."
		fi
		export EC2_PRIVATE_KEY="$(/bin/ls $HOME/.ec2/pk-*.pem)"
		export EC2_CERT="$(/bin/ls $HOME/.ec2/cert-*.pem)"
	fi
}

_configure_git_hub(){
	if which hub >/dev/null 2>&1; then
		alias git="hub"
	fi
}

_configure_lesspipe() {
	# Setup lesspipe
	if which lesspipe >/dev/null 2>&1; then
		export LESSOPEN="|lesspipe %s"
	elif which lesspipe.sh >/dev/null 2>&1; then
		export LESSOPEN="|lesspipe.sh %s"
	fi
}

_configure_perlbrew() {
	if [ -s $HOME/perl5/perlbrew/etc/bashrc ]; then
		. $HOME/perl5/perlbrew/etc/bashrc
		# On modern systems setting MANPATH screws things up
		if [ "$(uname -s)" = "Darwin" ]; then
			unset MANPATH
		fi
	fi
}

_configure_pip() {
	if which pip >/dev/null 2>&1; then
		eval "$(pip completion --bash)"
	fi
}

_configure_postgres_app() {
	if [ -d /Applications/Postgres.app ]; then
		__prepend_to_path "/Applications/Postgres.app/Contents/MacOS/bin"
	fi
}

_configure_rvm() {
	if [ -s "$HOME/.rvm/scripts/rvm" ]; then
		source "$HOME/.rvm/scripts/rvm"
	fi
}

_configure_vim() {
	# Ignore Vim temporary files for file completion
	FIGNORE=".swp:.swo"
	# Set Vim as $EDITOR if it's available
	if which mvim >/dev/null 2>&1; then
		 GUI_VIM=mvim
	elif which gvim >/dev/null 2>&1; then
		 GUI_VIM=gvim
	fi
	if which vim >/dev/null 2>&1; then
		VI=vim
	elif which vi >/dev/null 2>&1; then
		VI=vi
	fi
	if [ ! -z $GUI_VIM ]; then
		export EDITOR=$GUI_VIM
		if [ ! -z $VI ]; then
			export GIT_EDITOR=$VI
		fi
	elif [ ! -z $VI ]; then
		export EDITOR=$VI
	fi
}

_configure_virtualenv_wrapper() {
	# Pull in virtualenvwrapper
	local wrapper_source=$(which virtualenvwrapper.sh)
	if ! [ -z $wrapper_source ] && [ -s $wrapper_source ]; then
		# Set up the working directories
		if [ -d "$HOME/Development/Python" ]; then
			export PROJECT_HOME="$HOME/Development/Python"
		else
			export PROJECT_HOME="$HOME/Development"
			if ! [ -d $PROJECT_HOME ]; then
				mkdir $PROJECT_HOME
			fi
		fi
		source $wrapper_source
	fi
}

configure_apps() {
	_configure_android
	unset _configure_android
	_configure_bash
	unset _configure_bash
	_configure_ccache
	unset _configure_ccache
	_configure_cmf_krb5
	unset _configure_cmf_krb5
	_configure_ec2
	unset _configure_ec2
	_configure_git_hub
	unset _configure_git_hub
	_configure_lesspipe
	unset _configure_lesspipe
	_configure_perlbrew
	unset _configure_perlbrew
	_configure_pip
	unset _configure_pip
	_configure_postgres_app
	unset _configure_postgres_app
	_configure_rvm
	unset _configure_rvm
	_configure_vim
	unset _configure_vim
	_configure_virtualenv_wrapper
	unset _configure_virtualenv_wrapper
	unset configure_apps
}

