# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# Path utility functions
__prepend_to_path() {
	cd "${1}"
	local __real_path="$(pwd -P)"
	export PATH="${__real_path}${PATH:+:}${PATH}"
	cd
}

__append_to_path() {
	cd "${1}"
	local __real_path="$(pwd -P)"
	export PATH="${PATH}${PATH:+:}${1}"
	cd
}

__prepend_to_manpath() {
	cd "${1}"
	local __real_path="$(pwd -P)"
	export MANPATH="${__real_path}${MANPATH:+:}${MANPATH}"
	cd
}

__append_to_manpath() {
	cd "${1}"
	local __real_path="$(pwd -P)"
	export MANPATH="${MANPATH}${MANPATH:+:}${__real_path}"
	cd
}

__prepend_to_libpath() {
	cd "${1}"
	local __real_path="$(pwd -P)"
	export LD_LIBRARY_PATH="${__real_path}${LD_LIBRARY_PATH:+:}${LD_LIBRARY_PATH}"
	cd
}

__append_to_libpath() {
	cd "${1}"
	local __real_path="$(pwd -P)"
	export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}${LD_LIBRARY_PATH:+:}${__real_path}"
	cd
}

__prepend_to_pkgconfpath() {
	cd "${1}"
	local __real_path="$(pwd -P)"
	export PKG_CONFIG_PATH="${__real_path}${PKG_CONFIG_PATH:+:}${PKG_CONFIG_PATH}"
	cd
}

__append_to_pkgconfpath() {
	cd "${1}"
	local __real_path="$(pwd -P)"
	export PKG_CONFIG_PATH="${PKG_CONFIG_PATH}${PKG_CONFIG_PATH:+:}${__real_path}"
	cd
}

