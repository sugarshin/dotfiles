# Created by newuser for 5.7.1

### Added by Zplugin's installer
source '/Users/sugarshin/.zplugin/bin/zplugin.zsh'
autoload -Uz _zplugin
(( ${+_comps} )) && _comps[zplugin]=_zplugin
### End of Zplugin's installer chunk

zplugin light zsh-users/zsh-autosuggestions
zplugin light zdharma/fast-syntax-highlighting
zplugin ice pick"async.zsh" src"pure.zsh"; zplugin light sindresorhus/pure

autoload -U compinit
compinit

### nodenv
eval "$(nodenv init -)"

### rbenv
eval "$(rbenv init -)"

### goenv
export GOENV_ROOT="$HOME/.goenv"
export PATH="$GOENV_ROOT/bin:$PATH"
#export GOENV_DISABLE_GOPATH=1 #tmp
eval "$(goenv init -)"
export PATH="$GOROOT/bin:$PATH"
#export GOPATH="${HOME}/dev" #tmp
export PATH="$GOPATH/bin:$PATH"

### pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init -)"
fi

### anyenv
export ANYENV_ROOT="/Users/$USER/.anyenv"
export PATH=$PATH:"/Users/$USER/.anyenv/bin"
eval "$(anyenv init -)"

### colordiff
if [[ -x `which colordiff` ]]; then
  alias diff='colordiff -u'
else
  alias diff='diff -u'
fi

### aliases
alias k='kubectl'
alias air='~/.air'
