
fpath=(~/.zsh/util ~/.zsh/local ~/.zsh/themes $fpath)

autoload -U promptinit
promptinit
# Most of my terminals default to dark
if [[ ${COLOR_SCHEME:-dark} = dark ]]; then
	prompt paxswill-dark
else
	prompt paxswill-light
fi

source "${HOME}/.dotfiles/common.zsh"

### Completion Config ###
compinit
# Mixed size columns
setopt LIST_PACKED
# Don't beep on ambiguous completions
unsetopt LIST_BEEP


### History Config ###
HISTFILE=${HOME}/.zsh_history
# Keeping HISTSIZE larger than SAVEHIST gives a cushion for saving dupes
SAVEHIST=10000
HISTSIZE=$(( $SAVEHIST + 200 ))
# Have all shells append to the history
setopt APPEND_HIST
# Incrementally append to the history instead of waiting for the shell to exit
# The command still needs to return so that the elapsed time is recorded
setopt INC_APPEND_HISTORY_TIME
# Collapse dupes
setopt HIST_EXPIRE_DUPS_FIRST
# The platforms I'm using are recent enough to have working fnctl
setopt HIST_FNCTL_LOCK
# Skip repeated commands
setopt HIST_IGNORE_DUPS
# Ignore commands prefixed with a space
setopt HIST_IGNORE_SPACE
# Clean up the history
setopt HIST_REDUCE_BLANKS


### Other general config ###
autoload -z paxswill-set-aliases paxswill-set-os-config
paxswill-set-aliases
paxswill-set-os-config
