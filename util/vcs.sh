__hg_ps1() {
	if [ -d .hg ]; then
		printf "$1" $(<.hg/branch tr -d [:blank:])
	fi
}

__vcs_ps1() {
	# Display the VCS branch name if in a directory
	# Try git first
	GIT_PS1_SHOWUPSTREAM=auto
	local branch=""
	if type __git_ps1 &>/dev/null; then
		branch="$(__git_ps1 "${1}")"
	fi
	if [ -z "${branch}" ]; then
		# Try Mercurial
		branch="$(__hg_ps1 " (%s)")"
	fi
	printf "$branch"
}
