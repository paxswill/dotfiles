source ~/.dotfiles/util/bash/common.sh

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

# Cache for checking if commands have lazy-loaded completions available
# Associative arrays were added in bash 4
if (( ${BASH_VERSINFO[0]} >= 4 )); then
	declare -gA _CACHED_LAZY_COMPLETIONS
fi

_dotfile_completion_lazy() {
	# Usage:
	# _complete_lazy "function name" "source_command"
	# After this function is called, a function with the provided name will be
	# defined which will load in the real completion when called. For example:
	#
	# _dotfile_completion_lazy "_foo" "source foo.sh"
	# complete -F _foo foo
	#
	# 'source foo.sh' should be a string containing the command that would
	# normally be evaluated to define the completion.
	# Inspired by:
	# https://dev.to/zanehannanau/bash-lazy-completion-evaluation-2a2d
	local LAZY_FUNC_NAME="$1"
	shift
	eval "$LAZY_FUNC_NAME () {
		local OLD_COMPLETION=\"\$(complete -p \${1})\"
		eval \"${@}\"
		local NEW_COMPLETION=\"\$(complete -p \${1})\"
		[[ \$OLD_COMPLETION = \$NEW_COMPLETION ]] && return
		unset -f \"$LAZY_FUNC_NAME\"
		local FUNCTION_PATTERN='-F \w+'
		if [[ \"\$NEW_COMPLETION\" =~ \$FUNCTION_PATTERN ]]; then
			\"\${BASH_REMATCH[0]:3}\" \"\$1\" \"\$2\" \"\$3\"
		else
			compgen \${NEW_COMPLETION:9} \"\$1\"
		fi
	}"
}

_dotfile_completion_lazy_generator() {
	# Args: command name, generator command
	local LAZY_FUNC_NAME="_dotfile_completion_lazy_${1}"
	_dotfile_completion_lazy "$LAZY_FUNC_NAME" "\$(${2})"
	complete -F "$LAZY_FUNC_NAME" $1
}

_dotfile_completion_lazy_source() {
	# Args: command name, file path
	local LAZY_FUNC_NAME="_dotfile_completion_lazy_${1}"
	_dotfile_completion_lazy "$LAZY_FUNC_NAME" "source \"${2}\""
	complete -F "$LAZY_FUNC_NAME" $1
}

_dotfile_completion_go_cmds() {
	# These programs all operate the same way for generating completion
	# If their completion functions aren't already loaded, generate them
	# and load them dynamically
	local GO_COMPLETION_COMMANDS=(
		helm
		k0s
		k0sctl
		k3d
		kubectl
		kubectl-krew
		minikube
	)
	local COMPLETION_CMD
	for COMPLETION_CMD in "${GO_COMPLETION_COMMANDS[@]}"; do
		if _prog_exists "$COMPLETION_CMD" && ! _dotfile_completion_loaded "${COMPLETION_CMD}"; then
			_dotfile_completion_lazy_generator \
				"${COMPLETION_CMD}" \
				"${COMPLETION_CMD} completion bash"
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
		# Call _brew_prefix to make sure $BREW_PREFIX is set in this shell
		_brew_prefix >/dev/null
		COMPLETION_FILES+=("${BREW_PREFIX}/etc/profile.d/bash_completion.sh")
		# Newer versions of bash-completion will load completion files on
		# demand, which is nice as it makes start up faster. Old-style
		# completion files are also supported, but Homebrew's version of
		# the newer bash-completion (the @2 version, the default is the old
		# version) doesn't look for the old directory, so we have to point
		# it to the old path ourselves.
		# tl;dr https://discourse.brew.sh/t/bash-completion-2-vs-brews-auto-installed-bash-completions/2391/2
		export BASH_COMPLETION_COMPAT_DIR="${BREW_PREFIX}/etc/bash_completion.d"
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
