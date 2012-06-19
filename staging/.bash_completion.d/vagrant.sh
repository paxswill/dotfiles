# Autocompletion for Vagrant just put this line in your ~/.profile or link this file into it like:
# source /path/to/vagrant/contrib/bash/completion.sh
if which vagrant >/dev/null 2>&1; then
	complete -W "$(echo `vagrant --help | awk '/^     /{print $1}'`;)" vagrant
fi
