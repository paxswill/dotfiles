# OS based configuration

_configure_darwin() {
	# Only use MacPorts if we don't have Homebrew
	if ! which brew > /dev/null; then
		if [ -d /opt/local/bin -a -d /opt/local/sbin ]; then
				__append_to_path "/opt/local/bin:/opt/local/sbin"
		fi
		if [ -d /opt/local/share/man ]; then
			__append_to_manpath "/opt/local/share/man"
		fi
	fi
	# Homebrew setup
	if type brew >/dev/null 2>&1; then
		# Move homebrew to the front of the path if we have it
		local BREW_PREFIX=$(brew --prefix)
		if [ -d "${BREW_PREFIX}/sbin" ]; then
			__prepend_to_path "${BREW_PREFIX}/sbin"
		fi
		__prepend_to_path "${BREW_PREFIX}/bin"
		if brew list ruby >/dev/null; then
			if [ -d "$(brew --prefix ruby)/bin" ]; then
				__append_to_path "$(brew --prefix ruby)/bin"
			fi
		fi
		# Use brewed pythons if we have them
		for temp_python in python3 pypy python; do
			if brew list $temp_python >/dev/null && \
				[ -d "$BREW_PREFIX/share/$temp_python" ]; then
				__append_to_path "$BREW_PREFIX/share/$temp_python"
			fi
		done
		# Add Node.js modules to PATH
		if [ -d "$(brew --prefix)/lib/node_modules" ]; then
			__append_to_path "$(brew --prefix)/lib/node_modules"
		fi
	fi
	# Add the OpenCL offline compiler if it's there
	if [ -e /System/Library/Frameworks/OpenCL.framework/Libraries/openclc ]; then
		alias openclc='/System/Library/Frameworks/OpenCL.framework/Libraries/openclc'
	fi
	# Add the "hidden" airport command
	if [ -e '/System/Library/PrivateFrameworks/Apple80211.framework/Versions/A/Resources/airport' ]; then
		__append_to_path "/System/Library/PrivateFrameworks/Apple80211.framework/Versions/A/Resources"
	fi
	# Man page to Preview
	if which ps2pdf 2>&1 > /dev/null; then
		__vercmp "$(sw_vers -productVersion)" "10.7"
		if [[ $? == 2 ]]; then
			pman_open_bg="-g"
		fi
		pman () {
			man -t "${@}" | ps2pdf - - | open ${pman_open_bg} -f -a /Applications/Preview.app
		}
	fi
	# Increase the maximum number of open file descriptors
	# This is primarily for the Android build process
	if [ $(ulimit -n) -lt 1024 ]; then
		ulimit -S -n 1024
	fi
	# Define JAVA_HOME on OS X
	export JAVA_HOME=$(/usr/libexec/java_home)
}

_configure_debian() {
	# Set PATH to include system directories
	export PATH=/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/bin:/sbin
	export JAVA_HOME=/usr/lib/jvm/default_java
}

_configure_linux() {
	if type lsb_release >/dev/null 2>&1; then
		DISTRO=$(lsb_release -i)
		DISTRO=${DISTRO##*:}
	fi
	export DISTRO
	if [ $DISTRO = "Debian" ]; then
		_configure_debian
	elif [ $DISTRO = "Ubuntu" ]; then
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

