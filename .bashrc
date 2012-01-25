# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# Path utility functions
__prepend_to_path() {
	export PATH="${1}${PATH:+:}${PATH}"
}

__append_to_path() {
	export PATH="${PATH}${PATH:+:}${1}"
}

__prepend_to_manpath() {
	export MANPATH="${1}${MANPATH:+:}${MANPATH}"
}

__append_to_manpath() {
	export MANPATH="${MANPATH}${MANPATH:+:}${1}"
}

__prepend_to_libpath() {
	export LD_LIBRARY_PATH="${1}${LD_LIBRARY_PATH:+:}${LD_LIBRARY_PATH}"
}

__append_to_libpath() {
	export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}${LD_LIBRARY_PATH:+:}${1}"
}

__prepend_to_pkgconfpath() {
	export PKG_CONFIG_PATH="${1}${PKG_CONFIG_PATH:+:}${PKG_CONFIG_PATH}"
}

__append_to_pkgconfpath() {
	export PKG_CONFIG_PATH="${PKG_CONFIG_PATH}${PKG_CONFIG_PATH:+:}${1}"
}

# Bash Configuration
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

# vless is less with vim's syntax coloring
alias vless='vim -u /usr/share/vim/vim*/macros/less.vim'

# Set up paths
# Set a base PATH, depending on host
SYSTYPE=$(uname -s)
# A FQDN is required
HOSTNAME=$(hostname)
# Sometimes a flag is needed
if ! echo $HOSTNAME | grep '\.' >/dev/null; then
	if [ "$SYSTYPE" == "SunOS" ] && type getent >/dev/null 2>&1; then
		HOSTNAME=$(getent hosts $(hostname) | awk '{print $2'})
	elif hostname -f >/dev/null 2>&1; then
		HOSTNAME=$(hostname -f)
	fi
fi
DOMAINTAIL=$(echo $HOSTNAME | sed s/'^[a-zA-Z]*\.'/''/g)
# Host specific configuration
if [ "$HOSTNAME" == "Macbeth" ] && [ "$SYSTYPE" == "Linux"  ]; then
	# Macbeth is my main Debian System
	# Redefine path to include system binaries, like root
	PATH=/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/bin:/sbin
	JAVA_HOME=/usr/lib/jvm/default_java
elif [ "$DOMAINTAIL" == "cs.odu.edu" ]; then
	if [ "$HOSTNAME" == "procyon.cs.odu.edu" ] || [ "$HOSTNAME" == "capella.cs.odu.edu" ] || [ "$HOSTNAME" == "antares.cs.odu.edu" ] || [ "$HOSTNAME" == "vega.cs.odu.edu" ]; then
		LOCALNAME="fast-sparc"
		PATH=/usr/local/bin:/usr/local/ssl/bin:/usr/local/sunstudio/bin:/usr/local/sunstudio/netbeans/bin:/usr/sfw/bin:/usr/java/bin:/usr/bin:/bin:/usr/ccs/bin:/usr/ucb:/usr/dt/bin:/usr/X11/bin:/usr/X/bin:/usr/lib/lp/postscript
		LD_LIBRARY_PATH=/usr/local/lib/mysql:/usr/local/lib:/usr/local/ssl/lib:/usr/local/sunstudio/lib:/usr/sfw/lib:/usr/java/lib:/usr/lib:/lib:/usr/ccs/lib:/usr/ucblib:/usr/dt/lib:/usr/X11/lib:/usr/X/lib:/opt/local/oracle_instant_client/
		MANPATH=/usr/local/man:/usr/local/ssl/ssl/man:/usr/local/sunstudio/man:/usr/sfw/man:/usr/java/man:/usr/man:/usr/dt/man:/usr/X11/man:/usr/X/man
		PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:/usr/sfw/lib/pkgconfig:/usr/X/lib/pkgconfig
		JAVA_HOME=/usr/java
	elif [ "$HOSTNAME" == "atria.cs.odu.edu" ] || [ "$HOSTNAME" == "sirius.cs.odu.edu" ]; then
		LOCALNAME="fast-ubuntu"
	elif [ "$HOSTNAME" == "nvidia.cs.odu.edu" ]; then
		LOCALNAME="nv-s1070"
	elif [ "$HOSTNAME" == "cuda.cs.odu.edu" ] || [ "$HOSTNAME" == "tesla.cs.odu.edu" ] || [ "$HOSTNAME" == "stream.cs.odu.edu" ]; then
		LOCALNAME="nv-c870"
	elif [ "$HOSTNAME" == "smp" ]; then
		LOCALNAME="smp"
	fi
	# CUDA paths
	if [ -d /usr/local/cuda ]; then
		__append_to_path "/usr/local/cuda/bin:/usr/local/cuda/computeprof/bin"
		__append_to_libpath "/usr/local/cuda/lib64:/usr/local/cuda/lib"
	fi
	__prepend_to_path "${HOME}/local/${LOCALNAME}/bin:${HOME}/local/${LOCALNAME}/sbin"
	__prepend_to_libpath "${HOME}/local/${LOCALNAME}/lib:${HOME}/local/${LOCALNAME}/lib64"
	__prepend_to_pkgconfpath "${HOME}/local/${LOCALNAME}/lib/pkgconfig"
	unset LOCALNAME
