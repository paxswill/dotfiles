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
