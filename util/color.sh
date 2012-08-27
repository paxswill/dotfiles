# Common color functions

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
	# BSD includes md5, GNU includes md5sum
	if which md5 >/dev/null 2>&1; then
		hashed_host=$(hostname | md5)
	elif which md5sum >/dev/null 2>&1; then
		hashed_host=$(hostname | md5sum | grep -o -e '^[0-9a-f]*')
	fi
	# BSD has jot for generating sequences, GNU has seq
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

configure_colors() {
	case "$TERM" in
		xterm*|rxvt*)
			_configure_host_color
			_configure_less_colors
			;;
	esac
	unset _configure_host_color
	unset _configure_less_colors
	unset configure_colors
}

