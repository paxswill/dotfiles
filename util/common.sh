# Path utility functions
__prepend_to_path() {
	if [ -d "${1}" ]; then
		pushd "${1}" >/dev/null
		local __real_path="$(pwd -P)"
		export PATH="${__real_path}${PATH:+:}${PATH}"
		popd >/dev/null
	fi
}

__append_to_path() {
	if [ -d "${1}" ]; then
		pushd "${1}" >/dev/null
		local __real_path="$(pwd -P)"
		export PATH="${PATH}${PATH:+:}${1}"
		popd >/dev/null
	fi
}

__prepend_to_manpath() {
	if [ -d "${1}" ]; then
		pushd "${1}" >/dev/null
		local __real_path="$(pwd -P)"
		export MANPATH="${__real_path}${MANPATH:+:}${MANPATH}"
		popd >/dev/null
	fi
}

__append_to_manpath() {
	if [ -d "${1}" ]; then
		pushd "${1}" >/dev/null
		local __real_path="$(pwd -P)"
		export MANPATH="${MANPATH}${MANPATH:+:}${__real_path}"
		popd >/dev/null
	fi
}

__prepend_to_libpath() {
	if [ -d "${1}" ]; then
		pushd "${1}" >/dev/null
		local __real_path="$(pwd -P)"
		export LD_LIBRARY_PATH="${__real_path}${LD_LIBRARY_PATH:+:}${LD_LIBRARY_PATH}"
		popd >/dev/null
	fi
}

__append_to_libpath() {
	if [ -d "${1}" ]; then
		pushd "${1}" >/dev/null
		local __real_path="$(pwd -P)"
		export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}${LD_LIBRARY_PATH:+:}${__real_path}"
		popd >/dev/null
	fi
}

__prepend_to_pkgconfpath() {
	if [ -d "${1}" ]; then
		pushd "${1}" >/dev/null
		local __real_path="$(pwd -P)"
		export PKG_CONFIG_PATH="${__real_path}${PKG_CONFIG_PATH:+:}${PKG_CONFIG_PATH}"
		popd >/dev/null
	fi
}

__append_to_pkgconfpath() {
	if [ -d "${1}" ]; then
		pushd "${1}" >/dev/null
		local __real_path="$(pwd -P)"
		export PKG_CONFIG_PATH="${PKG_CONFIG_PATH}${PKG_CONFIG_PATH:+:}${__real_path}"
		popd >/dev/null
	fi
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

