# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

####
# Bash Configuration
####

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

# make less more friendly for non-text input files, see lesspipe(1)
#[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# Aliases
# ls
alias ls='ls -G'
alias ll='ls -lh'
alias la='ls -A'
alias lla='ls -lAh'

# grep
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# vless is less with vim's syntax coloring
alias vless='vim -u /usr/share/vim/vim*/macros/less.vim'

# enable programmable completion features 
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
	# Normal, sane systems
	. /etc/bash_completion
elif [ -f $HOME/local/common/share/bash-completion/bash_completion ] && shopt -oq posix; then
	# Systems that need customized help (fast.cs.odu.edu Solaris machines)
	. $HOME/local/common/share/bash-completion/bash_completion
elif which brew && [ -f $(brew --prefix)/etc/bash_completion ]; then
	. $(brew --prefix)/etc/bash_completion
fi

####
# Set PS1 (prompt)
####
# If we have git PS1 magic
if type __git_ps1 >/dev/null 2>&1; then
	# [user@host:dir(git branch)] $
	PS1='[\u@\h:\W$(__git_ps1 " (%s)")]\$ '
else
	# [user@host:dir] $
	PS1='[\u@\h:\W]\$ '
fi

####
# Set up path
####
# Set a base PATH, depending on host
HOSTNAME=$(hostname)
SYSTYPE=$(uname -s)
if [ "$SYSTYPE" == "Linux" ]; then
	DISTNAME=$(lsb_release -i | sed s/'.*:[ \t\r\n]*'//g)
elif [ "$SYSTYPE" == "Darwin" ]; then
	case "$(sw_vers -productVersion | sed s/'\.[0-9]+$'//)" in
		"10.0")
			DISTNAME="Cheetah";;
		"10.1")
			DISTNAME="Puma";;
		"10.2")
			DISTNAME="Jaguar";;
		"10.3")
			DISTNAME="Panther";;
		"10.4")
			DISTNAME="Tiger";;
		"10.5")
			DISTNAME="Leopard";;
		"10.6")
			DISTNAME="Snow Leopard";;
		"10.7")
			DISTNAME="Lion";;
	esac
fi
if [ "$HOSTNAME" == "Macbeth" ] && [ "$SYSTYPE" == "Linux"  ]; then
	# Macbeth is my main Debian System
	# Redefine path to include system binaries, like root
	PATH=/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/bin:/sbin
	JAVA_HOME=/usr/lib/jvm/default_java
elif [ "$HOSTNAME" == "procyon" ] || [ "$HOSTNAME" == "capella" ] || [ "$HOSTNAME" == "antares" ] || [ "$HOSTNAME" == "vega" ]; then
	# fast.cs.odu.edu Solaris Machines
	PATH=/usr/local/bin:/usr/local/ssl/bin:/usr/local/sunstudio/bin:/usr/local/sunstudio/netbeans/bin:/usr/sfw/bin:/usr/java/bin:/usr/bin:/bin:/usr/ccs/bin:/usr/ucb:/usr/dt/bin:/usr/X11/bin:/usr/X/bin:/usr/lib/lp/postscript
	PATH=$HOME/local/fast-sparc/bin:$HOME/local/fast-sparc/sbin:$PATH
	JAVA_HOME=/usr/java
	LD_LIBRARY_PATH=/usr/local/lib/mysql:/usr/local/lib:/usr/local/ssl/lib:/usr/local/sunstudio/lib:/usr/sfw/lib:/usr/java/lib:/usr/lib:/lib:/usr/ccs/lib:/usr/ucblib:/usr/dt/lib:/usr/X11/lib:/usr/X/lib:/opt/local/oracle_instant_client/
	LD_LIBRARY_PATH=$HOME/local/fast-sparc/lib:$LD_LIBRARY_PATH
	MANPATH=/usr/local/man:/usr/local/ssl/ssl/man:/usr/local/sunstudio/man:/usr/sfw/man:/usr/java/man:/usr/man:/usr/dt/man:/usr/X11/man:/usr/X/man
	MANPATH=$HOME/local/fast-sparc/share/man:$MANPATH
	PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:/usr/sfw/lib/pkgconfig:/usr/X/lib/pkgconfig
elif [ "$HOSTNAME" == "atria" ] || [ "$HOSTNAME" == "sirius" ]; then
	# fast.cs.odu.edu Ubuntu Machines
	PATH=$HOME/local/fast-ubuntu/bin:$HOME/local/fast-ubuntu/sbin:$PATH
	LD_LIBRARY_PATH=$HOME/local/fast-ubuntu/lib:$LD_LIBRARY_PATH
	MANPATH=$HOME/local/fast-ubuntu/share/man:$MANPATH
elif [ "$HOSTNAME" == "nvidia.cs.odu.edu" ]; then
	# ODU CS Nvida S1070 machine
	PATH=$HOME/local/nv-s1070/bin:$HOME/local/nv-s1070/sbin:$PATH:/usr/local/cuda/bin:/usr/local/cuda/computeprof/bin
	LD_LIBRARY_PATH=$HOME/local/nv-s1070/lib:$LD_LIBRARY_PATH:/usr/local/cuda/lib64:/usr/local/cuda/lib
	MANPATH=$HOME/local/nv-s1070/share/man:$MANPATH
	PKG_CONFIG_PATH=$HOME/local/nv-s1070/lib/pkgconfig:$PKG_CONFIG_PATH
elif [ "$HOSTNAME" == "cuda.cs.odu.edu" ] || [ "$HOSTNAME" == "tesla.cs.odu.edu" ] || [ "$HOSTNAME" == "stream.cs.odu.edu" ]; then
	# ODU CS C870 machines
	PATH=$HOME/local/nv-c870/bin:$HOME/local/nv-c870/sbin:$PATH:/usr/local/cuda/bin:/usr/local/cuda/computeprof/bin
	LD_LIBRARY_PATH=$HOME/local/nv-c870/lib:$LD_LIBRARY_PATH:/usr/local/cuda/lib64:/usr/local/cuda/lib
	MANPATH=$HOME/local/nv-c870/share/man:$MANPATH
	PKG_CONFIG_PATH=$HOME/local/nv-c870/lib/pkgconfig:$PKG_CONFIG_PATH
elif [ "$HOSTNAME" == "smp" ]; then
	PATH=$HOME/local/smp/bin:$HOME/local/smp/sbin:$PATH
	LD_LIBRARY_PATH=$HOME/local/smp/lib:$LD_LIBRARY_PATH
	MANPATH=$HOME/local/smp/share/man:$MANPATH
elif [ "$SYSTYPE" == "Darwin" ]; then
	PATH=$PATH:/System/Library/PrivateFrameworks/Apple80211.framework/Versions/A/Resources
fi
unset HOSTNAME
unset SYSTYPE
unset DISTNAME

# RVM
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"

# Android
if [ -d /opt/android-sdk ]; then
	PATH=$PATH:/opt/android-sdk/tools:/opt/android-sdk/platform-tools
fi

# Export the configuration
export PATH
export JAVA_HOME
export LD_LIBRARY_PATH
export MANPATH
export PKG_CONFIG_PATH
