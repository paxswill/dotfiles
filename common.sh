DOTFILES="${HOME}/.dotfiles"

create_m4_macros(){
	# Create the command-line aruments that define the M4 macros used to
	# process the template configuration files.
	# Set the type of system we're working on.
	if ! type set_systype &>/dev/null; then
		source "${DOTFILES}/util/hosts.sh"
	fi
	set_systype
	# Make sure _prog_exists is present
	if ! type _prog_exists &>/dev/null; then
		source "${DOTFILES}/util/common.sh"
	fi
	# Set up M4 macro definitions
	local M4_DEFS="-DUSER=$USER"
	# Choose an email for git
	if [ -f "${DOTFILES}/email" ]; then
		EMAIL=$(<"${DOTFILES}/email")
	else
		EMAIL="paxswill@paxswill.com"
	fi
	M4_DEFS="${M4_DEFS}${M4_DEFS:+ }-DEMAIL=${EMAIL}"
	# Check for OS X for the Git Keychain credential helper
	if [ "$SYSTYPE" = "Darwin" ]; then
		M4_DEFS="${M4_DEFS}${M4_DEFS:+ }-DOSX"
	elif [ "$SYSTYPE" = "Linux" ]; then
		M4_DEFS="${M4_DEFS}${M4_DEFS:+ }-DLINUX"
	fi
	# Pick a mergetool if we have one I like
	if _prog_exists opendiff; then
		M4_DEFS="${M4_DEFS}${M4_DEFS:+ }-DMERGETOOL=opendiff"
	elif _prog_exists meld; then
		M4_DEFS="${M4_DEFS}${M4_DEFS:+ }-DMERGETOOL=meld"
	fi
	# Try to find a PKCS11 Provider
	local PKCS11_PROVIDER=""
	local -a PKCS11_LIB_DIRS
	local -a PKCS11_PROVIDERS
	if [ "$SYSTYPE" = "Darwin" ]; then
		PKCS11_PROVIDERS+=("libykcs11.dylib")
		PKCS11_LIB_DIRS+=("/Library/OpenSC/lib")
		PKCS11_LIB_DIRS+=("/usr/local/opt/opensc/lib")
		PKCS11_LIB_DIRS+=("/usr/local/lib")
	elif [ "$SYSTYPE" = "Linux" ]; then
		PKCS11_PROVIDERS+=("libykcs11")
		PKCS11_LIB_DIRS+=("/lib" "/lib64" "/usr/lib" "/usr/lib64")
		PKCS11_LIB_DIRS+=("/usr/lib/*-linux-gnu")
	fi
	PKCS11_PROVIDERS+=("opensc-pkcs11.so")
	for PROVIDER in "${PKCS11_PROVIDERS[@]}"; do
		for LIB_DIR in "${PKCS11_LIB_DIRS[@]}"; do
			if [ -f "${LIB_DIR}/${PROVIDER}" ]; then
				PKCS11_PROVIDER="${LIB_DIR}/${PROVIDER}"
				break 2
			fi

		done
	done
	if [ ! -z "$PKCS11_PROVIDER" ]; then
		M4_DEFS="${M4_DEFS}${M4_DEFS:+ }-DPKCS11=${PKCS11_PROVIDER}"
	fi
	# Using printf instead of echo, because I don't want to get into the habit
	# of using `echo -n` and slip up and use it outside of bash.
	printf "%s" "$M4_DEFS"
}

process_source_files(){
	local oldpwd="$OLDPWD"
	# Set up M4 macro definitions
	local M4_DEFS="$(create_m4_macros)"
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
	local GIT_POINTER_LOG="${DOTFILES}/git-pointers.txt"
	[ -e "$DIRLOG" ] && mv "$DIRLOG" "${DIRLOG}.old"
	[ -e "$LINKLOG" ] && mv "$LINKLOG" "${LINKLOG}.old"
	[ -e "$GIT_POINTER_LOG" ] && mv "$GIT_POINTER_LOG" "${GIT_POINTER_LOG}.old"
	# Get a list of directories and files to link/create
	# The lines containing ".git" exclude git directories fomr being linked
	local DIRS="$(find "$STAGING" \
		-type d \
		-not -path "$STAGING" \
		-not -name ".git" \
		-o -type d -name ".git" -not -prune)"
	# Generate a list of files to link
	local FILES="$(find "$STAGING" \
		-type f \
		-not -name "*.sw?" \
		-not -name ".git" \
		-not -path "$STAGING")"
	local GIT_FILES="$(find "$STAGING" \
		-type f \
		-name ".git")"
	# Create directories
	for D in $DIRS; do
		local TARGET_DIR="${D/\/.dotfiles\/staging}"
		if mkdir -p "$TARGET_DIR" &>/dev/null; then
			echo "$TARGET_DIR" >> "$DIRLOG"
		fi
	done
	# Link files
	for LINK_TARGET in $FILES; do
		local LINK="${LINK_TARGET/\/.dotfiles\/staging}"
		if [ ! -e "$LINK" -o -L "$LINK" ]; then
			if [ ! "$LINK" -ef "$LINK_TARGET" ]; then
				ln -sf "$LINK_TARGET" "$LINK"
			fi
			echo "$LINK" >> "$LINKLOG"
		fi
	done
	# Fix up permissions of SSH config files (OpenBSD doesn't allow group
	# writeable config files, but most Linux distributions patch this).
	chmod -R g-w "${STAGING}/.ssh"
	# Create "pointer" git files
	for GIT_POINTER in $GIT_FILES; do
		# Read in the original git file and get the path it specifies
		# The file has the format:
		# gitfile: ./relative/path/to/git/directory
		local RELATIVE_GIT_DIR="$(< "${GIT_POINTER}")"
		local GIT_FILE_TARGET="${GIT_POINTER/\/.dotfiles\/staging}"
		pushd "$(dirname "${GIT_POINTER}")/${RELATIVE_GIT_DIR:8}" &>/dev/null
		printf "gitdir: %s" "$(pwd -P)" > "${GIT_FILE_TARGET}"
		popd &>/dev/null
		echo "${GIT_FILE_TARGET}" >> "$GIT_POINTER_LOG"
	done
	# Cleanup pointer git files
	if [ -e "${GIT_POINTER_LOG}.old" ]; then
		local OLD_POINTERS=$(comm -13 "$GIT_POINTER_LOG" "$GIT_POINTER_LOG".old)
		for OLD_POINTER in ${OLD_POINTERS}; do
			rm "$OLD_POINTER"
		done
		rm "${GIT_POINTER_LOG}.old"
	fi
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

# Update the dotfiles repo and relink it
update_dotfiles(){
	GIT_WORK_TREE="$DOTFILES"
	if [ "$(git status --porcelain)" != "" ]; then
		echo "The dotfile repo is dirty. Aborting"
		return 1
	fi
	git pull
	# Update git submodules
	git submodule update -i
}

