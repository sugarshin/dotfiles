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

# bun completions
[ -s "/Users/shingosato/.bun/_bun" ] && source "/Users/shingosato/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# bum
export BUM_INSTALL="$HOME/.bum"
export PATH="$BUM_INSTALL/bin:$PATH"

# pyenv
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init - zsh)"

# fnm
eval "$(fnm env --use-on-cd --shell zsh)"
