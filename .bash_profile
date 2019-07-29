#!/usr/bin/env bash

export LC_ALL=en_US.UTF-8
GPG_TTY=$(tty)
export GPG_TTY

# Python
PATH=/usr/local/opt/python/libexec/bin:$PATH

# anyenv
export ANYENV_ROOT="/Users/$USER/.anyenv"
export PATH=$PATH:"/Users/$USER/.anyenv/bin"
eval "$(anyenv init -)"

# php
export PATH="$(brew --prefix php@7.1)/bin:$PATH"

# bash-completion
[ -f /usr/local/etc/bash_completion ] && . /usr/local/etc/bash_completion

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
  alias diff='colordiff -u'
else
  alias diff='diff -u'
fi
