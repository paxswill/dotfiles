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

_prepend_to_path() {
	_common_prepend PATH "$1"
}

_append_to_path() {
	_common_append PATH "$1"
}

_prepend_to_manpath() {
	_common_prepend MANPATH "$1"
}

_append_to_manpath() {
	_common_append MANPATH "$1"
}

_prepend_to_libpath() {
	_common_prepend LD_LIBRARY_PATH "$1"
}

_append_to_libpath() {
	_common_append LD_LIBRARY_PATH "$1"
}

_prepend_to_pkgconfpath() {
	_common_prepend PKG_CONFIG_PATH "$1"
}

_append_to_pkgconfpath() {
	_common_append PKG_CONFIG_PATH "$1"
}

# From http://stackoverflow.com/a/4025065/96454, as of 15 April 2012
_vercmp () {
    if [[ $1 == $2 ]]
    then
        return 0
    fi
    local IFS=.
    local i ver1=($1) ver2=($2)
    # fill empty fields in ver1 with zeros
    for ((i=${#ver1[@]}; i<${#ver2[@]}; i++))
    do
        ver1[i]=0
    done
    for ((i=0; i<${#ver1[@]}; i++))
    do
        if [[ -z ${ver2[i]} ]]
        then
            # fill empty fields in ver2 with zeros
            ver2[i]=0
        fi
        if ((10#${ver1[i]} > 10#${ver2[i]}))
        then
            return 1
        fi
        if ((10#${ver1[i]} < 10#${ver2[i]}))
        then
            return 2
        fi
    done
    return 0
}

_prog_exists () {
	if type -p "$1" &>/dev/null; then
		return 0
	else
		return 1
	fi
}

