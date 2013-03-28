# ~/.bash_profile: executed by bash(1) for login shells.

# Pull in .bashrc
source $HOME/.bashrc

# Start tmux (if available) when connecting via ssh
if [ ! -z $SSH_TTY ] && [ $SHLVL = 1 ] && _prog_exists tmux; then
	# Try to attach to a running session before starting a new one
	if tmux has &>/dev/null; then
		tmux attach; exit
	else
		tmux; exit
	fi
fi
