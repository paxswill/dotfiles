# Shell aliases

_alias_grep() {
	get_term_colors
	if [ $TERM_COLORS -ge 8 ]; then
		for GREPCMD in grep egrep fgrep; do
			if echo f | ${GREPCMD} --color=auto 'f' &>/dev/null; then
				alias ${GREPCMD}="${GREPCMD} --color=auto"
			fi
		done
	fi
}

_alias_ls() {
	# BSD ls uses -G for color, GNU ls uses --color=auto
	if ls -G -d . &>/dev/null; then
		alias ls='ls -GF'
	elif ls --color=auto -d . &>/dev/null; then
		alias ls='ls --color=auto -F'
	fi
	alias ll='ls -lh'
	alias la='ls -A'
	alias lla='ls -lAh'
}

configure_aliases() {
	if [ ! -z "$PS1" ]; then
		_alias_grep
		_alias_ls
	fi
}
