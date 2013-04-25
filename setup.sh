#!/bin/bash

DOTFILES="${HOME}/.dotfiles"

_check_ssh_option() {
	if echo "$(ssh -o $1 2>&1)" | grep 'command-line: line 0:' &>/dev/null; then
		return 0
	else
		return 1
	fi
}

process_source_files(){
	local oldpwd="$OLDPWD"
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
		m4 $M4_DEFS "${DOTFILES}/src/${F}" > "${DOTFILES}/staging/${F}"
	done
	popd &>/dev/null # $DOTFILES
	popd &>/dev/null # $DOTFILES/src
	OLDPWD="$oldpwd"
}

link_dotfiles(){
	local STAGING="${DOTFILES}/staging"
	# Save the special IFS value
	local OLDIFS="$IFS"
	IFS=$'\n'
	# Move the list of old links and directories out of the way
	local DIRLOG="${DOTFILES}/dirs.txt"
	local LINKLOG="${DOTFILES}/links.txt"
	[ -e "$DIRLOG" ] && mv "$DIRLOG" "${DIRLOG}.old"
	[ -e "$LINKLOG" ] && mv "$LINKLOG" "${LINKLOG}.old"
	# Get a list of directories and files to link/create
	local DIRS="$(find "$STAGING" \
		-type d \
		-not -path "$STAGING" \
		-not -path "*/.git*")"
	local FILES="$(find "$STAGING" \
		-type f \
		-not -name "*.sw?" \
		-not -path "$STAGING" \
		-not -path "*/.git*")"
	# Create directories
	for D in $DIRS; do
		local TARGET_DIR="${D/\/.dotfiles\/staging}"
		if mkdir -p "$TARGET_DIR" &>/dev/null; then
			echo "$TARGET_DIR" >> "$DIRLOG"
		fi
	done
	# Link files
	for LINK_TARGET in $FILES; do
		local LINK="${F/\/.dotfiles\/staging}"
		if [ -L "$LINK" ]; then
			if [ ! "$LINK" -ef "$LINK_TARGET" ]; then
				ln -sf "$LINK_TARGET" "$LINK"
			fi
			echo "$LINK" >> "$LINKLOG"
		fi
	done
	# Cleanup links
	if [ -e "${LINKLOG}.old" ]; then
		for OLDLINK in $(< "${LINKLOG}.old"); do
			if [ -L "$OLDLINK" -a ! -e "$OLDLINK" ]; then
				unlink "$OLDLINK"
			fi
		done
		rm "${LINKLOG}.old"
	fi
	# Cleanup dirs
	if [ -e "${DIRLOG}.old" ]; then
		# This odd loop is so the directories are removed in reverse order.
		# For example, dirs.txt.old is:
		# ./a
		# ./a/b/c
		# ./a/d
		# ./a/d/e
		# If is done first, it fails as there's still stuff in it
		local OLDDIRS="$(< "${DIRLOG}.old")"
		for (( i=${#OLDDIRS}; i > 0; i-- )); do
			[ ! -z "${OLDDIRS[i]}" ] && rmdir "${OLDDIRS[i]}" &>/dev/null
		done
		rm "${DIRLOG}.old"
	fi
	# Put IFS back
	IFS="$OLDIFS"
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

	process_source_files
	link_dotfiles
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
