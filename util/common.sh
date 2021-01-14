# Path utility functions

_common_prepend() {
	# $1 is the name of the variable to prepend to
	# $2 is the directory to prepend
	if [ -d "$2" ]; then
		# Disambiguate the directory
		pushd "$2" &>/dev/null
		local realpath="$(pwd -P)"
		popd &>/dev/null
		# Remove any old instances of the path from the current value
		local oldpath="$(eval "printf \"\$$1\"")"
		oldpath="${oldpath:+:}${oldpath}${oldpath:+:}"
		local newpath="${oldpath/":${2}:"/:}"
		newpath="${realpath}${newpath%:}"
		eval "export $1='$newpath'"
	fi
}

_common_append() {
	# $1 is the name of the variable to append to
	# $2 is the directory to append
	if [ -d "$2" ]; then
		# Disambiguate the directory
		pushd "$2" &>/dev/null
		local realpath="$(pwd -P)"
		popd &>/dev/null
		# Remove any old instances of the path from the current value
		local oldpath="$(eval "printf \"\$$1\"")"
		oldpath="${oldpath:+:}${oldpath}${oldpath:+:}"
		local newpath="${oldpath/":${2}:"/:}"
		newpath="${newpath#:}${realpath}"
		eval "export $1='$newpath'"
	fi
}

prepend_to_path() {
	_common_prepend PATH "$1"
}

append_to_path() {
	_common_append PATH "$1"
}

prepend_to_manpath() {
	_common_prepend MANPATH "$1"
}

append_to_manpath() {
	_common_append MANPATH "$1"
}

prepend_to_libpath() {
	_common_prepend LD_LIBRARY_PATH "$1"
}

append_to_libpath() {
	_common_append LD_LIBRARY_PATH "$1"
}

prepend_to_pkgconfpath() {
	_common_prepend PKG_CONFIG_PATH "$1"
}

append_to_pkgconfpath() {
	_common_append PKG_CONFIG_PATH "$1"
}

_prog_exists () {
	if type -p "$1" &>/dev/null; then
		return 0
	else
		return 1
	fi
}

# Cache for checking if commands have lazy-loaded completions available
# Associative arrays were added in bash 4
if (( ${BASH_VERSINFO[0]} >= 4 )); then
	declare -gA _CACHED_LAZY_COMPLETIONS
fi
