
fpath=(~/.zsh/util ~/.zsh/themes $fpath)

autoload -U promptinit
promptinit
# Most of my terminals default to dark
if [[ ${COLOR_SCHEME:-dark} = dark ]]; then
	prompt paxswill-dark
else
	prompt paxswill-light
fi

autoload -z paxswill-set-aliases
paxswill-set-aliases