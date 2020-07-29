
source ~/.dotfiles/util/term.sh

_bash_prompt() {
	# Save the value of the last exit status to color things later
	local LAST_STATUS=$?
	# All shells share a history (append the new history to the HISTFILE).
	# n.b. the history is *not* reloaded automatically, that requires a manual
	# invocation of `history -r`.
	history -a
	# This variable will keep track of the correction to apply for non-printed
	# characters (like color control codes)
	local -i OFFSET=0
	# Figure out if we're in a Python virtualenv or a Ruby env
	local ENVIRONMENT=""
	if [ ! -z "$VIRTUAL_ENV" ]; then
		ENVIRONMENT="$(basename ${VIRTUAL_ENV})"
	elif [ ! -z "$rvm_bin_path" ]; then
		ENVIRONMENT="$(rvm_bin_path)/rvm-prompt"
	fi
	# Display the environment in muted colors
	if [ ! -z "$ENVIRONMENT" ]; then
		ENVIRONMENT="$(printf "%s(%s)%s" "$MUTED_COLOR" "$ENVIRONMENT" "$COLOR_RESET")"
		OFFSET+=${#MUTED_COLOR}
		OFFSET+=${#COLOR_RESET}
	fi
	# The 'context' is a combination of hostname, current directory and VCS
	# branch name
	local LOCATION="${HOST_COLOR}\h${COLOR_RESET}:\W"
	OFFSET+=${#HOST_COLOR}
	OFFSET+=${#COLOR_RESET}
	local BRANCH="$(__vcs_ps1 " (%s)")"
	# For both branches of this if block, the "normal" text is muted
	if [[ "${BRANCH}" =~ ^\ \((.*\ )(\*)?(\+)?([<>=]?\))?$ ]]; then
		# If the branch's dirty state is indicated, highlight that.
		# Add a COLOR_RESET to unset the bold state (which screws up later
		# colors).
		LOCATION+=" ${MUTED_COLOR}(${BASH_REMATCH[1]}${COLOR_RESET}"
		OFFSET+=${#MUTED_COLOR}
		OFFSET+=${#COLOR_RESET}
		# Highlight the dirty flag in red
		if [ -n "${BASH_REMATCH[2]}" ]; then
			LOCATION+="${RED_COLOR}${BASH_REMATCH[2]}"
			OFFSET+=${#RED_COLOR}
			# We can skip an escape sequence if there's a staged indicator
			# coming up
			if [ -z "${BASH_REMATCH[3]}" ]; then
				LOCATION+="${MUTED_COLOR}"
				OFFSET+=${#MUTED_COLOR}
			fi
		fi
		# And highlight the staged flag in green
		if [ -n "${BASH_REMATCH[3]}" ]; then
			LOCATION+="${GREEN_COLOR}${BASH_REMATCH[3]}${MUTED_COLOR}"
			OFFSET+=${#GREEN_COLOR}
			OFFSET+=${#MUTED_COLOR}
		fi
		# Add the closing parenthesis
		LOCATION+="${BASH_REMATCH[4]}${COLOR_RESET}"
		OFFSET+=${#COLOR_RESET}
	else
		# Mute the branch name as well
		LOCATION+="${MUTED_COLOR}${BRANCH}${COLOR_RESET}"
		OFFSET+=${#MUTED_COLOR}
		OFFSET+=${#COLOR_RESET}
	fi
	# Save the cursor position before we go mucking around with it
	_tput sc
	# First we write the current time on the right-hand side. We're going back
	# 8 characters to make room for HH:MM:SS
	# $COLUMNS is provided by bash, and is the width of the terminal in
	# characters.
	_tput cuf $((${COLUMNS}-8))
	# Older versions of bash (read: GPL2 bash Apple still ships with macOS)
	# don't understand the special time format argument to printf.
	if (( ${BASH_VERSINFO[0]} < 4 )); then
		printf "%s" "$(date -j +%H:%M:%S)"
	else
		printf '%(%H:%M:%S)T' -1
	fi
	# Color the last prompt character red if the last exit status was non-0
	local PROMPT_CHAR='\\$'
	if [ $LAST_STATUS != 0 ]; then
		PROMPT_CHAR="${RED_COLOR}${PROMPT_CHAR}${COLOR_RESET}"
	fi
	# Now bounce back for our regularly scheduled prompt writing
	_tput rc
	PS1="$(printf \
		"%s[\\\\u@%s]\n%s " \
		"${ENVIRONMENT}" \
		"${LOCATION}" \
		"${PROMPT_CHAR}" \
	)"
}

_bash_ps0() {
	# Save the cursor position
	_tput sc
	# Find out how many lines to go up. We need to go up at least two: one for
	# the newline from hitting "enter" (to run a command), and one for the
	# newline in my PS1.
	# Adapted from https://redandblack.io/blog/2020/bash-prompt-with-updating-time/
	local last_history="$(history 1)"
	# This dance with readarray and then getting the length of the array skips
	# forking off a process for `wc -l`
	local -i command_rows
	local -a command_rows_array
	if shopt lithist >/dev/null; then
		readarray -t command_rows_array <<<${last_history}
	else
		# This branch isn't as well tested as the other, as my shell has
		# lithist set normally.
		readarray -td';' command_rows_array <<<${last_history//';'/$'\n'}
	fi
	command_rows=${#command_rows_array[@]}
	local -i vertical_offset=0
	if (( $command_rows > 1 )); then
		vertical_offset=$command_rows
	else
		# Strip out the leading numbers from the history output.
		# Using bash's regex matching with BASH_REMATCH lets us avoid forking
		# out a call to sed.
		if [[ $last_history =~ ^[[:space:]]+[[:digit:]]+[[:space:]]+ ]]; then
			local last_command="${last_history:${#BASH_REMATCH[0]}}"
		fi
		# the effective length of PS1 is 2 characters for '$ ', so add that to
		# the command length.
		local -i total_length=$(( ${#last_command} + 2 ))
		local -i lines=$(( ${total_length} / ${COLUMNS} ))
		vertical_offset=$(( ${lines} + 1 ))
	fi
	# Add one for the newline when running a command
	vertical_offset+=1
	# Move the cursor to where the old timestamp was
	_tput cuu $vertical_offset
	# Moving back 8 characters for the timestamp (HH:MM:SS)
	_tput cuf $((${COLUMNS} - 8))
	# I couldn't get the '\t' prompt escape sequence working, so I'm running it
	# through the bash-specific parameter expansion that expands things like a
	# prompt would.
	local timestamp="\t"
	printf "%s" "${timestamp@P}"
	# Restore the cursor position
	_tput rc
}

_configure_iterm2_integration(){
	# Some systems don't work with iTerm integration locally.
	if [ -z "$SSH_CLIENT" ]; then
		[ "$SYSTYPE" = "FreeBSD" ] && return
		[[ "$(uname -r)" =~ .*[Mm]icrosoft.* ]] && return
	fi
	source "${HOME}/.dotfiles/util/iterm_integration.sh"
}

_configure_prompt() {
	# Exit early for non-interactive shells
	[ -z "$PS1" ] && return
	# Run some quick tasks after each command (and write out part of the
	# prompt).
	PROMPT_COMMAND='_bash_prompt'
	# iTerm integration plays with PROMPT_COMMAND, so we call it after we've
	# set it (iTerm is polite and keeps the old value enabled.
	"_configure_iterm2_integration"
	# Add PS0 for pre-command execution. This is only available on
	# bash >= 4.4, so we need to check against that first.
	# This PS0 overwites the time along the right column to the time that
	# the command starts. This rewuires that the terminal clears characters
	# instead of overstriking them. This is unlikely to be encountered on a
	# modern terminal, but things get a little wonky over minicom.
	# `tput os` checks the terminfo database for the overstrike setting.
	if (( ${BASH_VERSINFO[0]} > 4 || ${BASH_VERSINFO[1]} == 4 && ${BASH_VERSINFO[1]} >= 4)) && ! _tput os; then
		PS0="\$(_bash_ps0)"
	fi
}