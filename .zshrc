[ -f ~/.commonrc ] && source ~/.commonrc

autoload -zU compinit && compinit
autoload -U add-zsh-hook
autoload -U promptinit; promptinit
prompt pure

export LANG=en_US.UTF-8
export LANG='en_US.UTF-8'

### colordiff
if [[ -x `which colordiff` ]]; then
  alias diff='colordiff'
else
  alias diff='diff'
fi

eval "$(nodenv init - zsh)"
