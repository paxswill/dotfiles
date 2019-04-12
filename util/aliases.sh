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
	if ls --color=auto -d . &>/dev/null; then
		alias ls='ls --color=auto -F'
	elif ls -G -d . &>/dev/null; then
		alias ls='ls -GF'
	fi
	alias ll='ls -lh'
	alias la='ls -A'
	alias lla='ls -lAh'
}

_alias_pasteboard() {
	# macOS spoiled me with easy access to `pbcopy` and `pbpaste`. They're
	# super simple commands, and basically the only flags they have are very
	# rarely used. The linux alternatives on the other hand are not as simple
	# to use. These aliases wrap the linux alternatives up so they're as simple
	#to use as `pbcopy` and `pbpaste`.
	if ! _prog_exists "pbcopy"; then
		if _prog_exists "xclip"; then
			alias pbcopy='xclip -i -selection clipboard'
			alias pbpaste='xclip -o -selection clipboard'
		fi
	fi
}

configure_aliases() {
	if [ ! -z "$PS1" ]; then
		_alias_grep
		_alias_ls
		_alias_pasteboard
	fi
}
