# Common terminal functions
source ~/.dotfiles/util/hosts.sh

# FreeBSD's tput uses termcap names and not the basic capability names that
# ncurses tput (which is used by seemingly everyone else). This might be
# changing at some point, see
# https://bugs.freebsd.org/bugzilla/show_bug.cgi?id=214709
# These functions will call tput with the appropriate name for the appropriate
# platform when called using the capability name (i.e. like ncurses tput).

# SYSTYPE is used in every call to _tput, so call it once and get it over with
get_systype

_tput() {
	# Ensure SYSTYPE is set
	if [ $SYSTYPE = "FreeBSD" ]; then
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
	# Red and green used repeatedly in a few place
	RED_COLOR="$(_tput setaf 1)"
	GREEN_COLOR="$(_tput setaf 2)"
fi

_get_host_color() {
	# Figure out how many colors we can use. The hostname to derive a color
	# from should be given as the first (and only) argument. The hostname
	# should already be normalized (only lower case and only valid hostname
	# characters).
	local -i MAX_COLORS
	if (( $TERM_COLORS >= 8 && $TERM_COLORS < 16 )); then
		# For 8-color Solarized, the ANSI colors line up with the reduced
		# Solarized colors, so we can use all of them (except for the color
		# used for normal text, so 8 - 1).
		MAX_COLORS=7
	elif (( $TERM_COLORS >= 16 )); then
		# For 16-color solarized, we only have a few more colors available
		# as Solarized uses most of the extra colors for the extra "base"
		# colors. The only actual colors are violet (bright magenta in
		# ANSI), and orange (bright red in ANSI).
		MAX_COLORS=9
	fi
	# Now hash the input name, and add all of the digits together modulo
	# `2 * MAX_COLORS` (The we can double the number of maximum colors by using
	# standout mode, which is just reverse and bold modes at the same time).
	# BSD includes md5, GNU and Solaris include md5sum
	if _prog_exists md5; then
		hashed_host=$(printf "%s" "$1" | md5)
	elif _prog_exists md5sum; then
		hashed_host=$(printf "%s" "$1" | md5sum)
	fi
	# Handle the case where there isn't an MD5 program
	if [ ! -z "$hashed_host" ]; then
		# Sum all the digits modulo MAX_COLORS
		local -i SUM=0
		for ((i=0; i<32; ++i)); do
			SUM=$(( $SUM + 0x${hashed_host:$i:1} ))
		done
		SUM=$(( $SUM % ($MAX_COLORS * 2) ))
		local -i COLOR=$(( $SUM % $MAX_COLORS))
		# If we're in the "extra" colors, enable standout mode
		if (( $SUM > $MAX_COLORS )); then
			_tput bold
			_tput rev
		fi
		# The "extra" colors (orange and violet) do not immediately follow the
		# other colors.
		case $COLOR in
			8)
				# Orange
				_tput setaf 9;;
			9)
				# Violet
				_tput setaf 13;;
			*)
				# Add 1 so that 0 (background in 8-color, highlighted
				# background in 16-color) is mapped to red, and so on
				_tput setaf $(( $COLOR + 1 ));;
		esac
	fi
	# No need to return anything for the case where there isn't a host color.
}

_configure_host_color() {
	# Generate a color that is semi-unique for this host
	parse_fqdn
	# Normalize hostnames to only lower-case letters, numbers, and '-',
	# i.e. proper hostnames
	local name="$(printf "%s" "${HOST,,}" | tr -d -c "a-z0-9-")"
	HOST_COLOR="$(_get_host_color "$name")"
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
		declare -gi TERM_COLORS
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

