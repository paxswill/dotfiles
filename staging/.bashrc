# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

source $HOME/.dotfiles/util/common.sh
source $HOME/.dotfiles/util/apps.sh
source $HOME/.dotfiles/util/hosts.sh
source $HOME/.dotfiles/util/os.sh
source $HOME/.dotfiles/util/color.sh
source $HOME/.dotfiles/util/aliases.sh

# Use UTF8 for everything
export LANG=en_US.UTF-8

# Set up paths
if [ -d "$HOME/local/bin" ]; then
	__append_to_path "$HOME/local/bin"
fi

configure_hosts
configure_os
configure_aliases
configure_colors
configure_apps

# Pull in dotfiles management functions
if [ -d $HOME/.dotfiles ]; then
	source $HOME/.dotfiles/setup.sh
fi

# Clean up
unset SYSTYPE
unset __prepend_to_path
unset __append_to_manpath
unset __prepend_to_manpath
unset __append_to_manpath
unset __prepend_to_libpath
unset __append_to_libpath
unset __prepend_to_pkgconfpath
unset __append_to_pkgconfpath
#unset __vercmp
