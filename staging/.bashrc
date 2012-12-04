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

_configure_all() {
	# Set up personal paths
	if [ -d "$HOME/local/bin" ]; then
		append_to_path "$HOME/local/bin"
	fi
	# Configure everything
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
