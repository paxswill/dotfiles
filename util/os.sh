# OS based configuration

_configure_darwin() {
	# Check for Homebrew, then fall back to MacPorts
	if _prog_exists brew; then
		# Homebrew setup
		# Move homebrew to the front of the path if we have it
		local BREW_PREFIX=$(brew --prefix)
		prepend_to_path "${BREW_PREFIX}/sbin"
		prepend_to_path "${BREW_PREFIX}/bin"
		if brew list ruby &>/dev/null; then
			append_to_path "$(brew --prefix ruby)/bin"
		fi
	elif [ -d /opt ]; then
		# MacPorts
		append_to_path "/opt/local/bin"
		append_to_path "/opt/local/sbin"
	fi
	# Add the OpenCL offline compiler if available
	if [ -e /System/Library/Frameworks/OpenCL.framework/Libraries/openclc ]; then
		append_to_path "/System/Library/Frameworks/OpenCL.framework/Libraries"
	fi
	# Add the "hidden" airport command
	if [ -e '/System/Library/PrivateFrameworks/Apple80211.framework/Versions/A/Resources/airport' ]; then
		append_to_path "/System/Library/PrivateFrameworks/Apple80211.framework/Versions/A/Resources"
	fi
	# Man page to Preview
	if [ ! -z "$PS1" ]; then
		if _prog_exists ps2pdf; then
			_vercmp "$(sw_vers -productVersion)" "10.7"
			if [[ $? == 2 ]]; then
				pman_open_bg="-g"
			fi
			pman () {
				man -t "${@}" | ps2pdf - - | open ${pman_open_bg} -f -a /Applications/Preview.app
			}
		fi
	fi
	# Increase the maximum number of open file descriptors
	# This is primarily for the Android build process
	if [ $(ulimit -n) -lt 1024 ]; then
		ulimit -S -n 1024
	fi
	# Define JAVA_HOME on OS X
	if [ -d \
		/System/Library/Frameworks/JavaVM.framework/Versions/Current/Headers ];
	then
		export JAVA_HOME=$(/usr/libexec/java_home)
	fi
}

_configure_debian() {
	# Set PATH to include system directories
	prepend_to_path /usr/local/sbin
	prepend_to_path /usr/local/bin
	prepend_to_path /usr/sbin
	prepend_to_path /usr/bin
	prepend_to_path /sbin
	prepend_to_path /bin
	append_to_path /usr/local/games
	append_to_path /usr/games
	export JAVA_HOME=/usr/lib/jvm/default_java
}

_configure_linux() {
	if _prog_exists lsb_release; then
		DISTRO=$(lsb_release -i)
		DISTRO=${DISTRO##*:?}
	fi
	export DISTRO
	if [ "$DISTRO" = "Debian" ]; then
		_configure_debian
	elif [ "$DISTRO" = "Ubuntu" ]; then
		_configure_ubuntu
	fi
}

_configure_ubuntu() {
	export JAVA_HOME=/usr/lib/jvm/default_java
}

configure_os() {
	case ${SYSTYPE:=$(uname -s)} in
		Darwin)
			_configure_darwin;;
		Linux)
			_configure_linux;;
	esac
}

