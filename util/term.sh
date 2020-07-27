# Common terminal functions
source ~/.dotfiles/util/hosts.sh

# FreeBSD's tput uses termcap names and not the basic capability names that
# ncurses tput (which is used by seemingly everyone else). This might be
# changing at some point, see
# https://bugs.freebsd.org/bugzilla/show_bug.cgi?id=214709
# These functions will call tput with the appropriate name for the appropriate
# platform when called using the capability name (i.e. like ncurses tput).

_tput() {
	# Ensure SYSTYPE is set
	if [ $(get_systype) = "FreeBSD" ]; then
		case $1 in
			setab)
				tput AB "${@:2}";;
			setaf)
				tput AF "${@:2}";;
			sgr0)
				tput me "${@:2}";;
			bold)
				tput md "${@:2}";;
			dim)
				tput mh "${@:2}";;
			colors)
				tput Co "${@:2}";;
			cols)
				tput co "${@:2}";;
			cuf)
				tput RI "${@:2}";;
			cub)
				tput LE "${@:2}";;
			cuu)
				tput UP "${@:2}";;
			cud)
				tput DO "${@:2}";;
			# For unhandled capabilities just pass them through. This is fine
			# for those capabilites which have the same names in both databses
			# (os, sc, rc).
			*)
				tput "${@}";;
		esac
	else
		tput "${@}"
	fi
}

if [ ! -z "$PS1" ]; then
	# Define common control sequences
	COLOR_RESET="$(_tput sgr0)"
	# This is the muted color
	MUTED_COLOR="$(_tput bold)$(_tput setaf 2)"
fi

_configure_host_color() {
	# Generate a color that is semi-unique for this host
	parse_fqdn
	# Normalize hostnames to only lower-case letters, numbers, and '-',
	# i.e. proper hostnames
	local name="$(printf "%s" "${HOST,,}" | tr -d -c "a-z0-9-")"
	# BSD includes md5, GNU and Solaris include md5sum
	case "$name" in
		thor)
			HOST_COLOR="$(_tput setab 0)$(_tput setaf 1)";;
		odin)
			HOST_COLOR="$(_tput setab 0)$(_tput setaf 2)";;
		venus)
			HOST_COLOR="$(_tput setab 0)$(_tput setaf 3)";;
		tyr)
			HOST_COLOR="$(_tput setab 0)$(_tput setaf 4)";;
		heimdall)
			HOST_COLOR="$(_tput setab 0)$(_tput setaf 5)";;
		baldur)
			HOST_COLOR="$(_tput setab 0)$(_tput setaf 6)";;
		freya)
			HOST_COLOR="$(_tput setab 0)$(_tput setaf 7)";;
		*)
			if _prog_exists md5; then
				hashed_host=$(printf $name | md5)
			elif _prog_exists md5sum; then
				hashed_host=$(printf $name | md5sum)
			fi
			if [ ! -z "$hashed_host" ]; then
				# Sum all the digits modulo 9 (ANSI colors 31-37 normal, and 31 and 35
				# bright. Solarized only has those two bright colors as actual colors)
				sum=0
				for ((i=0;i<32;++i)); do
					sum=$(($sum + 0x${hashed_host:$i:1}))
				done
				sum=$((sum % 9))
				if [ $sum -eq 7 ]; then
					# Orange in Solarized
					HOST_COLOR="$(_tput bold)$(_tput setaf 1)"
				elif [ $sum -eq 8 ]; then
					HOST_COLOR="$(_tput bold)$(_tput setaf 5)"
				else
					HOST_COLOR="$(_tput setaf $((1 + $sum)))"
				fi
			else
				# Default to no color
				HOST_COLOR=""
			fi
	esac
}

_configure_less_colors() {
	# Prettify man pages
	# Bold will be cyan
	export LESS_TERMCAP_mb=$'\E[36m'
	export LESS_TERMCAP_md=$'\E[36m'
	export LESS_TERMCAP_me=$'\E[0m'
	# Standaout uses a highlighted background and foreground
	export LESS_TERMCAP_so=$'\E[1;40m'
	export LESS_TERMCAP_se=$'\E[0m'
	# Instead of underlines, use the highlighted back and foreground
	export LESS_TERMCAP_us=$'\E[1;34;40m'
	export LESS_TERMCAP_ue=$'\E[0m'
}

get_term_colors() {
	if [ -z $TERM_COLORS ] && [ ! -z "$PS1" ]; then
		if _prog_exists tput; then
			TERM_COLORS=$(_tput colors)
		else
			case "$TERM" in
				xterm|screen)
					TERM_COLORS=8
					;;
				*-256colors)
					TERM_COLORS=256
					;;
			esac
		fi
	fi
	if [ -z $TERM_COLORS ] || ! [[ "$TERM_COLORS" =~ ^[0-9]+$ ]]; then
		TERM_COLORS=0
	fi
}

configure_colors() {
	get_term_colors
	if [ $TERM_COLORS -ge 8 ]; then
		_configure_host_color
		_configure_less_colors
	fi
}

