_dotfile_completion_loaded () {
	if complete -p "$1" &>/dev/null; then
		# Check if the completion is already loaded
		# This does not handle lazy-loaded completions used by
		# bash-completion >=2
		return 0
	else
		# Check to see if we've looked for this command already
		if [ -n "${_CACHED_LAZY_COMPLETIONS[${1}]}" ]; then
			return 0
		fi
		# Check for lazy-loaded completion
		local -a _LAZY_COMPLETION_DIRS
		OLDIFS="$IFS"
		IFS=":"
		read -a _LAZY_COMPLETION_DIRS <<< "${XDG_DATA_DIRS:-/usr/local/share/:/usr/share/}"
		IFS="$OLDIFS"
		# Newer versions of bash-completion allow user-local completion files to
		# be installed in
		# ${XDG_DATA_HOME:-${HOME}/.local/share}bash-completion
		if (( ${BASH_COMPLETION_VERSINFO[0]} > 2 || ${BASH_COMPLETION_VERSINFO[0]} == 2 && ${BASH_COMPLETION_VERSINFO[1]} >= 9 )); then
			_LAZY_COMPLETION_DIRS+=("${XDG_DATA_HOME:-${HOME}/.local/share}")
		fi
		# Check each location to see if there's a completion file there, ready
		# to be lazy loaded
		for _LAZY_COMPLETION_DIR in "${_LAZY_COMPLETION_DIRS[@]}"; do
			if [ -r "${_LAZY_COMPLETION_DIR}/bash-completion/completions/${1}" ]; then
				# Note in the cache that we've found this command
				_CACHED_LAZY_COMPLETIONS[${1}]="y"
				return 0
			fi
		done
	fi
	return 1
}

_dotfile_completion_go_cmds() {
	# These programs all operate the same way for generating completion
	# If their completion functions aren't already loaded, generate them
	# and load them dynamically
	local GO_COMPLETION_COMMANDS=( kubectl minikube helm k3d )
	local COMPLETION_CMD
	for COMPLETION_CMD in "${GO_COMPLETION_COMMANDS[@]}"; do
		if _prog_exists "$COMPLETION_CMD" && ! _dotfile_completion_loaded "${COMPLETION_CMD}"; then
			echo "Loading dynamic completion for ${COMPLETION_CMD}"
			eval "$("${COMPLETION_CMD}" completion bash)"
		fi
	done
}

_dotfile_completion_find_completion() {
	local -a COMPLETION_FILES=(
		# Standard-ish locations from Linux
		"/usr/share/bash-completion/bash_completion"
		"/etc/bash_completion"
		"/usr/local/etc/bash_completion"
		# ODU Solaris Machines
		"${HOME}/local/common/share/bash-completion/bash_completion"
		# MacPorts
		"/opt/local/etc/bash_completion"
		# FreeBSD Ports
		"/usr/local/share/bash-completion/bash-completion.sh"
		"/usr/local/share/bash-completion/bash_completion.sh"
	)
	if _prog_exists brew; then
		COMPLETION_FILES+=("$(brew --prefix)/etc/profile.d/bash_completion.sh")
		# Newer versions of bash-completion will load completion files on
		# demand, which is nice as it makes start up faster. Old-style
		# completion files are also supported, but Homebrew's version of
		# the newer bash-completion (the @2 version, the default is the old
		# version) doesn't look for the old directory, so we have to point
		# it to the old path ourselves.
		# tl;dr https://discourse.brew.sh/t/bash-completion-2-vs-brews-auto-installed-bash-completions/2391/2
		export BASH_COMPLETION_COMPAT_DIR="$(brew --prefix)/etc/bash_completion.d"
	fi
	# Find a bash-completion script and source it
	local COMPLETE_PATH
	for COMPLETE_PATH in ${COMPLETION_FILES[@]}; do
		if [ -f "$COMPLETE_PATH" ]; then
			source "$COMPLETE_PATH"
			break
		fi
	done
}

_configure_bash_completion() {
	[ -z "$PS1" ] && return
	# Ignore Vim swap files when completing
	FIGNORE=".swp:.swo"
	# ...but if they're the only completion, allow them
	shopt -u force_fignore
	# Autocomplete for hostnames
	shopt -s hostcomplete
	if ! shopt -oq posix; then
		# Enable programmable shell completion features
		# Extra bash-completion configuration
		# Add hosts from avahi if avahi-browse is avaiable
		export COMP_KNOWON_HOSTS_WITH_AVAHI=y
		# If a completion is normally file-extension based, but no files with
		# that extension are found, list all files
		export COMP_FILEDIR_FALLBACK=y
		_dotfile_completion_find_completion
		_dotfile_completion_go_cmds
	fi
}