# From http://stackoverflow.com/a/4025065/96454, as of 15 April 2012
__vercmp () {
    if [[ $1 == $2 ]]
    then
        return 0
    fi
    local IFS=.
    local i ver1=($1) ver2=($2)
    # fill empty fields in ver1 with zeros
    for ((i=${#ver1[@]}; i<${#ver2[@]}; i++))
    do
        ver1[i]=0
    done
    for ((i=0; i<${#ver1[@]}; i++))
    do
        if [[ -z ${ver2[i]} ]]
        then
            # fill empty fields in ver2 with zeros
            ver2[i]=0
        fi
        if ((10#${ver1[i]} > 10#${ver2[i]}))
        then
            return 1
        fi
        if ((10#${ver1[i]} < 10#${ver2[i]}))
        then
            return 2
        fi
    done
    return 0
}

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

# make less more friendly for non-text input files, see lesspipe(1)
if which lesspipe >/dev/null 2>&1; then
	export LESSOPEN="|lesspipe %s"
elif which lesspipe.sh >/dev/null 2>&1; then
	export LESSOPEN="|lesspipe.sh %s"
fi

# Ignore Vim temporary files for file completion
FIGNORE=".swp:.swo"

# Set up paths
if [ -d "$HOME/local/bin" ]; then
	__append_to_path "$HOME/local/bin"
fi
# Set a base PATH, depending on host
SYSTYPE=$(uname -s)
# A FQDN is required
__HOSTNAME=$(hostname)
# Sometimes a flag is needed
if ! echo $__HOSTNAME | grep '\.' >/dev/null; then
	if [ "$SYSTYPE" = "SunOS" ] && type getent >/dev/null 2>&1; then
		__HOSTNAME=$(getent hosts $(hostname) | awk '{print $2}')
	elif hostname -f >/dev/null 2>&1; then
		__HOSTNAME=$(hostname -f)
	fi
fi
DOMAINTAIL=$(echo $__HOSTNAME | sed s/'^[a-zA-Z]*\.'/''/g)
# Host specific configuration
if [ "$__HOSTNAME" = "Macbeth" ] && [ "$SYSTYPE" = "Linux"  ]; then
	# Macbeth is my main Debian System
	# Redefine path to include system binaries, like root
	PATH=/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/bin:/sbin
	JAVA_HOME=/usr/lib/jvm/default_java
elif [ "$DOMAINTAIL" = "cs.odu.edu" ]; then
	if [ "$__HOSTNAME" = "procyon.cs.odu.edu" ] || [ "$__HOSTNAME" = "capella.cs.odu.edu" ] || [ "$__HOSTNAME" = "antares.cs.odu.edu" ] || [ "$__HOSTNAME" = "vega.cs.odu.edu" ]; then
		LOCALNAME="fast-sparc"
		PATH=/usr/local/bin:/usr/local/ssl/bin:/usr/local/sunstudio/bin:/usr/local/sunstudio/netbeans/bin:/usr/sfw/bin:/usr/java/bin:/usr/bin:/bin:/usr/ccs/bin:/usr/ucb:/usr/dt/bin:/usr/X11/bin:/usr/X/bin:/usr/lib/lp/postscript
		LD_LIBRARY_PATH=/usr/local/lib/mysql:/usr/local/lib:/usr/local/ssl/lib:/usr/local/sunstudio/lib:/usr/sfw/lib:/usr/java/lib:/usr/lib:/lib:/usr/ccs/lib:/usr/ucblib:/usr/dt/lib:/usr/X11/lib:/usr/X/lib:/opt/local/oracle_instant_client/
		MANPATH=/usr/local/man:/usr/local/ssl/ssl/man:/usr/local/sunstudio/man:/usr/sfw/man:/usr/java/man:/usr/man:/usr/dt/man:/usr/X11/man:/usr/X/man
		PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:/usr/sfw/lib/pkgconfig:/usr/X/lib/pkgconfig
		JAVA_HOME=/usr/java
	elif [ "$__HOSTNAME" = "atria.cs.odu.edu" ] || [ "$__HOSTNAME" = "sirius.cs.odu.edu" ]; then
		LOCALNAME="fast-ubuntu"
	elif [ "$__HOSTNAME" = "nvidia.cs.odu.edu" ]; then
		LOCALNAME="nv-s1070"
	elif [ "$__HOSTNAME" = "cuda.cs.odu.edu" ] || [ "$__HOSTNAME" = "tesla.cs.odu.edu" ] || [ "$__HOSTNAME" = "stream.cs.odu.edu" ]; then
		LOCALNAME="nv-c870"
	elif [ "$__HOSTNAME" = "smp.cs.odu.edu" ]; then
		LOCALNAME="smp"
	fi
    export LOCAL_PREFIX="$HOME/local/$LOCALNAME"
	unset LOCALNAME
	# CUDA paths
	if [ -d /usr/local/cuda ]; then
		__append_to_path "/usr/local/cuda/bin:/usr/local/cuda/computeprof/bin"
		__append_to_libpath "/usr/local/cuda/lib64:/usr/local/cuda/lib"
	fi
	__prepend_to_path "${LOCAL_PREFIX}/bin:${LOCAL_PREFIX}/sbin"
	__prepend_to_libpath "${LOCAL_PREFIX}/lib:${LOCAL_PREFIX}/lib64"
	__prepend_to_pkgconfpath "${LOCAL_PREFIX}/lib/pkgconfig:${LOCAL_PREFIX}/lib64/pkgconfig"
	# Autoconf Site configuration
	export CONFIG_SITE=$HOME/local/config.site
elif [ "$DOMAINTAIL" = "cmf.nrl.navy.mil" ]; then
	if [ "$SYSTYPE" = "Darwin" ]; then
		# PATH on CMF OS X machines is getting munged
		unset PATH
		eval "$(/usr/libexec/path_helper -s)"
		# Re-add ~/local/bin, unless there's /scratch/local/bin
		MY_BIN="/afs/cmf.nrl.navy.mil/users/wross/local/bin"
		if [ -d "/scratch/wross/local/bin" ]; then
			__prepend_to_path "/scratch/wross/local/bin"
		elif [ -d "${MY_BIN}" ]; then
			__prepend_to_path "${MY_BIN}"
		fi
		unset MY_BIN
		# Staging/Linking up packages with Homebrew can fail when crossing file
		# system boundaries. This forces the homebrew temporary folder to be
		# on the same FS as the destination.
		if which brew > /dev/null; then
			export HOMEBREW_TEMP="$(brew --prefix)/.tmp/homebrew"
			if ! [ -d "${HOMEBREW_TEMP}" ]; then
				mkdir -p "${HOMEBREW_TEMP}"
			fi
		fi
		if [ -d /scratch/wross ]; then
			export VAGRANT_HOME=/scratch/wross/.vagrantd
			mkdir -p $VAGRANT_HOME
		fi
	fi
	if [ -z "$SCRATCH_VOLUME" -a -d /scratch -a -w /scratch ]; then
		export CCACHE_DIR=/scratch/ccache

	fi
	# AFS Resources
	if [ -d "/afs/cmf.nrl.navy.mil/@sys/bin" ]; then
		__append_to_path "/afs/cmf.nrl.navy.mil/@sys/bin"
	fi
fi
# OS X Specific setup
if [ "$SYSTYPE" = "Darwin" ]; then
	# MacPorts
	if ! which brew > /dev/null; then
		if [ -d /opt/local/bin -a -d /opt/local/sbin ]; then
				__append_to_path "/opt/local/bin:/opt/local/sbin"
		fi
		if [ -d /opt/local/share/man ]; then
			__append_to_manpath "/opt/local/share/man"
		fi
	fi
	# Homebrew setup
	if type brew >/dev/null 2>&1; then
		# Move homebrew to the front of the path if we have it
		BREW_PREFIX=$(brew --prefix)
		if [ -d "${BREW_PREFIX}/sbin" ]; then
			__append_to_path "${BREW_PREFIX}/sbin"
		fi
		if brew list ruby >/dev/null; then
			if [ -d "$(brew --prefix ruby)/bin" ]; then
				__append_to_path "$(brew --prefix ruby)/bin"
			fi
		fi
		# Use brewed pythons if we have them
		for temp_python in python3 pypy python; do
			if brew list $temp_python >/dev/null && \
				[ -d "$BREW_PREFIX/share/$temp_python" ]; then
				__append_to_path "$BREW_PREFIX/share/$temp_python"
			fi
		done
		# Add Node.js modules to PATH
		if [ -d "$(brew --prefix)/lib/node_modules" ]; then
			__append_to_path "$(brew --prefix)/lib/node_modules"
		fi
		unset BREW_PREFIX
	fi
	# Add the OpenCL offline compiler if it's there
	if [ -e /System/Library/Frameworks/OpenCL.framework/Libraries/openclc ]; then
		alias openclc='/System/Library/Frameworks/OpenCL.framework/Libraries/openclc'
	fi
	# Add the "hidden" airport command
	if [ -e '/System/Library/PrivateFrameworks/Apple80211.framework/Versions/A/Resources/airport' ]; then
		alias airport='/System/Library/PrivateFrameworks/Apple80211.framework/Versions/A/Resources/airport'
	fi
	# Man page to Preview
	if which ps2pdf 2>&1 > /dev/null; then
		__vercmp "$(sw_vers -productVersion)" "10.7"
		if [[ $? == 2 ]]; then
			pman_open_bg="-g"
		fi
		pman () {
			man -t "${@}" | ps2pdf - - | open ${pman_open_bg} -f -a /Applications/Preview.app
		}
	fi
	# Increase the maximum number of open file descriptors
	# This is primarily for the Android build process
	if [ $(ulimit -n) -lt 1024 ]; then
		ulimit -S -n 1024
	fi
	# Define JAVA_HOME on OS X
	JAVA_HOME=$(/usr/libexec/java_home)
fi

# Android SDK (non-OS X)
if [ -d /opt/android-sdk ]; then
	export ANDROID_SDK_ROOT="/opt/android-sdk"
	__append_to_path "${ANDROID_SDK_ROOT}/tools"
	__append_to_path "${ANDROID_SDK_ROOT}/platform-tools"
fi

# HPCMO Kerberos
if [ -d /usr/krb5 ]; then
	__prepend_to_path "/usr/krb5/bin"
	__prepend_to_path "/usr/krb5/sbin"
elif [ -d /usr/local/krb5 ]; then
	__prepend_to_path "/usr/local/krb5/bin"
	__prepend_to_path "/usr/local/krb5/sbin"
fi

# Perlbrew
if [ -s $HOME/perl5/perlbrew/etc/bashrc ]; then
	. $HOME/perl5/perlbrew/etc/bashrc
	# On modern systems setting MANPATH screws things up
	if [ "$(uname -s)" = "Darwin" ]; then
		unset MANPATH
	fi
fi

# Enable ccache in Android if we have it, and set it up
if which ccache >/dev/null; then
	if [ ! -z "$CCACHE_DIR" -a ! -d "$CCACHE_DIR" ]; then
		mkdir "$CCACHE_DIR"
	fi
	if [ ! -w "$CCACHE_DIR" ]; then
		unset CCACHE_DIR
	else
		export USE_CCACHE=1
		ccache -M 50G > /dev/null
	fi
fi

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

# Set Vim as $EDITOR if it's available
if which mvim >/dev/null 2>&1; then
	 GUI_VIM=mvim
elif which gvim >/dev/null 2>&1; then
	 GUI_VIM=gvim
fi
if which vim >/dev/null 2>&1; then
	VI=vim
elif which vi >/dev/null 2>&1; then
	VI=vi
fi
if [ ! -z $GUI_VIM ]; then
	export EDITOR=$GUI_VIM
	if [ ! -z $VI ]; then
		export GIT_EDITOR=$VI
	fi
elif [ ! -z $VI ]; then
	export EDITOR=$VI
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

# Quick access to git grep
if which git > /dev/null; then
	alias ggrep="git grep"
fi

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

# Pull in dotfiles management functions
if [ -d $HOME/.dotfiles ]; then
	source $HOME/.dotfiles/setup.sh
fi

# RVM
if [ -s "$HOME/.rvm/scripts/rvm" ]; then
	source "$HOME/.rvm/scripts/rvm"
fi

# Pull in virtualenvwrapper
wrapper_source=$(which virtualenvwrapper.sh >/dev/null 2>&1)
if ! [ -z $wrapper_source ] && [ -s $wrapper_source ]; then
	# Use python3
	if which python3 >/dev/null 2>&1; then
		export VIRTUALENVWRAPPER_PYTHON=$(which python3)
	fi
	# Set up the working directories
	if [ -d "$HOME/Development/Python" ]; then
		export PROJECT_HOME="$HOME/Development/Python"
	else
		export PROJECT_HOME="$HOME/Development"
		if ! [ -d $PROJECT_HOME ]; then
			mkdir $PROJECT_HOME
		fi
	fi
	export WORKON_HOME="$HOME/.virtualenvs"
	if ! [ -d $WORKON_HOME ]; then
		mkdir $WORKON_HOME
	fi
	source $wrapper_source
fi
unset wrapper_source

# Set up Amazon EC2 keys
if [ -d "$HOME/.ec2" ] && which ec2-cmd >/dev/null; then
	# EC2_HOME needs the jars directory. Right now I'm just using Homebrew, so
	# I'll need to add special handling if I use other platforms in the future.
	if which brew >/dev/null; then
		export EC2_HOME="$(brew --prefix ec2-api-tools)/jars"
	else
		echo "WARNING: ec2-cmd detected but no Homebrew."
	fi
	export EC2_PRIVATE_KEY="$(/bin/ls $HOME/.ec2/pk-*.pem)"
	export EC2_CERT="$(/bin/ls $HOME/.ec2/cert-*.pem)"
fi

# Prettify man pages
# Bold will be cyan
export LESS_TERMCAP_mb=$'\E[0;36m'
export LESS_TERMCAP_md=$'\E[0;36m'
export LESS_TERMCAP_me=$'\E[0m'
# Standaout uses a highlighted background and foreground
export LESS_TERMCAP_so=$'\E[01;40m'
export LESS_TERMCAP_se=$'\E[0m'
# Instead of underlines, use the highlighted back and foreground
export LESS_TERMCAP_us=$'\E[01;34;40m'
export LESS_TERMCAP_ue=$'\E[0m'

# Export the configuration
export PATH
export JAVA_HOME
export LD_LIBRARY_PATH
export MANPATH
export PKG_CONFIG_PATH

# Clean up
unset __HOSTNAME
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
#unset __vercmp
