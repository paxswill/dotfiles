# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# Use UTF8 for everything
export LANG=en_US.UTF-8

_dotfile_log_times=0

load_bashrc() {
	local UTIL_FILE
	for UTIL_FILE in common apps hosts os term aliases vcs; do
		if [[ ${_dotfile_log_times:-0} != 0 ]]; then
			TIMEFORMAT="${UTIL_FILE}.sh: %R"
			time source "${HOME}/.dotfiles/util/bash/${UTIL_FILE}.sh"
		else
			source "${HOME}/.dotfiles/util/bash/${UTIL_FILE}.sh"
		fi
	done
	# Set up personal paths
	if [ -d "$HOME/local/bin" ]; then
		append_to_path "$HOME/local/bin"
	fi
	# Configure everything
	local CONFIG_CMD
	for CONFIG_CMD in os hosts aliases colors apps; do
		if [[ ${_dotfile_log_times:-0} != 0 ]]; then
			TIMEFORMAT="configure_${CONFIG_CMD}: %R"
			time configure_${CONFIG_CMD}
		else
			configure_${CONFIG_CMD}
		fi
	done
	unset TIMEFORMAT
}
load_bashrc

# Pull in dotfiles management functions
if [ -d $HOME/.dotfiles ]; then
	source $HOME/.dotfiles/common.bash
fi


# If this is the base shell over SSH, it's interactive, and there's a tmux
# session available, attach to it.
if [ -n "$SSH_CONNECTION" ] && [ -n "$SSH_TTY" ] && (( $SHLVL == 1 )); then
	if _prog_exists tmux && [ -z "$TMUX" ] && tmux has-session 2>/dev/null; then
		tmux attach
	fi
fi
