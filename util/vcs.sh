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
