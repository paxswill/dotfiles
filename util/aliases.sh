# Shell aliases
source $HOME/.dotfiles/util/color.sh

_alias_grep() {
	get_term_colors
	if [ $TERM_COLORS -ge 8 ]; then
		for GREPCMD in grep egrep fgrep; do
			if echo f | ${GREPCMD} --color=auto 'f' >/dev/null 2>&1; then
				alias ${GREPCMD}="${GREPCMD} --color=auto"
			fi
		done
	fi
}

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

configure_aliases() {
	_alias_grep
	unset _alias_grep
	_alias_ls
	unset _alias_ls
	unset configure_aliases
}
