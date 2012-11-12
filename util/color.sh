# Common color functions

source $HOME/.dotfiles/util/hosts.sh

# Define common control sequences
CSI_START="\[\033["
CSI_END="\]"
SGR_END="m$CSI_END"
SGR_RESET=0
SGR_BOLD=1
SGR_ITALIC=3
SGR_UNDERLINE=4
FG_BLACK="30"
FG_RED="31"
FG_GREEN="32"
FG_YELLOW="33"
FG_BLUE="34"
FG_MAGENTA="35"
FG_CYAN="36"
FG_WHITE="37"
BG_BLACK="40"
BG_RED="41"
BG_GREEN="42"
BG_YELLOW="43"
BG_BLUE="44"
BG_MAGENTA="45"
BG_CYAN="46"
BG_WHITE="47"
COLOR_RESET="${CSI_START}${SGR_RESET}${SGR_END}"

_configure_host_color() {
	# Generate a color that is semi-unique for this host
	parse_fqdn
	# Normalize hostnames to only lower-case letters, numbers, and '-',
	# i.e. proper hostnames
	local name="$(printf $HOST | tr [:upper:] [:lower:] | tr -d -c "a-z0-9-")"
	# BSD includes md5, GNU and Solaris include md5sum
	if which md5 >/dev/null 2>&1; then
		hashed_host=$(printf $name | md5)
	elif which md5sum >/dev/null 2>&1; then
		hashed_host=$(printf $name | md5sum)
		hashed_host=${hashed_host:0:32}
	fi
	# BSD has jot for generating sequences, GNU has seq, and Solaris has both.
	if which jot >/dev/null 2>&1; then
		hashed_seq="$(jot ${#hashed_host} 0)"
	elif which seq >/dev/null 2>&1; then
		hashed_seq="$(seq 0 $((${#hashed_host} - 1)))"
	fi
	if [ ! -z "$hashed_host" -a ! -z "$hashed_seq" ]; then
		# Sum all the digits modulo 9 (ANSI colors 31-37 normal, and 31 and 35
		# bright. Solarized only has those two bright colors as actual colors)
		sum=0
		for i in $hashed_seq; do
			sum=$(($sum + 0x${hashed_host:$i:1}))
		done
		sum=$((sum % 9))
		if [ $sum -eq 7 ]; then
			HOST_COLOR="${CSI_START}${SGR_BOLD};${FG_RED}${SGR_END}"
		elif [ $sum -eq 8 ]; then
			HOST_COLOR="${CSI_START}${SGR_BOLD};${FG_MAGENTA}${SGR_END}"
		else
			HOST_COLOR="${CSI_START}$((31 + $sum))${SGR_END}"
		fi
	else
		# Default to no color
		HOST_COLOR=""
	fi
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
	if [ -z $TERM_COLORS ] && which infocmp >/dev/null 2>&1; then
		TERM_COLORS=$(infocmp -I -1 $TERM | grep 'colors')
		TERM_COLORS=${TERM_COLORS#*colors#}
		TERM_COLORS=${TERM_COLORS%,}
	fi
	if [ -z $TERM_COLORS ] || ! [[ "$TERM_COLORS" =~ ^[0-9]$ ]]; then
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

