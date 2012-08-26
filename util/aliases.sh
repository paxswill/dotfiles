# Shell aliases

_alias_ls() {
	# BSD ls uses -G for color, GNU ls uses --color=auto
	if strings "$(which ls)" | grep 'GNU' > /dev/null; then
		alias ls='ls --color=auto'
	elif ls -G >/dev/null 2>&1; then
		alias ls='ls -G'
	fi
	alias ll='ls -lh'
	alias la='ls -A'
	alias lla='ls -lAh'
}

_alias_grep() {
	for GREPCMD in grep egrep fgrep; do
		if echo f | ${GREPCMD} --color=auto 'f' >/dev/null 2>&1; then
			alias ${GREPCMD}="${GREPCMD} --color=auto"
		fi
	done
}

configure_aliases() {
	_alias_ls
	unset _alias_ls
	_alias_grep
	unset _alias_grep
	unset configure_aliases
}
