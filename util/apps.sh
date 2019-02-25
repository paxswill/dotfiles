# Application or program specific configuration
source ~/.dotfiles/util/color.sh

_configure_android() {
	# Android SDK (non-OS X)
	if [ -d /opt/android-sdk ]; then
		export ANDROID_SDK_ROOT="/opt/android-sdk"
		append_to_path "${ANDROID_SDK_ROOT}/tools"
		append_to_path "${ANDROID_SDK_ROOT}/platform-tools"
	fi
}

_configure_bash() {
	# Use a larger history file
	HISTSIZE=10000
	HISTFILESIZE=30000
	# don't put duplicate lines in the history. See bash(1) for more options
	# ... or force ignoredups and ignorespace
	HISTCONTROL=ignoreboth
	# append to the history file, don't overwrite it
	shopt -s histappend
	# All shells share a history
	PROMPT_COMMAND='_bash_prompt'
	# Multi-line commands in the same history entry
	shopt -s cmdhist
	shopt -s lithist
	# Files beginning with '.' are included in globbing
	shopt -s dotglob
	# check the window size after each command and, if necessary,
	# update the values of LINES and COLUMNS.
	shopt -s checkwinsize
	# Spell check for paths for cd
	shopt -s cdspell
	# Bash-related configuration
	_configure_bash_completion
	# Add PS0 for pre-command execution. This is only available on bash >= 4.4,
	# so we need to check against that first.
	if (( ${BASH_VERSINFO[0]} > 4 || ${BASH_VERSINFO[1]} == 4 && ${BASH_VERSINFO[1]} >= 4)); then
		PS0="\$(tput sc && tput cuu 2 && tput cuf \$((\$(tput cols)-8)) && date '+%H:%M:%S' && tput rc)"
	fi
}

_configure_bash_completion() {
	[ -z "$PS1" ] && return
	# Autocomplete for hostnames
	shopt -s hostcomplete
	if ! shopt -oq posix; then
		# Enable programmable shell completion features
		local COMPLETION_FILES=(
			# Standard-ish locations form Linux
			[1]="/usr/share/bash-completion/bash_completion"
			[2]="/etc/bash_completion"
			[3]="/usr/local/etc/bash_completion"
			# ODU Solaris Machines
			[4]="${HOME}/local/common/share/bash-completion/bash_completion"
			# MacPorts
			[5]="/opt/local/etc/bash_completion"
			# FreeBSD Ports
			[6]="/usr/local/share/bash-completion/bash-completion.sh"
		)
		if [ "$SYSTYPE" == "Darwin" ] && _prog_exists brew; then
			if (( ${BASH_VERSINFO[0]} >= 4 )); then
				COMPLETION_FILES[0]="$(brew --prefix)/share/bash-completion/bash_completion"
			else
				COMPLETION_FILES[0]="$(brew --prefix)/etc/bash_completion"
			fi
		fi
		for COMPLETE_PATH in ${COMPLETION_FILES[@]}; do
			if [ -f "$COMPLETE_PATH" ]; then
				source "$COMPLETE_PATH"
				break
			fi
		done
	fi
}

