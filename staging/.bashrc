# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# Use UTF8 for everything
export LANG=en_US.UTF-8

_load_util() {
	source $HOME/.dotfiles/util/common.sh
	source $HOME/.dotfiles/util/apps.sh
	source $HOME/.dotfiles/util/hosts.sh
	source $HOME/.dotfiles/util/os.sh
	source $HOME/.dotfiles/util/color.sh
	source $HOME/.dotfiles/util/aliases.sh
}

source $HOME/.dotfiles/util/common.sh
# Set up paths
if [ -d "$HOME/local/bin" ]; then
	_append_to_path "$HOME/local/bin"
fi

_configure_all() {
	configure_os
	configure_hosts
	configure_aliases
	configure_colors
	configure_apps
}

load_bashrc() {
	_load_util
	_configure_all
}
load_bashrc

# Pull in dotfiles management functions
if [ -d $HOME/.dotfiles ]; then
	source $HOME/.dotfiles/setup.sh
fi

if [ ! -z $SSH_TTY ] && [ $SHLVL = 1 ] && _prog_exists tmux; then
	if tmux has &>/dev/null; then
		tmux attach
	else
		tmux
	fi
fi

