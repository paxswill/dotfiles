# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

source $HOME/.dotfiles/util/common.sh
source $HOME/.dotfiles/util/apps.sh
source $HOME/.dotfiles/util/hosts.sh
source $HOME/.dotfiles/util/os.sh

# Bash Configuration
# Use UTF8.
export LANG=en_US.UTF-8
# don't put duplicate lines in the history. See bash(1) for more options
# ... or force ignoredups and ignorespace
HISTCONTROL=ignoreboth
# append to the history file, don't overwrite it
shopt -s histappend
# All shells share a history
PROMPT_COMMAND='history -a'
# Multi-line commands in the same history entry
shopt -s cmdhist
shopt -s lithist
# Files beginning with '.' are included in globbing
shopt -s dotglob
# Autocomplete for hostnames
shopt -s hostcomplete
# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# Set up paths
if [ -d "$HOME/local/bin" ]; then
	__append_to_path "$HOME/local/bin"
fi

configure_hosts
configure_os

# Enable programmable shell completion features
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
	# Normal, sane systems
	. /etc/bash_completion
elif [ -f $HOME/local/common/share/bash-completion/bash_completion ] && shopt -oq posix; then
	# Systems that need customized help (fast.cs.odu.edu Solaris machines)
	. $HOME/local/common/share/bash-completion/bash_completion
elif [ "$SYSTYPE" == "Darwin" ] && which brew 2>&1 > /dev/null && [ -f $(brew --prefix)/etc/bash_completion ]; then
	# Homebrew
	. $(brew --prefix)/etc/bash_completion
elif [ -f /opt/local/etc/bash_completion ]; then
	# Macports
	. /opt/local/etc/bash_completion
fi

# Aliases
# ls
# BSD ls uses -G for color, GNU ls uses --color=auto
if strings "$(which ls)" | grep 'GNU' > /dev/null; then
    alias ls='ls --color=auto'
elif ls -G >/dev/null 2>&1; then
	alias ls='ls -G'
fi
alias ll='ls -lh'
alias la='ls -A'
alias lla='ls -lAh'

# grep
for GREPCMD in grep egrep fgrep; do
	if echo f | ${GREPCMD} --color=auto 'f' >/dev/null 2>&1; then
		alias ${GREPCMD}="${GREPCMD} --color=auto"
	fi
done

# Set PS1 (prompt)
# Determine which color to use for the hostname
# BSD includes md5, GNU includes md5sum
if which md5 >/dev/null 2>&1; then
	hashed_host=$(hostname | md5)
elif which md5sum >/dev/null 2>&1; then
	hashed_host=$(hostname | md5sum | grep -o -e '^[0-9a-f]*')
fi
# BSD has jot for generating sequences, GNU has seq
if which jot >/dev/null 2>&1; then
	hashed_seq="$(jot ${#hashed_host} 0)"
elif which seq >/dev/null 2>&1; then
	hashed_seq="$(seq 0 $((${#hashed_host} - 1)))"
fi
if [ ! -z "$hashed_host" -a ! -z "$hashed_seq" ]; then
	# Sum all the digits modulo 9 (ANSI colors 31-37 normal, and 31 and 35
	# bright. Solarized only has those two bright colors as actual colors)
	sum=0
	for i in $hashed_seq; do
		sum=$(($sum + 0x${hashed_host:$i:1}))
	done
	sum=$((sum % 9))
	if [ $sum -eq 7 ]; then
		host_color="\[\033[1;31m\]"
	elif [ $sum -eq 8 ]; then
		host_color="\[\033[1;35m\]"
	else
		host_color="\[\033[$((31 + $sum))m\]"
	fi
else
	host_color=""
fi
# If we have git PS1 magic
if type __git_ps1 >/dev/null 2>&1; then
	# [user@host:dir(git branch)] $
	GIT_PS1_SHOWUPSTREAM="auto"
	PS1="[\u@${host_color}\h\[\033[0m\]:\W$(__git_ps1 " (%s)")]\$ "
else
	# [user@host:dir] $
	PS1="[\u@${host_color}\h\[\033[0m\]:\W]\$ "
fi

configure_apps

# Pull in dotfiles management functions
if [ -d $HOME/.dotfiles ]; then
	source $HOME/.dotfiles/setup.sh
fi

# Export the configuration
export PATH
export JAVA_HOME
export LD_LIBRARY_PATH
export MANPATH
export PKG_CONFIG_PATH

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
