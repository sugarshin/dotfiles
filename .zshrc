[ -f ~/.commonrc ] && source ~/.commonrc

autoload -zU compinit && compinit
autoload -U add-zsh-hook

export LANG=en_US.UTF-8
export LANG='en_US.UTF-8'

### nodenv
eval "$(nodenv init -)"

### colordiff
if [[ -x `which colordiff` ]]; then
  alias diff='colordiff'
else
  alias diff='diff'
fi

alias nodenvu='nodenv update-version-defs'
