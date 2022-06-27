#!/usr/bin/env bash

export LC_ALL=en_US.UTF-8

# Python
PATH=/usr/local/opt/python/libexec/bin:$PATH

# bash-completion
[[ $PS1 && -f /usr/share/bash-completion/bash_completion ]] && \
    . /usr/share/bash-completion/bash_completion

# gpg-agent
export PATH="/usr/local/opt/gpg-agent/bin:$PATH"
export GPG_TTY=$(tty)

# goenv
export GOENV_ROOT="$HOME/.goenv"
export PATH="$GOENV_ROOT/bin:$PATH"
eval "$(goenv init -)"
export PATH="$GOROOT/bin:$PATH"
export PATH="$GOPATH/bin:$PATH"

export HISTTIMEFORMAT='%Y-%m-%dT%T%z '

# rbenv
eval "$(rbenv init -)"

# nodenv
export PATH="$HOME/.nodenv/bin:$PATH"
eval "$(nodenv init -)"

# colordiff
if [[ -x `which colordiff` ]]; then
  alias diff='colordiff'
else
  alias diff='diff'
fi

. "$HOME/.cargo/env"