_bash_prompt() {
	# All shells share a history
	history -a
	# This variable will keep track of the correction to apply for non-printed
	# characters (like color control codes)
	local -i OFFSET=0
	# Figure out if we're in a Python virtualenv or a Ruby env
	local ENVIRONMENT=""
	if [ ! -z "$VIRTUAL_ENV" ]; then
		ENVIRONMENT="$(basename ${VIRTUAL_ENV})"
	elif [ ! -z "$rvm_bin_path" ]; then
		ENVIRONMENT="$(rvm_bin_path)/rvm-prompt"
	fi
	# Display the environment in muted colors
	if [ ! -z "$ENVIRONMENT" ]; then
		ENVIRONMENT="$(printf "%s(%s)%s" "$MUTED_COLOR" "$ENVIRONMENT" "$COLOR_RESET")"
		OFFSET+=${#MUTED_COLOR}
		OFFSET+=${#COLOR_RESET}
	fi
	# The 'context' is a combination of hostname, current directory and VCS
	# branch name
	local LOCATION="${HOST_COLOR}\h${COLOR_RESET}:\W"
	OFFSET+=${#HOST_COLOR}
	OFFSET+=${#COLOR_RESET}
	LOCATION+="${MUTED_COLOR}$(__vcs_ps1 ' (%s)')${COLOR_RESET}"
	OFFSET+=${#MUTED_COLOR}
	OFFSET+=${#COLOR_RESET}
	# Save the cursor position before we go mucking around with it
	tput sc
	# First we write the current time on the right-hand side. We're going back
	# 8 characters to make room for HH:MM:SS
	# $COLUMNS is provided by bash, and is the width of the terminal in
	# characters.
	tput cuf $((${COLUMNS}-8))
	date "+%H:%M:%S"
	# Now bounce back for our regularly scheduled prompt writing
	tput rc
	PS1="$(printf \
		"%s[\\\\u@%s]\n\\$ " \
		"${ENVIRONMENT}" \
		"${LOCATION}" \
	)"
}

_configure_cabal() {
	# Add cabal (Haskell package manager) executables to PATH
	append_to_path "${HOME}/.cabal/bin"
}

_configure_cargo() {
	append_to_path "${HOME}/.cargo/bin"
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

_configure_docker() {
	# Add bash completion for docker and docker associated commands
	local DOCKER_APP="/Applications/Docker.app/Contents/Resources/etc"
	if [ -d "${DOCKER_APP}" ]; then
		for F in ${DOCKER_APP}/*.bash-completion; do
			[ -f "$F" ] && . $F
		done
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

_configure_golang() {
	if _prog_exists go; then
		export GOROOT="$(go env GOROOT)"
	fi
}

_configure_git_hub(){
	if _prog_exists hub; then
		alias git="hub"
	fi
}

_configure_iterm2_integration(){
	# Some systems don't work with iTerm integration locally
	if [ -z "$SSH_CLIENT" ]; then
		[ "$SYSTYPE" = "FreeBSD" ] && return
		[[ "$(uname -r)" =~ .*[Mm]icrosoft.* ]] && return

	fi
	source "${HOME}/.dotfiles/util/iterm_integration.sh"
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

_configure_npm() {
	if _prog_exists npm; then
		# Don't add an extra path (or move the position of an existing path)
		if [[ ! $PATH =~ (:/usr/local/bin:|^/usr/local/bin:|:/usr/local/bin$) ]]; then
			append_to_path "$(npm bin -g 2>/dev/null)"
		fi
		# This isn't really portable
		if [ -e "$(npm prefix -g)/lib/node_modules/npm/lib/utils/completion.sh" ]; then
			. "$(npm prefix -g)/lib/node_modules/npm/lib/utils/completion.sh"
		fi
	fi
}

_configure_nvm() {
	local nvm_dir_path=""
	local nvm_path
	if _prog_exists brew; then
		nvm_dir_path="$(brew --prefix nvm)"
	fi
	nvm_path="${nvm_dir_path}/nvm.sh"
	if [ ! -z "$nvm_dir_path" ] && [ -r "$nvm_path" ] && [ ! -d "$nvm_path" ]; then
		export NVM_DIR="${HOME}/.nvm"
		mkdir -p "$NVM_DIR"
		. "$nvm_path"

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
	# Add command completion for pip
	if [ ! -z "$PS1" ]; then
		if _prog_exists pip; then
			eval "$(pip completion --bash 2>/dev/null)"
			# Make the completion for pip available for the suffixed variants
			local VERSION=(2 2.7 3 3.3 3.4 3.5)
			local PIP_COMPLETE="$(complete -p pip)"
			for V in ${VERSION[@]}; do
				if _prog_exists "pip${V}"; then
					eval "${PIP_COMPLETE}${V}"
				fi
			done
		fi
	fi
}

_configure_postgres_app() {
	if [ -d /Applications/Postgres.app/Contents/Versions/latest/bin ]; then
		prepend_to_path "/Applications/Postgres.app/Contents/Versions/latest/bin"
	fi
}

_configure_rbenv() {
	if _prog_exists rbenv; then
		eval "$(rbenv init -)"
	fi
}

_configure_travis() {
	# Config info for Travis-CI command line tool
	if [ -d "${HOME}/.travis/travis.sh" ]; then
		source "${HOME}/.travis/travis.sh"
	fi
}

_configure_vagrant() {
	if _prog_exists vagrant && [ ! -z "$PS1" ]; then
		complete -W "$(echo `vagrant --help | awk '/^     /{print $1}'`;)" vagrant
	fi
}

_configure_videocore() {
	# Configure Broadcom Videocore files
	append_to_path /opt/vc/sbin
	append_to_path /opt/vc/bin
	append_to_libpath /opt/vc/lib
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
	# Pull in virtualenvwrapper
	local wrapper_source=$(type -p virtualenvwrapper.sh)
	if ! [ -z $wrapper_source ] && [ -s $wrapper_source ]; then
		# Set up the project directory
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
		# Find the python distribution that has virtualenvwrapper installed.
		# PRefer Py3 over Py2
		for PY in python3 python2 python; do
			if _prog_exists $PY && $PY -c "import virtualenvwrapper" 2>/dev/null; then
				export VIRTUALENVWRAPPER_PYTHON="$(which $PY)"
				break
			fi
		done
		source $wrapper_source
		# Have pip play nice with virtualenv
		export PIP_VIRTUALENV_BASE="${WORKON_HOME}"
		export PIP_RESPECT_VIRTUALENV=true
		# Provide an alias for creating Python3 and Python2 virtualenvs
		for PYVER in 2 3; do
			for VENV_CMD in "mkvirtualenv" "mkproject" "mktmpenv"; do
				local PYOPT="-p $(type -p python${PYVER})"
				alias "${VENV_CMD}${PYVER}"="\
					VIRTUALENVWRAPPER_VIRTUALENV_ARGS=\"${PYOPT}\"\
					${VENV_CMD}"
			done
		done
		# Configure usernames for Bitbucket and GitHub extensions
		export VIRTUALENVWRAPPER_BITBUCKET_USER="paxswill"
		export VIRTUALENVWRAPPER_GITHUB_USER="paxswill"
	fi
}

configure_apps() {
	_configure_android
	_configure_bash
	_configure_cabal
	_configure_cargo
	_configure_ccache
	_configure_docker
	_configure_ec2
	# This MUST be done after _configure_bash is done, as PROMPT_COMMAND is set
	# there and that value gets modified for iTerm's use.
	_configure_iterm2_integration
	_configure_git_hub
	_configure_golang
	_configure_lesspipe
	_configure_npm
	_configure_nvm
	_configure_perlbrew
	_configure_pip
	_configure_postgres_app
	_configure_rbenv
	_configure_travis
	_configure_vagrant
	_configure_videocore
	_configure_vim
	_configure_virtualenv_wrapper
	# And now for tiny enironmental configurtion that doesn't fit elsewhere
	# AKA, Misc.
	export BLOCKSIZE=K
}

