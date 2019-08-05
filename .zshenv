export DOTFILES=${HOME}/dotfiles
export PATH=${PATH}:${HOME}/bin:${DOTFILES}/bin

export HISTTIMEFORMAT='%Y-%m-%dT%T%z '

export LC_ALL=en_US.UTF-8
GPG_TTY=$(tty)
export GPG_TTY

### goenv
export GOENV_ROOT="$HOME/.goenv"
export PATH="$GOENV_ROOT/bin:$PATH"
eval "$(goenv init -)"
export PATH="$GOROOT/bin:$PATH"
export PATH="$GOPATH/bin:$PATH"

### pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init -)"
fi
