# Host specific customizations
source ~/.dotfiles/util/bash/common.sh

get_systype() {
	# Set an exported SYSTYPE variable for configuring a the environment based
	# (roughly) on the current OS. This is the output from `uname -s`, which is
	# the name of the current kernel. Typical values include Linux, Darwin, and
	# SunOS.
	if ! [ -v SYSTYPE ]; then
		# Export SYSTYPE and declare it as readonly
		declare -grx SYSTYPE="$(uname -s)"
	fi
}

parse_fqdn() {
	# Parse out the hostname and domain from the fully-qualified domain name
	# (FQDN) of the current system. These are then exported as the HOST and
	# DOMAIN variables. The hostname is *not* exported as HOSTNAME as that
	# variable is set by bash, and is usually just the output of `hostname`.
	get_systype
	if [ -z $HOST ] && [ -z $DOMAIN ]; then
		# Get some information to base later decisions on
		# Obtain and normalize the host name and domain name
		if [ $HOSTNAME = ${HOSTNAME#*.} ]; then
			if hostname --short &>/dev/null && type dnsdomainname &>/dev/null; then
				# Newer versions of net-tools on Linux have a short option and
				# a separate command for the dns domain. This is preferred over
				# `hostname -f` as that can return "localhost" in some
				# situations
				HOST="$(hostname --short)"
				DOMAIN="$(dnsdomainname)"
			else
				if [ "${SYSTYPE:=$(uname -s)}" = "SunOS" ] && type getent &>/dev/null; then
					# Solaris uses getent for reaching getting the full hostname
					hostname=$(getent hosts $HOSTNAME | awk '{print $2}')
				elif hostname -f &>/dev/null; then
					# Beware, this can return "localhost" when you don't expect
					# it!
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
			fi
		else
			DOMAIN=${HOSTNAME#*.}
			HOST=${HOSTNAME%%.*}
		fi
		# Mark HOST and DOMAIN as readonly and exported
		declare -rx HOST DOMAIN
	fi
}

configure_hosts() {
	parse_fqdn
	# Configure for host
	# Skipped for now, no host/domain-specific customizations needed
}

