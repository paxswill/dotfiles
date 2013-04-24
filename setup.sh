#!/bin/bash

DOTFILES="${HOME}/.dotfiles"

_check_ssh_option() {
	if echo "$(ssh -o $1 2>&1)" | grep 'command-line: line 0:' &>/dev/null; then
		return 0
	else
		return 1
	fi
}

_process_source_files(){
	# Find the domain of this host
	if ! type parse_fqdn &>/dev/null; then
		source "${DOTFILES}/util/hosts.sh"
	fi
	# Set up M4 macro definitions
	local M4_DEFS="-DUSER=$USER"
	# Choose an email for git
	if [[ "$DOMAIN" =~ "nrl\.navy\.mil" ]]; then
		M4_DEFS="${M4_DEFS}${M4_DEFS:+ }-DEMAIL=wross@cmf.nrl.navy.mil"
	else
		M4_DEFS="${M4_DEFS}${M4_DEFS:+ }-DEMAIL=paxswill@gmail.com"
	fi
	# Check SSH configuration options. Basically, Solaris SSH is old and likes
	# being different and OpenSSH likes adding useful new features. Also, OS X
	# can sometimes use an old version of OpenSSH.
	if ! _check_ssh_option "ControlMaster=auto"; then
		M4_DEFS="${M4_DEFS}${M4_DEFS:+ }-DSSH_HAS_CONTROL_MASTER"
		if ! _check_ssh_option "ControlPersist=15m"; then
			M4_DEFS="${M4_DEFS}${M4_DEFS:+ }-DSSH_HAS_CONTROL_PERSIST"
		fi
	fi
	if ! _check_ssh_option "ExitOnForwardFailure=yes"; then
		M4_DEFS="${M4_DEFS}${M4_DEFS:+ }-DSSH_HAS_EXIT_ON_FORWARD_FAILURE"
	fi
	if ! _check_ssh_option "HashKnownHosts=yes"; then
		M4_DEFS="${M4_DEFS}${M4_DEFS:+ }-DSSH_HAS_HASH_KNOWN_HOSTS"
	fi
	if ! _check_ssh_option "GSSAPIAuthentication" && \
		! _check_ssh_option "GSSAPIKeyExchange"; then
		M4_DEFS="${M4_DEFS}${M4_DEFS:+ }-DSSH_HAS_GSSAPI"
	fi
	# Check for OS X (for the git keychain connector)
	if [ "$SYSTYPE" = "Darwin" ]; then
		M4_DEFS="${M4_DEFS}${M4_DEFS:+ }-DOSX"
	fi

	# Process source files with M4
	pushd "${DOTFILES}/src" &>/dev/null
	local M4FILES=$(find . -type f ! -name '*.sw*')
	pushd "${DOTFILES}" &>/dev/null
	for F in $M4FILES; do
		mkdir -p "${DOTFILES}/staging/$(dirname $F)"
		m4 "$M4_DEFS" "${DOTFILES}/src/${F}" > "${DOTFILES}/staging/${F}"
	done
	popd &>/dev/null # $DOTFILES
	popd &>/dev/null # $DOTFILES/src
}

clean_dotfiles(){
	pushd "$HOME" &>/dev/null
	# Clean up any old links
	if [ -f "${DOTFILES}/links.txt" ]; then
		local FILES=$(cat "${DOTFILES}/links.txt")
		for F in $FILES; do
			if [ -h "$F" ]; then
				unlink "$F"
			fi
		done
	fi
	# Remove extraneous directories
	if [ -f "${DOTFILES}/dirs.txt" ]; then
		local DIRS=$(cat "${DOTFILES}/dirs.txt")
		for D in $DIRS; do
			rmdir -p "$D" &>/dev/null
		done
	fi
	popd &>/dev/null # $HOME
}

setup_dotfiles(){
	local oldpwd="$OLDPWD"
	local DEST="$HOME/.dotfiles"
	# Get the dotfiles directory if needed
	if [ ! -d "$DEST" ]; then
		if ! git clone git@github.com:paxswill/dotfiles.git "$DEST"; then
			echo "Cloning public URL"
			git clone git://github.com/paxswill/dotfiles.git "$DEST"
		fi
		pushd "$DEST" &>/dev/null
		git submodule update -i
		popd &>/dev/null
	fi

	_process_source_files

	# Clean up any old files and directories
	local FILES
	local DIRS
	clean_dotfiles

	# Link everything up
	pushd "$DEST/staging" &>/dev/null
	DIRS=$(find . -type d ! -name . -prune)
	FILES=$(find . ! -name . -prune -type f ! -name '*.sw*')
	for D in $DIRS; do
		pushd "$D" &>/dev/null
		local tmp_files=$(find . ! -name . -prune ! -name '*.sw*')
		for f in $tmp_files; do
			FILES="$FILES $D/$f"
		done
		popd &>/dev/null
	done
	popd &>/dev/null
	pushd "$HOME" &>/dev/null
	for D in $DIRS; do
		mkdir $D &>/dev/null
	done
	for F in $FILES; do
		ln -s $DEST/staging/$F $F
	done
	popd &>/dev/null

	# Save record of links and directories for future upgrades
	echo "$FILES" > $DEST/links.txt
	echo "$DIRS" > $DEST/dirs.txt
	OLDPWD="$oldpwd"
}

# Update the dotfiles repo and relink it
update_dotfiles(){
	local oldpwd="$OLDPWD"
	pushd "$HOME/.dotfiles" &>/dev/null
	if [ "$(git status --porcelain)" != "" ]; then
		echo "The dotfile repo is dirty. Aborting"
		return 1
	fi
	git pull
	# Update git submodules
	git submodule update -i
	popd &>/dev/null
	OLDPWD="$oldpwd"
	setup_dotfiles
	load_bashrc
}

if [ "${BASH_SOURCE[0]}" == "${0}" ]; then
	# We're running as a script within a shell
	# This is the case if this is during bootstrap, or during a manual setup
	setup_dotfiles
fi
