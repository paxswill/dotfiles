source $HOME/.dotfiles/util/common.sh

_configure_android() {
	# Android SDK (non-OS X)
	if [ -d /opt/android-sdk ]; then
		export ANDROID_SDK_ROOT="/opt/android-sdk"
		__append_to_path "${ANDROID_SDK_ROOT}/tools"
		__append_to_path "${ANDROID_SDK_ROOT}/platform-tools"
	fi
}

_configure_ccache() {
	# Enable ccache in Android if we have it, and set it up
	if which ccache >/dev/null; then
		if [ ! -z "$CCACHE_DIR" -a ! -d "$CCACHE_DIR" ]; then
			mkdir "$CCACHE_DIR"
		fi
		if [ ! -w "$CCACHE_DIR" ]; then
			unset CCACHE_DIR
		else
			export USE_CCACHE=1
			ccache -M 50G > /dev/null
		fi
	fi
}

_configure_cmf_krb5() {
	if [ -d /usr/krb5 ]; then
		__prepend_to_path "/usr/krb5/bin"
		__prepend_to_path "/usr/krb5/sbin"
	elif [ -d /usr/local/krb5 ]; then
		__prepend_to_path "/usr/local/krb5/bin"
		__prepend_to_path "/usr/local/krb5/sbin"
	fi
}

_configure_ec2() {
	# Set up Amazon EC2 keys
	if [ -d "$HOME/.ec2" ] && which ec2-cmd >/dev/null; then
		# EC2_HOME needs the jars directory. Right now I'm just using Homebrew, so
		# I'll need to add special handling if I use other platforms in the future.
		if which brew >/dev/null; then
			export EC2_HOME="$(brew --prefix ec2-api-tools)/jars"
		else
			echo "WARNING: ec2-cmd detected but no Homebrew."
		fi
		export EC2_PRIVATE_KEY="$(/bin/ls $HOME/.ec2/pk-*.pem)"
		export EC2_CERT="$(/bin/ls $HOME/.ec2/cert-*.pem)"
	fi
}

_configure_perlbrew() {
	if [ -s $HOME/perl5/perlbrew/etc/bashrc ]; then
		. $HOME/perl5/perlbrew/etc/bashrc
		# On modern systems setting MANPATH screws things up
		if [ "$(uname -s)" = "Darwin" ]; then
			unset MANPATH
		fi
	fi
}

_configure_rvm() {
	if [ -s "$HOME/.rvm/scripts/rvm" ]; then
		source "$HOME/.rvm/scripts/rvm"
	fi
}

_configure_virtualenv_wrapper() {
	# Pull in virtualenvwrapper
	local wrapper_source=$(which virtualenvwrapper.sh >/dev/null 2>&1)
	if ! [ -z $wrapper_source ] && [ -s $wrapper_source ]; then
		# Use python3
		if which python3 >/dev/null 2>&1; then
			export VIRTUALENVWRAPPER_PYTHON=$(which python3)
		fi
		# Set up the working directories
		if [ -d "$HOME/Development/Python" ]; then
			export PROJECT_HOME="$HOME/Development/Python"
		else
			export PROJECT_HOME="$HOME/Development"
			if ! [ -d $PROJECT_HOME ]; then
				mkdir $PROJECT_HOME
			fi
		fi
		export WORKON_HOME="$HOME/.virtualenvs"
		if ! [ -d $WORKON_HOME ]; then
			mkdir $WORKON_HOME
		fi
		source $wrapper_source
	fi
}

configure_apps() {
	_configure_android
	unset _configure_android
	_configure_ccache
	unset _configure_ccache
	_configure_cmf_krb5
	unset _configure_cmf_krb5
	_configure_ec2
	unset _configure_ec2
	_configure_perlbrew
	unset _configure_perlbrew
	_configure_rvm
	unset _configure_rvm
	_configure_virtualenv_wrapper
	unset _configure_virtualenv_wrapper
}