elif [ "$SYSTYPE" == "Darwin" ]; then
	# Add the undocumented airport command
	__append_to_path "/System/Library/PrivateFrameworks/Apple80211.framework/Versions/A/Resources"
	# MacPorts
	if [ -d /opt/local/bin -a -d /opt/local/sbin ]; then
		__append_to_path "/opt/local/bin:/opt/local/sbin"
	fi
	if [ -d /opt/local/share/man ]; then
		__append_to_manpath "/opt/local/share/man"
	fi
	# Move homebrew to the front of the path if we have it
	if type brew >/dev/null 2>&1; then
		BREW_PREFIX=$(brew --prefix)
		if [ -d "${BREW_PREFIX}/sbin" ]; then
			__prepend_to_path "${BREW_PREFIX}/sbin"
		fi
		if [ -d "${BREW_PREFIX}/bin" ]; then
			__prepend_to_path "${BREW_PREFIX}/bin"
		fi
		if [ -d /usr/local/share/python3 ]; then
			__prepend_to_path "/usr/local/share/python3"
		fi
		unset BREW_PREFIX
	fi
	# Add the OpenCL offline compiler if it exists
	if [ -e /System/Library/Frameworks/OpenCL.framework/Libraries/openclc ]; then
		__append_to_path "/System/Library/Frameworks/OpenCL.framework/Libraries"
	fi
	# Man page to Preview
	if which ps2pdf > /dev/null; then
		pman () {
			man -t "${@}" | ps2pdf - - | open -g -f -a /Applications/Preview.app
		}
	fi
fi

# RVM
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"

# Android
if [ -d /opt/android-sdk ]; then
	__append_to_path "/opt/android-sdk/tools:/opt/android-sdk/platform-tools"
fi

# Fancy Kerberos
if [ -d /usr/krb5 ]; then
	__prepend_to_path "/usr/krb5/bin:/usr/krb5/sbin"
elif [ -d /usr/local/krb5 ]; then
	__prepend_to_path "/usr/local/krb5/bin:/usr/local/krb5/sbin"
fi

# enable programmable completion features 
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
	# Normal, sane systems
	. /etc/bash_completion
elif [ -f $HOME/local/common/share/bash-completion/bash_completion ] && shopt -oq posix; then
	# Systems that need customized help (fast.cs.odu.edu Solaris machines)
	. $HOME/local/common/share/bash-completion/bash_completion
elif [ "$SYSTYPE" == "Darwin" ] && which brew > /dev/null && [ -f $(brew --prefix)/etc/bash_completion ]; then
	# Homebrew
	. $(brew --prefix)/etc/bash_completion
elif [ -f /opt/local/etc/bash_completion ]; then
	# Macports
	. /opt/local/etc/bash_completion
fi

# Set Vim as $EDITOR if it's available
if which vim >/dev/null; then
	export EDITOR=vim
elif which vi > /dev/null; then
	export EDITOR=vi
fi

# Set PS1 (prompt)
# If we have git PS1 magic
if type __git_ps1 >/dev/null 2>&1; then
	# [user@host:dir(git branch)] $
	GIT_PS1_SHOWUPSTREAM="auto"
	PS1='[\u@\h:\W$(__git_ps1 " (%s)")]\$ '
else
	# [user@host:dir] $
	PS1='[\u@\h:\W]\$ '
fi

# Export the configuration
export PATH
export JAVA_HOME
export LD_LIBRARY_PATH
export MANPATH
export PKG_CONFIG_PATH

# Clean up
unset HOSTNAME
unset SYSTYPE
unset DOMAINTAIL
unset __prepend_to_path
unset __append_to_manpath
unset __prepend_to_manpath
unset __append_to_manpath
unset __prepend_to_libpath
unset __append_to_libpath
unset __prepend_to_pkgconfpath
unset __append_to_pkgconfpath
