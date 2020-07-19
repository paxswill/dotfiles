# Putting this in a separate file as it's used by common.sh as well.
DOTFILES="${HOME}/.dotfiles"
source "${DOTFILES}/util/hosts.sh"

find_pkcs11() {
	# Try to find a PKCS11 Provider
	local PKCS11_PROVIDER=""
	local -a PKCS11_LIB_DIRS
	local -a PKCS11_PROVIDERS
	local SYSTYPE="$(get_systype)"
	if [ "$SYSTYPE" = "Darwin" ]; then
		PKCS11_PROVIDERS+=("libykcs11.dylib")
		PKCS11_LIB_DIRS+=("/Library/OpenSC/lib")
		PKCS11_LIB_DIRS+=("/usr/local/opt/opensc/lib")
		PKCS11_LIB_DIRS+=("/usr/local/lib")
	elif [ "$SYSTYPE" = "Linux" ]; then
		PKCS11_PROVIDERS+=("libykcs11")
		PKCS11_PROVIDERS+=("libykcs11.so")
		PKCS11_LIB_DIRS+=("/lib" "/lib64" "/usr/lib" "/usr/lib64")
		PKCS11_LIB_DIRS+=("/usr/lib/${HOSTTYPE}-linux-gnu")
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
	printf "%s" "$PKCS11_PROVIDER"
}
