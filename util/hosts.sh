# Host specific customizations
source ~/.dotfiles/util/common.sh

_configure_cmf() {
	if [ "$SYSTYPE" = "Darwin" ]; then
		# PATH on CMF OS X machines is getting munged
		unset PATH
		eval "$(/usr/libexec/path_helper -s)"
		# Re-add ~/local/bin, unless there's /scratch/local/bin
		local MY_BIN="/afs/cmf.nrl.navy.mil/users/wross/local/bin"
		if [ -d "/scratch/wross/local/bin" ]; then
			prepend_to_path "/scratch/wross/local/bin"
		elif [ -d "${MY_BIN}" ]; then
			prepend_to_path "${MY_BIN}"
		fi
		# Staging/Linking up packages with Homebrew can fail when crossing file
		# system boundaries. This forces the homebrew temporary folder to be
		# on the same FS as the destination.
		if _prog_exists brew; then
			export HOMEBREW_TEMP="$(brew --prefix)/.tmp/homebrew"
			if ! [ -d "${HOMEBREW_TEMP}" ]; then
				mkdir -p "${HOMEBREW_TEMP}"
			fi
		fi
		if [ -d /scratch/wross ]; then
			export VAGRANT_HOME=/scratch/wross/.vagrantd
			mkdir -p $VAGRANT_HOME
		fi
	fi
	# Don't put caches on AFS if we can help it
	if [ -z "$SCRATCH_VOLUME" -a -d /scratch -a -w /scratch ]; then
		export CCACHE_DIR=/scratch/ccache
		export PIP_DOWNLOAD_CACHE=/scratch/pip-cache
	fi
	# AFS Resources
	if [ -d "/afs/cmf.nrl.navy.mil/@sys/bin" ]; then
		append_to_path "/afs/cmf.nrl.navy.mil/@sys/bin"
	fi
}

parse_fqdn() {
	if [ -z $HOST ] && [ -z $DOMAIN ]; then
		# Get some information to base later decisions on
		# Obtain and normalize the host name and domain name
		if [ $HOSTNAME = ${HOSTNAME#*.} ]; then
			if [ "${SYSTYPE:=$(uname -s)}" = "SunOS" ] && type getent &>/dev/null; then
				hostname=$(getent hosts $HOSTNAME | awk '{print $2}')
			elif hostname -f &>/dev/null; then
				hostname=$(hostname -f)
			else
				hostname=$HOSTNAME
			fi
			DOMAIN=${hostname#*.}
			HOST=${hostname%%.*}
			if [ $DOMAIN = $HOST ]; then
				DOMAIN=""
			fi
			unset hostname
		else
			DOMAIN=${HOSTNAME#*.}
			HOST=${HOSTNAME%%.*}
		fi
		export SYSTYPE
		export HOST
		export DOMAIN
	fi
}

configure_hosts() {
	parse_fqdn
	# Configure for host
	case $HOST.$DOMAIN in
		*.cmf.nrl.navy.mil)
			_configure_cmf;;
	esac
}

