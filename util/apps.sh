source $HOME/.dotfiles/util/common.sh

_configure_android() {
	# Android SDK (non-OS X)
	if [ -d /opt/android-sdk ]; then
		export ANDROID_SDK_ROOT="/opt/android-sdk"
		_append_to_path "${ANDROID_SDK_ROOT}/tools"
		_append_to_path "${ANDROID_SDK_ROOT}/platform-tools"
	fi
}

_configure_bash() {
	# Run only for interactive terminals
	[ -z "$PS1" ] && return
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
	_configure_bash_PS1
}

_configure_bash_completion() {
	if ! shopt -oq posix; then
		# Enable programmable shell completion features
		if [ -f /usr/share/bash-completion/bash_completion ]; then
			. /usr/share/bash-completion/bash_completion
		elif [ -f /etc/bash_completion ]; then
			. /etc/bash_completion
		elif [ -f /usr/local/etc/bash_completion ]; then
			. /usr/local/etc/bash_completion
		elif [ -f $HOME/local/common/share/bash-completion/bash_completion ]; then
			# Systems that need customized help (fast.cs.odu.edu Solaris machines)
			. $HOME/local/common/share/bash-completion/bash_completion
		elif [ "$SYSTYPE" == "Darwin" ] && _prog_exists brew && [ -f $(brew --prefix)/etc/bash_completion ]; then
			# Homebrew
			. $(brew --prefix)/etc/bash_completion
		elif [ -f /opt/local/etc/bash_completion ]; then
			# Macports
			. /opt/local/etc/bash_completion
		fi
	fi
}

__hg_ps1() {
	if [ -d .hg ]; then
		printf "$1" $(<.hg/branch tr -d [:blank:])
	fi
}

__vcs_ps1() {
	# Display the VCS branch name if in a directory
	# Try git first
	local branch=""
	if type __git_ps1 &>/dev/null; then
		branch="$(__git_ps1 "${1}")"
	fi
	if [ -z "${branch}" ]; then
		# Try Mercurial
		branch="$(__hg_ps1 " (%s)")"
	fi
	printf "$branch"
}

_configure_bash_PS1() {
	# Set PS1 (prompt)
	PS1="[\u@${HOST_COLOR}\h${COLOR_RESET}:\W\$(__vcs_ps1 \" (%s)\")]\\$ "
}

_configure_ccache() {
	# Enable ccache in Android if we have it, and set it up
	if _prog_exists ccache; then
		if [ ! -z "$CCACHE_DIR" -a ! -d "$CCACHE_DIR" ]; then
			mkdir "$CCACHE_DIR"
		fi
		if [ ! -w "$CCACHE_DIR" ]; then
			unset CCACHE_DIR
		else
			export USE_CCACHE=1
			ccache -M 50G &>/dev/null
		fi
	fi
}

_configure_cmf_krb5() {
	if [ -d /usr/krb5 ]; then
		_prepend_to_path "/usr/krb5/bin"
		_prepend_to_path "/usr/krb5/sbin"
	elif [ -d /usr/local/krb5 ]; then
		_prepend_to_path "/usr/local/krb5/bin"
		_prepend_to_path "/usr/local/krb5/sbin"
	fi
}

_configure_ec2() {
	# Set up Amazon EC2 keys
	if [ -d "$HOME/.ec2" ] && _prog_exists ec2-cmd; then
		# EC2_HOME needs the jars directory. Right now I'm just using Homebrew, so
		# I'll need to add special handling if I use other platforms in the future.
		if _prog_exists brew; then
			export EC2_HOME="$(brew --prefix ec2-api-tools)/jars"
		else
			echo "WARNING: ec2-cmd detected but no Homebrew."
		fi
		export EC2_PRIVATE_KEY="$(/bin/ls $HOME/.ec2/pk-*.pem)"
		export EC2_CERT="$(/bin/ls $HOME/.ec2/cert-*.pem)"
	fi
}

_configure_git_hub(){
	# Only for interactive sessions
	[ -z "$PS1" ] && return
	if _prog_exists hub; then
		alias git="hub"
	fi
}

_configure_lesspipe() {
	# Only for interactive sessions
	[ -z "$PS1" ] && return
	# Setup lesspipe
	if _prog_exists lesspipe; then
		export LESSOPEN="|lesspipe %s"
	elif _prog_exists lesspipe.sh; then
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
	# Only for interactive sessions
	[ -z "$PS1" ] && return
	# Add command completion for pip
	if _prog_exists pip; then
		eval "$(pip completion --bash)"
	fi
	# Use a package cache
	mkdir -p "${PIP_DOWNLOAD_CACHE:=${HOME}/.pip_cache}"
	export PIP_DOWNLOAD_CACHE
}

_configure_postgres_app() {
	if [ -d /Applications/Postgres.app ]; then
		_prepend_to_path "/Applications/Postgres.app/Contents/MacOS/bin"
	fi
}

_configure_rvm() {
	if [ -s "$HOME/.rvm/scripts/rvm" ]; then
		source "$HOME/.rvm/scripts/rvm"
	fi
}

_configure_vagrant() {
	if _prog_exists vagrant; then
		complete -W "$(echo `vagrant --help | awk '/^     /{print $1}'`;)" vagrant
	fi
}

_configure_vim() {
	# Only for interactive sessions
	[ -z "$PS1" ] && return
	# Ignore Vim temporary files for file completion
	FIGNORE=".swp:.swo"
	# Set Vim as $EDITOR if it's available
	if _prog_exists mvim; then
		 GUI_VIM=mvim
	elif _prog_exists gvim; then
		 GUI_VIM=gvim
	fi
	if _prog_exists vim; then
		VI=vim
	elif _prog_exists vi; then
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
	# Only for interactive sessions
	[ -z "$PS1" ] && return
	# Pull in virtualenvwrapper
	local wrapper_source=$(type -p virtualenvwrapper.sh)
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
		# Use Distribute instead of Setuptools by default
		export VIRTUALENV_DISTRIBUTE=1
		source $wrapper_source
	fi
}

configure_apps() {
	_configure_android
	_configure_bash
	_configure_ccache
	_configure_cmf_krb5
	_configure_ec2
	_configure_git_hub
	_configure_lesspipe
	_configure_perlbrew
	_configure_pip
	_configure_postgres_app
	_configure_rvm
	_configure_vagrant
	_configure_vim
	_configure_virtualenv_wrapper
	# And now for tiny enironmental configurtion that doesn't fit elsewhere
	# AKA, Misc.
	export BLOCKSIZE=K
}

