# Path utility functions
__prepend_to_path() {
	cd "${1}"
	local __real_path="$(pwd -P)"
	export PATH="${__real_path}${PATH:+:}${PATH}"
	cd
}

__append_to_path() {
	cd "${1}"
	local __real_path="$(pwd -P)"
	export PATH="${PATH}${PATH:+:}${1}"
	cd
}

__prepend_to_manpath() {
	cd "${1}"
	local __real_path="$(pwd -P)"
	export MANPATH="${__real_path}${MANPATH:+:}${MANPATH}"
	cd
}

__append_to_manpath() {
	cd "${1}"
	local __real_path="$(pwd -P)"
	export MANPATH="${MANPATH}${MANPATH:+:}${__real_path}"
	cd
}

__prepend_to_libpath() {
	cd "${1}"
	local __real_path="$(pwd -P)"
	export LD_LIBRARY_PATH="${__real_path}${LD_LIBRARY_PATH:+:}${LD_LIBRARY_PATH}"
	cd
}

__append_to_libpath() {
	cd "${1}"
	local __real_path="$(pwd -P)"
	export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}${LD_LIBRARY_PATH:+:}${__real_path}"
	cd
}

__prepend_to_pkgconfpath() {
	cd "${1}"
	local __real_path="$(pwd -P)"
	export PKG_CONFIG_PATH="${__real_path}${PKG_CONFIG_PATH:+:}${PKG_CONFIG_PATH}"
	cd
}

__append_to_pkgconfpath() {
	cd "${1}"
	local __real_path="$(pwd -P)"
	export PKG_CONFIG_PATH="${PKG_CONFIG_PATH}${PKG_CONFIG_PATH:+:}${__real_path}"
	cd
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

