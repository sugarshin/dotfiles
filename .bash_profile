#!/usr/bin/env bash

# Path to the bash it configuration
export BASH_IT="/Users/$USER/.bash_it"

# Lock and Load a custom theme file
# location /.bash_it/themes/
export BASH_IT_THEME='minimal'

# Don't check mail when opening terminal.
unset MAILCHECK

# Set this to false to turn off version control status checking within the prompt for all themes
export SCM_CHECK=true

# Set Xterm/screen/Tmux title with only a short hostname.
# Uncomment this (or set SHORT_HOSTNAME to something else),
# Will otherwise fall back on $HOSTNAME.
export SHORT_HOSTNAME=$(hostname -s)

# (Advanced): Uncomment this to make Bash-it reload itself automatically
# after enabling or disabling aliases, plugins, and completions.
export BASH_IT_AUTOMATIC_RELOAD_AFTER_CONFIG_CHANGE=1

# Load Bash It
source "$BASH_IT"/bash_it.sh

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

# Go
export GOPATH=$HOME/dev
export PATH=$PATH:$GOPATH/bin

# goenv
export GOENV_ROOT="$HOME/.goenv"
export PATH="$GOENV_ROOT/bin:$PATH"
eval "$(goenv init -)"
export PATH="$GOROOT/bin:$PATH"
export PATH="$GOPATH/bin:$PATH"

# brew file
export HOMEBREW_BREWFILE=$GOPATH/src/github.com/sugarshin/dotfiles/.brewfile/Brewfile

export HISTTIMEFORMAT='%Y-%m-%dT%T%z '

# rbenv
eval "$(rbenv init -)"
