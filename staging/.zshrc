
fpath=(~/.zsh/util ~/.zsh/themes $fpath)

autoload -U promptinit
promptinit
prompt paxswill-dark
autoload -z paxswill-set-aliases
paxswill-set-aliases