# Path utility functions

__common_prepend() {
	# $1 is the name of the variable to prepend to
	# $2 is the directory to prepend
	if [ -d "$2" ]; then
		# Disambiguate the directory
		pushd "$2" >/dev/null
		local realpath="$(/bin/pwd -P)"
		popd >/dev/null
		# Remove any old instances of the path from the current value
		local oldpath="$(eval "printf \"\$$1\"")"
		oldpath="${oldpath:+:}${oldpath}${oldpath:+:}"
		local newpath="${oldpath/":${2}:"/:}"
		newpath="${realpath}${newpath%:}"
		eval "export $1='$newpath'"
	fi
}

__common_append() {
	# $1 is the name of the variable to append to
	# $2 is the directory to append
	if [ -d "$2" ]; then
		# Disambiguate the directory
		pushd "$2" >/dev/null
		local realpath="$(/bin/pwd -P)"
		popd >/dev/null
		# Remove any old instances of the path from the current value
		local oldpath="$(eval "printf \"\$$1\"")"
		oldpath="${oldpath:+:}${oldpath}${oldpath:+:}"
		local newpath="${oldpath/":${2}:"/:}"
		newpath="${newpath#:}${realpath}"
		eval "export $1='$newpath'"
	fi
}

__prepend_to_path() {
	__common_prepend PATH "$1"
}

__append_to_path() {
	__common_append PATH "$1"
}

__prepend_to_manpath() {
	__common_prepend MANPATH "$1"
}

__append_to_manpath() {
	__common_append MANPATH "$1"
}

__prepend_to_libpath() {
	__common_prepend LD_LIBRARY_PATH "$1"
}

__append_to_libpath() {
	__common_append LD_LIBRARY_PATH "$1"
}

__prepend_to_pkgconfpath() {
	__common_prepend PKG_CONFIG_PATH "$1"
}

__append_to_pkgconfpath() {
	__common_append PKG_CONFIG_PATH "$1"
}

# From http://stackoverflow.com/a/4025065/96454, as of 15 April 2012
__vercmp () {
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

cleanup_common() {
	unset __prepend_to_path
	unset __append_to_path
	unset __prepend_to_manpath
	unset __append_to_manpath
	unset __prepend_to_libpath
	unset __append_to_libpath
	unset __prepend_to_pkgconfpath
	unset __append_to_pkgconfpath
	unset __vercmp
	unset cleanup_common
}

