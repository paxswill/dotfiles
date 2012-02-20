#!/bin/bash

__check_ssh_option() {
	if echo "$(ssh -o $1 2>&1)" | grep 'command-line: line 0:' >/dev/null; then
		return 0
	else
		return 1
	fi
}

setup_dotfiles(){
	# Save starting directory
	DEST="$PWD"

	# Get the dotfiles directory if needed
	if ! [ -d "$DEST/.dotfiles" ]; then
		if ! git clone git@github.com:paxswill/dotfiles.git $DEST/.dotfiles; then
			echo "Cloning public URL"
			git clone git://github.com/paxswill/dotfiles.git $DEST/.dotfiles
		fi
		cd $DEST/.dotfiles
		git submodule update -i
		cd $DEST
		BASE="$DEST/.dotfiles"
	fi

	# Set up macro definitions
	if ! [ -z $1 ] && [ "$1" == "NRL" ]; then
		M4_DEFS="${M4_DEFS}-DNRL "
	fi
	if ! __check_ssh_option "ControlMaster=auto"; then
		M4_DEFS="${M4_DEFS}-DSSH_HAS_CONTROL_MASTER "
		if ! __check_ssh_option "ControlPersist=15m"; then
			M4_DEFS="${M4_DEFS}-DSSH_HAS_CONTROL_PERSIST "
		fi
	fi
	if ! __check_ssh_option "ExitOnForwardFailure=yes"; then
		M4_DEFS="${M4_DEFS}-DSSH_HAS_EXIT_ON_FORWARD_FAILURE "
	fi

	# Make sure BASE is set and that it isn't the DEST
	if [ -z $BASE ]; then
		if [ -d $HOME/.dotfiles ]; then
			BASE="$HOME/.dotfiles"
		else
			BASE=$(dirname $0)
			cd $BASE
			BASE=$PWD
			cd $OLDPWD
		fi
	fi
	cd $BASE
	if [ "$PWD" == "$DEST" ]; then
		echo "Cannot install into the base directory"
		return 1
	else
		cd "$DEST"
	fi

	# Clean up any old files and directories
	cd $DEST
	if [ -f $BASE/links.txt ]; then
		FILES=$(cat $BASE/links.txt)
		for F in $FILES; do
			if [ -h $F ]; then
				unlink $F
			fi
		done
	fi
	if [ -f $BASE/dirs.txt ]; then
		DIRS=$(cat $BASE/dirs.txt)
		for D in $DIRS; do
			rmdir $DIRS >/dev/null 2>&1
		done
	fi

	# Process files with M4
	cd $BASE/src
	FILES=$(find . -type f ! -name '*.sw*')
	cd $DEST
	for F in $FILES; do
		mkdir -p $BASE/staging/$(dirname $F)
		m4 $M4_DEFS $BASE/src/$F > $BASE/staging/$F
	done

	# Link everything up
	cd $BASE/staging
	DIRS=$(find . -type d ! -name . -prune)
	FILES=$(find . ! -name . -prune -type f ! -name '*.sw*')
	for D in $DIRS; do
		goback=$PWD
		cd "$D"
		tmp_files=$(find . ! -name . -prune ! -name '*.sw*')
		for f in $tmp_files; do
			FILES="$FILES $D/$f"
		done
		cd $goback
		unset tmp_files
	done
	cd $DEST
	for D in $DIRS; do
		mkdir $D >/dev/null 2>&1
	done
	for F in $FILES; do
		ln -s $BASE/staging/$F $F
	done

	# Save record of links and directories for future upgrades
	echo "$FILES" > $BASE/links.txt
	echo "$DIRS" > $BASE/dirs.txt
}

# Uupdate the dotfiles repo and relink it
update_dotfiles(){
	start_dir=$PWD
	cd $HOME/.dotfiles
	if [ "$(git status --porcelain)" != "" ]; then
		echo "The dotfile repo is dirty. Aborting"
		return 1
	fi
	git pull origin
	cd $start_dit
	unset start_dir
	setup_dotfiles $1
}

if [ "${BASH_SOURCE[0]}" == "${0}" ]; then
	# We're running as a script within a shell
	# This is the case if this is during bootstrap, or during a manual setup
	setup_dotfiles $1
fi
