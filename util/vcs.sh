__hg_ps1() {
	if [ -f .hg/branch ]; then
		printf "$1" $(<.hg/branch tr -d [:blank:])
	fi
}

__vcs_ps1() {
	# Display the VCS branch name if in a directory
	# Try git first
	local branch=""
	if type __git_ps1 &>/dev/null; then
		# Show '<', '>', or '=' if we're behind, ahead, or equal to the upstream
		GIT_PS1_SHOWUPSTREAM=auto
		# Indicate if there are dirty files
		GIT_PS1_SHOWDIRTYSTATE=y
		branch="$(__git_ps1 "${1}")"
	fi
	if [ -z "${branch}" ]; then
		# Try Mercurial
		branch="$(__hg_ps1 " (%s)")"
	fi
	printf "$branch"
}

# Flag controlling whether or not to show the VCS branch. Default to on, but can
# be disabled because ~Windows~
declare -gi SHOW_VCS_BRANCH=1

show_vcs_env() {
	if ! _prog_exists kubectl; then
		echo "Missing kubectl"
		return 1
	else
		SHOW_VCS_BRANCH=1
	fi
}

hide_vcs_env() {
	SHOW_VCS_BRANCH=0
}

toggle_vcs_env() {
	if [ ${SHOW_VCS_BRANCH} = 0 ]; then
		show_vcs_env
	else
		hide_vcs_env
	fi
}