

function prompt-length() {
	emulate -L zsh
	local -i x y=${#1} m
	if (( y )); then
		while (( ${${(%):-$1%$y(l.1.0)}[-1]} )); do
			x=y
			(( y *= 2 ))
		done
		while (( y > x + 1 )); do
			(( m = x + (y - x) / 2 ))
			(( ${${(%):-$1%$m(l.x.y)}[-1]} = m ))
		done
	fi
	echo $x
}

function fill-line() {
	local left_len=$(prompt-length $1)
	local right_len=$(prompt-length $2)
	local pad_len=$((COLUMNS - left_len - right_len - 1))
	local pad=${(pl.$pad_len.. .)}  # pad_len spaces
	echo ${1}${pad}${2}
}

function set-prompt() {
	# Put a basic prompt with username, hostname (first component) and the
	# current directory name. The prompt character will be printed in a precmd,
	# to handle resizing nicely. Source:
	# https://superuser.com/a/395784
	# Put the current timestamp at the right side.
	local top_left='[%n@%m:%1~]'
	local top_right='%*'
	local bottom_left='%# '
	# Skipping bottom_right; I don't use it
	PROMPT="$(fill-line "$top_left" "$top_right")"$'\n'$bottom_left
}

function _configure_prompt() {
	autoload -Uz add-zsh-hook
	add-zsh-hook -D precmd set-prompt
	add-zsh-hook precmd set-prompt
}
