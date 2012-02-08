#!/bin/bash

# Save starting directory
DEST="$PWD"

# Get the dotfiles directory if needed
if ! [ -d "$DEST/.dotfiles" ]; then
	git clone -b Macros paxswill_git@git.paxswill.com:~/repos/dotfiles.git $DEST/.dotfiles
	cd $DEST/.dotfiles
	git submodule update -i
	cd $DEST
	BASE="$DEST/.dotfiles"
fi

# Set up macro definitions
if ! [ -z $1 ] && [ "$1" == "NRL" ]; then
	M4_DEFS="${M4_DEFS}-DNRL "
fi
if ! echo "$(ssh -o ControlMaster=auto >/dev/null 2>&1)" | grep 'command-line: line 0:'; then
	M4_DEFS="${M4_DEFS}-DSSH_HAS_CONTROL_MASTER "
	if ! echo "$(ssh -o ControlPersist=15m >/dev/null 2>&1)" | grep 'command-line: line 0:'; then
		M4_DEFS="${M4_DEFS}-DSSH_HAS_CONTROL_PERSIST "
	fi
fi
if ! echo "$(ssh -o ExitOnForwardfailure=yes >/dev/null 2>&1)" | grep 'command-line: line 0:'; then
	M4_DEFS="${M4_DEFS}-DSSH_HAS_EXIT_ON_FORWARD_FAILURE "
fi

# Make sure BASE is set and that it isn't the DEST
if [ -z $BASE ]; then
	BASE=$(dirname $0)
	cd $BASE
	BASE=$PWD
	cd $OLDPWD
fi
cd $BASE
if [ "$PWD" == "$DEST" ]; then
	echo "Cannot install into the base directory"
	exit 1
else
	cd "$DEST"
fi

# Clean up any old and directories
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
FILES=$(find . -type f)
cd $DEST
for F in $FILES; do
	mkdir -p $BASE/staging/$(dirname $F)
	m4 $M4_DEFS $BASE/src/$F > $BASE/staging/$F
done

# Link everything up
cd $BASE/staging
DIRS=$(find . -maxdepth 1 -mindepth 1 -type d)
FILES=$(find . -maxdepth 1 -mindepth 1 -type f)
for D in $DIRS; do
	FILES="$FILES $(find $D -maxdepth 1 -mindepth 1)"
done
cd $DEST
for D in $DIRS; do
	mkdir $D
done
for F in $FILES; do
	ln -s $BASE/staging/$F $F
done

# Save record of links and directories for future upgrades
echo "$FILES" > $BASE/links.txt
echo "$DIRS" > $BASE/dirs.txt
