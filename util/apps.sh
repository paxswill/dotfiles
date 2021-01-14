# Application or program specific configuration
source ~/.dotfiles/util/term.sh
source ~/.dotfiles/util/find_pkcs11.sh
source ~/.dotfiles/util/prompt.sh
source ~/.dotfiles/util/completion.sh

_list_installed_python() {
	# Unlike all of the other functions in this file, this function does *not*
	# configure an application. Instead it's used to find out which versions of
	# Python are installed.

	# If an argument is given, that string is used as the base for testing the
	# existance of things (ex: given the name "pip", this function checks for
	# versions of pip).
	local PROG_NAME="python"
	if [ ! -z "$1" ]; then
		PROG_NAME="$1"
	fi
	# Generate a list of suffixes for the minor python versions
	local PY_SUFFIXES=()
	PY_SUFFIXES=(2.6 2.7)
	# Update this in a few years when Python 3.15 is in development
	PY_SUFFIXES=(3.{0..15})
	# Add just major version suffixes
	PY_SUFFIXES+=(2)
	PY_SUFFIXES+=(3)
	# If we're checking for actual python interpreters, the PyPy variants are
	# just 'pypy' and 'pypy3', but if we're checking for something like pip,
	# it's 'pip_pypy' and 'pip_pypy3'
	local NAMES_TO_CHECK=("$PROG_NAME")
	if [ "$PROG_NAME" = "python" ]; then
		NAMES_TO_CHECK+=("pypy")
		NAMES_TO_CHECK+=("pypy3")
	else
		PY_SUFFIXES+=("_pypy")
		PY_SUFFIXES+=("_pypy3")
	fi
	for PY_SUFFIX in ${PY_SUFFIXES[@]}; do
		NAMES_TO_CHECK+=("${PROG_NAME}${PY_SUFFIX}")
	done
	# Check everything
	local FOUND=()
	for NAME in ${NAMES_TO_CHECK[@]}; do
		if _prog_exists "$NAME"; then
			echo "$NAME"
		fi
	done
}

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
	# Multi-line commands in the same history entry
	shopt -s cmdhist
	shopt -s lithist
	# Files beginning with '.' are included in globbing
	shopt -s dotglob
	# The rest of this is only applicable to interactive shells
	if [ ! -z "$PS1" ]; then
		# check the window size after each command and, if necessary,
		# update the values of LINES and COLUMNS.
		shopt -s checkwinsize
		# Correct spelling errors
		shopt -s cdspell dirspell
		# Bash-related configuration
		_configure_bash_completion
	fi
	# Configure the prompt from here
	_configure_prompt
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
	[ -z "$PS1" ] && return
	# Add bash completion for docker and docker associated commands
	local DOCKER_APP="/Applications/Docker.app/Contents/Resources/etc"
	if [ -d "${DOCKER_APP}" ]; then
		for F in ${DOCKER_APP}/*.bash-completion; do
			local CMD_NAME="$(basename "$F" .bash-completion)"
			if ! _dotfile_completion_loaded "$CMD_NAME"; then
				_dotfile_completion_lazy_source "$CMD_NAME" "$F"
			fi
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
		local COMPLETION_PATH="$(npm prefix -g)/lib/node_modules/npm/lib/utils/completion.sh"
		if ! _completion_loaded npm && [ -e "$COMPLETION_PATH" ]; then
			_dotfile_completion_lazy_source npm "$COMPLETION_PATH"
		fi
	fi
}

_configure_nvm() {
	local nvm_dir_path=""
	local nvm_path
	if _prog_exists brew; then
		nvm_dir_path="$(brew --prefix nvm)"
	elif [ ! -z "$XDG_CONFIG_HOME" ]; then
		nvm_dir_path="${XDG_CONFIG_HOME}/nvm"
	else
		nvm_dir_path="${HOME}/.nvm"
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
		# Get the list of all versions of pip
		local PIP_VERSIONS=($(_list_installed_python pip))
		if (( ${#PIP_VERSIONS[@]} > 0 )); then
			# Enable completion for the first version of pip
			local FIRST_PIP="${PIP_VERSIONS[0]}"
			eval "$(${FIRST_PIP} completion --bash 2>/dev/null)"
			# Get a shorthand bash completion string for the first version of
			# pip
			local PIP_COMPLETE="$(complete -p ${FIRST_PIP})"
			if (( ${#PIP_VERSIONS[@]} > 1 )); then
				# For every version of pip besides the first, add completion
				# for the new version by replacing the name of the first
				# version of pip with whatever version of pip is being
				# processed right now.
				for PIP_NAME in ${PIP_VERSIONS[@]:1}; do
					if ! _completion_loaded "$PIP_NAME"; then
						eval "${PIP_COMPLETE/%${FIRST_PIP}/${PIP_NAME}}"
					fi
				done
			fi
		fi
	fi
}

_configure_pkcs11() {
	# Just use find_pkcs11 to export an envvar to make using PKCS11 easier for
	# some things like ssh-add/ssh-agent (which require the path to the
	# provider to be given).
	[ -z "$PS1" ] && return
	export PKCS11_PROVIDER="$(find_pkcs11)"
}

_configure_postgres_app() {
	if [ -d /Applications/Postgres.app/Contents/Versions/latest/bin ]; then
		prepend_to_path "/Applications/Postgres.app/Contents/Versions/latest/bin"
	fi
}

_configure_python() {
	local PYTHON_VERSIONS=($(_list_installed_python))
	if (( ${#PYTHON_VERSIONS[@]} > 0 )); then
		export PYTHONSTARTUP="$HOME/.pythonrc"
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
		_dotfile_completion_lazy_generator \
			vagrant
			"complete -W \$(vagrant --help | awk '/^     /{print $1}') vagrant"
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
	# Debian and Ubuntu package virtualenvwrapper to it's own directory outside
	# of $PATH.
	local debian_source="/usr/share/virtualenvwrapper/virtualenvwrapper.sh"
	if [ -z $wrapper_source ] && [ -f $debian_source ]; then
		wrapper_source="$debian_source"
	fi
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
		# Find the python distribution that has virtualenvwrapper installed.
		# Prefer Py3 over Py2
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

_configure_windows_ssh_agent() {
	# Adapted from https://github.com/rupor-github/wsl-ssh-agent
	# This is only applicable on WSL, and let's skip it if SSH_AUTH_SOCK if
	# already defined
	if ! [[ $(uname -r) =~ ^.*[Mm]icrosoft.*$ ]] || [ -n "${SSH_AUTH_SOCK}" ]; then
		return
	fi
	local MISSING_PROG=0
	for PROG in ss socat setsid npiperelay.exe; do
		if ! _prog_exists $PROG; then
			printf "Unable to connect to Windows SSH Agent, missing %s\n" \
				"$PROG"
			MISSING_PROG=1
		fi
	done
	# Bail out if we're missing any of the required utilities
	[ $MISSING_PROG = 1 ] && return
	SSH_AUTH_SOCK="${TMPDIR:-/tmp}/ssh_agent.sock"
	# If there isn't already a socket set up for us, make one
	if ! [[ "$(ss -a)" =~ "${SSH_AUTH_SOCK}" ]]; then
		rm -f "${SSH_AUTH_SOCK}"
		(
			setsid \
			socat \
			UNIX-LISTEN:${SSH_AUTH_SOCK},fork \
			EXEC:"$(which npiperelay.exe) -ei -s //./pipe/openssh-ssh-agent",nofork &
		) &>/dev/null
	fi
	export SSH_AUTH_SOCK
}

configure_apps() {
	local CONFIG_FUNCTIONS=(
		"_configure_android"
		"_configure_bash"
		"_configure_cabal"
		"_configure_cargo"
		"_configure_ccache"
		"_configure_docker"
		"_configure_ec2"
		"_configure_git_hub"
		"_configure_golang"
		"_configure_lesspipe"
		"_configure_npm"
		"_configure_nvm"
		"_configure_perlbrew"
		"_configure_pip"
		"_configure_pkcs11"
		"_configure_python"
		"_configure_postgres_app"
		"_configure_rbenv"
		"_configure_travis"
		"_configure_vagrant"
		"_configure_videocore"
		"_configure_vim"
		"_configure_virtualenv_wrapper"
		"_configure_windows_ssh_agent"
	)
	# AS a debugging facility, set this variable to "y" to print the current
	# time for each config function to help figure out what is taking so long.
	local PRINT_TIMES="n"
	for CONFIG_FUNCTION in ${CONFIG_FUNCTIONS[@]}; do
		if [ $PRINT_TIMES = "y" ]; then
			printf '%s: %(%H:%M:%S)T\n' "$CONFIG_FUNCTION" '-1'
		fi
		eval $CONFIG_FUNCTION
	done
	# And now for tiny enironmental configurtion that doesn't fit elsewhere
	# AKA, Misc.
	export BLOCKSIZE=K
}

