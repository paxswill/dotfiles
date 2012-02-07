#!/bin/bash

# Get the dotfiles directory if needed
if ! [ -d ~/.dotfiles ]; then
	git clone paxswill_git@git.paxswill.com:~/repos/dotfiles.git .dotfiles
	BASE="$HOME/.dotfiles"
fi

# Set up macro definitions
if ! [ -z $1 ] && [ "$1" == "NRL" ]; then
	M4_DEFS="${M4_DEFS}-DNRL "
fi
if ! echo "$(ssh -o ControlMaster=auto 2>&1)" | grep 'command-line: line 0:'; then
	M4_DEFS="${M4_DEFS}-DSSH_HAS_CONTROL_MASTER "
	if ! echo "$(ssh -o ControlPersist=15m 2>&1)" | grep 'command-line: line 0:'; then
		M4_DEFS="${M4_DEFS}-DSSH_HAS_CONTROL_PERSIST "
	fi
fi
if ! echo "$(ssh -o ExitOnForwardfailure=yes 2>&1)" | grep 'command-line: line 0:'; then
	M4_DEFS="${M4_DEFS}-DSSH_HAS_EXIT_ON_FORWARD_FAILURE "
fi

if [-z $BASE ]; then
	BASE=$(dirname $0)
fi
# Clean up any old links
if [ -f $BASE/links.txt ]; then
	FILES=$(cat $BASE/links.txt)
	for F in $FILES; do
		if [ -h $F ]; then
			unlink $F
		fi
	done
fi

# Process files with M4
cd $BASE/src
FILES=$(find . -type f)
cd -
for F in $FILES; do
	mkdir -p $BASE/staging/$(dirname $F)
	m4 $M4_DEFS $BASE/src/$F > $BASE/staging/$F
done

# Link everything up
cd $BASE/staging
FILES=$(find . -maxdepth 1)
cd -
for F in $FILES; do
	ln -s $BASE/staging/$F $F
done

# Save record of links for future upgrades
echo $FILES > $BASE/links.txt
