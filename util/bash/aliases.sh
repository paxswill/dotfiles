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

_alias_1password() {
	if _prog_exists "op"; then
		# Skipping a separator between 'op' and 'signin' because I'm lazy and
		# don't want to reach my fingers over and type that.
		alias opsignin='eval $(op signin my)'
	fi
}

_alias_pasteboard() {
	# macOS spoiled me with easy access to `pbcopy` and `pbpaste`. They're
	# super simple commands, and basically the only flags they have are very
	# rarely used. The linux alternatives on the other hand are not as simple
	# to use. These aliases wrap the linux alternatives up so they're as simple
	# to use as `pbcopy` and `pbpaste`.
	if ! _prog_exists "pbcopy"; then
		if _prog_exists "xclip"; then
			alias pbcopy='xclip -i -selection clipboard'
			alias pbpaste='xclip -o -selection clipboard'
		fi
	fi
}

_alias_reset() {
	# A quick alias to print the control sequence to disable mouse position
	# reporting. An example of when this is useful is when tmux doesn't disable
	# it when being closed. If there's a spew of garbage when clicking,
	# dragging, etc, run this alias to disable it. iTerm2 can disable it with a
	# menu item, but this is a bit quicker, and also works on things other than
	# iTerm (for example, Windows Terminal)
	alias resetmouse='printf "\e[?1000l"'
}

configure_aliases() {
	if [ ! -z "$PS1" ]; then
		_alias_grep
		_alias_ls
		_alias_1password
		_alias_pasteboard
		_alias_reset
	fi
}
