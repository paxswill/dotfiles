# Host specific customizations
source ~/.dotfiles/util/common.sh

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
	# Skipped for now, no host/domain-specific customizations needed
}

