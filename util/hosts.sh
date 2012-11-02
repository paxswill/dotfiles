# Host specific customizations

_configure_cmf() {
	if [ "$SYSTYPE" = "Darwin" ]; then
		# PATH on CMF OS X machines is getting munged
		unset PATH
		eval "$(/usr/libexec/path_helper -s)"
		# Re-add ~/local/bin, unless there's /scratch/local/bin
		local MY_BIN="/afs/cmf.nrl.navy.mil/users/wross/local/bin"
		if [ -d "/scratch/wross/local/bin" ]; then
			__prepend_to_path "/scratch/wross/local/bin"
		elif [ -d "${MY_BIN}" ]; then
			__prepend_to_path "${MY_BIN}"
		fi
		# Staging/Linking up packages with Homebrew can fail when crossing file
		# system boundaries. This forces the homebrew temporary folder to be
		# on the same FS as the destination.
		if which brew > /dev/null; then
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
	if [ -z "$SCRATCH_VOLUME" -a -d /scratch -a -w /scratch ]; then
		export CCACHE_DIR=/scratch/ccache

	fi
	# AFS Resources
	if [ -d "/afs/cmf.nrl.navy.mil/@sys/bin" ]; then
		__append_to_path "/afs/cmf.nrl.navy.mil/@sys/bin"
	fi
}

_configure_oducs() {
	local LOCALNAME
	if [ "$HOST" = "procyon" ] || [ "$HOST" = "capella" ] || [ "$HOST" = "antares" ] || [ "$HOST" = "vega" ]; then
		LOCALNAME="fast-sparc"
		PATH=/usr/local/bin:/usr/local/ssl/bin:/usr/local/sunstudio/bin:/usr/local/sunstudio/netbeans/bin:/usr/sfw/bin:/usr/java/bin:/usr/bin:/bin:/usr/ccs/bin:/usr/ucb:/usr/dt/bin:/usr/X11/bin:/usr/X/bin:/usr/lib/lp/postscript
		LD_LIBRARY_PATH=/usr/local/lib/mysql:/usr/local/lib:/usr/local/ssl/lib:/usr/local/sunstudio/lib:/usr/sfw/lib:/usr/java/lib:/usr/lib:/lib:/usr/ccs/lib:/usr/ucblib:/usr/dt/lib:/usr/X11/lib:/usr/X/lib:/opt/local/oracle_instant_client/
		MANPATH=/usr/local/man:/usr/local/ssl/ssl/man:/usr/local/sunstudio/man:/usr/sfw/man:/usr/java/man:/usr/man:/usr/dt/man:/usr/X11/man:/usr/X/man
		PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:/usr/sfw/lib/pkgconfig:/usr/X/lib/pkgconfig
		JAVA_HOME=/usr/java
	elif [ "$HOST" = "atria" ] || [ "$HOST" = "sirius" ]; then
		LOCALNAME="fast-ubuntu"
	elif [ "$HOST" = "nvidia" ]; then
		LOCALNAME="nv-s1070"
	elif [ "$HOST" = "cuda" ] || [ "$HOST" = "tesla" ] || [ "$HOST" = "stream" ]; then
		LOCALNAME="nv-c870"
	elif [ "$HOST" = "smp" ]; then
		LOCALNAME="smp"
	fi
    export LOCAL_PREFIX="$HOME/local/$LOCALNAME"
	# CUDA paths
	if [ -d /usr/local/cuda ]; then
		__append_to_path "/usr/local/cuda/computeprof/bin"
		__append_to_path "/usr/local/cuda/bin"
		__append_to_libpath "/usr/local/cuda/lib"
		__append_to_libpath "/usr/local/cuda/lib64"
	fi
	__prepend_to_path "${LOCAL_PREFIX}/bin"
	__prepend_to_path "${LOCAL_PREFIX}/sbin"
	__prepend_to_libpath "${LOCAL_PREFIX}/lib"
	__prepend_to_libpath "${LOCAL_PREFIX}/lib64"
	__prepend_to_pkgconfpath "${LOCAL_PREFIX}/lib/pkgconfig"
	__prepend_to_pkgconfpath "${LOCAL_PREFIX}/lib64/pkgconfig"
	# Autoconf Site configuration
	export CONFIG_SITE=$HOME/local/config.site
}

parse_fqdn() {
	if [ -z $HOST ] && [ -z $DOMAIN ]; then
		# Get some information to base later decisions on
		# Obtain and normalize the host name and domain name
		if [ $HOSTNAME = ${HOSTNAME#*.} ]; then
			if [ "${SYSTYPE:=$(uname -s)}" = "SunOS" ] && type getent >/dev/null 2>&1; then
				hostname=$(getent hosts $HOSTNAME | awk '{print $2}')
			elif hostname -f >/dev/null 2>&1; then
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
		*.cs.odu.edu)
			_configure_oducs;;
		*.cmf.nrl.navy.mil)
			_configure_cmf;;
	esac
}

